'// Created on 06-May-2025 00:05

dim shared lblClass(8) as ushort => {&h53, &h74, &h61, &h74, &h69, &h63, 0}

' dim shared MCS_NOTRAILINGDATES as const DWORD = &h40
' dim shared MCS_SHORTDAYSOFWEEK as const DWORD = &h80
' dim shared MCM_SETCURRENTVIEW as const DWORD = MCM_FIRST + 32

constructor Label(byref parent as Form, byref txt as string, __xywh(0, 0))
    __setControlMembers(ControlType.Label, lblClass(0)) 
    this._name = "Label_" & Label._stLBLCount          
    this._style = WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or SS_NOTIFY
    this._exStyle = 0   
    this._font = new FontInfo(parent.font)
    this._text = txt      
    this._textable = true
    this._fontable = true
    this._autoSize = true
    this._wideText = new WideString(txt)  
    this._bColor = parent.backColor
    this._fColor = BLACK_RGB
    parent._appendChild(@this)
    Label._stLBLCount += 1
    if parent.createChilds then this.createHandle()
end constructor

constructor Label(byref parent as Form, byref txt as string, p as POINT, __wh(0, 0) )
    constructor(parent, txt, p.x, p.y, w, h)
end constructor

constructor Label()
    
end constructor

destructor Label()
    ' print "Label wtext "; this._wideText->dataPtr
    ' delete this._wideText
    ' this._wideText = 0
end destructor

sub Label.createHandle()
    this._setLblStyle()
    this._createHwnd() 
    if this._handle then        
        this._setSubClass(@Label._wndProc) 
        if this._autoSize then this._setAutoSize(false)
    else
        print "Error: Can't create LBL handle "; GetLastError()
    end if
end sub 



' property Label.shortDateNames(bvalue as boolean)
'     this._shortDateNames = bvalue
' end property

' property Label.shortDateNames() as boolean
'     return this._shortDateNames
' end property


sub Label._setLblStyle()
    if this._border <> LabelBorder.lbNone then
        this._style = iif(this._border = LabelBorder.lbSunken, this._style or SS_SUNKEN, this._style or WS_BORDER)
    end if
    if this._multiLine orElse this._width > 0 orElse this._height > 0 then this._autoSize = false
    this._bkBrush = this._bColor.makeHBrush()
end sub



sub Label._setAutoSize(redraw as boolean)
    var ss = Graphics.getTextSize(@this)
    this._width = ss.cx + 3
    this._height = ss.cy
    __setCtlPos(SWP_NOMOVE)
    if redraw then InvalidateRect(this._handle, null, 1)
end sub




static function Label._wndProc(hwnd As HWND, umsg As UINT, wpm As WPARAM, lpm As LPARAM, uidsub As UINT_PTR, dwref As DWORD_PTR ) As LRESULT
    ' print "btn message "; umsg
    select case umsg
    case WM_DESTROY
        RemoveWindowSubclass(hwnd, @Label._wndProc, uidsub)
        ' print "rem calendar subclass "
    ' case WM_PAINT
    '     var btn  = cptr(Label Ptr, dwref)
        
    ' case WM_SETFOCUS
    '     var self  = cptr(Label Ptr, dwref)
    '     __generalEventHandler(onGotFocus)

    ' case WM_KILLFOCUS
    '     var self  = cptr(Label Ptr, dwref)
    '     __generalEventHandler(onLostFocus)

    case WM_LBUTTONDOWN
        var self  = cptr(Label Ptr, dwref)
        __mouseEventHandler(onLeftMouseDown)

    case WM_LBUTTONUP
        var self  = cptr(Label Ptr, dwref)
        __mouseEventHandler(onLeftMouseUp)
        if self->onClick then self->onClick(self, gea)
        
    case WM_RBUTTONDOWN
        var self  = cptr(Label Ptr, dwref)
        __mouseEventHandler(onRightMouseDown)
        
    case WM_RBUTTONUP
        var self  = cptr(Label Ptr, dwref)
        __mouseEventHandler(onRightMouseUp)
        if self->onRightClick then self->onRightClick(self, gea)
        
    case WM_MOUSEWHEEL
        var self  = cptr(Label Ptr, dwref)
        __mouseEventHandler(onMouseWheel)

    case WM_MOUSEMOVE
        __mouseMoveHandler(Label)
        
    case WM_MOUSELEAVE
        var self  = cptr(Label Ptr, dwref)
        self->_isMouseEntered = false
        __generalEventHandler(onMouseLeave)
        
    case CM_COLOR_STATIC
        var self  = cptr(Label Ptr, dwref)
        var hdc = cptr(HDC, wpm)
        if (self->_drawMode and 1) = 1 then SetTextColor(hdc, self->_fColor.cref)
        SetBkColor(hdc, self->_bColor.cref)
        return cast(LRESULT, self->_bkBrush)
    end select
    
    Return DefSubclassProc(hwnd, umsg, wpm, lpm)
end function