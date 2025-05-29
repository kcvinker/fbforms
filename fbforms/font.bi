'// Created on 30-Mar-2025 21:11


Constructor FontInfo()
	constructor("Tahoma", 11, FontWeight.normal, false, false)	 					
end constructor

Constructor FontInfo(byref fName As String, fSize As integer = 11)
	constructor(fName, fSize, FontWeight.normal, false, false)
end constructor

Constructor FontInfo(byref fName As String, fSize As integer, fweight as FontWeight, _
						bItal As Boolean = False, bUnder As Boolean = False)
						
	this._name = fname 
	this._size = fsize 
	this._weight = fweight
	this._ital = bItal
	this._under = bUnder 						
end constructor

constructor FontInfo(byref rhs as FontInfo)
	this._copyCtorHelper(rhs)
end constructor

constructor FontInfo(rhs as FontInfo ptr)
	this.copyFrom(rhs)
end constructor

operator FontInfo.Let(byref rhs as FontInfo)
	this._copyCtorHelper(rhs)
end operator

sub FontInfo.copyFrom(rhs as FontInfo ptr)
	this._copyCtorHelper(*rhs)
end sub

sub FontInfo._copyCtorHelper(byref rhs as FontInfo)
	this._name = rhs._name 
	this._size = rhs._size 
	this._weight = rhs._weight
	this._ital = rhs._ital
	this._under = rhs._under 
	if rhs.fontHandle then 
		dim lf As LOGFONTW
    	var x = GetObjectW(rhs.fontHandle, sizeof(LOGFONTW), cptr(LPVOID, @lf))
    	if x > 0 then this._handle = CreateFontIndirectW(@lf)
	end if
end sub

destructor FontInfo()
	if this._handle then 
        DeleteObject(this._handle)
        ' print "font handle destroyed "; this._name
    end if	
end destructor

sub FontInfo._createFontHandle()
	' print "font is going to create handle"
	dim scale as double = appinfo._scaleFactor / 100
	dim fnsize as integer =  cint(scale *  cdbl(this._size))
    dim iHeight as integer = -MulDiv(fnsize, appinfo._sysDPI, 72)  
	dim lf as LOGFONTW	
	WideString.fillBuffer(@lf.lfFaceName[0], this._name)
	lf.lfHeight = iHeight
	lf.lfWeight =  clng(this._weight)
	lf.lfCharSet = DEFAULT_CHARSET
	lf.lfOutPrecision = OUT_STRING_PRECIS
	lf.lfClipPrecision = CLIP_DEFAULT_PRECIS
	lf.lfQuality = PROOF_QUALITY
	lf.lfPitchAndFamily = DEFAULT_PITCH
	this._handle = CreateFontIndirect(@lf) 
	if (this._handle) then this._isCreated = true 
    ' print "face name "; this._weight
end sub

const property FontInfo.isCreated() as boolean
	return this._isCreated
end property

const property FontInfo.fontHandle() as HFONT
	return this._handle
end property

Property FontInfo.weight() As FontWeight
    return this._weight
end property

const property WideString.fullLen() as const integer 
	return this._wcharLen + 1
end property