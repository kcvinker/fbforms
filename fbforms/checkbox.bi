'// Created on 01-May-2025 14:10

' Declare function cbxWndProc(hwnd As HWND, message As UINT, wParam As WPARAM, lParam As LPARAM, uIdSubclass As UINT_PTR, dwRefData As DWORD_PTR ) As LRESULT

constructor CheckBox(byref parent as Form, byref sText as string, __xywh(0, 0))
    __setControlMembers(ControlType.checkBox, btnClass(0)) 
    this._name = "CheckBox_" & CheckBox._stCBCount
    this._style = WS_CHILD or WS_VISIBLE or BS_AUTOCHECKBOX
    this._exStyle = WS_EX_LTRREADING or WS_EX_LEFT
    this._textStyle = DT_SINGLELINE or DT_VCENTER   
    this._font = new FontInfo(parent.font)
    this._text = sText      
    this._textable = true
    this._fontable = true
    this._wideText = new WideString(sText)  
    this._bColor = parent.backColor 
    parent._appendChild(@this)
    CheckBox._stCBCount += 1
    if parent.createChilds then this.createHandle()
end constructor

constructor CheckBox(byref parent as Form, byref sText as string, p as POINT, __wh(0, 0))
    constructor(parent, sText, p.x, p.y, w, h)
end constructor

constructor checkBox(byref parent as Form, byref sText as string)
    constructor(parent, sText, 10, 10, 120, 30)
end constructor 

sub CheckBox.createHandle()
    this._setCbStyles()
    this._createHwnd() 
    this._setSubClass(@CheckBox._wndProc) 
    this._setCbSize()
end sub 

property CheckBox.checked() as boolean
    return this._checked
end property

property CheckBox.checked(value as boolean)
    this._checked = value 
    if this._isCreated then __sendMsg0(BM_SETCHECK, value, 0)
end property


function CheckBox._wmNotifyHandler(lp as LPARAM) as LRESULT
    var nmc = cptr(NMCUSTOMDRAW ptr, lp)
    select case nmc->dwDrawStage
    case CDDS_PREERASE
    	return CDRF_NOTIFYPOSTERASE
    case CDDS_PREPAINT
        '// Adjusing rect. Otherwise, text will be drawn upon the check area
        if not this._rightAlign then nmc->rc.left += 18 else nmc->rc.right -= 18 end if
        if (this._drawMode and 1) = 1 then SetTextColor(nmc->hdc, this._fColor.cref)
        DrawText(nmc->hdc, this._wideText->constPtr, -1, @nmc->rc, this._textStyle)
        return CDRF_SKIPDEFAULT
    end select
    return CDRF_DODEFAULT
end function

sub CheckBox._setCbStyles() 
    '// We need to set some checkbox styles
    if this._rightAlign then
        this._style = this._style or BS_RIGHTBUTTON
        this._textStyle = this._textStyle or DT_RIGHT
    end if
    this._bkBrush = this._bColor.makeHBrush()
end sub

sub CheckBox._setCbSize() 
    '// We need to find the width & hight to provide the auto size feature.
    dim ss as SIZE
    __sendMsg0(BCM_GETIDEALSIZE, 0, @ss)
    this._width = ss.cx
    this._height = ss.cy
    MoveWindow(this._handle, this._xpos, this._ypos, ss.cx, ss.cy, true)
end sub



destructor CheckBox()
     
    ' print "CheckBox destructed"
end destructor  

static function CheckBox._wndProc(hwnd As HWND, umsg As UINT, wpm As WPARAM, lpm As LPARAM, uidsub As UINT_PTR, dwref As DWORD_PTR ) As LRESULT
    ' print "btn message "; umsg
    select case umsg
    case WM_DESTROY
        RemoveWindowSubclass(hwnd, @CheckBox._wndProc, uidsub)
        ' print "rem cbx subclass "
    ' case WM_PAINT: 
    '     var btn  = Cast(CheckBox Ptr, dwref)
        
    case WM_SETFOCUS
        var self  = cptr(CheckBox Ptr, dwref)
        __generalEventHandler(onGotFocus)

    case WM_KILLFOCUS
        var self  = cptr(CheckBox Ptr, dwref)
        __generalEventHandler(onLostFocus)

    case WM_LBUTTONDOWN 
        var self  = cptr(CheckBox Ptr, dwref)
        __mouseEventHandler(onLeftMouseDown)

    case WM_LBUTTONUP 
        var self  = cptr(CheckBox Ptr, dwref)
        __mouseEventHandler(onLeftMouseUp)
        if self->onClick then self->onClick(self, gea)
        
    case WM_RBUTTONDOWN 
        var self  = cptr(CheckBox Ptr, dwref)
        __mouseEventHandler(onRightMouseDown)
        
    case WM_RBUTTONUP 
        var self  = cptr(CheckBox Ptr, dwref)
        __mouseEventHandler(onRightMouseUp)
        if self->onRightClick then self->onRightClick(self, gea)
        
    case WM_MOUSEWHEEL 
        var self  = cptr(CheckBox Ptr, dwref)
        __mouseEventHandler(onMouseWheel)

    case WM_MOUSEMOVE 
        __mouseMoveHandler(CheckBox)
        
    case WM_MOUSELEAVE 
        var self  = cptr(CheckBox Ptr, dwref)
        self->_isMouseEntered = false
        __generalEventHandler(onMouseLeave)
        
    case CM_NOTIFY 
        var self  = cptr(CheckBox Ptr, dwref)
        return self->_wmNotifyHandler(lpm)

    case CM_CTLCOMMAND
        var self  = cptr(CheckBox Ptr, dwref)
		self->_checked = cbool(__sendmsg1(self->_handle, BM_GETCHECK, 0, 0))
		if self->onCheckedChanged then self->onCheckedChanged(self, gea)

    case CM_COLOR_STATIC         
        var self = cptr(CheckBox ptr, dwref)
        var hdc = cast(HDC, wpm)
        SetBkMode(hdc, TRANSPARENT)
        SetBkColor(hdc, self->_bColor.cref)
        return cast(LRESULT, self->_bkBrush)
    end select

    Return DefSubclassProc(hwnd, umsg, wpm, lpm)
end function