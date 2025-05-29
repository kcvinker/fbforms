
'// Created on 23-Mar-2025 14:29

'// Contains all the types needed for FBForms


#Include Once "enums.bi"

#define ERR_EMPTY_STRING = 100
type FormDummy as Form 
type ControlDummy as Control
type WideStrDummy as WideString
type MenuItemDummy as MenuItem

#macro __declare_rw_property(_pname_, _dtype_)
	Declare Property _pname_() As _dtype_	
	Declare Property _pname_(_value_ As _dtype_)
#endmacro
  
Type RgbColor	
 	Declare Constructor()  
	Declare Constructor(ivalue As uinteger) 
	Declare Constructor(r As uinteger, g As uinteger, b As uinteger) 
	declare sub changeShade(adjVal as double = 0.0)
	declare sub copyAndChangeShade(ivalue as uinteger)
	declare function changeShadeCREF(adj as double) as COLORREF
	declare sub updateColor(ivalue as uinteger)
	declare sub updateColor(clr as RgbColor)
	declare const property cref() as COLORREF
	declare function makeHBrush() as HBRUSH
	declare function makeHotHBrush(adj as double) as HBRUSH
	declare static function getCREF(value as uinteger) as COLORREF
	_red As ubyte
	_green As ubyte
	_blue As ubyte
	_value as uinteger 
	_cref as COLORREF
End Type

type AppData
	_mainLoopOn as boolean
	_isDateInit as boolean
	_screenWidth as integer
	_screenHeight as integer
	_sysDPI as integer
	_scaleFactor as double
	_hIns as HINSTANCE
	_mainHwnd as HWND
	_defWinColor as RgbColor
	_gCtlID as integer
	_gSubClsID as UINT_PTR
	_iccEx as INITCOMMONCONTROLSEX
	_lvItemBuffer as WideStrDummy ptr 
	_sendMsgBuffer as WideStrDummy ptr '// No allocation, faster SendMessage
end type
 	
type WideString  	
	declare	constructor	
	declare destructor 
	declare constructor(nSize as integer)
	declare constructor(rhs as WideString ptr)
	declare constructor(byref sValue as string, bprint as boolean = false)	
	declare sub init(byref sValue as string, bprint as boolean = false)
	declare static function getStr(pwchar as const ushort ptr, tlen as integer) as string
	declare static sub fillBuffer(pwchar as ushort ptr, txt as string) 
	declare sub updateBuffer(byref txt as string)
	declare sub ensureSize(charCount as integer)
	declare const property constPtr() as LPCWSTR	
	declare const property dataPtr() as LPWSTR	
	declare const property byteLen() as const integer 	
	declare const property wcharLen() as const integer 	 	
	declare const property fullLen() as const integer 	 	
	declare property toStr() byref as string 	
	declare property strLen() as integer
	declare operator Let (byref rhs as WideString) 
	' declare sub copyFrom(rhs as WideString ptr)
	private: 
	_data as wstring ptr  
	_inputLen as integer 
	_wcharLen as integer	   
	_bytes as uinteger
	_inputStr as string 
	_buffer as string
	_printMsg as boolean
	declare sub _convertToUTF16() 	  
end type

type Graphics
	declare constructor
	declare constructor(hw as HWND)
	declare constructor(wp as WPARAM)
	declare constructor(dc as HDC)
	declare destructor
	declare static function getTextSize(pc as ControlDummy ptr ) as SIZE
	declare sub drawHLine(mPen as HPEN, sx as integer, y as integer, ex as integer )
	declare sub drawText(pc as ControlDummy ptr, x as integer, y as integer)
	private:
		_hdc as HDC
		_hwnd as HWND
		_freeDC as boolean
end type

Type FontInfo
	declare constructor()
	declare constructor(byref rhs as FontInfo)
	declare constructor(rhs as FontInfo ptr)
	Declare Constructor(byref fname as string, fsize as integer = 11)	 
	Declare Constructor(byref fName As String, _
						fSize As Integer, _
						fweight as FontWeight, _
						bItal As Boolean = False, _
						bUnder As Boolean = False)

	declare operator Let (byref rhs as FontInfo) 

	Declare const Property fontHandle() As HFONT		
	__declare_rw_property(fontName, string)
	__declare_rw_property(fontSize, integer)
	__declare_rw_property(bold, boolean)
	__declare_rw_property(italics, boolean)
	__declare_rw_property(undeline, boolean)

	Declare Property weight() As FontWeight	
	Declare const Property isCreated() As Boolean
	Declare Sub _createFontHandle()	
	declare sub copyFrom(rhs as FontInfo ptr)
	declare destructor()
	Private :
	
	
	private:
	declare sub _copyCtorHelper(byref rhs as FontInfo)
	_handle As HFONT
	_name As String
	_size As Integer
	_iHeight As Integer
	_weight As FontWeight
	_ital As Boolean
	_under As Boolean	
	_bold As Boolean
	_isCreated as boolean

End Type

type EventArgs extends object
	handled as boolean
	cancel as boolean
	declare constructor
end type

type MouseEventArgs extends EventArgs
	declare constructor
	declare constructor(umsg as UINT, wpm as WPARAM, lpm as LPARAM)
	declare property xpos() as integer
	declare property ypos() as integer
	private:
	_x as integer
	_y as integer
	_delta as integer
	_button as MouseButton
	_shiftKey as MouseButtonState
	_ctrlKey as MouseButtonState
end type

type KeyEventArgs extends EventArgs
	declare constructor
	declare constructor(wp as WPARAM) 

	private:
	_altPressed as boolean
	_shiftPressed as boolean 
	_ctrlPressed as boolean
	_supressKeyPress as boolean
	_keyValue as integer
	_keyCode as KeyCode
	_modifier as KeyCode
end type

type KeyPressEventArgs extends EventArgs
	declare constructor(wp as WPARAM)
	private:
	_keyChar as byte
end type

type Area  
	width as integer
	height as integer
end type

type SizeEventArgs extends EventArgs
	declare constructor(umsg as UINT, wpm as WPARAM, lpm as LPARAM)
	_windowRect as RECT
	private : 
    
    _sizedOn as SizedPosition
    _clientArea as Area
end type 

type PaintEventArgs extends EventArgs
	declare constructor(ps as PAINTSTRUCT ptr)
	private:
	_paintInfo as PAINTSTRUCT ptr
end type

type DateTimeEventArgs extends EventArgs
	declare constructor(dtpStr as LPCWSTR)
	_dateString as LPCWSTR
	_dateStruct as SYSTEMTIME ptr
end type

type EventHandler as sub (sender as ControlDummy ptr, byref ea as EventArgs)
type MouseEventHandler as sub (sender as ControlDummy ptr, byref mea as MouseEventArgs)
type KeyEventHandler as sub (sender as ControlDummy ptr, byref kea as KeyEventArgs)
type KeyPressEventHandler as sub (sender as ControlDummy ptr, byref kea as KeyPressEventArgs)
type DateTimeEventHandler as sub (sender as ControlDummy ptr, byref kea as DateTimeEventArgs)
type MenuEventHandler as sub (sender as MenuItemDummy ptr, byref kea as DateTimeEventArgs)


type Control extends object    
	' declare constructor() 
	
	declare sub createHandle()
	declare sub placeRightTo(c as Control)
	declare function rpos(y as integer = 0) as POINT
	declare destructor  

	declare property text() byref as string
	declare property text(byref value as string)
	declare const property name() as string
	declare property font() as FontInfo ptr
	declare property width() as integer
	declare property height() as integer
	declare virtual property width(value as integer)
	declare virtual property height(value as integer)

	__declare_rw_property(xpos, integer)
	__declare_rw_property(ypos, integer)

	declare function right(add as integer = 5) as integer
	declare function bottom(add as integer = 5) as integer

	declare virtual property backColor(value as uinteger)
	declare virtual property foreColor(value as uinteger)
	declare property backColor() byref as RgbColor
	declare property foreColor() byref as RgbColor
	declare property handle() as HWND
	declare property wtext() as WideString ptr
	declare property isCreated() as boolean
	



	onClick as EventHandler
	onRightClick as EventHandler
	onMouseEnter as EventHandler
	onLeftMouseDown as MouseEventHandler
	onMouseMove as MouseEventHandler
	onLeftMouseUp as MouseEventHandler
	onRightMouseDown as MouseEventHandler
	onRightMouseUp as MouseEventHandler 
	onMouseWheel as MouseEventHandler 
	onMouseHover as MouseEventHandler 
	onKeyDown as KeyEventHandler
	onKeyUp as KeyEventHandler 
	onKeyPress as KeyPressEventHandler
	onMouseLeave as EventHandler 
	onGotFocus as EventHandler
	onLostFocus as EventHandler
	
	protected: '=====================================================
		declare sub _createHwnd(special as boolean = false) 
		declare sub _setCtlID()
		declare sub _setFont()
		declare function _toDwdPtr() as DWORD_PTR
		declare sub _setSubClass(pFn as SUBCLASSPROC)
		declare function sendMsg(uMsg as UINT, wpm as WPARAM, lpm as LPARAM) as LRESULT
		declare function _clientRect() as RECT
		declare sub _checkRedraw()
		' declare function right() as 

		declare sub _setFocusHandler()
		declare sub _killFocusHandler()
		declare sub _mouseDownHandler(msg as UINT, wp as WPARAM, lp as LPARAM)
		declare sub _mouseUpHandler(msg as UINT, wp as WPARAM, lp as LPARAM)
		declare sub _mouseRDownHandler(msg as UINT, wp as WPARAM, lp as LPARAM)
		declare sub _mouseRUpHandler(msg as UINT, wp as WPARAM, lp as LPARAM)
		declare sub _mouseWheelHandler(msg as UINT, wp as WPARAM, lp as LPARAM)
		declare sub _mouseMoveHandler(msg as UINT, wp as WPARAM, lp as LPARAM)
		declare sub _mouseLeaveHandler()
		declare sub _keyDownHandler(wp as WPARAM)
		declare sub _keyUpHandler(wp as WPARAM)
		declare sub _keyPressHandler(wp as WPARAM)	
		 

		_isMouseEntered as boolean
		_handle as HWND
		_ctype as ControlType
		_cname as LPCWSTR 
		_text as string
		_name as string
		_bColor as RgbColor 
		_fColor as RgbColor
		_width as integer
		_height as integer 
		_xpos as integer
		_ypos as integer
		_ctlID as DWORD_PTR
		_style as DWORD
		_exStyle as DWORD
		_drawMode as uinteger
		_isCreated as boolean
		_lbDown as boolean
		_rbDown as boolean		
		_textable as boolean
		_autoSizable as boolean
		_cmenuUsed as boolean
		_fontable as boolean
		_bkBrush as HBRUSH
		_wideText as WideString ptr
		_font as FontInfo ptr
		_parent as FormDummy ptr
	
	
	
end type 'Control'

' __makeListOf(Control ptr, ControlList) '// Generate code for a list<Control ptr>



' type ControlArranger
' 	parent as FormDummy ptr 
' 	startPos as integer
' 	gap as integer
' 	id as integer
' 	mode as ArrangeMode
' 	controls as CtlPtrList
' 	declare sub add()
' end type

type ComboInfo 
	listHwnd as HWND
	cmbHwnd as HWND
end type

' __makeListOf(ComboInfo ptr, CmbInfoList)
 
' __makeListOf(ControlArranger ptr, ArrangerList) '// Generate code for a list<Control ptr>

type Form extends Control  
	
	declare constructor()
	declare constructor(byref sTitle as string, _
						w as integer = 500, h as integer = 400, _ 
						pos as FormPosition = FormPosition.center, _ 
						style as FormStyle = FormStyle.normalWin)
	
	declare sub createHandle()
	declare sub show() 
	declare sub close() 
	declare sub printPoint() 
	' declare sub arrangeControls cdecl (startPos as integer, gap as integer, count as integer, ...)
	declare sub _handleMouseMove(msg as UINT, wpm as WPARAM, lpm as LPARAM)
	declare destructor()

	declare sub setBackColor( clr as uinteger)
	declare sub setControlListGrowthMode(gmode as GrowthPolicy, gvalue as single)
	declare sub _appendComboInfo(cinfo as ComboInfo ptr)
	declare sub _appendChild(pChild as Control ptr)
	declare static function _wndProc(hw As HWND, uMsg As UINT, wp As WPARAM, lp As LPARAM) As LRESULT
	
	createChilds as boolean = true

	'// Events
	onClosing as EventHandler
	onClosed as EventHandler
	onLoad as EventHandler
	onActivate as EventHandler
	onDeActivate as EventHandler
	onSizing as EventHandler
	onSized as EventHandler
	onMoving as EventHandler
	onMoved as EventHandler
	onMinimized as EventHandler
	onMaximized as EventHandler 
	onRestored as EventHandler
	 

	'// Public but for private use
	
	private: 
	static _stFormCount as ushort
	_isMouseTracking as boolean
	_isLoaded as boolean	
	_isMouseEntered as boolean 
	_isSizingStarted as boolean
	_maxBox as boolean
	_minBox as boolean
	
	_fpos as FormPosition 
	_fstyle as FormStyle
	_fstate as FormState	
	
	_controls as PtrList ptr 'ControlList ptr
	_cmbList as PtrList ptr
	
	declare sub _setPosition()
	declare sub _setStyles() 
	declare sub _setBackColorInternal(dc as HDC)

end type

type ButtonDrawBase
	defPen as HPEN = 0
	hotPen as HPEN = 0
	defBrush as HBRUSH = 0
	hotBrush as HBRUSH = 0
	isUsed as boolean
	declare destructor()
	declare sub reset()
end type

type ButtonFlatDraw extends ButtonDrawBase	 
	declare sub _setData(byref clr as RgbColor)	
end type

type GradColor
	c1 as RgbColor
	c2 as RgbColor
end type

type ButtonGradDraw extends ButtonDrawBase
	defClr as GradColor 
	hotClr as GradColor 
	rtl as boolean
	declare sub _setData(c1 as uinteger, c2 as uinteger)
	declare sub _createGradientBrush(nmcd as NMCUSTOMDRAW ptr, dMode as GdrawMode)
end type

type Button extends Control
	
	declare constructor
	declare destructor
	declare constructor(byref parent as Form, byref sText as string, x as integer, y as integer, w as integer, h as integer)
	declare constructor(byref parent as Form, byref sText as string, p as POINT, w as integer, h as integer)
	declare constructor (byref parent as Form, byref sText as string)
	declare sub createHandle()
	declare sub setGradientColor(c1 as uinteger, c2 as uinteger)

	declare function _wmNotifyHandler(lpm as LPARAM) as LRESULT
	declare function _drawTextColor(nmcd as NMCUSTOMDRAW ptr) as LRESULT
	declare function _drawBackColor(nmcd as NMCUSTOMDRAW ptr) as LRESULT
	declare function _drawGradientBackColor(nmcd as NMCUSTOMDRAW ptr) as LRESULT	
	declare sub _paintFlatColor(nmcd as NMCUSTOMDRAW ptr, hbr as HBRUSH, pen as HPEN)
	declare sub _paintGradientRound(dc as HDC, rc as RECT, gBrush as HBRUSH, pen as HPEN)
	declare property backColor(value as uinteger) override
	declare property foreColor(value as uinteger) override
	declare property width(value as integer) override
	declare property height(value as integer) override

	
	private:
		__declare_static_wndproc(_wndProc)
		declare sub _setBackColorInternal(value as RgbColor)
		static _stBtnCount as ushort
		_fdraw as ButtonFlatDraw
		_gdraw as ButtonGradDraw
		_sample as integer = 104
		
end type  


type DateTime
	year as integer
	month as integer
	day as integer
	hour as integer
	minute as integer
	second as integer
	milliSeconds as integer
	dayOfWeek as WeekDays
	declare sub _init(byref st as SYSTEMTIME)
end type

type Calendar extends Control	
	declare constructor
	declare destructor
	declare constructor(byref parent as Form, x as integer, y as integer)	
	declare constructor(byref parent as Form, p as POINT)	
	declare sub createHandle()
	declare function _wmNotifyHandler(lpm as LPARAM) as LRESULT

	__declare_rw_property(value, DateTime)
	__declare_rw_property(viewMode, CalendarViewMode)
	__declare_rw_property(oldViewMode, CalendarViewMode)
	__declare_rw_property(showWeekNumber, boolean)
	__declare_rw_property(noTodayCircle, boolean)
	__declare_rw_property(noToday, boolean)
	__declare_rw_property(shortDateNames, boolean)
	__declare_rw_property(noTrailDates, boolean)

	onSelectionCommitted as EventHandler
	onValueChanged as EventHandler
	onViewChanged as EventHandler

	private:
		__declare_static_wndproc(_wndProc)
		Declare sub _setCalStyle()
		declare sub _afterCreation

		
		static _stCalCount as ushort

		_viewMode as CalendarViewMode
		_oldViewMode as CalendarViewMode
		_value as DateTime
		_showWeekNum as boolean 
		_noTodayCircle as boolean
		_noToday as boolean
		_noTrailDates as boolean
		_shortDateNames as boolean
end type


type CheckBox extends Control	
	declare constructor
	declare destructor
	declare constructor(byref parent as Form, byref sText as string, _
						x as integer, y as integer, w as integer = 0, h as integer = 0)
	declare constructor(byref parent as Form, byref sText as string, _
						p as POINT, w as integer = 0, h as integer = 0)
	declare constructor (byref parent as Form, byref sText as string)
	declare sub createHandle()	

	__declare_rw_property(checked, boolean)
	
	onCheckedChanged as EventHandler	

	private:
		__declare_static_wndproc(_wndProc)
		static _stCBCount as ushort
		_autoSize as boolean		
		_rightAlign as boolean
		_textStyle as uinteger
		_checked as boolean
		declare sub _setCbStyles() 
		declare sub _setCbSize() 
		declare function _wmNotifyHandler(lpm as LPARAM) as LRESULT
	' declare sub _setBackColorInternal(value as RgbColor)
end type  


' __makeListOf(string, StrList) 
type ComboBox extends Control
	declare constructor
	declare destructor
	declare constructor(byref parent as Form, x as integer, y as integer, w as integer = 140, h as integer = 27)
	declare constructor(byref parent as Form, p as POINT, w as integer = 140, h as integer = 27)
	declare constructor (byref parent as Form )
	declare sub createHandle()	

	declare sub addItem(byref value as string) ' Okay
	declare sub addItems(values(any) as string) 'Okay
	declare sub insertItem(byref value as string, index as integer)
	declare sub removeItem(byref value as string) 'Okay
	declare sub removeItemAt(index as integer) 'Okay
	declare sub removeAll() 'Okay
	declare function getItems(arr(any) as string) as integer

	__declare_rw_property(selectedIndex, integer)
	__declare_rw_property(hasInput, boolean)	
	declare property selectedItem() byref as string
	declare property selectedItem(byref value as  string) 
	
	onSelectionChanged as EventHandler
	onTextChanged as EventHandler
	onTextUpdated as EventHandler
	onListOpened as EventHandler
	onListClosed as EventHandler
	onSelectionCommitted as EventHandler
	onSelectionCancelled as EventHandler

	private:
		__declare_static_wndproc(_wndProc)
		__declare_static_wndproc(_editWndProc)
		static _stCMBCount as ushort
		_selIndex as integer
		_ctID as integer
		_hasInput as boolean
		_reEnabled as boolean		 	
		_oldHwnd as HWND
		_items as PtrList ptr

		declare sub _preCreationJobs()
		declare sub _getComboInfo()
		declare sub _getComboMousePoints()
		declare sub _isMouseInCombo()
		declare function _wmCommandHandler(wpm as WPARAM) as LRESULT

end type




type DateTimePicker extends Control	
	declare constructor
	declare destructor
	declare constructor(byref parent as Form, x as integer, y as integer, w as integer = 0, h as integer = 0)
	declare constructor(byref parent as Form, p as POINT, w as integer = 0, h as integer = 0)
	declare constructor (byref parent as Form)
	declare sub createHandle()

	declare property formatString(byref svalue as string)
	declare property formatString() byref as string

	__declare_rw_property(value, DateTime)
	__declare_rw_property(viewMode, CalendarViewMode)
	__declare_rw_property(oldViewMode, CalendarViewMode)
	__declare_rw_property(showWeekNumber, boolean)
	__declare_rw_property(noTodayCircle, boolean)
	__declare_rw_property(noToday, boolean)
	__declare_rw_property(shortDateNames, boolean)
	__declare_rw_property(noTrailDates, boolean)
	__declare_rw_property(rightAlign, boolean)
	__declare_rw_property(fourDigitYear, boolean)
	__declare_rw_property(showUpDown, boolean)
	__declare_rw_property(format, DTPFormat)

	onValueChanged as EventHandler
	onCalendarOpened as EventHandler 
	onCalendarClosed as EventHandler
	onTextChanged as DateTimeEventHandler

	private:
		__declare_static_wndproc(_wndProc)
		static _stDTPCount as ushort
		_format as DTPFormat
		_dropDownCount as Integer
		_calStyle as DWORD		
		_fmtString as string
		_value as DateTime
		_rightAlign as boolean
		_4DYear as boolean
		_autoSize as boolean
		_showUpDown as boolean
		_showWeekNum as boolean 
		_noTodayCircle as boolean
		_noToday as boolean
		_noTrailDates as boolean
		_shortDateNames as boolean
		declare sub _setDTPStyles() 
		declare sub _setDTPSize() 
		declare function _wmNotifyHandler(lpm as LPARAM) as LRESULT
	' declare sub _setBackColorInternal(value as RgbColor)
end type 



type GroupBox extends Control	
	declare constructor
	declare destructor
	declare constructor(byref parent as Form, byref txt as string, _
						x as integer, y as integer, _
						w as integer = 150, h as integer = 150, _
						style as GroupBoxStyle = GroupBoxStyle.system)
	declare constructor(byref parent as Form, byref txt as string, p as POINT, _
						w as integer = 150, h as integer = 150, _
						style as GroupBoxStyle = GroupBoxStyle.system)
	declare constructor (byref parent as Form)
	declare sub createHandle()	

	declare function left(add as integer = 5) as integer
	declare function top(add as integer = 25) as integer
	declare sub changeFont(byref fname1 as string, fsize1 as integer, fweight1 as FontWeight)

	declare property backColor(value as uinteger) override
	declare property foreColor(value as uinteger) override
	declare property text(byref value as string)
	declare property font(value as FontInfo ptr) 
	declare property width(value as integer) override
	declare property height(value as integer) override
	

	private:
		__declare_static_wndproc(_wndProc)
		static _stGBCount as ushort
		_txtWidth as integer
		_pen as HPEN
		_hdc as HDC
		_hbmp as HBITMAP
		_rect as RECT	
		_dbFill as boolean
		_getWidth as boolean
		_themeOff as boolean
		_gbStyle as GroupBoxStyle	
		_childList as PtrList ptr 
		
		declare sub _setDTPStyles() 
		declare sub _resetGDIObjects(brpn as boolean)
end type 

type Label extends Control	
	declare constructor
	declare destructor
	declare constructor(byref parent as Form, byref txt as string, _
			x as integer, y as integer, w as integer = 0, h as integer = 0)	
	declare constructor(byref parent as Form, byref txt as string, _
				p as POINT, w as integer = 0, h as integer = 0)	
	declare sub createHandle()
	' declare function _wmNotifyHandler(lpm as LPARAM) as LRESULT

	private:
		__declare_static_wndproc(_wndProc)
		Declare sub _setLblStyle()
		Declare sub _setAutoSize(redraw as boolean)
		' declare sub _afterCreation

		static _stLBLCount as ushort

		_textAlign as TextAlignment
		_border as LabelBorder
		_alignFlag as DWORD
		_autoSize as boolean 
		_multiLine as boolean
end type




type ListBox extends Control	
	declare constructor
	declare destructor
	declare constructor(byref parent as Form, x as integer, y as integer, _
						w as integer = 140, h as integer = 140)	
	declare constructor(byref parent as Form, _
				p as POINT, w as integer = 140, h as integer = 140)	
	declare sub createHandle()
	' declare function _wmNotifyHandler(lpm as LPARAM) as LRESULT

	'// Public methods
	declare sub selectAll()
	declare sub clearSelection()
	declare sub addItem(byref sitem as string)
	declare sub addItems(sitems(any) as string)
	declare sub insertItem(byref sitem as string, index as integer)
	declare sub removeItem(byref sitem as string)
	declare sub removeItemAt(index as integer)
	declare sub removeAll()
	declare function getItems(arr(any) as string) as integer
	declare function getSelIndices(arr(any) as string) as integer
	declare function getSelItems(arr(any) as string) as integer
	declare function indexOf(item as string) as integer
	'//Props
	
	declare property hotIndex() as integer
	declare property hotItem() as string
	declare property selectedItem() byref as string
	declare property selectedItem(byref sitem as string)
	__declare_rw_property(selectedIndex, integer)
	__declare_rw_property(horizScroll, boolean)
	__declare_rw_property(vertScroll, boolean)
	__declare_rw_property(multiSel, boolean)

	'// Events
	onSelectionChanged as EventHandler
	onSelectionCancelled as EventHandler

	private:
		__declare_static_wndproc(_wndProc)
		Declare sub _setLbxStyle()		
		declare function _getItemInternal(indx as integer) as string
		declare sub _getMultiItemsInternal(outArr(any) as string, iarr(any) as integer)

		static _stLBXCount as ushort
		
		_hasSort as boolean
		_noSelection as boolean
		_multiColumn as boolean
		_keyPreview as boolean
		_vertScroll as boolean
		_horizScroll as boolean
		_multiSel as boolean
		_dummyIndex as integer
		_selIndex as integer
		_selIndices as PtrList ptr
		_items as PtrList ptr     
end type

type ListViewColumn
	declare constructor(byref txt as string, width as integer = 100, imgIndex as integer = -1)
	declare constructor
	declare destructor

	__declare_rw_property(index, integer)
	__declare_rw_property(hasImage, boolean)
	__declare_rw_property(isInserted, boolean)
	declare property textAlign() as TextAlignment
	declare property width() as integer
	declare property imageIndex() as integer
	declare property imageOnRight() as boolean
	declare property textPtr() as wstring ptr
	declare property headerTextFlag() as uinteger
	declare property textSize() as integer

	_pLvc as LPLVCOLUMNW

	private:
		_text as string
        _wideText as WideString ptr
        _width as integer
		_index as integer
		_imgIndex as integer
		_order as integer
		_hdrTextFlag as uinteger
        _imgOnRight as boolean
		_hasImage as boolean
		_drawNeeded as boolean
		_isHotItem as boolean
		_isInserted as boolean
        _textAlign as TextAlignment
		_hdrTextAlign as TextAlignment
        _bColor as RgbColor
		_fColor as RgbColor        
        
end type

type ListViewItem
	declare constructor
	declare constructor(byref txt as string, bgColor as uinteger = &hFFFFFF, _ 
						fgColor as uinteger = &h000000, imgIndex as integer = -1)
	declare destructor

	declare property imageIndex() as integer
	declare property text() byref as string
	' declare property index() as integer
	' declare property index() as integer
	__declare_rw_property(index, integer)

	private:
		_text as string
		_index as integer
		_imgIndex as integer
		_colCount as integer
		_bColor as RgbColor
		_fColor as RgbColor
		_font as FontInfo ptr
		_lvHwnd as HWND
		_subItems as PtrList ptr
end type


' __makeListOf(ListViewColumn ptr, LVColList)
' __makeListOf(ListViewItem ptr, LVItemList)


type ListView extends Control	
	declare constructor
	declare destructor
	declare constructor(byref parent as Form, x as integer, y as integer, _
						cols as integer = 3,w as integer = 250, h as integer = 200)	
	declare constructor(byref parent as Form, p as POINT, _
						cols as integer = 3, w as integer = 250, h as integer = 200)
	declare constructor(byref parent as Form, x as integer, y as integer, _ 
                        cols(any) as string, w as integer = 250, h as integer = 200)

	declare sub createHandle()
	declare sub addColumns(cols(any) as string)
	declare sub addColumns(cols(any) as ListViewColumn ptr)
	declare sub addColumn(col as ListViewColumn ptr)
	declare sub addColumn(byref txt as string, colWidth as integer = 100, imgIndex as integer = -1)

	declare sub addItem(pItem as ListViewItem ptr)
	declare sub addItem(byref txt as string, bgColor as uinteger = &hFFFFFF, _ 
						fgColor as uinteger = &h000000, imgIndex as integer = -1)
	declare sub addItems(pItems(any) as ListViewItem ptr)
	declare sub addSubItem(byref subitem as string, itemIndex as integer, subindex as integer)
	' declare sub setColumnWidths(widths(any) as integer)

	declare property headerBackColor() as RgbColor
	declare property headerForeColor() as RgbColor

	declare property headerBackColor(value as uinteger)
	declare property headerForeColor(value as uinteger)

	__declare_rw_property(checked, boolean)
	__declare_rw_property(editLabel, boolean)
	__declare_rw_property(hideSelection, boolean)
	__declare_rw_property(multiSelection, boolean)
	__declare_rw_property(hasCheckBox, boolean)
	__declare_rw_property(fullRowSelection, boolean)
	__declare_rw_property(showGrid, boolean)
	__declare_rw_property(oneClickActivate, boolean)
	__declare_rw_property(hotTrackSelection, boolean)
	__declare_rw_property(headerClickable, boolean)
	__declare_rw_property(checkBoxLast, boolean)

	__declare_rw_property(selectedIndex, integer)
	__declare_rw_property(selectedSubIndex, integer)
	__declare_rw_property(headerHeight, integer)
	__declare_rw_property(headerFont, FontInfo ptr)
	__declare_rw_property(selectedItem, ListViewItem ptr)
	__declare_rw_property(viewStyle, ListViewStyle)

	'// Events
	onCheckedChanged as EventHandler
	onSelectionChanged as EventHandler
	onItemDoubleClicked as EventHandler
    onItemClicked as EventHandler
	onItemHover as EventHandler

	private:
		__declare_static_wndproc(_wndProc)
		__declare_static_wndproc(_hdrWndProc)
		Declare sub _setLVStyle()
		declare sub _setLVExStyles() 	
		declare sub _setHeaderSubclass() 
		declare sub _postCreationTasks()
		declare sub _addColumnInternal(lvCol as ListViewColumn ptr)	
		declare sub _addItemInternal(pItem as ListViewItem ptr) 
		declare sub _addSubItemInternal(pItem as ListViewItem ptr, byref subitem as string, _
                                    subIndex as integer, appendSubItem as boolean = true )
		declare function _drawHeader(nmcd as NMCUSTOMDRAW ptr) as LRESULT 

		static _stLVCount as ushort
		_pendingColIns as boolean
		_multiSel as boolean
		_showGrid as Boolean
		_fullRowSel as boolean
		_hideSel as boolean
		_editLabel as boolean
		_hasCbox as boolean
		_1ClickAct as boolean
		_hotTrackSel as boolean
		_cbLast as boolean
		_checked as boolean
		_autoSizeLastCol as boolean		
		_selIndex as integer
		_selSubIndex as integer
		_colIndex as integer
		_rowIndex as integer
		_itemIndex as integer
		_layoutCount as integer
		_viewStyle as ListViewStyle
		_selItem as ListViewItem ptr

		_hdrClickable as boolean
		_noHdr as boolean
		_hdrChangeHeight as boolean
		_hdrBColor as RgbColor
		_hdrFColor as RgbColor
		_hdrHeight as integer
		_hdrHotIndex as DWORD_PTR
		_hdrHotBrush as HBRUSH
		_hdrBackBrush as HBRUSH
		_hdrPen as HPEN
		_hdrHwnd as HWND
		_hdrFont as FontInfo ptr

		_columns as PtrList ptr
		_items as PtrList ptr     
end type

type MenuTable
	name as string
	item as MenuItemDummy ptr
end type


type MenuBase
	declare constructor
	declare destructor
	protected:
	static _stMenuID as integer
	_handle as HMENU
	_font as FontInfo ptr
	_menuCount as ulong
	_menus as PtrList ptr

end type
dim MenuBase._stMenuID as integer = 100

type MenuBar extends MenuBase
	declare constructor
	declare constructor(parent as Form ptr)
	declare destructor
	private:
	_formPtr as Form ptr
	_grayCref as COLORREF
	_defBgBrush as HBRUSH
	_hotBgBrush as HBRUSH
	_frameBrush as HBRUSH
	_grayBrush  as HBRUSH
end type

type MenuItem extends MenuBase

	'// Events
	onClick as MenuEventHandler
	onPopup as MenuEventHandler
	onCloseup as MenuEventHandler
	onFocus as MenuEventHandler
	private:
	_isCreated as boolean
	_isEnabled as boolean
	_popup as boolean
	_formMenu as boolean
	_id as ulong
	_index as ulong
	_wideText as WideString ptr '// For drawing make fast
	_bgColor as RgbColor
	_fgColor as RgbColor
	_parentHandle as HMENU
	_text as string
	_type as MenuType
	_formHwnd as HWND
	_pMenubar as MenuBar ptr
end type





'// Static variables
dim Form._stFormCount as ushort = 1
dim Button._stBtnCount as ushort = 1
dim Calendar._stCalCount as ushort = 1
dim CheckBox._stCBCount as ushort = 1
dim ComboBox._stCMBCount as ushort = 1
dim DateTimePicker._stDTPCount as ushort = 1
dim GroupBox._stGBCount as ushort = 1
dim Label._stLBLCount as ushort = 1
dim ListBox._stLBXCount as ushort = 1
dim ListView._stLVCount as ushort = 1

#define __thisAsDwdPtr() cast(DWORD_PTR, @this)
#define __sendmsg0(m, w, l) (SendMessageW(this._handle, m, cast(WPARAM, w), cast(LPARAM, l))) 
#define __sendmsg2(m, w, l) (SendMessageW(self->_handle, m, cast(WPARAM, w), cast(LPARAM, l))) 
#define __sendmsg1(h, m, w, l) (SendMessageW(h, m, cast(WPARAM, w), cast(LPARAM, l))) 
#define __cwstrp(p) cast(LPCWSTR, p)
#define __xywh(wv, hv) x as integer, y as integer, w as integer = wv, h as integer = hv
#define __xy() x as integer, y as integer
#define __wh(v1, v2) w as integer = v1, h as integer = v2


''// Custom messages
const MSG_BASE as UINT = WM_USER + 1
const CM_NOTIFY as UINT = MSG_BASE 
const CM_CTLCOMMAND as UINT = MSG_BASE + 3
const CM_COLOR_EDIT as UINT = MSG_BASE + 4
const CM_COLOR_STATIC as UINT = MSG_BASE + 5
const CM_COLOR_LIST as UINT = MSG_BASE + 6
const CM_COMBOTBCOLOR as UINT = MSG_BASE + 7
const CM_TBTXTCHANGED as UINT = MSG_BASE + 8
const CM_HSCROLL as UINT = MSG_BASE + 9
const CM_VSCROLL as UINT = MSG_BASE + 10
const CM_BUDDY_RESIZE as UINT = MSG_BASE + 11
const CM_MENU_ADDED as UINT = MSG_BASE + 12
const CM_WIN_THREAD_MSG as UINT = MSG_BASE + 13
const CM_TRAY_MSG as UINT = MSG_BASE + 14
const CM_CMENU_DESTROY as UINT = MSG_BASE + 15  



