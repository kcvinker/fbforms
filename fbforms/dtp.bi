'// Created on 04-May-2025 19:13

dim shared dtpClsName(18) as ushort = {&h53, &h79, &h73, &h44, &h61, &h74, &h65, &h54, &h69, &h6D, &h65, &h50, &h69, &h63, &h6B, &h33, &h32, 0}

dim DTM_SETMCSTYLE as const DWORD = DTM_FIRST + 11
dim DTM_GETMCSTYLE as const DWORD = DTM_FIRST + 12
dim DTM_GETIDEALSIZE as const DWORD = DTM_FIRST + 15

constructor DateTimePicker(byref parent as Form, __xywh(0, 0))
    __setControlMembers(ControlType.DateTimePicker, dtpClsName(0))
    this._name = "DateTimePicker_" & DateTimePicker._stDTPCount 
    this._style = WS_CHILD or WS_VISIBLE or WS_TABSTOP
    this._exStyle = 0
    this._font = new FontInfo(parent.font) 
    this._fontable = true
    this._autoSize = true
    this._format = DTPFormat.custom
    this._fmtString = "dd-MM-yyyy"  
    this._bColor = WHITE_RGB
    this._fColor = BLACK_RGB
    if not appinfo._isDateInit then
        appinfo._isDateInit = true
        appinfo._iccEx.dwICC = ICC_DATE_CLASSES
        InitCommonControlsEx(@appinfo._iccEx)
    end if
    parent._appendChild(@this)
    DateTimePicker._stDTPCount += 1
    if parent.createChilds then this.createHandle()
end constructor

constructor DateTimePicker(byref parent as Form, p as POINT, __wh(0, 0))
    constructor(parent, p.x, p.y, w, h)
end constructor

constructor DateTimePicker(byref parent as Form)
    constructor(parent, 10, 10, 120, 30)
end constructor 

sub DateTimePicker.createHandle()
    this._setDTPStyles()
    this._createHwnd() 
    this._setSubClass(@DateTimePicker._wndProc) 
    this._setDTPSize()
end sub 

property DateTimePicker.value(dvalue as DateTime)
    this._value = dvalue
    var stime = makeSYSTEMTIME(this._value)
    if this._isCreated then __sendMsg0(DTM_SETSYSTEMTIME, 0, @stime)
end property

property DateTimePicker.value() as DateTime
    return this._value
end property

property DateTimePicker.formatString(svalue as string)
    this._fmtString = svalue
    this._format = DTPFormat.custom
    if this._isCreated then
        var ws = WideString(this._fmtString)
        __sendMsg0(DTM_SETFORMATA, 0, ws.constPtr)
    end if
end property

property DateTimePicker.formatString() byref as string
    return this._fmtString
end property

property DateTimePicker.rightAlign(bvalue as boolean)
    this._rightAlign = bvalue
end property

property DateTimePicker.rightAlign() as boolean
    return this._rightAlign
end property

property DateTimePicker.format(bvalue as DTPFormat)
    this._format = bvalue
end property

property DateTimePicker.format() as DTPFormat
    return this._format
end property

property DateTimePicker.showWeekNumber(bvalue as boolean)
    this._showWeekNum = bvalue
end property

property DateTimePicker.showWeekNumber() as boolean
    return this._showWeekNum
end property

property DateTimePicker.noTodayCircle(bvalue as boolean)
    this._noTodayCircle = bvalue
end property

property DateTimePicker.noTodayCircle() as boolean
    return this._noTodayCircle
end property

property DateTimePicker.noToday(bvalue as boolean)
    this._noToday = bvalue
end property

property DateTimePicker.noToday() as boolean
    return this._noToday
end property

property DateTimePicker.noTrailDates(bvalue as boolean)
    this._noTrailDates = bvalue
end property

property DateTimePicker.noTrailDates() as boolean
    return this._noTrailDates
end property

property DateTimePicker.showUpdown(bvalue as boolean)
    this._showUpdown = bvalue
end property

property DateTimePicker.showUpdown() as boolean
    return this._showUpdown
end property

property DateTimePicker.shortDateNames(bvalue as boolean)
    this._shortDateNames = bvalue
end property

property DateTimePicker.shortDateNames() as boolean
    return this._shortDateNames
end property

property DateTimePicker.fourDigitYear(bvalue as boolean)
    this._4DYear = bvalue
end property

property DateTimePicker.fourDigitYear() as boolean
    return this._4DYear
end property 


function DateTimePicker._wmNotifyHandler(lp as LPARAM) as LRESULT
    var nm = cptr(NMHDR ptr, lp)
    select case nm->code
    case DTN_USERSTRINGW
        if this.onTextChanged then
            var dts = cast(NMDATETIMESTRINGW ptr, lp)
            var dtea = DateTimeEventArgs(dts->pszUserString)
            this.onTextChanged(@this, dtea)
            if dtea.handled then __sendMsg0(DTM_SETSYSTEMTIME, 0, dtea._dateStruct)
        end if

    case DTN_DROPDOWN
        if this.onCalendarOpened then this.onCalendarOpened(@this, gea)

    case DTN_DATETIMECHANGE
        if this._dropDownCount = 0 then
            this._dropDownCount = 1
            var nmd = cast(NMDATETIMECHANGE ptr, lp)
            this._value._init(nmd->st)
            if this.onValueChanged then this.onValueChanged(@this, gea)

        elseif this._dropDownCount = 1 then
            this._dropDownCount = 0
            return 0
        end if

    case DTN_CLOSEUP
        if this.onCalendarClosed then this.onCalendarClosed(@this, gea)
    end select
    return 0
end function

sub DateTimePicker._setDTPStyles() 
    select case this._format
    case DTPFormat.custom
        this._style = this._style or DTS_LONGDATEFORMAT or DTS_APPCANPARSE
    case  DTPFormat.longDate
        this._style = this._style or DTS_LONGDATEFORMAT
    case  DTPFormat.shortDate
        if this._4DYear then
            this._style = this._style or DTS_SHORTDATECENTURYFORMAT
        else
            this._style = this._style or DTS_SHORTDATEFORMAT
        end if
    case  DTPFormat.timeOnly
        this._style = this._style or DTS_TIMEFORMAT
    end select

    if this._showWeekNum then this._calStyle = this._calStyle or  MCS_WEEKNUMBERS
    if this._noTodayCircle then this._calStyle = this._calStyle or  MCS_NOTODAYCIRCLE
    if this._noToday then this._calStyle = this._calStyle or  MCS_NOTODAY
    if this._noTrailDates then this._calStyle = this._calStyle or  MCS_NOTRAILINGDATES
    if this._shortDateNames then this._calStyle = this._calStyle or  MCS_SHORTDAYSOFWEEK
    if this._rightAlign then this._style = this._style or  DTS_RIGHTALIGN
    if this._showUpdown then this._style = this._style or  DTS_UPDOWN
end sub

sub DateTimePicker._setDTPSize() 
    '// Although we are using 'W' based unicode functions & messages,
    '// here we must use ANSI message. DTM_SETFORMATW won't work here for unknown reason.
    if this._format = DTPFormat.custom then __sendMsg0(DTM_SETFORMATA, 0, strptr(this._fmtString))
    if this._calStyle > 0 then __sendMsg0(DTM_SETMCSTYLE, 0, this._calStyle)
    if this._autoSize then '# We don't need this user set the size
        dim ss as SIZE
        __sendMsg0(DTM_GETIDEALSIZE, 0, @ss)
        this._width = ss.cx + 2
        this._height = ss.cy + 5
        ' SetWindowPos(this._handle, 0, this._xpos, this._ypos, this._width, this._height, SWP_NOZORDER)
        __setCtlPos(SWP_NOZORDER)
    end if
end sub



destructor DateTimePicker()
     
    ' print "DateTimePicker destructed"
end destructor  

static function DateTimePicker._wndProc(hwnd As HWND, umsg As UINT, wpm As WPARAM, lpm As LPARAM, uidsub As UINT_PTR, dwref As DWORD_PTR ) As LRESULT
    ' print "btn message "; umsg
    select case umsg
    case WM_DESTROY
        var x = RemoveWindowSubclass(hwnd, @DateTimePicker._wndProc, uidsub)
        ' print "rem dtp subclass "
    ' case WM_PAINT: 
    '     var btn  = Cast(DateTimePicker Ptr, dwref)
        
    case WM_SETFOCUS
        var self  = cptr(DateTimePicker Ptr, dwref)
        __generalEventHandler(onGotFocus)

    case WM_KILLFOCUS
        var self  = cptr(DateTimePicker Ptr, dwref)
        __generalEventHandler(onLostFocus)

    case WM_LBUTTONDOWN 
        var self  = cptr(DateTimePicker Ptr, dwref)
        __mouseEventHandler(onLeftMouseDown)

    case WM_LBUTTONUP 
        var self  = cptr(DateTimePicker Ptr, dwref)
        __mouseEventHandler(onLeftMouseUp)
        if self->onClick then self->onClick(self, gea)
        
    case WM_RBUTTONDOWN 
        var self  = cptr(DateTimePicker Ptr, dwref)
        __mouseEventHandler(onRightMouseDown)
        
    case WM_RBUTTONUP 
        var self  = cptr(DateTimePicker Ptr, dwref)
        __mouseEventHandler(onRightMouseUp)
        if self->onRightClick then self->onRightClick(self, gea)
        
    case WM_MOUSEWHEEL 
        var self  = cptr(DateTimePicker Ptr, dwref)
        __mouseEventHandler(onMouseWheel)

    case WM_MOUSEMOVE 
        __mouseMoveHandler(DateTimePicker)
        
    case WM_MOUSELEAVE 
        var self  = cptr(DateTimePicker Ptr, dwref)
        self->_isMouseEntered = false
        __generalEventHandler(onMouseLeave)
        
    case CM_NOTIFY 
        var self  = cptr(DateTimePicker Ptr, dwref)
        return self->_wmNotifyHandler(lpm)

    end select

    Return DefSubclassProc(hwnd, umsg, wpm, lpm)
end function