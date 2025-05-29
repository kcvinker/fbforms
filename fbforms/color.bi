'// Created on 02-Apr-25 14:11

function clip_set(value as uinteger, adj as double) as uinteger
	var x = cdbl(value) * adj
	if x < 0 then
		return 0U
	elseif x > 255 then 
		return 255U
	else
		return cuint(x)
	end if
end function

 Constructor RgbColor() 
	this._value = 0
	this._red = 0
	this._green = 0
	this._blue = 0 
end constructor 

Constructor RgbColor(ivalue As uinteger)
	this._value = ivalue
	this._red = ivalue shr 16
	this._green = (ivalue and &h00ff00) shr 8
	this._blue = ivalue and &h0000ff
	this._cref = cast(COLORREF, (((this._blue shl 16) or (this._green shl 8)) or (this._red)))
end constructor  

Constructor RgbColor(r As uinteger, g As uinteger, b As uinteger)
	this._value = (((r shl 16) or (g shl 8)) or (b))
	this._red = r
	this._green = g
	this._blue = b
	this._cref = cast(COLORREF, (((r shl 16) or (g shl 8)) or (b)))
end constructor

Function getColorRef(r as integer, g as integer, b as integer) as COLORREF
	return cast(COLORREF, (((b shl 16) or (g shl 8)) or (r))) 
end Function 

static function RgbColor.getCREF(value as uinteger) as COLORREF
	dim a_red as uinteger = value shr 16
	dim a_green as uinteger = (value and &h00ff00) shr 8
	dim a_blue as uinteger = value and &h0000ff
	dim a_cref as COLORREF = cast(COLORREF, (((a_blue shl 16) or (a_green shl 8)) or (a_red)))
	return a_cref
end function

property RgbColor.cref() as COLORREF
	return this._cref 
end property

#define __clrRef(r, g, b) cast(COLORREF, (((b shl 16) or (g shl 8)) or (r))) 
#define __clrRef1(rc) cast(COLORREF, (((rc._blue shl 16) or (rc._green shl 8)) or (rc._red))) 

sub RgbColor.changeShade(adjVal as double = 0.0)
	dim adj as double
	if adjVal = 0.0 then
		dim x as double = (this._red * 0.2126) + (this._green * 0.7152) + (this._blue * 0.0722)
		adj = iif(x < 40, 1.5, 1.2)
	else
		adj = adjVal
	end if
	this._red = clip_set(this._red, adj)
	this._green = clip_set(this._green, adj)
	this._blue = clip_set(this._blue, adj)
	this._cref =  cast(COLORREF, (((this._blue shl 16) or (this._green shl 8)) or (this._red)))
end sub

function RgbColor.changeShadeCREF(adjVal as double = 0.0) as COLORREF
	dim adj as double
	if adjVal = 0.0 then
		dim x as double = (this._red * 0.2126) + (this._green * 0.7152) + (this._blue * 0.0722)
		adj = iif(x < 40, 1.5, 1.2)
	else
		adj = adjVal
	end if
	var red = clip_set(this._red, adj)
	var green = clip_set(this._green, adj)
	var blue = clip_set(this._blue, adj)
	var cref1 = __clrRef(red, green, blue)
	return cref1
end function

sub RgbColor.updateColor(ivalue as uinteger)
	this._value = ivalue
	this._red = ivalue shr 16
	this._green = (ivalue and &h00ff00) shr 8
	this._blue = ivalue and &h0000ff
	this._cref = __clrRef1(this)
end sub

function RgbColor.makeHBrush() as HBRUSH
	return CreateSolidBrush(this._cref)
end function

function RgbColor.makeHotHBrush(adj as double) as HBRUSH
	var crf = this.changeShadeCREF(adj)
	return CreateSolidBrush(crf)
end function

sub RgbColor.copyAndChangeShade(ivalue as uinteger)
	this._value = ivalue
	this._red = ivalue shr 16
	this._green = (ivalue and &h00ff00) shr 8
	this._blue = ivalue and &h0000ff
	dim x as double = (this._red * 0.2126) + (this._green * 0.7152) + (this._blue * 0.0722)
	var adj = iif(x < 40, 1.5, 1.2)
	this._red = clip_set(this._red, adj)
	this._green = clip_set(this._green, adj)
	this._blue = clip_set(this._blue, adj)
	this._cref =  cast(COLORREF, (((this._blue shl 16) or (this._green shl 8)) or (this._red)))
end sub

function _createGradientBrush(dc as HDC, rct as RECT, c1 as RgbColor, _ 
								c2 as RgbColor, isRtL as boolean = false ) as HBRUSH

    dim memHDC as HDC = CreateCompatibleDC(dc)
    dim hBmp as HBITMAP = CreateCompatibleBitmap(dc, rct.right, rct.bottom)
    dim loopEnd as integer = iif(isRtL, rct.right, rct.bottom)
    SelectObject(memHDC, hBmp)

    for i as integer = 0 to loopEnd 
        dim tRct as RECT
        dim as uinteger r, g, b
        r = c1._red + (i * (c2._red - c1._red) / loopEnd)
        g = c1._green + (i * (c2._green - c1._green) / loopEnd)
        b = c1._blue + (i * (c2._blue - c1._blue) / loopEnd)

        dim tBrush as HBRUSH = CreateSolidBrush(__clrRef(r, g, b))
        tRct.left = iif(isRtL, i, 0)
        tRct.top =  iif(isRtL, 0, i )
        tRct.right = iif(isRtL, i + 1, rct.right)
        tRct.bottom = iif(isRtL, loopEnd, i + 1)
        FillRect(memHDC, @tRct, tBrush)
		DeleteObject(tBrush)
    next

    dim grBrush as HBRUSH = CreatePatternBrush(hBmp)
	DeleteObject(hBmp)
    DeleteDC(memHDC)
    return grBrush
end function

var BLACK_RGB = RgbColor(&h000000) 
var WHITE_RGB = RgbColor(&hFFFFFF) 