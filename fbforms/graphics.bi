'// Created on 05-May-2025 18:20


constructor Graphics(hw as HWND)
    this._hdc = GetDC(hw)
    this._hwnd = hw
    this._freeDC = true
end constructor

constructor Graphics(wp as WPARAM)
    this._hdc = cptr(HDC, wp)
end constructor
constructor Graphics(dc as HDC)
    this._hdc = dc
end constructor

constructor Graphics()

end constructor

destructor Graphics()
    if this._freeDC then 
        ReleaseDC(this._hwnd, this._hdc)
        ' print "HDC Released..."
    end if
end destructor

static function Graphics.getTextSize(pc as Control ptr) as SIZE
    var dc = GetDC(pc->handle)
    dim sz as SIZE    
    SelectObject(dc, pc->font->fontHandle)
    GetTextExtentPoint32(dc, pc->wtext->constPtr, pc->wtext->strLen, @sz)
    ReleaseDC(pc->handle, dc)
    ' print "HDC released for "; pc->name
    return sz
end function

sub Graphics.drawHLine(mPen as HPEN, sx as integer, y as integer, ex as integer)
    SelectObject(this._hdc, mPen)
    MoveToEx(this._hdc, sx, y, 0)
    LineTo(this._hdc, ex, y)
end sub

sub Graphics.drawText(pc as Control ptr, x as integer, y as integer)
    SetBkMode(this._hdc, 1)
    SelectObject(this._hdc, pc->font->fontHandle)
    SetTextColor(this._hdc, pc->foreColor.cref)
    TextOut(this._hdc, x, y, pc->wtext->constPtr, pc->wtext->strLen)
end sub

