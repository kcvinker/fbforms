'// Created on 08-May-25 00:05

constructor ListViewColumn(byref txt as string, colWidth as integer = 100, imgIndex as integer = -1)
    this._text = txt
    this._width = colWidth
    this._imgIndex = imgIndex
    this._imgOnRight = false
    this._textAlign = TextAlignment.left
    this._index = -1
    this._hdrTextAlign = TextAlignment.center
    this._hdrTextFlag = DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_NOPREFIX
    this._wideText = new WideString(txt)
end constructor

constructor ListViewColumn()
end constructor

destructor ListViewColumn
    print "list view column destroyed"
    delete this._wideText
end destructor

constructor ListViewItem(byref txt as string, bgColor as uinteger = &hFFFFFF, _ 
						fgColor as uinteger = &h000000, imgIndex as integer = -1)
    this._text = txt 
    this._bColor.updateColor(bgColor)
    this._fColor.updateColor(fgColor)
    this._index = -1
    this._imgIndex = imgIndex
    ' ? txt
end constructor

constructor ListViewItem()

end constructor

destructor ListViewItem

end destructor

property ListViewColumn.index() as integer
    return this._index
end property

property ListViewColumn.index(ivalue as integer)
    this._index = ivalue
end property

property ListViewColumn.textAlign() as TextAlignment
    return this._textAlign
end property

property ListViewColumn.width() as integer
    return this._width
end property

property ListViewColumn.imageIndex() as integer
    return this._imgIndex
end property

property ListViewColumn.imageOnRight() as boolean
    return this._imgOnRight
end property

property ListViewColumn.hasImage() as boolean
    return this._hasImage
end property

property ListViewColumn.isInserted() as boolean
    return this._isInserted
end property

property ListViewColumn.isInserted(value as boolean)
    this._isInserted = value
end property

property ListViewColumn.textPtr() as wstring ptr
    return this._wideText->dataPtr
end property

property ListViewColumn.textSize() as integer
    return this._wideText->wcharLen
end property

property ListViewColumn.headerTextFlag() as uinteger
    return this._hdrTextFlag
end property

property ListViewItem.imageIndex() as integer
    return this._imgIndex
end property

property ListViewItem.text() byref as string
    return this._text
end property

property ListViewItem.index() as integer
    return this._index
end property

property ListViewItem.index(value as integer)
    this._index = value
end property



static function ListView._hdrWndProc(hwnd As HWND, umsg As UINT, _
                                    wpm As WPARAM, lpm As LPARAM, uidsub As UINT_PTR, _ 
                                    dwref As DWORD_PTR ) As LRESULT
    ' print "btn message "; umsg
    select case umsg
    case WM_MOUSEMOVE
        var self  = cptr(ListView Ptr, dwref)
        dim hinfo as HDHITTESTINFO
        getMousePos(@hinfo.pt, lpm)
        self->_hdrHotIndex = cast(DWORD_PTR, SendMessageW(hwnd, _
                                                        HDM_HITTEST, 0, _
                                                        cast(LPARAM, @hinfo)))

    case WM_MOUSELEAVE 
        var self  = cptr(ListView Ptr, dwref)
        self->_hdrHotIndex = cast(DWORD_PTR, -1)

    case HDM_LAYOUT
        var self  = cptr(ListView Ptr, dwref)
        if self->_hdrChangeHeight then
            var pHl = cptr(LPHDLAYOUT, lpm)
            pHl->pwpos->hwnd = hwnd
            pHl->pwpos->flags = SWP_FRAMECHANGED
            pHl->pwpos->x = pHl->prc->left
            pHl->pwpos->y = 0
            pHl->pwpos->cx = (pHl->prc->right - pHl->prc->left)
            pHl->pwpos->cy = self->_hdrHeight
            pHl->prc->top = self->_hdrHeight
            return 1
        end if

    case WM_PAINT
        var self  = cptr(ListView Ptr, dwref)
        DefSubclassProc(hwnd, umsg, wpm, lpm)
        dim hrc as RECT
        SendMessageW(hwnd, HDM_GETITEMRECT, _
                        cast(WPARAM, self->_columns->count - 1), _ 
                        cast(LPARAM, @hrc))
        var rc = type<RECT>(hrc.right + 1, hrc.top, self->width, hrc.bottom)
        dim dc as HDC = GetDC(hwnd)
        FillRect(dc, @rc, self->_hdrBackBrush)
        ReleaseDC(hwnd, dc)
        return 0
    end select

    Return DefSubclassProc(hwnd, umsg, wpm, lpm)
end function
