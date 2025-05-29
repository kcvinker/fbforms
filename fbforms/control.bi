 
'// Created on 29-Mar-2025 18:13
' constructor Control
' 	Control._gSubClsID = 1000
' end constructor
dim shared gea as EventArgs

destructor Control()
	print "Control destructed "; this._name
	if this._bkBrush then
		' print "bk brush deleted"
		DeleteObject(this._bkBrush)
	end if
	
	if this._wideText then 		
		delete this._wideText
		this._wideText = 0
	end if
	if this._font then 
		delete this._font
		this._font = 0
	end if
	
end destructor 

sub Control._createHwnd(special as boolean = false)
	var txtPtr = iif(this._textable, this._wideText->dataPtr, null)
	this._handle = CreateWindowExW(this._exStyle, this._cname, txtPtr, _
									this._style, this._xpos, this._ypos, _
									this._width, this._height, this._parent->_handle, _
                                    cast(HMENU, this._ctlID), appinfo._hIns, NULL)
    if this._handle then
        this._isCreated = true 
		if this._fontable then this._setFont()
	else:
		print "HWND creation failed - "; GetLastError()
    end	if
end sub

sub Control._setCtlID()
	this._ctlID = appinfo._gSubClsID
	appinfo._gSubClsID += 1
end sub

sub Control._setFont()
	if not this._font->isCreated then this._font->_createFontHandle()
	' this.sendMsg(WM_SETFONT, cast(WPARAM, this._font.fontHandle), 1)
	' __sendmsg(this._handle, WM_SETFONT, this._font.fontHandle, 1)
	__sendmsg0( WM_SETFONT, this._font->fontHandle, 1)
end sub

' function Control.sendMsg(uMsg as UINT, wpm as WPARAM, lpm as LPARAM) as LRESULT
' 	' return SendMessageW(this._handle, uMsg, wpm, lpm)
' 	return __sendmsg0(uMsg, wpm, lpm)
' end function



function Control._clientRect() as RECT
	dim rct as RECT
	GetClientRect(this._handle, @rct)
	return rct
end function

sub Control._setSubClass(pFn as SUBCLASSPROC)
	SetWindowSubclass(this._handle, pFn, appinfo._gSubClsID, __thisAsDwdPtr())
	appinfo._gSubClsID += 1
end sub

sub Control._checkRedraw()
	if this._isCreated then InvalidateRect(this._handle, NULL, true)
end sub

sub Control.placeRightTo(c as Control)
	this._xpos = c.xpos + c.width + 10
	SetWindowPos(this._handle, HWND_TOP, this._xpos, c.ypos, this._width, this._height, CTLPOSFLAG)
end sub

#define __setPos0(flag) SetWindowPos(this._handle, HWND_TOP, this._xpos, this.ypos, this._width, this._height, flag)


function Control.rpos(y as integer = 0) as POINT
	if y = 0 then y = this._ypos
	return type<POINT>(this._xpos + this._width + 10, y)
end function

function Control.right(add as integer = 5) as integer
	return this._xpos + this._width + add
end function

function Control.bottom(add as integer = 5) as integer
	return this._ypos + this._height + add
end function



'//====================Control properties=================================================
	property Control.handle() as HWND
		return this._handle
	end property

	property Control.isCreated() as boolean
		return this._isCreated
	end property

	property Control.name() as string
		return this._name
	end property


	property Control.font() as FontInfo ptr
		return this._font
	end property
	
	property Control.text() byref as string
		return this._text
	end property

	property Control.wtext() as WideString ptr
		return this._wideText
	end property

	property Control.width() as integer
		return this._width
	end property
	property Control.height() as integer
		return this._height
	end property
	property Control.width(value as integer)
		this._width = value
	end property
	property Control.height(value as integer)
		this._height = value
	end property 

	'=================================='
	property Control.xpos() as integer
		return this._xpos
	end property

	property Control.ypos() as integer
		return this._ypos
	end property	

	property Control.xpos(value as integer)
		this._xpos = value
	end property
	property Control.ypos(value as integer)
		this._ypos = value
	end property 

	property Control.backColor() byref as RgbColor
		return this._bColor
	end property

	property Control.foreColor() byref as RgbColor
		return this._fColor
	end property

	property Control.backColor(value as uinteger)
		' if this._ctype = ControlType.Button then 
		' 	cptr(Button ptr, @this)->_setBackColorInternal(value)
		' else 
		' 	print "TODO"
		' end if
	end property

	property Control.foreColor(value as uinteger)
		' return this._fColor
	end property
'//End of Control props===================================


'// Event handlers
#macro __generalEventHandler(event)
	if self->event then self->event(self, gea)
#endmacro

#macro __generalEventHandlerRet(event, retVal)
	if self->event then self->event(self, gea)
	return retVal	
#endmacro
#macro __mouseEventHandler(event)
	if self->event then 
		var mea = MouseEventArgs(umsg, wpm, lpm)
		self->event(self, mea)
	end if	
#endmacro

#macro __mouseMoveHandler(ctl_type)
	var self  = Cast(ctl_type Ptr, dwref)
	if self->_isMouseEntered then 
		if self->onMouseMove then 
			var mea = MouseEventArgs(umsg, wpm, lpm)
			self->onMouseMove(self, mea)
		end if
	else
		self->_isMouseEntered = true
		if self->onMouseEnter then self->onMouseEnter(self, gea)
	end if
#endmacro

' sub Control._setFocusHandler()
' 	if this->onGotFocus then 
' 		this->onGotFocus(this, gea)
' 	end if
' end sub
' sub Control._killFocusHandler()
' 	if this. then 
' 		this. ()
' end sub
' sub Control._mouseDownHandler(msg as UINT, wp as WPARAM, lp as LPARAM)
' 	if this. then 
' 		this. ()
' end sub
' sub Control._mouseUpHandler(msg as UINT, wp as WPARAM, lp as LPARAM)
' 	if this. then 
' 		this. ()
' end sub
' sub Control._mouseRDownHandler(msg as UINT, wp as WPARAM, lp as LPARAM)
' 	if this. then 
' 		this. ()
' end sub
' sub Control._mouseRUpHandler(msg as UINT, wp as WPARAM, lp as LPARAM)
' 	if this. then 
' 		this. ()
' end sub
' sub Control._mouseWheelHandler(msg as UINT, wp as WPARAM, lp as LPARAM)
' 	if this. then 
' 		this. ()
' end sub
' sub Control._mouseMoveHandler(msg as UINT, wp as WPARAM, lp as LPARAM)
' 	if this. then 
' 		this. ()
' end sub
' sub Control._mouseLeaveHandler()
' 	if this. then 
' 		this. ()
' end sub
' sub Control._keyDownHandler(wp as WPARAM)
' 	if this. then 
' 		this. ()
' end sub
' sub Control._keyUpHandler(wp as WPARAM)
' 	if this. then 
' 		this. ()
' end sub
' sub Control._keyPressHandler(wp as WPARAM)
' 	if this. then 
' 		this. ()
' end sub