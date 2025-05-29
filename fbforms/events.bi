'// Created on 31-Mar-2025 14:50

#define __keyStateWpm(wp) (cast(WORD, LOWORD(wp)))
#define __getXFromLp(lp) (cast(integer, cast(short, LOWORD(lp))))
#define __getYFromLp(lp) (cast(integer, cast(short, HIWORD(lp))))

constructor EventArgs()
end constructor

constructor MouseEventArgs
end constructor

constructor MouseEventArgs(umsg as UINT, wpm as WPARAM, lpm as LPARAM)
    var fwKeys = __keyStateWpm(wpm)
    this._delta = GET_WHEEL_DELTA_WPARAM(wpm)  
    select case fwKeys
    case 4
        this._shiftKey = MouseButtonState.pressed
    case 8
        this._ctrlKey = MouseButtonState.pressed
    case 16
        this._button = MouseButton.middle
    case 32 
        this._button = MouseButton.xButton1
    end select

    select case umsg
    case WM_MOUSEWHEEL, WM_MOUSEMOVE, WM_MOUSEHOVER, WM_NCHITTEST
        this._x = __getXFromLp(lpm)
        this._y = __getYFromLp(lpm)        
    case WM_LBUTTONDOWN, WM_LBUTTONUP 
        this._button = MouseButton.left
        this._x = __getXFromLp(lpm)
        this._y = __getYFromLp(lpm)        
    case WM_RBUTTONDOWN, WM_RBUTTONUP 
        this._button = MouseButton.right
        this._x = __getXFromLp(lpm)
        this._y = __getYFromLp(lpm)        
    end select
end constructor

property MouseEventArgs.xpos() as integer
    return this._x
end property
property MouseEventArgs.ypos() as integer
    return this._y
end property


constructor KeyEventArgs()
    
end constructor 

constructor KeyEventArgs(wp as WPARAM)
    this._keyCode = cast(KeyCode, wp) 
    select case this._keyCode
    case KeyCode.shift 
        this._shiftPressed = true
        this._modifier = KeyCode.shiftModifier
    case KeyCode.ctrl 
        this._ctrlPressed = true
        this._modifier = KeyCode.ctrlModifier
    case KeyCode.alt 
        this._altPressed = true
        this._modifier = KeyCode.altModifier
    end select 
    this._keyValue = this._keyCode
end constructor  

constructor KeyPressEventArgs(wp as WPARAM)
    this._keyChar = cast(byte, wp)
end constructor
 
constructor SizeEventArgs(umsg as UINT, wp as WPARAM, lp as LPARAM)
    if umsg = WM_SIZING then
        this._sizedOn = cast(SizedPosition, wp)
        this._windowRect = *cast(RECT ptr, lp)
    else
        this._clientArea.width = LOWORD(lp)
        this._clientArea.height = HIWORD(lp)
    end if 
end constructor   

constructor PaintEventArgs(ps as PAINTSTRUCT ptr)
    this._paintInfo = ps
end constructor 

constructor DateTimeEventArgs(dtpStr as LPCWSTR)
    this._dateString = dtpStr
end constructor 
