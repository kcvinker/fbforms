
'// Created on 05-May-2025 15:01
#inclib "UxTheme"
extern "Windows"
	declare function SetWindowTheme(hw as HWND, cl as LPCWSTR, p3 as LPCWSTR) as HRESULT
end extern
dim shared gbStyle as DWORD = WS_CHILD or WS_VISIBLE or BS_GROUPBOX or BS_NOTIFY or BS_TOP or WS_OVERLAPPED or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
dim shared ypoint as const integer = 8
dim shared penwidth as const integer = 5
dim ewsa(1) as ushort = {0}
dim shared emptyWStrPtr as const ushort ptr = @ewsa(0)

constructor GroupBox(byref parent as Form, byref txt as string, __xywh(150, 150), _ 
                                style as GroupBoxStyle = GroupBoxStyle.system)
    __setControlMembers(ControlType.GroupBox, btnClass(0)) 
    this._name = "GroupBox_" & GroupBox._stGBCount
    this._style = gbStyle
    this._exStyle = WS_EX_CONTROLPARENT
    this._text = txt
    this._textable = true
    this._fontable = true
    this._dbFill = true 
    this._getWidth = true
    this._wideText = new WideString(txt)
    this._gbStyle = style
    this._font = new FontInfo(parent.font)    
    this._bColor = parent.backColor
    this._fColor = BLACK_RGB    
    this._childList = new PtrList(4)
    parent._appendChild(@this)
    GroupBox._stGBCount += 1
    if parent.createChilds then this.createHandle()
    
end constructor

constructor GroupBox(byref parent as Form, byref txt as string, p as POINT, __wh(150, 150), _
                                                style as GroupBoxStyle = GroupBoxStyle.system)
    constructor(parent, txt, p.x, p.y, w, h, style)
end constructor

constructor GroupBox(byref parent as Form)
    constructor(parent, "GroupBox", 10, 10, 120, 30)
end constructor 

sub GroupBox.createHandle()
    this._bkBrush = this._bColor.makeHBrush()
    if this._gbStyle = GroupBoxStyle.overriden then 
        this._pen = CreatePen(PS_SOLID, penwidth, this._bColor.cref)
    end if
    this._rect = type<RECT>(0, 0, this._width, this._height)
    this._createHwnd()     
    if this._gbStyle = GroupBoxStyle.classic then 
        SetWindowTheme(this._handle, emptyWStrPtr, emptyWStrPtr)
        this._themeOff = true
    end if
    this._setSubClass(@GroupBox._wndProc)  
    this._setFont()     
end sub 

sub GroupBox._resetGDIObjects(brpn as boolean)
    '// brpn = Reset Hbrush and Hpen
    if brpn then
        if this._bkBrush > 0 then DeleteObject(this._bkBrush)        
        this._bkBrush = CreateSolidBrush(this._bColor.cref)
        if this._gbStyle = GroupBoxStyle.overriden then
            if this._pen > 0 then DeleteObject(this._pen)
            this._pen = CreatePen(PS_SOLID, penwidth, this._bColor.cref)
        end if
    end if
    if this._hdc > 0 then DeleteDC(this._hdc)
    if this._hbmp > 0 then DeleteObject(this._hbmp)    
    this._dbFill = true
end sub

property GroupBox.backColor(value as uinteger)
    this._bColor.updateColor(value)
    this._resetGDIObjects(true)
    this._checkRedraw()
end property

property GroupBox.foreColor(value as uinteger)
    this._fColor.updateColor(value)
    if this._gbStyle = GroupBoxStyle.system then this._gbStyle = GroupBoxStyle.classic
    if this._gbStyle = GroupBoxStyle.classic then
        if not this._themeOff then
            SetWindowTheme(this._handle, emptyWStrPtr, emptyWStrPtr)
            this._themeOff = true
        end if
    end if	
    if this._gbStyle = GroupBoxStyle.overriden then
        this._getWidth = true
        if this._pen = 0 then this._pen = CreatePen(PS_SOLID, penwidth, this._bColor.cref)
    end if
    this._checkRedraw()
end property

property GroupBox.text(byref value as string)
    this._text = value
    this._wideText->updateBuffer(value)
    this._getWidth = true
    if this._isCreated then SetWindowTextW(this._handle, this._wideText->constPtr)
    this._checkRedraw()
end property

property GroupBox.width(value as integer)
    this._width = value
    this._resetGdiObjects(false)
    if this._isCreated then __setPos0(SWP_NOZORDER)
end property

property GroupBox.height(value as integer)
    this._height = value
    this._resetGdiObjects(false)
    if this._isCreated then __setPos0(SWP_NOZORDER)
end property

property GroupBox.font(value as FontInfo ptr)
    if this._font then 
		delete this._font
		this._font = 0
	end if
    this._font = new FontInfo(value)
    if this._font->fontHandle = 0 then this._font->_createFontHandle()
    __sendMsg0(WM_SETFONT, this._font->fontHandle, 1)
    this._getWidth = true
    this._checkRedraw()
end property


sub GroupBox.changeFont(byref fname as string, fsize as integer, fweight as FontWeight )
   if this._font then 
		delete this._font
		this._font = 0
	end if
    this._font = new FontInfo(fname, fsize, fweight)
    this._font->_createFontHandle()
    __sendMsg0(WM_SETFONT, this._font->fontHandle, 1)
    this._getWidth = true
    this._checkRedraw()
end sub

function GroupBox.top(add as integer = 25) as integer
    return this._ypos + add
end function

function GroupBox.left(add as integer = 5) as integer
    return this._xpos + add
end function





destructor GroupBox()     
    ' print "GroupBox destructed"
    if this._pen then DeleteObject(this._pen)
    DeleteObject(this._hbmp)
    DeleteDC(this._hdc)
    delete this._childList
end destructor  

static function GroupBox._wndProc(hwnd As HWND, umsg As UINT, wpm As WPARAM, lpm As LPARAM, uidsub As UINT_PTR, dwref As DWORD_PTR ) As LRESULT
    ' print "btn message "; umsg
    select case umsg
    case WM_DESTROY        
        RemoveWindowSubclass(hwnd, @GroupBox._wndProc, uidsub)

    case CM_COLOR_STATIC
        var self = Cast(GroupBox Ptr, dwref)
        if self->_gbStyle = GroupBoxStyle.classic then
            var dc = cptr(HDC, wpm)
            SetBkMode(dc, 1)
            SetTextColor(dc, self->_fColor.cref)    
		end if
        ? "173"
        return cast(LRESULT, self->_bkBrush)        

    case WM_PAINT        
        var self = Cast(GroupBox Ptr, dwref)
        if self->_gbStyle = GroupBoxStyle.overriden then
            var ret = DefSubclassProc(hwnd, umsg, wpm, lpm)
            var gfx = Graphics(hwnd)
            gfx.drawHLine(self->_pen, 10, 12, self->_txtWidth)
            gfx.drawText(self, 12, 0)
            return ret
        end if

     case WM_GETTEXTLENGTH     
        var self = Cast(GroupBox Ptr, dwref)
        if self->_gbStyle = GroupBoxStyle.overriden then return 0 

    case  WM_ERASEBKGND
        var self = Cast(GroupBox Ptr, dwref)
        var dc = cptr(HDC, wpm)
        if self->_getWidth then
            dim size as SIZE
            SelectObject(dc, self->_font->fontHandle)
            GetTextExtentPoint32(dc, self->_wideText->constPtr, self->_wideText->wcharLen, @size)
            self->_txtWidth = size.cx + 10
            self->_getWidth = false  
        end if
        if self->_dbFill then
            self->_hdc = CreateCompatibleDC(dc)
            self->_hbmp = CreateCompatibleBitmap(dc, self->_width, self->_height)
            SelectObject(self->_hdc, self->_hbmp)
            FillRect(self->_hdc, @self->_rect, self->_bkBrush)
            self->_dbFill = false
        end if
        BitBlt(dc, 0, 0, self->_width, self->_height, self->_hdc, 0, 0, SRCCOPY)
        return 1 
        
    ' case WM_SETFOCUS
    '     var self  = cptr(GroupBox Ptr, dwref)
    '     __generalEventHandler(onGotFocus)

    ' case WM_KILLFOCUS
    '     var self  = cptr(GroupBox Ptr, dwref)
    '     __generalEventHandler(onLostFocus)

    case WM_LBUTTONDOWN 
        var self  = cptr(GroupBox Ptr, dwref)
        __mouseEventHandler(onLeftMouseDown)

    case WM_LBUTTONUP 
        var self  = cptr(GroupBox Ptr, dwref)
        __mouseEventHandler(onLeftMouseUp)
        if self->onClick then self->onClick(self, gea)
        
    case WM_RBUTTONDOWN 
        var self  = cptr(GroupBox Ptr, dwref)
        __mouseEventHandler(onRightMouseDown)
        
    case WM_RBUTTONUP 
        var self  = cptr(GroupBox Ptr, dwref)
        __mouseEventHandler(onRightMouseUp)
        if self->onRightClick then self->onRightClick(self, gea)
        
    case WM_MOUSEWHEEL 
        var self  = cptr(GroupBox Ptr, dwref)
        __mouseEventHandler(onMouseWheel)

    case WM_MOUSEMOVE 
        __mouseMoveHandler(GroupBox)
        
    case WM_MOUSELEAVE 
        var self  = cptr(GroupBox Ptr, dwref)
        self->_isMouseEntered = false
        __generalEventHandler(onMouseLeave)
        
    end select

    Return DefSubclassProc(hwnd, umsg, wpm, lpm)
end function