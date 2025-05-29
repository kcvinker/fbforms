'// Created on 30-Mar-2025 11:51
dim shared btnClass(7)  as ushort => {66, 117, 116, 116, 111, 110, 0}
dim shared TXTFLAG as const uinteger  = DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_NOPREFIX
'Declare function btnWndProc(hwnd As HWND, message As UINT, wParam As WPARAM, lParam As LPARAM, uIdSubclass As UINT_PTR, dwRefData As DWORD_PTR ) As LRESULT

constructor Button(byref parent as Form, byref sText as string, __xywh(120, 30))
    
    __setControlMembers(ControlType.Button, btnClass(0))  
    this._name = "Button_" & Button._stBtnCount  
    this._font = new FontInfo(parent.font)
    this._text = sText      
    this._style = WS_CHILD or BS_NOTIFY or WS_TABSTOP or WS_VISIBLE or BS_PUSHBUTTON
    this._textable = true
    this._fontable = true
    this._wideText = new WideString(sText) 
        
    parent._appendChild(@this)
    Button._stBtnCount += 1
    if parent.createChilds then this.createHandle()
end constructor

constructor Button(byref parent as Form, byref sText as string, p as POINT, __wh(120, 30))
    constructor(parent, sText, p.x, p.y, w, h)
end constructor


constructor Button(byref parent as Form, byref sText as string)
    constructor(parent, sText, 10, 10, 120, 30)
end constructor 
 
sub Button.createHandle()
    ' print "button's impl"
    this._createHwnd() 
    this._setSubClass(@Button._wndProc) 
end sub  

sub Button.setGradientColor(c1 as uinteger, c2 as uinteger)    
    if (this._drawMode and 4) <> 4 then this._drawMode += 4

    '// 3 Chances are here.
    '// 1. A fresh button. So no need to reset anything.
    '// 2. Already a flat colored button. Then we need to reset old resources.
    '// 3. Already a gradient colored button. Then we need to free the resources.
    if this._gdraw.isUsed then this._gdraw.reset()
    if this._fdraw.isUsed then this._fdraw.reset()
    this._gdraw._setData(c1, c2)
    this._checkRedraw()
end sub



'// Overriding Control's backColor prop
property Button.backColor(value as uinteger)
    this._bColor.updateColor(value)
    if (this._drawMode and 2) <> 2 then this._drawMode += 2

    '// 3 Chances are here.
    '// 1. A fresh button. So no need to reset anything.
    '// 2. Already a flat colored button. Then we need to reset old resources.
    '// 3. Already a gradient colored button. Then we need to free the resources.
    if this._gdraw.isUsed then this._gdraw.reset()
    if this._fdraw.isUsed then this._fdraw.reset()
    this._fdraw._setData(this._bColor)
    this._checkRedraw()
end property

'// Overriding Control's width prop
property Button.width(value as integer)
    this._width = value
    if this._isCreated and this._drawMode <> 0 then 
        if this._gdraw.isUsed then this._gdraw.reset()
        if this._fdraw.isUsed then this._fdraw.reset()
    end if
    
end property

'// Overriding Control's height prop
property Button.height(value as integer)
    this._height = value
    if this._isCreated and this._drawMode <> 0 then 
        if this._gdraw.isUsed then this._gdraw.reset()
        if this._fdraw.isUsed then this._fdraw.reset()
    end if
end Property

'// Overriding Control's foreColor prop
property Button.foreColor(value as uinteger)
    this._fColor.updateColor(value)
    if (this._drawMode and 1) <> 1 then this._drawMode += 1
    this._checkRedraw()
end property

function Button._wmNotifyHandler(lpm as LPARAM) as LRESULT
    dim ret as LRESULT = CDRF_DODEFAULT
    if this._drawMode then
        dim nmcd as NMCUSTOMDRAW ptr = cptr(NMCUSTOMDRAW ptr, lpm)
        select case this._drawMode
        case 1 
            ret = this._drawTextColor(nmcd)' // ForeColor only
        case 2 
            ret = this._drawBackColor(nmcd)' // BackColor only
        case 3
            this._drawBackColor(nmcd)
            ret = this._drawTextColor(nmcd)
        case 4 
            ret = this._drawGradientBackColor(nmcd)
        case 5
            this._drawGradientBackColor(nmcd)
            ret = this._drawTextColor(nmcd)
        end select
    end if
    return ret
end function

function Button._drawTextColor(ncd as NMCUSTOMDRAW ptr) as LRESULT
    SetBkMode(ncd->hdc, TRANSPARENT)
    SetTextColor(ncd->hdc, this._fColor._cref)
    SelectObject(ncd->hdc, cptr(HGDIOBJ, this._font->fontHandle))
    DrawText(ncd->hdc, this._wideText->constPtr, -1, @ncd->rc, TXTFLAG)
    return CDRF_NOTIFYPOSTPAINT
end function

function Button._drawBackColor(nmcd as NMCUSTOMDRAW ptr) as LRESULT
    select case nmcd->dwDrawStage 
    case CDDS_PREERASE	'// Note: This return value is critical. Otherwise we don't get below notifications.
        return  CDRF_NOTIFYPOSTERASE
    case CDDS_PREPAINT
        if (nmcd->uItemState and &b1) = &b1 then '// Button clicked
            this._paintFlatColor(nmcd, this._fdraw.defBrush, this._fdraw.hotPen)

        elseif (nmcd->uItemState and &b1000000) = &b1000000 then '// Button focused
            this._paintFlatColor(nmcd, this._fdraw.hotBrush, this._fdraw.hotPen)
        else
            this._paintFlatColor(nmcd, this._fdraw.defBrush, this._fdraw.defPen)
        end if
    end select
    return CDRF_DODEFAULT
end function

sub ButtonGradDraw._createGradientBrush(nmcd as NMCUSTOMDRAW ptr, dMode as GdrawMode)
    dim as GradColor gc
    select case dMode
    case GdrawMode.default
        gc = this.defClr
    case GdrawMode.focused
        gc = this.hotClr
    case GdrawMode.clicked
        gc = this.defClr
    end select

    var rct = nmcd->rc
    dim memHDC as HDC = CreateCompatibleDC(nmcd->hdc)
    dim hBmp as HBITMAP = CreateCompatibleBitmap(nmcd->hdc, rct.right, rct.bottom)
    dim loopEnd as integer = iif(this.rtl, rct.right, rct.bottom)
    SelectObject(memHDC, hBmp)

    for i as integer = 0 to loopEnd 
        dim tRct as RECT
        dim as uinteger r, g, b
        r = gc.c1._red + (i * (gc.c2._red - gc.c1._red) / loopEnd)
        g = gc.c1._green + (i * (gc.c2._green - gc.c1._green) / loopEnd)
        b = gc.c1._blue + (i * (gc.c2._blue - gc.c1._blue) / loopEnd)

        dim tBrush as HBRUSH = CreateSolidBrush(__clrRef(r, g, b))
        tRct.left = iif(this.rtl, i, 0)
        tRct.top =  iif(this.rtl, 0, i )
        tRct.right = iif(this.rtl, i + 1, rct.right)
        tRct.bottom = iif(this.rtl, loopEnd, i + 1)
        FillRect(memHDC, @tRct, tBrush)
		DeleteObject(tBrush)
    next
    if dMode = GdrawMode.default or dMode = GdrawMode.clicked then 
        this.defBrush = CreatePatternBrush(hBmp)
    else
        this.hotBrush = CreatePatternBrush(hBmp)
    end if
	DeleteObject(hBmp)
    DeleteDC(memHDC) 
end sub

function Button._drawGradientBackColor(nmcd as NMCUSTOMDRAW ptr) as LRESULT
    select case nmcd->dwDrawStage
    case CDDS_PREERASE'	// Note: This return value is critical. Otherwise we don't get below notifications.
        return  CDRF_NOTIFYPOSTERASE
    case CDDS_PREPAINT
        
        '// In any of these case, we only create a brush if it's null.
        '// So at first, we create two brushes, but later, we don't
        '// need that until user changes the color and/or size.
        if (nmcd->uItemState and &b1) = &b1 then
            if this._gdraw.defBrush = 0 then this._gdraw._createGradientBrush(nmcd, GdrawMode.clicked)
            this._paintGradientRound(nmcd->hdc, nmcd->rc, this._gdraw.defBrush, this._gdraw.hotPen)
        elseif (nmcd->uItemState and &b1000000) = &b1000000 then
            if this._gdraw.hotBrush = 0 then this._gdraw._createGradientBrush(nmcd, GdrawMode.focused)
            this._paintGradientRound(nmcd->hdc, nmcd->rc, this._gdraw.hotBrush, this._gdraw.hotPen)
        else
            if this._gdraw.defBrush = 0 then this._gdraw._createGradientBrush(nmcd, GdrawMode.default)
            this._paintGradientRound(nmcd->hdc, nmcd->rc, this._gdraw.defBrush, this._gdraw.defPen)
        end if
    end select
    return CDRF_DODEFAULT
end function

sub Button._paintFlatColor(nmcd as NMCUSTOMDRAW ptr, hbr as HBRUSH, pen as HPEN)
    SelectObject(nmcd->hdc, cptr(HGDIOBJ, hbr))
    SelectObject(nmcd->hdc, cptr(HGDIOBJ, pen))
    RoundRect(nmcd->hdc, nmcd->rc.left, nmcd->rc.top, nmcd->rc.right, nmcd->rc.bottom, 5, 5)
    FillPath(nmcd->hdc)
end sub

sub Button._paintGradientRound(dc as HDC, rc as RECT, gBrush as HBRUSH, pen as HPEN)        
    SelectObject(dc, pen)
    SelectObject(dc, gBrush)
    RoundRect(dc, rc.left, rc.top, rc.right, rc.bottom, 5, 5)
    FillPath(dc)
end sub

sub ButtonFlatDraw._setData(byref clr as RgbColor) '// Set the gdi resources
    this.isUsed = true
	this.defBrush = CreateSolidBrush(clr._cref)
	this.hotBrush = CreateSolidBrush(clr.changeShadeCREF(0.0))
	this.defPen = CreatePen(PS_SOLID, 1, clr.changeShadeCREF(0.6))
	this.hotPen = CreatePen(PS_SOLID, 1, clr.changeShadeCREF(0.3))
end sub

sub ButtonGradDraw._setData(c1 as uinteger, c2 as uinteger)
    this.isUsed = true
    this.defClr.c1.updateColor(c1)
	this.defClr.c2.updateColor(c2)
	this.hotClr.c1.copyAndChangeShade(c1)
	this.hotClr.c2.copyAndChangeShade(c2)	   
	this.defPen = CreatePen(PS_SOLID, 1, this.defClr.c1.changeShadeCREF(0.6))
	this.hotPen = CreatePen(PS_SOLID, 1, this.hotClr.c1.changeShadeCREF(0.3))
end sub

sub ButtonDrawBase.reset()
    DeleteObject(this.defBrush)
    DeleteObject(this.hotBrush)
    DeleteObject(this.defPen)
    DeleteObject(this.hotPen)
    this.defBrush = 0
    this.hotBrush = 0
    this.defPen = 0
    this.hotPen = 0
end sub

destructor ButtonDrawBase() '// We need to delete the gdi resources.
    if this.isUsed then 
        this.reset()
        this.isUsed = false
        ' print "Button draw resources freed"
    end if
end destructor


destructor Button()
    
    ' print "Button destructed"
end destructor  

function Button._wndProc(hwnd As HWND, umsg As UINT, wpm As WPARAM, lpm As LPARAM, uidsub As UINT_PTR, dwref As DWORD_PTR ) As LRESULT
    ' print "btn message "; umsg
    select case umsg
    case WM_DESTROY
        var x = RemoveWindowSubclass(hwnd, @Button._wndProc, uidsub)
        ' print "rem btn subclass "
    ' case WM_PAINT: 
    '     var btn  = Cast(Button Ptr, dwref)
        
    case WM_SETFOCUS
        var self  = cptr(Button Ptr, dwref)
        __generalEventHandler(onGotFocus)

    case WM_KILLFOCUS
        var self  = cptr(Button Ptr, dwref)
        __generalEventHandler(onLostFocus)

    case WM_LBUTTONDOWN 
        var self  = cptr(Button Ptr, dwref)
        __mouseEventHandler(onLeftMouseDown)

    case WM_LBUTTONUP 
        var self  = cptr(Button Ptr, dwref)
        __mouseEventHandler(onLeftMouseUp)
        if self->onClick then self->onClick(self, gea)
        
    case WM_RBUTTONDOWN 
        var self  = cptr(Button Ptr, dwref)
        __mouseEventHandler(onRightMouseDown)
        
    case WM_RBUTTONUP 
        var self  = cptr(Button Ptr, dwref)
        __mouseEventHandler(onRightMouseUp)
        if self->onRightClick then self->onRightClick(self, gea)
        
    case WM_MOUSEWHEEL 
        var self  = cptr(Button Ptr, dwref)
        __mouseEventHandler(onMouseWheel)

    case WM_MOUSEMOVE 
        __mouseMoveHandler(Button)
        
    case WM_MOUSELEAVE 
        var self  = cptr(Button Ptr, dwref)
        self->_isMouseEntered = false
        __generalEventHandler(onMouseLeave)
        
    case CM_NOTIFY 
        var self  = cptr(Button Ptr, dwref)
        return self->_wmNotifyHandler(lpm)
    end select

    Return DefSubclassProc(hwnd, umsg, wpm, lpm)
end function