
'// Created on 29-Mar-2025 15:11
#include "formstyle_consts.bi"

'declare sub registerWinClass() 



constructor Form(byref sTitle as string, _
						w as integer = 500, h as integer = 400, _ 
						pos as FormPosition = FormPosition.center, _ 
						style as FormStyle = FormStyle.normalWin)
                        
	this._name = "Form_" & Form._stFormCount
	this._ctype = ControlType.Form
	this._text = sTitle
	this._width = w   
	this._height = h  
	this._fpos = pos  
	this._fstyle = style
    this._fstate = FormState.normal
	this._maxBox = true
	this._minBox = true
    this._bColor = appinfo._defWinColor
    this._font = new FontInfo("Tahoma", 11)
    this._controls = new PtrList(10)
    Form._stFormCount += 1 
    ' print "cmb list cap "; this._cmbList.capacity; ", count "; this._cmbList.count    
end constructor  

destructor Form()
    print "Form is destroying " 
    if this._cmbList then
        for i as integer = 0 to this._cmbList->count - 1
            delete cptr(ComboInfo ptr, this._cmbList->getItem(i))
            ' print "deleted cmb info ptr"
        next
        delete this._cmbList
    end if    
    delete this._controls
end destructor

sub Form.createHandle()
	this._setPosition()
	this._setStyles()
    var wTitle = WideString(this._text)
    this._handle = CreateWindowExW(this._exStyle, cast(LPCWSTR, @fbfClsName(0)), _  
                                    wTitle.constPtr, this._style, this._xpos, _  
                                    this._ypos, this._width, this._height, _  
                                    NULL, NULL, appinfo._hIns, NULL)
    if this._handle then
        this._isCreated = true
        if appinfo._mainHwnd = NULL then appinfo._mainHwnd = this._handle
        SetWindowLongPtrW(this._handle, GWLP_USERDATA, cast(LONG_PTR, @this) ) 
        
        ' this._setFont()
    end if   
end sub   

sub Form.show() 
    ShowWindow(This._handle, SW_SHOWDEFAULT)
    UpdateWindow(This._handle)
    if this._fstate = FormState.minimized then CloseWindow(this._handle)

    If Not appinfo._mainLoopOn Then
        appinfo._mainHwnd = this._handle
        ' print "_handle "; this._handle; ", main hwnd "; appinfo._mainHwnd
        appinfo._mainLoopOn = True
        dim uMsg as MSG   
        While GetMessage(@uMsg, 0, 0, 0)  <> 0      
            TranslateMessage( @uMsg )    
            DispatchMessageW(@uMsg )                
        Wend
    End If
end sub

'// Users can set the grow mode for Form's PtrList _controls.
'// Default grow mode is GrowthPolicy.linearGrowth and grow by 16.
sub Form.setControlListGrowthMode(gmode as GrowthPolicy, gvalue as single)
    this._controls->setGrowthMode(gmode, gvalue)
end sub

sub Form.setBackColor( clr as uinteger)
    print "TODO"
end sub


sub Form._setPosition()
	select case this._fpos
	case FormPosition.center
        this._xpos = (appinfo._screenWidth - this._width) / 2
        this._ypos = (appinfo._screenHeight - this._height) / 2
    case FormPosition.topMid  
        this._xpos = (appinfo._screenWidth - this._width) / 2
    case FormPosition.topRight
        this._xpos = appinfo._screenWidth - this._width
    case FormPosition.midLeft 
        this._ypos = (appinfo._screenHeight - this._height) / 2
    case FormPosition.midRight
        this._xpos = appinfo._screenWidth - this._width
        this._ypos = (appinfo._screenHeight - this._height) / 2
    case FormPosition.bottomLeft
        this._ypos = appinfo._screenHeight - this._height
    case FormPosition.bottomMid
        this._xpos = (appinfo._screenWidth - this._width) / 2
        this._ypos = appinfo._screenHeight - this._height
    case FormPosition.bottomRight
        this._xpos = appinfo._screenWidth - this._width
        this._ypos = appinfo._screenHeight - this._height
    end select
end sub

sub Form._setStyles()
	select case this._fstyle 
    case FormStyle.fixed3D 
        this._exStyle = fixed3DExStyle
        this._style = fixed3DStyle
        if not this._maxBox then this._style = this._style xor WS_MAXIMIZEBOX
        if not this._minBox then this._style = this._style xor WS_MINIMIZEBOX
    case FormStyle.fixedDialog 
        this._exStyle = fixedDialogExStyle
        this._style = fixedDialogStyle
        if not this._maxBox then this._style = this._style xor WS_MAXIMIZEBOX
        if not this._minBox then this._style = this._style xor WS_MINIMIZEBOX
    case FormStyle.fixedSingle 
        this._exStyle = fixedSingleExStyle
        this._style = fixedSingleStyle
        if not this._maxBox then this._style = this._style xor WS_MAXIMIZEBOX
        if not this._minBox then this._style = this._style xor WS_MINIMIZEBOX
    case FormStyle.normalWin 
        this._exStyle = normalWinExStyle
        this._style = normalWinStyle
        if not this._maxBox then this._style = this._style xor WS_MAXIMIZEBOX
        if not this._minBox then this._style = this._style xor WS_MINIMIZEBOX
    case FormStyle.fixedTool 
        this._exStyle = fixedToolExStyle
        this._style = fixedToolStyle
    case FormStyle.sizableTool 
        this._exStyle = sizableToolExStyle
        this._style = sizableToolStyle
    case FormStyle.hidden
        this._exStyle = WS_EX_TOOLWINDOW
        this._style = WS_BORDER
    end select
end sub

sub Form._setBackColorInternal(dc as HDC)
    var rct = this._clientRect()
    FillRect(dc, @rct, this._bkBrush)
end sub

sub Form._appendChild(pChild as Control ptr)
    this._controls->append(pChild)
end sub

sub Form._appendComboInfo(cinfo as ComboInfo ptr)
    ' print "cmb list cap "; this._cmbList->capacity
    if this._cmbList = 0 then this._cmbList = new PtrList(CMBINFOLS)
    this._cmbList->append(cinfo)
end sub




#macro __printMsg(m)
    static var x = 1
    print "["; x; "] main message "; m 
    x += 1
#endmacro 

#define __getForm() cptr(Form ptr, GetWindowLongPtrW(hw, GWLP_USERDATA))
#define noReturn false 
#define return0 true 
#define declForm true 

#macro __HandleEvent(event, argType, bDeclareForm, bReturn)
    #if bDeclareForm
        var frm = cptr(Form ptr, GetWindowLongPtrW(hw, GWLP_USERDATA))
    #endif
    if frm->event then
        #if #argType = "MouseEventArgs"
            var ea = argType(uMsg, wp, lp)
        #elseif #argType = "SizeEventArgs"
            var ea = argType(uMsg, wp, lp)
        #elseif #argType = "KeyEventArgs" 
            var ea = argType(wp)
        #elseif #argType = "KeyPressEventArgs" 
            var ea = argType(wp)
        #elseif #argType = "PaintEventArgs" 
            var ps = PAINTSTRUCT
            BeginPaint(hw, @ps)  
            var ea = argType(@ps) 
        #else
            var ea = argType
        #endif
        frm->event(frm, ea)
        #if #argType = "PaintEventArgs"
            EndPaint(hw, @ps)
        #endif 
        #if bReturn
            return 0
        #endif
    end if
#endmacro 


 

static function Form._wndProc(hw As HWND, uMsg As UINT, wp As WPARAM, lp As LPARAM) As LRESULT
    '__printMsg(uMsg)
    select case uMsg 
    case WM_LBUTTONDOWN 
        __HandleEvent(onLeftMouseDown, MouseEventArgs, declForm, return0)   
 
    case WM_LBUTTONUP 
        var frm = __getForm()
        __HandleEvent(onLeftMouseUp, MouseEventArgs, false, noReturn)
        __HandleEvent(onClick, EventArgs, false, noReturn)
        return 0   

    case WM_RBUTTONDOWN
        __HandleEvent(onLeftMouseDown, MouseEventArgs, declForm, return0)

    case WM_RBUTTONUP
        var frm = __getForm()
        __HandleEvent(onRightMouseUp, MouseEventArgs, false, noReturn)
        __HandleEvent(onRightClick, EventArgs, false, noReturn)
        return 0 

    case WM_SHOWWINDOW
        var frm = __getForm()
        if not frm->_isLoaded then
            frm->_isLoaded = true
            var ea = EventArgs
            if frm->onLoad then frm->onLoad(frm, ea)
        end if
        ' print "Form showed "; frm->_cmbList->count
        return 0  

    case WM_ACTIVATEAPP:
        var frm = __getForm()
        if frm->onActivate <> NULL or frm->onDeActivate <> NULL then
            var ea = EventArgs
            dim flag as boolean = cast(boolean, wp)
            if not flag then
                if frm->onDeActivate then frm->onDeActivate(frm, ea)
                return 0
            else
                if frm->onActivate then frm->onActivate(frm, ea)
            end if
        end if  

    case WM_COMMAND
        var frm = __getForm()
        select case lp
        case 0 '// It's from menu
            if HIWORD(wp) = 0 then
                'auto mid = cast(uint)(LOWORD(wp));
                'auto menu = win.mMenuItemDict.get(mid, null);
                'if (menu && menu.onClick) menu.onClick(menu, new EventArgs());
                return 0
            else  '// It's from accelerator key
                return 0 
            end if 
        
       case else '// Its from a control
            var ctlHwnd = cptr(HWND, lp)
            return SendMessageW(ctlHwnd, CM_CTLCOMMAND, wp, lp)        
        end select 

    case WM_KEYUP, WM_SYSKEYUP
         __HandleEvent(onKeyUp, KeyEventArgs, declForm, noReturn)
          

    case WM_KEYDOWN, WM_SYSKEYDOWN
        __HandleEvent(onKeyDown, KeyEventArgs, declForm, noReturn)

    case WM_CHAR 
         __HandleEvent(onKeyPress, KeyPressEventArgs, declForm, noReturn)

    case WM_MOUSEWHEEL
        __HandleEvent(onMouseWheel, MouseEventArgs, declForm, noReturn)

    case WM_MOUSEMOVE
        var frm = __getForm()  
        if not frm->_isMouseTracking then
            frm->_isMouseTracking = true
            _trackMouseMove(frm->handle)
            if not frm->_isMouseEntered then
                if frm->onMouseEnter then
                    frm->_isMouseEntered = true
                    var ea = EventArgs
                    frm->onMouseEnter(frm, ea) 
                end if
            end if
        end if
        if frm->onMouseMove then
            var ea = MouseEventArgs(uMsg, wp, lp)
            frm->onMouseMove(frm, ea)
        end if

    case WM_MOUSEHOVER
        var frm = __getForm()
        if frm->_isMouseTracking then frm->_isMouseTracking = false
        __HandleEvent(onMouseHover, MouseEventArgs, false, noReturn)

    case WM_MOUSELEAVE
        var frm = __getForm()
        if frm->_isMouseTracking then
            frm->_isMouseTracking = false
            frm->_isMouseEntered = false
        end if
        __HandleEvent(onMouseLeave, EventArgs, false, noReturn)

    case WM_SIZING
        var frm = __getForm()
        frm->_isSizingStarted = true
        var sea = SizeEventArgs(uMsg, wp, lp)
        frm->width = sea._windowRect.right - sea._windowRect.left
        frm->height = sea._windowRect.bottom - sea._windowRect.top
        if frm->onSizing then 
            frm->onSizing(frm, sea)
            return 1
        end if
        return 0

    case WM_SIZE
        var frm = __getForm()
        frm->_isSizingStarted = false
        if (frm->onSized) then
            var sea = SizeEventArgs(uMsg, wp, lp)
            frm->onSized(frm, sea)
            return 1
        end if 

    case WM_MOVE
        var frm = __getForm()
        frm->xpos = __getXFromLp(lp)
        frm->ypos = __getYFromLp(lp)
        __HandleEvent(onMoved, EventArgs, false, noReturn)
        return 0
     
    case WM_MOVING
        var frm = __getForm()
        var rct = cast(RECT ptr, lp)
        frm->xpos = rct->left 
        frm->ypos = rct->top
        if frm->onMoving then
            var ea = EventArgs
            frm->onMoving(frm, ea)
            return 1
        end if
        return 0 

    case WM_SYSCOMMAND:
        var frm = __getForm()
        var aMsg = cast(UINT, (wp and &hFFF0))
        select case aMsg
        case SC_MINIMIZE
            __HandleEvent(onMinimized, EventArgs, false, noReturn)
        case SC_MAXIMIZE
            __HandleEvent(onMaximized, EventArgs, false, noReturn) 
        case SC_RESTORE
            __HandleEvent(onRestored, EventArgs, false, noReturn) 
        end select 	
	
    case WM_HSCROLL 
        return SendMessageW(cast(HWND, lp), CM_HSCROLL, wp, lp)

    case WM_VSCROLL 
        return SendMessageW(cast(HWND, lp), CM_VSCROLL, wp, lp) 
     
    case WM_NOTIFY 
        var nm = cptr(NMHDR ptr, lp)
        '// writefln("WM_NOTIFY nmhdr.hwndFrom: %d, nmhdr.idFrom: %d, nmhdr.code: %d", nm.hwndFrom, nm.idFrom, nm.code);
        return SendMessageW(nm->hwndFrom, CM_NOTIFY, wp, lp) 

    case WM_CTLCOLOREDIT 
        var ctlHwnd = cptr(HWND, lp) 
        return SendMessageW(ctlHwnd, CM_COLOR_EDIT, wp, lp)
    
    case WM_CTLCOLORSTATIC
        var ctlHwnd = cptr(HWND, lp)
        return SendMessageW(ctlHwnd, CM_COLOR_STATIC, wp, lp) 

    case WM_CTLCOLORLISTBOX 
        var frm = __getForm()
        var hc = cptr(HWND, lp)
        if frm->_cmbList->count then
            for i as integer = 0 to frm->_cmbList->count - 1 
                dim ci as ComboInfo ptr = frm->_cmbList->getItem(i)
                if ci->listHwnd = hc then
                    hc = ci->cmbHwnd 
                    exit for
                end if
            next
        end if
        return SendMessageW(hc, CM_COLOR_LIST, wp, lp)
    
    ' TODO
    ' case WM_MEASUREITEM
    ' case WM_DRAWITEM
    ' case WM_MENUSELECT
    ' case WM_INITMENUPOPUP
    ' case WM_UNINITMENUPOPUP
    ' case WM_CONTEXTMENU
    ''===================================================
    case WM_CLOSE
        var frm = __getForm()
        var ea = EventArgs
        if frm->onClosing then frm->onClosing(frm, ea)        
        if ea.cancel then return 0   

    case WM_DESTROY        
         __HandleEvent(onClosed, EventArgs, declForm, noReturn)          

    case WM_NCDESTROY
        if hw = appinfo._mainHwnd then PostQuitMessage(0)
         
        
    case else   
        return DefWindowProcW(hw, uMsg, wp, lp) 
    end select
	return DefWindowProcW(hw, uMsg, wp, lp)
end function  
 