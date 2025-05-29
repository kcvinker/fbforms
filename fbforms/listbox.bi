'// Created on 06-May-2025 11:22

dim shared lbxClass(8) as ushort => {&h4C, &h69, &h73, &h74, &h62, &h6F, &h78, 0}

' dim shared MCS_NOTRAILINGDATES as const DWORD = &h40
' dim shared MCS_SHORTDAYSOFWEEK as const DWORD = &h80
' dim shared MCM_SETCURRENTVIEW as const DWORD = MCM_FIRST + 32

constructor ListBox(byref parent as Form, __xywh(140, 140))

    __setControlMembers(ControlType.ListBox, lbxClass(0)) 
    this._name = "ListBox_" & ListBox._stLBXCount          
    this._style = WS_VISIBLE or WS_CHILD or WS_BORDER  or LBS_NOTIFY or LBS_HASSTRINGS
    this._exStyle = 0   
    this._font = new FontInfo(parent.font)
    this._dummyIndex = -1
    this._selIndex = -1   
    this._fontable = true       
    this._bColor = WHITE_RGB
    this._fColor = BLACK_RGB
    this._items = new PtrList(16)
    parent._appendChild(@this)
    ListBox._stLBXCount += 1
    if parent.createChilds then this.createHandle()
end constructor

constructor ListBox(byref parent as Form, p as POINT, __wh(140, 140))
    constructor(parent, p.x, p.y, w, h)
end constructor

constructor ListBox()
end constructor

destructor ListBox()
    delete this._items
end destructor

sub ListBox.createHandle()
    this._setLbxStyle()
    this._createHwnd()             
    this._setSubClass(@ListBox._wndProc) 
    if this._items->count > 0 then 
        for i as integer = 0 to this._items->count - 1
            appinfo._sendMsgBuffer->updateBuffer(*cptr(string ptr, this._items->getItem(i)))
            __sendMsg0(LB_ADDSTRING, 0, appinfo._sendMsgBuffer->constPtr)
        next
        if this._dummyIndex > -1 then __sendMsg0(LB_SETCURSEL, this._dummyIndex, 0)
    end if
    
end sub 

sub ListBox.selectAll()
    if this._isCreated andAlso this._multiSel then __sendMsg0(LB_SETSEL, 1, -1)
end sub

sub ListBox.clearSelection()
    if this._isCreated then
        if this._multiSel then
            __sendMsg0(LB_SETSEL, 0, -1)
        else
            __sendMsg0(LB_SETCURSEL, -1, 0)
        end if 
    end if
end sub

sub ListBox.addItem(byref sitem as string)
    if this._isCreated then
        appinfo._sendMsgBuffer->updateBuffer(sitem) 
        __sendMsg0(LB_ADDSTRING, 0, appinfo._sendMsgBuffer->constPtr)
    end if
    this._items->append(@sitem)
end sub

sub ListBox.addItems(sitems(any) as string)
    if this._isCreated then
        for i as integer = 0 to ubound(sitems)
            appinfo._sendMsgBuffer->updateBuffer(sitems(i)) 
            __sendMsg0(LB_ADDSTRING, 0, appinfo._sendMsgBuffer->constPtr)
            this._items->append(@(sitems(i)))
        next
    end if 
    ' print "len(sitems) " ; ubound(sitems)
end sub

sub ListBox.insertItem(byref sitem as string, index as integer)
    if this._isCreated then        
        appinfo._sendMsgBuffer->updateBuffer(sitem) 
        __sendMsg0(LB_INSERTSTRING, index, appinfo._sendMsgBuffer->constPtr)
        this._items->insert(@sitem, index)    
    end if    
end sub

sub ListBox.removeItem(byref sitem as string)
    if this._isCreated then 
        appinfo._sendMsgBuffer->updateBuffer(sitem)   
        var index = cast(integer, __sendMsg0(LB_FINDSTRINGEXACT, -1, _ 
                                                appinfo._sendMsgBuffer->constPtr))
        if index <> LB_ERR then         
            __sendMsg0(LB_DELETESTRING, index, 0)
            this._items->removeAt(index) 
        end if   
    end if    
end sub

sub ListBox.removeItemAt(index as integer)
    if this._isCreated andAlso index > -1 then            
        __sendMsg0(LB_DELETESTRING, index, 0)
        this._items->removeAt(index)   
    end if    
end sub

sub ListBox.removeAll()
    if this._items->count > 0 then this._items->clear(true) 'Re-Usable clear
    if this._isCreated then __sendMsg0(LB_RESETCONTENT, 0, 0)   
end sub

function ListBox.getItems(arr(any) as string) as integer
    var itemcount = this._items->count - 1
    if itemcount > 0 then
        redim arr(itemcount)
        for i as integer = 0 to itemcount
            arr(i) = *cptr(string ptr, this._items->getItem(i))
        next
    end if
    return itemcount + 1
end function

function ListBox.indexOf(item as string) as integer
    if this._isCreated then
        appinfo._sendMsgBuffer->updateBuffer(item)
        return cast(integer, __sendMsg0(LB_FINDSTRINGEXACT, -1, _
                                        appinfo._sendMsgBuffer->constPtr))
    end if
    return -1
end function

function ListBox.getSelIndices(arr(any) as string) as integer
    dim selcount as integer
    if this._isCreated andAlso this._multiSel then
        selcount = cast(integer, __sendMsg0(LB_GETSELCOUNT, 0, 0))
        if selcount <> LB_ERR then 
            redim arr(selcount - 1)
            __sendMsg0(LB_GETSELITEMS, selcount, @arr(0))
        end if
    end if
    return selcount
end function

function ListBox.getSelItems(arr(any) as string) as integer
    dim selcount as integer
    if this._isCreated andAlso this._multiSel then
        selcount = __sendMsg0(LB_GETSELCOUNT, 0, 0)
        if selcount <> LB_ERR then 
            redim arr(selcount - 1)
            redim iarr(selcount - 1) as integer
            __sendMsg0(LB_GETSELITEMS, selcount, @iarr(0))
            this._getMultiItemsInternal(arr(), iarr())
            erase iarr
        end if
    end if
    return selcount
end function


property ListBox.hotIndex() as integer
    if this._isCreated andAlso this._multiSel then
        return cast(integer, __sendMsg0(LB_GETCARETINDEX, 0, 0))
    else
        return -1
    end if
end property

property ListBox.hotItem() as string
    if this._isCreated andAlso this._multiSel then
        var hindex = cast(integer, __sendMsg0(LB_GETCARETINDEX, 0, 0))
        if hindex <> LB_ERR then return this._getItemInternal(hindex)
    else
        return space(0)
    end if
end property

' property ListBox.shortDateNames() as boolean
'     return this._shortDateNames
' end property


sub ListBox._setLbxStyle()
    if this._hasSort then this._style = this._style or LBS_SORT
    if this._multiSel then this._style = this._style or LBS_EXTENDEDSEL or LBS_MULTIPLESEL
    if this._multiColumn then this._style = this._style or LBS_MULTICOLUMN
    if this._noSelection then this._style = this._style or LBS_NOSEL
    if this._keyPreview then this._style = this._style or LBS_WANTKEYBOARDINPUT
    if this._horizScroll then this._style = this._style or WS_HSCROLL
    if this._vertScroll then this._style = this._style or WS_VSCROLL
    this._bkBrush = this._bColor.makeHBrush()
end sub

function ListBox._getItemInternal(indx as integer) as string
    var txtlen = __sendMsg0(LB_GETTEXTLEN, indx, 0)
    if txtlen then
        appinfo._sendMsgBuffer->ensureSize(txtlen + 1)
        __sendMsg0(LB_GETTEXT, indx, appinfo._sendMsgBuffer->dataPtr)
        function = appinfo._sendMsgBuffer->toStr        
    end if
end function

sub ListBox._getMultiItemsInternal(outArr(any) as string, iarr(any) as integer)
    for i as integer = 0 to len(iarr) - 1
        var txtlen = __sendMsg0(LB_GETTEXTLEN, iarr(i), 0)
        if txtlen then
            appinfo._sendMsgBuffer->ensureSize(txtlen + 1)
            __sendMsg0(LB_GETTEXT, iarr(i), appinfo._sendMsgBuffer->dataPtr)
            outArr(i) = appinfo._sendMsgBuffer->toStr            
        end if
    next
end sub

#macro __listBoxAddItems(lbx, params...)
    scope
        #define _count __FB_EVAL__(__FB_ARG_COUNT__(params) - 1)
        dim arr(_count) as string = {##params##}
        lbx.addItems(arr())
    end scope
#endmacro



static function ListBox._wndProc(hwnd As HWND, umsg As UINT, wpm As WPARAM, lpm As LPARAM, uidsub As UINT_PTR, dwref As DWORD_PTR ) As LRESULT
    ' print "btn message "; umsg
    select case umsg
    case WM_DESTROY
        RemoveWindowSubclass(hwnd, @ListBox._wndProc, uidsub)
        ' print "rem calendar subclass "
    ' case WM_PAINT
    '     var btn  = cptr(ListBox Ptr, dwref)
        
    ' case WM_SETFOCUS
    '     var self  = cptr(ListBox Ptr, dwref)
    '     __generalEventHandler(onGotFocus)

    ' case WM_KILLFOCUS
    '     var self  = cptr(ListBox Ptr, dwref)
    '     __generalEventHandler(onLostFocus)

    case WM_LBUTTONDOWN
        var self  = cptr(ListBox Ptr, dwref)
        __mouseEventHandler(onLeftMouseDown)

    case WM_LBUTTONUP
        var self  = cptr(ListBox Ptr, dwref)
        __mouseEventHandler(onLeftMouseUp)
        if self->onClick then self->onClick(self, gea)
        
    case WM_RBUTTONDOWN
        var self  = cptr(ListBox Ptr, dwref)
        __mouseEventHandler(onRightMouseDown)
        
    case WM_RBUTTONUP
        var self  = cptr(ListBox Ptr, dwref)
        __mouseEventHandler(onRightMouseUp)
        if self->onRightClick then self->onRightClick(self, gea)
        
    case WM_MOUSEWHEEL
        var self  = cptr(ListBox Ptr, dwref)
        __mouseEventHandler(onMouseWheel)

    case WM_MOUSEMOVE
        __mouseMoveHandler(ListBox)
        
    case WM_MOUSELEAVE
        var self  = cptr(ListBox Ptr, dwref)
        self->_isMouseEntered = false
        __generalEventHandler(onMouseLeave)
        
    ' case CM_COLOR_STATIC
    '     var self  = cptr(ListBox Ptr, dwref)
    '     var hdc = cptr(HDC, wpm)
    '     if (self->_drawMode and 1) = 1 then SetTextColor(hdc, self->_fColor.cref)
    '     SetBkColor(hdc, self->_bColor.cref)
    '     return cast(LRESULT, self->_bkBrush)
    end select
    
    Return DefSubclassProc(hwnd, umsg, wpm, lpm)
end function