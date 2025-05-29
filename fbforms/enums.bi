'// Created on 29-Mar-2025 18:15

enum FontWeight
	thin = 100
	extraLight = 200
	light = 300
	normal = 400
	medium = 500
	semiBold = 600 
	bold = 700
	extraBold = 800 
	thick = 900
end enum

enum ControlType explicit
	Form
	Button
	Calendar 
	CheckBox
	ComboBox
	DateTimePicker 
	GroupBox
	Label
	ListBox
	ListView
	NumberPicker
	ProgressBar
	RadioButton
	TextBox
	TrackBar
	TreeView	
end enum

enum FormPosition
	topLeft
	topMid 
	topRight
    midLeft
    center
    midRight
    bottomLeft
    bottomMid
    bottomRight
    manual
end enum
enum FormStyle
	fixedSingle
	fixed3D
	fixedDialog
	normalWin
	fixedTool
	sizableTool
	hidden 
end enum
enum FormState
	none
	normal
	maximized
	minimized
end enum
enum MouseButton 
    none = 0
    right = 2097152
    middle = 4194304
    left = 1048576
    xButton1 = 8388608
    xButton2 = 16777216
end enum
enum MouseButtonState
	none
	released 
	pressed
end enum

enum SizedPosition
    leftEdge = 1
    rightEdge
    topEdge
    topLeftCorner
    topRightCorner
    bottomEdge
    bottomLeftCorner
    bottomRightCorner
end enum

enum FormBkMode ' Private enum'
	normal
	singleColor
	gradient
end enum

enum GdrawMode
    default 
	focused
	clicked 
end enum

enum CalendarViewMode 
	monthView
    yearView
    decadeView
    centuaryView
end enum

enum WeekDays
	sunday
	monday
	tuesday
	wednesday
	thursday
	friday
	saturday
end enum

enum ArrangeMode
	horizontal
	vertical
end enum

enum DTPFormat
	longDate = 1
	shortDate = 2
	timeOnly = 4 
	custom = 8
end enum

enum TextAlignment
	left
	center
	right
end enum

enum LabelBorder
	lbNone
	lbSingle
	lbSunken 
end enum

enum ListViewStyle
    largeIcon
	report
	smallIcon
	list
	tile
end enum

enum GroupBoxStyle
	system
	classic
	overriden
end enum

enum MenuType
	baseMenu
	menuItem
	popup
	separator
	menubar
	contextMenu
	contextSep
end enum



enum KeyCode
	modifier = -65536	
    none = 0	
    lButton
	rButton 
	cancel
	mButton
	xButtonOne
	xButtonTwo	
    backSpace = 8
	tab
	lineFeed
	clear = 12
	enter
	shift = 16
	ctrl
	alt
	pause
	capsLock
	escape = 27
	space = 32
	pageUp
	pageDown
	endKey
	home
	leftArrow
	upArrow
	rightArrow 
	downArrow
	selectKey
	print
	execute
	printScreen
	insert 
	del
	help
	d0
	d1
	d2
	d3
	d4
	d5
	d6
	d7
	d8
	d9	
    a = 65
	b
	c
	d
	e
	f
	g
	h
	i
	j
	k
	l
	m
	n	
    o
	p
	q
	r
	s
	t
	u
	v
	w
	x
	y
	z	
    leftWin
	rightWin
	apps
	sleep = 95
	numPad0
	numPad1
	numPad2
	numPad3
	numPad4
	numPad5
	numPad6
	numPad7
	numPad8
	numPad9
	multiply
	add
	seperator
	subtract
	decimal
	divide
	f1
	f2
	f3
	f4
	f5
	f6
	f7
	f8
	f9
	f10
	f11
	f12
	f13
	f14
	f15
	f16
	f17
	f18
	f19
	f20
	f21
	f22
	f23
	f24
	numLock = 144
	scroll
	leftShift = 160
	rightShift
	leftCtrl
	rightCtrl
	leftMenu
	rightmenu	
    browserBack
	browserForward
	browerRefresh
	browserStop
	browserSearch
	browserFavorites
	browserHome	
    volumeMute
	volumeDown
	volumeUp	
    mediaNextTrack
	mediaPrevTrack
	mediaStop
	mediaPlayPause
	launchMail
	selectMedia
	launchApp1
	launchApp2
	oem1 = 186
	oemPlus
	oemComma
	oemMinus
	oemPeriod
	oemQuestion
	oemTilde
    oemOpenBracket = 219
	oemPipe
	oemCloseBracket
	oemQuotes
	oem8	
    oemBackSlash = 226
	process = 229
	packet = 231
	attn = 246
	crSel
	exSel
	eraseEof
	play
	zoom
	noName
	pa1
	oemClear
	  '// start from 400
    keyCode = 65535	
    shiftModifier = 65536	
    ctrlModifier = 131072	
    altModifier = 262144
end enum 
 
