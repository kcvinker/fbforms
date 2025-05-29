'// Created on 03-May-2025 17:07

dim shared cmbClass(9)  as ushort => {67, 111, 109, 98, 111, 66, 111, 120, 0}
dim shared editSubClsID as uinteger = 50

constructor ComboBox(byref parent as Form, __xywh(140, 27))
    __setControlMembers(ControlType.ComboBox, cmbClass(0)) 
    this._name = "ComboBox_" & ComboBox._stCMBCount
    this._style = WS_CHILD or WS_VISIBLE
    this._exStyle = WS_EX_CLIENTEDGE   
    this._font = new FontInfo(parent.font)      
    this._bColor = WHITE_RGB
    this._fColor = BLACK_RGB
    this._selIndex = -1
    this._fontable = true
    this._items = new PtrList(10)
    parent._appendChild(@this)
    ComboBox._stCMBCount += 1
    if parent.createChilds then this.createHandle()
end constructor

constructor ComboBox(byref parent as Form, p as POINT, __wh(140, 27))
    constructor(parent, p.x, p.y, w, h)
end constructor

constructor ComboBox(byref parent as Form)
    constructor(parent, 10, 10, 120, 30)
end constructor 

sub ComboBox.createHandle()
    this._preCreationJobs()
    this._createHwnd() 
    this._setSubClass(@ComboBox._wndProc) 
    this._getComboInfo()
   
end sub 

sub ComboBox.addItem(value as string)
    this._items->append(@value)
    if this._isCreated Then
        appinfo._sendMsgBuffer->updateBuffer(value)
        __sendMsg0(CB_ADDSTRING, 0, appinfo._sendMsgBuffer->constPtr)
    end if
end sub

sub ComboBox.addItems(values(any) as string)
    dim count as integer = ubound(values)
    ' this._items->addRange(values())
    if this._isCreated then 
        for i as integer = 0 to count
            appinfo._sendMsgBuffer->updateBuffer(values(i))
            __sendMsg0(CB_ADDSTRING, 0, appinfo._sendMsgBuffer->constPtr)
            this._items->append(@values(i))
        next
    end if
end sub

#macro __comboAddItems(cmb, args...)
    scope
        dim arr(__FB_EVAL__( __FB_ARG_COUNT__(args) - 1)) as string = {##args##}
        cmb.addItems(arr())
    end scope
#endmacro

sub ComboBox.removeItem(value as string)
    if this._isCreated then
        appinfo._sendMsgBuffer->updateBuffer(value)
        var index = cast(integer, __sendMsg0(CB_FINDSTRINGEXACT, -1, _
                                                appinfo._sendMsgBuffer->constPtr))
        if index <> CB_ERR then
            __sendMsg0(CB_DELETESTRING, index, 0)
            this._items->remove(@value)
        end if
    end if
end sub

sub ComboBox.removeItemAt(index as integer)
    if this._isCreated andAlso index > -1 then
        __sendMsg0(CB_DELETESTRING, index, 0)
        this._items->removeAt(index)
    end if
end sub

sub ComboBox.removeAll()
    if this._isCreated then
        __sendMsg0(CB_DELETESTRING, 0, 0)
        this._items->clear(true) ' re-usable
    end if
end sub

function ComboBox.getItems(arr(any) as string) as integer
    redim arr(this._items->count - 1)
    for i as integer = 0 to this._items->count - 1
        arr(i) = *cptr(string ptr, this._items->getItem(i))
    next
    return this._items->count
end function

property ComboBox.selectedIndex() as integer
    return this._selIndex
end property

property ComboBox.selectedIndex(value as integer)
    this._selIndex = value
    if this._isCreated then __sendMsg0(CB_SETCURSEL, value, 0)
end property

property ComboBox.hasInput() as boolean
    return this._hasInput
end property

property ComboBox.hasInput(value as boolean)
    if this._hasInput <> value then
        this._hasInput = value
        if this._isCreated then
            this._selIndex = cast(integer, __sendMsg0(CB_GETCURSEL, 0, 0 ))
            this._reEnabled = true
            DestroyWindow(this._handle)
            this._createHwnd()
        end if
    end if
end property

property ComboBox.selectedItem() byref as string
    if this._isCreated and this._items->count > 0 then
        this._selIndex = cast(integer, __sendMsg0(CB_GETCURSEL, 0, 0))
        if this._selIndex <> CB_ERR then
            var iLen = cast(integer, __sendMsg0(CB_GETLBTEXTLEN, this._selIndex, 0))
            appinfo._sendMsgBuffer->ensureSize(iLen + 1)
            __sendMsg0(CB_GETLBTEXT, this._selIndex, appinfo._sendMsgBuffer->dataPtr)
            return appinfo._sendMsgBuffer->toStr
        end if
    end if
    return empty_str
end property

property ComboBox.selectedItem(value as  string)
    if this._isCreated and this._items->count > 0 then
        appinfo._sendMsgBuffer->updateBuffer(value)
        var index = cast(integer, __sendMsg0(CB_FINDSTRINGEXACT, -1, appinfo._sendMsgBuffer->constPtr))
        if index <> CB_ERR then __sendMsg0(CB_SETCURSEL, index, 0)
    end if
end property
 

sub ComboBox._preCreationJobs()
    if not this._reEnabled then
        '// Means, combo is creating freshly
        this._setCtlID()
        this._bkBrush = this._bColor.makeHBrush()
        ' print "brush ----------------- "; cast(integer, this._bkBrush )
        if this._hasInput then 
            this._style = this._style or CBS_DROPDOWN
        else
            this._style = this._style or CBS_DROPDOWNLIST
        end if
    else 
        '// This happens when combo recreates for a style change
        if this._hasInput then
            if (this._style and CBS_DROPDOWNLIST) = CBS_DROPDOWNLIST then 
                this._style = this._style xor CBS_DROPDOWNLIST
            end if
            this._style = this._style or CBS_DROPDOWN
        else
            if (this._style and CBS_DROPDOWN) = CBS_DROPDOWN then
                this._style = this._style xor CBS_DROPDOWN
            end if
            this._style = this._style or CBS_DROPDOWNLIST
        end if
    end if
end sub

sub ComboBox._getComboInfo()
    dim cmbInfo as COMBOBOXINFO
    cmbInfo.cbSize = sizeof(COMBOBOXINFO)
    __sendMsg0(CB_GETCOMBOBOXINFO, 0, @cmbInfo)
    dim ci as ComboInfo ptr = new ComboInfo(cmbInfo.hwndList, cmbInfo.hwndCombo)

    '// Parent needs to keep track of combo's list handle
    this._parent->_appendComboInfo(ci) 
    SetWindowSubclass(cmbInfo.hwndItem, @ComboBox._editWndProc, editSubClsID, __thisAsDwdPtr())
    editSubClsID += 1
end sub


destructor ComboBox()
     delete this._items
    ' print "ComboBox destructed"
end destructor  

static function ComboBox._wndProc(hwnd As HWND, umsg As UINT, wpm As WPARAM, lpm As LPARAM, uidsub As UINT_PTR, dwref As DWORD_PTR ) As LRESULT
    ' print "btn message "; umsg
    select case umsg
    case WM_DESTROY
        RemoveWindowSubclass(hwnd, @ComboBox._wndProc, uidsub)
        ' print "rem combo subclass "
    ' case WM_PAINT: 
    '     var btn  = Cast(ComboBox Ptr, dwref)
        
    case WM_SETFOCUS
        var self  = cptr(ComboBox Ptr, dwref)
        __generalEventHandler(onGotFocus)

    case WM_KILLFOCUS
        var self  = cptr(ComboBox Ptr, dwref)
        __generalEventHandler(onLostFocus)

    case WM_LBUTTONDOWN 
        var self  = cptr(ComboBox Ptr, dwref)
        __mouseEventHandler(onLeftMouseDown)

    case WM_LBUTTONUP 
        var self  = cptr(ComboBox Ptr, dwref)
        __mouseEventHandler(onLeftMouseUp)
        if self->onClick then self->onClick(self, gea)
        
    case WM_RBUTTONDOWN 
        var self  = cptr(ComboBox Ptr, dwref)
        __mouseEventHandler(onRightMouseDown)
        
    case WM_RBUTTONUP 
        var self  = cptr(ComboBox Ptr, dwref)
        __mouseEventHandler(onRightMouseUp)
        if self->onRightClick then self->onRightClick(self, gea)
        
    case WM_MOUSEWHEEL 
        var self  = cptr(ComboBox Ptr, dwref)
        __mouseEventHandler(onMouseWheel)

    case WM_MOUSEMOVE 
        __mouseMoveHandler(ComboBox)
        
    case WM_MOUSELEAVE 
        var self  = cptr(ComboBox Ptr, dwref)
        self->_isMouseEntered = false
        __generalEventHandler(onMouseLeave)
        

    case CM_CTLCOMMAND
        var self  = cptr(ComboBox Ptr, dwref)
        select case HIWORD(wpm)
        case CBN_SELCHANGE
            __comboCommandHandler(onSelectionChanged)
        case CBN_EDITCHANGE
            __comboCommandHandler(onTextChanged)
        case CBN_EDITUPDATE
            __comboCommandHandler(onTextUpdated)
        case CBN_DROPDOWN
            __comboCommandHandler(onListOpened)
        case CBN_CLOSEUP
            __comboCommandHandler(onListClosed)
        case CBN_SELENDOK
            __comboCommandHandler(onSelectionCommitted)
        case CBN_SELENDCANCEL
            __comboCommandHandler(onSelectionCancelled)
        end select

    case CM_COLOR_STATIC         
        var self = cptr(ComboBox ptr, dwref)
        var hdc = cast(HDC, wpm)
        if (self->_drawMode and 1) = 1 then SetTextColor(hdc, self->_fColor.cref)
        if (self->_drawMode and 2) = 2 then SetBkColor(hdc, self->_bColor.cref)        
        return cast(LRESULT, self->_bkBrush)

    case CM_COLOR_LIST
        var self = cptr(ComboBox ptr, dwref)
        if self->_drawMode then
			var hdc = cptr(HDC, wpm)
			if (self->_drawMode and 1) = 1 then SetTextColor(hdc, self->_fColor.cref)
			if (self->_drawMode and 2) = 2 then SetBkColor(hdc, self->_bColor.cref)
		end if
        return cast(LRESULT, self->_bkBrush)
    end select

    Return DefSubclassProc(hwnd, umsg, wpm, lpm)
end function

static function ComboBox._editWndProc(hwnd As HWND, umsg As UINT, wpm As WPARAM, lpm As LPARAM, uidsub As UINT_PTR, dwref As DWORD_PTR ) As LRESULT
    ' print "btn message "; umsg
    select case umsg
    case WM_DESTROY
        var x = RemoveWindowSubclass(hwnd, @ComboBox._editWndProc, uidsub)
        print "rem combo edit subclass "

    case WM_SETFOCUS
        var self  = cptr(ComboBox Ptr, dwref)
        __generalEventHandler(onGotFocus)

    case WM_KILLFOCUS
        var self  = cptr(ComboBox Ptr, dwref)
        __generalEventHandler(onLostFocus)

    case WM_LBUTTONDOWN 
        var self  = cptr(ComboBox Ptr, dwref)
        __mouseEventHandler(onLeftMouseDown)

    case WM_LBUTTONUP 
        var self  = cptr(ComboBox Ptr, dwref)
        __mouseEventHandler(onLeftMouseUp)
        if self->onClick then self->onClick(self, gea)
        
    case WM_RBUTTONDOWN 
        var self  = cptr(ComboBox Ptr, dwref)
        __mouseEventHandler(onRightMouseDown)
        
    case WM_RBUTTONUP 
        var self  = cptr(ComboBox Ptr, dwref)
        __mouseEventHandler(onRightMouseUp)
        if self->onRightClick then self->onRightClick(self, gea)
        
    case WM_MOUSEWHEEL 
        var self  = cptr(ComboBox Ptr, dwref)
        __mouseEventHandler(onMouseWheel)

    case WM_MOUSEMOVE 
        __mouseMoveHandler(ComboBox)
        
    case WM_MOUSELEAVE 
        var self  = cptr(ComboBox Ptr, dwref)
        self->_isMouseEntered = false
        __generalEventHandler(onMouseLeave)

    case CM_COLOR_EDIT
        var self  = cptr(ComboBox Ptr, dwref)
        if self->_drawMode > 0 then
            var hdc = cast(HDC, wpm)
            if (self->_drawMode and 1) = 1 then SetTextColor(hdc, self->_fColor.cref)
            if (self->_drawMode and 2) = 2 then SetBkColor(hdc, self->_bColor.cref)
        end if
        return cast(LRESULT, self->_bkBrush)
    end select

    Return DefSubclassProc(hwnd, umsg, wpm, lpm)
end function