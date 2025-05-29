'// Created on 07-May-2025 15:16
#include once "lvcol_lvitem.bi"
dim shared lvClass(14) as ushort => {&h53, &h79, &h73, &h4C, &h69, &h73, &h74, &h56, &h69, &h65, &h77, &h33, &h32, 0}
dim shared LVSTYLE as const DWORD = WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LVS_REPORT or WS_BORDER or LVS_ALIGNLEFT or LVS_SINGLESEL
dim shared NM_CUSTOMDRAW_NM as const DWORD = NM_FIRST-12

constructor ListView(byref parent as Form, __xy(), cols as integer = 3, __wh(250, 200))
    __setControlMembers(ControlType.ListView, lvClass(0)) 
    this._name = "ListView_" & ListView._stLVCount 
    if appinfo._lvItemBuffer = 0 then appinfo._lvItemBuffer = new WideString(64)         
    this._style = LVSTYLE
    this._exStyle = 0   
    this._font = new FontInfo(parent.font)
    this._fontable = true
    this._viewStyle = ListViewStyle.report
    this._showGrid = true 
    this._fullRowSel = true
    this._hideSel = true
    this._editLabel = true
    this._itemIndex = -1        
    this._bColor = WHITE_RGB
    this._fColor = BLACK_RGB
    this._columns = new PtrList(cols)
    this._items = new PtrList(16)
    this._hdrClickable = true
    this._hdrHeight = 35
    this._hdrHotIndex = cast(DWORD_PTR, -1)
    this._hdrBColor = RgbColor(&hdce1de)
    this._hdrFColor = BLACK_RGB
    this._hdrFont = this._font
    parent._appendChild(@this)
    ListView._stLVCount += 1
    if parent.createChilds then this.createHandle()
end constructor

constructor ListView(byref parent as Form, p as POINT, cols as integer = 3, __wh(250, 200))
    constructor(parent, p.x, p.y, cols, w, h)
end constructor

constructor ListView(byref parent as Form, __xy(), cols(any) as string, __wh(250, 200))
    constructor(parent, x, y, ubound(cols) + 1, w, h) 
    var colLen = ubound(cols)   
    if colLen > 0 then         
        if not this._isCreated then this._pendingColIns = true
        for i as integer = 0 to colLen
            var pLVC = new ListViewColumn(cols(i))
            if this._isCreated then 
                this._addColumnInternal(pLVC)
            else
                this._columns->append(pLVC)
            end if
        next 
    end if 
end constructor

constructor ListView()
end constructor

destructor ListView()
    if this._columns->count > 0 then
        for i as integer = 0 to this._columns->count - 1
            dim col as ListViewColumn ptr = this._columns->getItem(i) 
            delete col 
        next
        delete this._columns
    end if
    if this._items->count > 0 then
        for i as integer = 0 to this._items->count - 1
            dim item as ListViewItem ptr = this._items->getItem(i)
            delete item 
        next
        delete this._items
    end if
end destructor

sub ListView.createHandle()
    this._setLVStyle()
    this._createHwnd() 
    if this._handle then        
        this._setSubClass(@ListView._wndProc) 
        this._setLVExStyles()
        this._setHeaderSubclass()
        this._postCreationTasks()
        if this._pendingColIns then 
            for i as integer = 0 to this._columns->count - 1
                dim col as ListViewColumn ptr = this._columns->getItem(i)
                if not col->isInserted then this._addColumnInternal(col)
            next
            this._pendingColIns = false
        end if
    else
        print "Error: Can't create LBL handle "; GetLastError()
    end if
end sub 

' sub ListView.selectAll()
'     if this._isCreated andAlso this._multiSel then __sendMsg0(LB_SETSEL, 1, -1)
' end sub

' sub ListView.clearSelection()
'     if this._isCreated then
'         if this._multiSel then
'             __sendMsg0(LB_SETSEL, 0, -1)
'         else
'             __sendMsg0(LB_SETCURSEL, -1, 0)
'         end if 
'     end if
' end sub

sub ListView.addColumn(col as ListViewColumn ptr) 
    if not col->isInserted andalso this._isCreated then 
        this._addColumnInternal(col)
    end if 
end sub

sub ListView.addColumn(byref txt as string, colWidth as integer = 100, imgIndex as integer = -1)
    var pCol = new ListViewColumn(txt, colWidth, imgIndex)
    if this._isCreated then this._addColumnInternal(pCol)
end sub

sub ListView.addColumns(cols(any) as string)
    if this._isCreated then
        for i as integer = 0 to ubound(cols)
            dim lvc as ListViewColumn ptr = new ListViewColumn(cols(i))
            this._addColumnInternal(lvc)
        next
    end if
end sub

sub ListView.addColumns(cols(any) as ListViewColumn ptr)
    if this._isCreated then
        for i as integer = 0 to ubound(cols)
            this._addColumnInternal(cols(i))
        next
    end if
end sub

'// Adds columns to ListView.
'// If isPtr is true, this macro expects ListViewColumn ptr as args
'// If isPtr is false, this macro expects strings as args. 
#macro __listViewAddColumns(lv, isPtr, args...)
    scope
        #define _count __FB_EVAL__(__FB_ARG_COUNT__(args) - 1)
        #if isPtr
            dim arr(_count) as ListViewColumn ptr = {##args##}
        #else
            dim arr(_count) as string = {##args##}
        #endif
        lv.addColumns(arr())
    end scope
#endmacro

sub ListView.addItem(pItem as ListViewItem ptr)
    ' if this._isCreated then 
    this._addItemInternal(pItem)

end sub

sub ListView.addItem(byref txt as string, bgColor as uinteger = &hFFFFFF, _ 
						fgColor as uinteger = &h000000, imgIndex as integer = -1)
    var pItem = new ListViewItem(txt, bgColor, fgColor, imgIndex)
    if this._isCreated then this._addItemInternal(pItem)
end sub 

sub ListView.addItems(pItems(any) as ListViewItem ptr)
    if this._isCreated then
        for i as integer = 0 to ubound(pItems)
            this._addItemInternal(pItems(i))
        next
    end if 
end sub

#macro __listViewAddItems(lv, isPtr, args...)
    scope
        #define _count __FB_EVAL__(__FB_ARG_COUNT__(args) - 1)
        #if isPtr
            dim arr(_count) as ListViewItem ptr = {##args##}
            for i as integer = 0 to _count
                this._addItemInternal(arr(i))
            next
        #else
            dim arr(_count) as string = {##args##}
            for i as integer = 0 to _count
                var pItem = new ListViewItem(arr(i))
                this._addItemInternal(pItem)
            next
        #endif        
    end scope
#endmacro

sub ListView.addSubItem(byref subitem as string, itemIndex as integer, subindex as integer )
    appinfo._lvItemBuffer->updateBuffer(subitem)
    dim lw as LVITEMW
    lw.iSubItem = subindex
    lw.pszText = appinfo._lvItemBuffer->dataPtr
    lw.iImage = -1
    __sendmsg0(LVM_SETITEMTEXTW, itemIndex, @lw)
    ' this.mSubItems.add(sitem)
end sub

#macro __listViewAddRow(lv, args...)
    scope
        #define _count __FB_EVAL__(__FB_ARG_COUNT__(args) - 1)
        dim arr(_count) as string = {##args##}
        if lv.isCreated then
            dim pItem as ListViewItem ptr = new ListViewItem(arr(0))
            lv.addItem(pItem)
            for i as integer = 1 to _count
                lv.addSubItem(arr(i), pItem->index, i)
            next
        end if        
    end scope
#endmacro

sub ListView._setLVStyle()
    select case this._viewStyle
    case ListViewStyle.largeIcon
        this._style = this._style or LVS_ICON
    case ListViewStyle.report
        this._style = this._style or LVS_REPORT
    case ListViewStyle.smallIcon
        this._style = this._style or LVS_SMALLICON
    case ListViewStyle.list
        this._style = this._style or LVS_LIST
    end select

    if this._editLabel then this._style = this._style or LVS_EDITLABELS
    if this._noHdr then this._style = this._style or LVS_NOCOLUMNHEADER
    if this._hideSel then this._style = this._style xor LVS_SHOWSELALWAYS
    if this._multiSel then this._style = this._style xor LVS_SINGLESEL

    '// Set some brushes & pen
    this._hdrBackBrush = this._hdrBColor.makeHBrush()
    this._hdrHotBrush = this._hdrBColor.makeHotHBrush(0.9)
    this._hdrPen = CreatePen(PS_SOLID, 1, &h00FFFFFF) 
end sub

sub ListView._setLVExStyles() 
    dim lvExStyle as DWORD = &h0000
    if this._showGrid then lvExStyle = lvExStyle or LVS_EX_GRIDLINES
    if this._hasCbox then lvExStyle = lvExStyle or LVS_EX_CHECKBOXES
    if this._fullRowSel then lvExStyle = lvExStyle or LVS_EX_FULLROWSELECT
    if this._1ClickAct then lvExStyle = lvExStyle or LVS_EX_ONECLICKACTIVATE
    if this._hotTrackSel then lvExStyle = lvExStyle or LVS_EX_TRACKSELECT
   '// if (this.viewStyle == ListViewStyle.TileView then SendMessageW(this.handle, LVM_SETVIEW, 0x0004, 0)
    __sendMsg0(LVM_SETEXTENDEDLISTVIEWSTYLE, 0, lvExStyle)
end sub

sub ListView._setHeaderSubclass() 
    this._hdrHwnd = cast(HWND, __sendMsg0(LVM_GETHEADER, 0, 0))
    SetWindowSubclass(this._hdrHwnd, @ListView._hdrWndProc, _
                        appinfo._gSubClsID, __thisAsDwdPtr())
    appinfo._gSubClsID += 1
end sub

sub ListView._postCreationTasks()
    if this._bColor._value <> CLR_WHITE then __sendMsg0(LVM_SETBKCOLOR, 0, this._bColor.cref)
    if this._cbLast andAlso this._columns->count > 0 then '// We need to move the first col to last position.
        redim iarr(this._columns->count - 1) as integer
        dim j as integer = 0
        for i as integer = 0 to this._columns->count - 1
            dim col as ListViewColumn ptr = this._columns->getItem(i)
            if col->index > 0 then iarr(j) = col->index
            j += 1
        next
        iarr(j) = 0
        __sendMsg0(LVM_SETCOLUMNORDERARRAY, (j + 1), @iarr(0))
    end if
end sub


sub ListView._addColumnInternal(lvCol as ListViewColumn ptr)
    lvCol->index = this._colIndex
    dim lvc as LVCOLUMNW
    lvc.mask = LVCF_FMT or LVCF_TEXT  or LVCF_WIDTH  or LVCF_SUBITEM '#-or LVCF_ORDER
    lvc.fmt = cast(integer, lvCol->textAlign)
    lvc.cx = lvCol->width
    lvc.pszText = lvCol->textPtr
    if lvCol->hasImage then
        lvc.mask = lvc.mask or LVCF_IMAGE
        lvc.fmt = lvc.fmt or LVCFMT_COL_HAS_IMAGES or LVCFMT_IMAGE
        lvc.iImage = lvCol->imageIndex
        if lvCol->imageOnRight then lvc.fmt = lvc.fmt or LVCFMT_BITMAP_ON_RIGHT
    end if

    lvCol->_pLvc = @lvc 
    if this._isCreated then
        var x = __sendMsg0(LVM_INSERTCOLUMNW, lvCol->index, @lvc)
        if x > -1 then lvCol->isInserted = true
        '// We need this to do the painting in wm notify.
        '// if (!this.mDrawColumns && lvCol->mDrawNeeded) this.mDrawColumns = true
    end if
    if not this._pendingColIns then this._columns->append(lvCol)
    this._colIndex += 1
end sub

'// Adding item to ListView.
sub ListView._addItemInternal(pItem as ListViewItem ptr)
    if this._itemIndex = -1 then this._itemIndex = 0
    pItem->index = this._itemIndex
    dim lvi as LVITEMW
    lvi.mask = LVIF_TEXT or LVIF_PARAM or LVIF_STATE
    if pItem->imageIndex <> -1 then lvi.mask = lvi.mask or LVIF_IMAGE

    '// We are using a global buffer to speed up things. This buffer will handle...
    '// the allocation if text is bigger than current buffer.
    ' dim wc(11) as ushort => {87,105,110,100,111,119,115,49,49, 0}
    appinfo._lvItemBuffer->updateBuffer(pItem->text)
    lvi.state = 0
    lvi.stateMask = 0
    lvi.iItem = pItem->index
    lvi.iSubItem = 0
    lvi.iImage = pItem->imageIndex
    lvi.pszText = appinfo._lvItemBuffer->dataPtr
    lvi.cchTextMax = appinfo._lvItemBuffer->wcharLen
    ' lvi.lParam = cast(LPARAM, pItem)
    ' var x = __sendMsg0(LVM_INSERTITEMW, 0, @lvi) 
    var x = SendMessageW(this._handle, LVM_INSERTITEMW, 0, cast(LPARAM, @lvi))
    ? "lvm ins "; x ; " error "; GetLastError() ; " lv hwnd "; this._itemIndex
    ' if this._items->count = 0 then this._items = new LVItemList(16)
    this._items->append(pItem)
    this._itemIndex += 1
end sub

'// Adding subitems to given item.
sub ListView._addSubItemInternal(pItem as ListViewItem ptr, byref subitem as string, _
                                    subIndex as integer, appendSubItem as boolean = true )
    dim lvi as LVITEMW
    '// lvi.mask = con.LVIF_TEXT | con.LVIF_STATE
    '// lvi.iItem = item_index
    appinfo._lvItemBuffer->updateBuffer(subitem)
    lvi.iSubItem = subIndex
    lvi.pszText = appinfo._lvItemBuffer->dataPtr
    lvi.iImage = -1
    __sendMsg0(LVM_SETITEMTEXTW, pItem->index, @lvi)		
    ' if appendSubItem then pItem->subItems->append(subitem)
end sub

function ListView._drawHeader(nmcd as NMCUSTOMDRAW ptr) as LRESULT 
    '// Drawing header to beautify with colors and font.
    '// Windows's own header drawing is white bkg color.
    '// But listview itself is white bkg. That's nasty when hdr & listview in white.
    '// So, we need to draw it on our own.
    if nmcd->dwItemSpec <> 0 then nmcd->rc.left += 1 '// Give room for header divider.
    dim col as ListViewColumn ptr = this._columns->getItem(nmcd->dwItemSpec) '// Get our column struct
    SetBkMode(nmcd->hdc, TRANSPARENT)
    if (nmcd->uItemState and CDIS_SELECTED) = CDIS_SELECTED then
        FillRect(nmcd->hdc, @nmcd->rc, this._hdrBackBrush)
    else
        '// We will draw with a different color if mouse is over this hdr.
        if nmcd->dwItemSpec = this._hdrHotIndex then
            FillRect(nmcd->hdc, @nmcd->rc, this._hdrHotBrush)
        else
            FillRect(nmcd->hdc, @nmcd->rc, this._hdrBackBrush)
        end if
    end if
    SelectObject(nmcd->hdc, this._hdrFont->fontHandle)
    SetTextColor(nmcd->hdc, this._hdrFColor.cref)
    if this._hdrClickable andalso ((nmcd->uItemState and CDIS_SELECTED) <> 0) then
        '// We are mimicing the dotnet listview header's nature here.
        '// They did not resize the entire header item. They just reduce...
        '// it and drawing text. That means, text is drawing in a small rect.
        '// Thus, the user thinks the header is pressed a little bit. 
        nmcd->rc.left += 2
        nmcd->rc.top += 2
    end if
    DrawText(nmcd->hdc, col->textPtr, col->textSize, @nmcd->rc, col->headerTextFlag)
    return CDRF_SKIPDEFAULT
end function


property ListView.selectedIndex() as integer 
    return this._selIndex
end property

property ListView.selectedSubIndex() as integer 
    return this._selSubIndex
end property

property ListView.checked() as boolean
    return this._checked
end property

property ListView.headerHeight(value as integer) 
    this._hdrHeight = value
end property

property ListView.headerHeight() as integer 
    return this._hdrHeight
end property

property ListView.editLabel(value as boolean) 
    this._editLabel = value
end property

property ListView.editLabel() as boolean
    return this._editLabel
end property

property ListView.hideSelection(value as boolean) 
    this._hideSel = value
end property

property ListView.hideSelection() as boolean
    return this._hideSel
end property


property ListView.multiSelection(value as boolean) 
    this._multiSel = value
end property

property ListView.multiSelection() as boolean 
    return this._multiSel
end property

property ListView.hasCheckBox(value as boolean) 
    this._hasCBox = value
end property

property ListView.hasCheckBox() as boolean 
    return this._hasCBox
end property

property ListView.fullRowSelection(value as boolean) 
    this._fullRowSel = value
end property

property ListView.fullRowSelection() as boolean 
    return this._fullRowSel
end property

property ListView.showGrid(value as boolean) 
    this._showGrid =  value
end property

property ListView.showGrid() as boolean 
    return this._showGrid
end property

property ListView.oneClickActivate(value as boolean) 
    this._1ClickAct = value
end property

property ListView.oneClickActivate() as boolean 
    return this._1ClickAct
end property

property ListView.hotTrackSelection(value as boolean) 
    this._hotTrackSel = value
end property

property ListView.hotTrackSelection() as boolean 
    return this._hotTrackSel
end property

property ListView.headerClickable(value as boolean) 
    this._hdrClickable = value
end property

property ListView.headerClickable() as boolean 
    return this._hdrClickable
end property

property ListView.checkBoxLast(value as boolean) 
    this._cbLast = value
end property

property ListView.checkBoxLast() as boolean 
    return this._cbLast
end property

property ListView.headerBackColor(value as uinteger) 
    this._hdrBColor.updateColor(value)
end property

property ListView.headerBackColor() as RgbColor 
    return this._hdrBColor
end property

property ListView.headerForeColor(value as uinteger) 
    this._hdrFColor.updateColor(value)
end property

property ListView.headerForeColor() as RgbColor 
    return this._hdrFColor
end property

property ListView.headerFont(value as FontInfo ptr) 
    this._hdrFont = value
end property

property ListView.headerFont() as FontInfo ptr
    return this._hdrFont
end property

property ListView.selectedItem(value as ListViewItem ptr) 
    this._selItem = value
end property

property ListView.selectedItem() as ListViewItem ptr 
    return this._selItem
end property

property ListView.viewStyle(value as ListViewStyle) 
    this._viewStyle = value
end property

property ListView.viewStyle() as ListViewStyle 
    return this._viewStyle
end property





static function ListView._wndProc(hwnd As HWND, umsg As UINT, wpm As WPARAM, lpm As LPARAM, uidsub As UINT_PTR, dwref As DWORD_PTR ) As LRESULT
    ' print "btn message "; umsg
    select case umsg
    case WM_DESTROY
        RemoveWindowSubclass(hwnd, @ListView._wndProc, uidsub)
        ' print "rem calendar subclass "
    ' case WM_PAINT
    '     var btn  = cptr(ListView Ptr, dwref)
        
    case WM_SETFOCUS
        var self  = cptr(ListView Ptr, dwref)
        __generalEventHandler(onGotFocus)

    case WM_KILLFOCUS
        var self  = cptr(ListView Ptr, dwref)
        __generalEventHandler(onLostFocus)

    case WM_LBUTTONDOWN
        var self  = cptr(ListView Ptr, dwref)
        __mouseEventHandler(onLeftMouseDown)

    case WM_LBUTTONUP
        var self  = cptr(ListView Ptr, dwref)
        __mouseEventHandler(onLeftMouseUp)
        if self->onClick then self->onClick(self, gea)
        
    case WM_RBUTTONDOWN
        var self  = cptr(ListView Ptr, dwref)
        __mouseEventHandler(onRightMouseDown)
        
    case WM_RBUTTONUP
        var self  = cptr(ListView Ptr, dwref)
        __mouseEventHandler(onRightMouseUp)
        if self->onRightClick then self->onRightClick(self, gea)
        
    case WM_MOUSEWHEEL
        var self  = cptr(ListView Ptr, dwref)
        __mouseEventHandler(onMouseWheel)

    case WM_MOUSEMOVE
        __mouseMoveHandler(ListView)
        
    case WM_MOUSELEAVE
        var self  = cptr(ListView Ptr, dwref)
        self->_isMouseEntered = false
        __generalEventHandler(onMouseLeave)

    case WM_NOTIFY '// This is from header.
        var self  = cptr(ListView Ptr, dwref)
        var nmh = cptr(LPNMHDR, lpm)
        if nmh->code = NM_CUSTOMDRAW_NM then '// Let's draw header back & fore colors
            var nmcd = cptr(LPNMCUSTOMDRAW, lpm)
            select case nmcd->dwDrawStage '// NM_CUSTOMDRAW is always -12 when item painting
            case CDDS_PREPAINT: 
                return CDRF_NOTIFYITEMDRAW
            case CDDS_ITEMPREPAINT:
                '// We are drawing our headers.
                return self->_drawHeader(nmcd)
            end select
        end if

    case CM_NOTIFY 
       var self  = cptr(ListView Ptr, dwref)
        var nmh = cptr(LPNMHDR, lpm)
        '// echo "nmhdr code ", $nmh.code
        select case nmh->code
        case NM_CUSTOMDRAW_NM
            var nmLvcd = cptr(LPNMLVCUSTOMDRAW, lpm)
            select case nmLvcd->nmcd.dwDrawStage
            case CDDS_PREPAINT
                return CDRF_NOTIFYITEMDRAW
            case CDDS_ITEMPREPAINT
                nmLvcd->clrTextBk = self->_bColor.cref
                return CDRF_NEWFONT or CDRF_DODEFAULT
            end select

        case LVN_ITEMCHANGED
            var nmlv = cptr(LPNMLISTVIEW, lpm)
            if nmlv->uNewState = 8192 orelse nmlv->uNewState = 4096 then
                self->_checked = iif(nmlv->uNewState = 8192, true, false)
                if self->onCheckedChanged then self->onCheckedChanged(self, gea)
            else
                if nmlv->uNewState = 3 then
                    self->_selIndex = nmlv->iItem
                    self->_selSubIndex = nmlv->iSubItem
                    if self->onSelectionChanged then self->onSelectionChanged(self, gea)
                end if
            end if

        '// case NM_DBLCLK:
        '//     if self->onItemDoubleClicked != nil: self->onItemDoubleClicked(self-> newEventArgs())

        '// case NM_CLICK:
        '//     let nmia = cast[LPNMITEMACTIVATE](lpm)
        '#'//  if self->onItemClicked != nil: self->onItemClicked(self-> newEventArgs())

        case NM_HOVER
            if self->onItemHover then self->onItemHover(self, gea)

        case LVN_BEGINLABELEDIT
            ? "591 ok"
       end select
    end select
    
    Return DefSubclassProc(hwnd, umsg, wpm, lpm) 
end function

