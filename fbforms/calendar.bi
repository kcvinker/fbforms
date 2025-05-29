'// Created on 30-Apr-2025 19:23

dim shared calClass(14) as ushort => {83, 121, 115, 77, 111, 110, 116, 104, 67, 97, 108, 51, 50, 0}
' Declare function calWndProc(hwnd As HWND, message As UINT, wParam As WPARAM, lParam As LPARAM, uIdSubclass As UINT_PTR, dwRefData As DWORD_PTR ) As LRESULT
dim shared MCS_NOTRAILINGDATES as const DWORD = &h40
dim shared MCS_SHORTDAYSOFWEEK as const DWORD = &h80
dim shared MCM_SETCURRENTVIEW as const DWORD = MCM_FIRST + 32

constructor Calendar(byref parent as Form, x as integer, y as integer)
    __setControlMembers(ControlType.Calendar, calClass(0))  
    this._name = "Calendar_" & Calendar._stCalCount         
    this._style = WS_CHILD or WS_TABSTOP or WS_VISIBLE      
    this._viewMode = CalendarViewMode.monthView
    parent._appendChild(@this)
    Calendar._stCalCount += 1
    if parent.createChilds then this.createHandle()
end constructor

constructor Calendar(byref parent as Form, p as POINT)
    constructor(parent, p.x, p.y)
end constructor

constructor Calendar()
end constructor

destructor Calendar()
end destructor

sub Calendar.createHandle()
    this._setCalStyle()
    this._createHwnd() 
    this._setSubClass(@Calendar._wndProc) 
    this._afterCreation()
end sub 

property Calendar.value(dvalue as DateTime)
    this._value = dvalue
    var stime = makeSYSTEMTIME(this._value)
    if this._isCreated then __sendMsg0(MCM_SETCURSEL, 0, @stime)
end property

property Calendar.value() as DateTime
    return this._value
end property

property Calendar.viewMode(svalue as CalendarViewMode)
    this._viewMode = svalue
    if this._isCreated then __sendMsg0(MCM_SETCURRENTVIEW, 0, cast(integer, this._viewMode))
end property

property Calendar.viewMode() as CalendarViewMode
    return this._viewMode
end property

property Calendar.oldViewMode() as CalendarViewMode
    return this._oldViewMode
end property

property Calendar.showWeekNumber(bvalue as boolean)
    this._showWeekNum = bvalue
end property

property Calendar.showWeekNumber() as boolean
    return this._showWeekNum
end property

property Calendar.noTodayCircle(bvalue as boolean)
    this._noTodayCircle = bvalue
end property

property Calendar.noTodayCircle() as boolean
    return this._noTodayCircle
end property

property Calendar.noToday(bvalue as boolean)
    this._noToday = bvalue
end property

property Calendar.noToday() as boolean
    return this._noToday
end property

property Calendar.noTrailDates(bvalue as boolean)
    this._noTrailDates = bvalue
end property

property Calendar.noTrailDates() as boolean
    return this._noTrailDates
end property

property Calendar.shortDateNames(bvalue as boolean)
    this._shortDateNames = bvalue
end property

property Calendar.shortDateNames() as boolean
    return this._shortDateNames
end property


sub Calendar._setCalStyle()
    if this._showWeekNum then this._style = this._style or MCS_WEEKNUMBERS
    if this._noTodayCircle then this._style = this._style or MCS_NOTODAYCIRCLE
    if this._noToday then this._style  = this._style or MCS_NOTODAY
    if this._noTrailDates then this._style = this._style or MCS_NOTRAILINGDATES
    if this._shortDateNames then this._style = this._style or MCS_SHORTDAYSOFWEEK
end sub



sub Calendar._afterCreation()
    dim rc as RECT
    __sendmsg0(MCM_GETMINREQRECT, 0, @rc)
    this._width = rc.right
    this._height = rc.bottom
    ' SetWindowPos(this._handle, 0, this._xpos, this._ypos, rc.right, rc.bottom, SWP_NOZORDER)
    __setCtlPos(SWP_NOZORDER)
    dim st as SYSTEMTIME
    __sendmsg0(MCM_GETCURSEL, 0, @st)
    this._value._init(st)
end sub

function Calendar._wmNotifyHandler(lpm as LPARAM) as LRESULT
    var nm = cptr(NMHDR ptr, lpm)
    select case nm->code
    case MCN_SELECT
        var nms = cptr(NMSELCHANGE ptr, lpm)
        this._value._init(nms->stSelStart)
        if this.onValueChanged then this.onValueChanged(@this, gea)

    case MCN_SELCHANGE
        var nms = cptr(NMSELCHANGE ptr, lpm)
        this._value._init(nms->stSelStart)
        if this.onSelectionCommitted then this.onSelectionCommitted(@this, gea)

    case MCN_VIEWCHANGE
        var nmv = cptr(NMVIEWCHANGE ptr, lpm)
        this._viewMode = cast(CalendarViewMode, nmv->dwNewView)
        this._oldViewMode = cast(CalendarViewMode, nmv->dwOldView)
        if this.onViewChanged then this.onViewChanged(@this, gea)
    end select
    return 0
end function


static function Calendar._wndProc(hwnd As HWND, umsg As UINT, wpm As WPARAM, lpm As LPARAM, uidsub As UINT_PTR, dwref As DWORD_PTR ) As LRESULT
    ' print "btn message "; umsg
    select case umsg
    case WM_DESTROY
        var x = RemoveWindowSubclass(hwnd, @Calendar._wndProc, uidsub)
        ' print "rem calendar subclass "
    ' case WM_PAINT: 
    '     var btn  = cptr(Calendar Ptr, dwref)
        
    case WM_SETFOCUS:
        var self  = cptr(Calendar Ptr, dwref)
        __generalEventHandler(onGotFocus)

    case WM_KILLFOCUS:
        var self  = cptr(Calendar Ptr, dwref)
        __generalEventHandler(onLostFocus)

    case WM_LBUTTONDOWN: 
        var self  = cptr(Calendar Ptr, dwref)
        __mouseEventHandler(onLeftMouseDown)

    case WM_LBUTTONUP: 
        var self  = cptr(Calendar Ptr, dwref)
        __mouseEventHandler(onLeftMouseUp)
        if self->onClick then self->onClick(self, gea)
        
    case WM_RBUTTONDOWN: 
        var self  = cptr(Calendar Ptr, dwref)
        __mouseEventHandler(onRightMouseDown)
        
    case WM_RBUTTONUP: 
        var self  = cptr(Calendar Ptr, dwref)
        __mouseEventHandler(onRightMouseUp)
        if self->onRightClick then self->onRightClick(self, gea)
        
    case WM_MOUSEWHEEL: 
        var self  = cptr(Calendar Ptr, dwref)
        __mouseEventHandler(onMouseWheel)

    case WM_MOUSEMOVE: 
        __mouseMoveHandler(Calendar)
        
    case WM_MOUSELEAVE: 
        var self  = cptr(Calendar Ptr, dwref)
        self->_isMouseEntered = false
        __generalEventHandler(onMouseLeave)
        
    case CM_NOTIFY: 
        var self  = cptr(Calendar Ptr, dwref)
        return self->_wmNotifyHandler(lpm)
    end select
    
    Return DefSubclassProc(hwnd, umsg, wpm, lpm)
end function