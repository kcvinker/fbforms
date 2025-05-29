' Generic container using raw memory and Any Ptr
' Note: This version does NOT manage object lifetimes (no destructors called)

enum GrowthFactor
    GF_DOUBLE = 2
    GF_ONE_AND_HALF = 3
end enum

type AnyPtrList
    private:
        _index as integer = 0
        _cap as integer = 0
        _elemsize as integer = 0
        _data as any ptr = 0
        _growth as GrowthFactor = GF_DOUBLE

        function getGrowthSize(byval oldCap as integer) as integer
            select case _growth
                case GF_DOUBLE: return oldCap * 2
                case GF_ONE_AND_HALF: return oldCap + (oldCap \ 2)
                case else: return oldCap + 4
            end select
        end function

    public:
        declare constructor()
        declare constructor(byval elemSize as integer, byval initialCap as integer = 4, byval growth as GrowthFactor = GF_DOUBLE)
        declare destructor()

        declare sub init(byval elemSize as integer, byval initialCap as integer = 4, byval growth as GrowthFactor = GF_DOUBLE)
        declare sub clear()
        declare sub append(byval item as any ptr)
        declare sub insert(byval index as integer, byval item as any ptr)
        declare sub removeAt(byval index as integer)
        declare sub remove(byval item as any ptr)
        declare sub ensureCapacity(byval minCap as integer)
        declare sub trimCapacity()

        declare property capacity() as integer
        declare property count() as integer
        declare property index() as integer
        declare property arrayPointer() as any ptr

        declare operator [](byval i as integer) as any ptr
end type

constructor CtlArray()
    ' Default ctor
end constructor

constructor CtlArray(byval elemSize as integer, byval initialCap as integer, byval growth as GrowthFactor)
    init(elemSize, initialCap, growth)
end constructor

destructor CtlArray()
    if _data then deallocate _data
end destructor

sub CtlArray.init(byval elemSize as integer, byval initialCap as integer, byval growth as GrowthFactor)
    if _data then deallocate _data
    _elemsize = elemSize
    _cap = initialCap
    _index = 0
    _growth = growth
    _data = allocate(_elemsize * _cap)
end sub

sub CtlArray.ensureCapacity(byval minCap as integer)
    if minCap <= _cap then exit sub
    dim as integer newCap = getGrowthSize(_cap)
    if newCap < minCap then newCap = minCap
    dim as any ptr newData = allocate(_elemsize * newCap)
    if _index > 0 then
        memcpy(newData, _data, _elemsize * _index)
    end if
    deallocate _data
    _data = newData
    _cap = newCap
end sub

sub CtlArray.append(byval item as any ptr)
    ensureCapacity(_index + 1)
    dim as any ptr dest = _data + (_index * _elemsize)
    memcpy(dest, item, _elemsize)
    _index += 1
end sub

sub CtlArray.insert(byval i as integer, byval item as any ptr)
    if i < 0 or i > _index then exit sub
    ensureCapacity(_index + 1)
    dim as any ptr dest = _data + ((i + 1) * _elemsize)
    dim as any ptr src  = _data + (i * _elemsize)
    dim as integer bytesToMove = (_index - i) * _elemsize
    memmove(dest, src, bytesToMove)
    memcpy(src, item, _elemsize)
    _index += 1
end sub

sub CtlArray.removeAt(byval i as integer)
    if i < 0 or i >= _index then exit sub
    dim as any ptr dest = _data + (i * _elemsize)
    dim as any ptr src  = _data + ((i + 1) * _elemsize)
    dim as integer bytesToMove = (_index - i - 1) * _elemsize
    memmove(dest, src, bytesToMove)
    _index -= 1
end sub

sub CtlArray.remove(byval item as any ptr)
    for i as integer = 0 to _index - 1
        dim as any ptr ptr_i = _data + (i * _elemsize)
        if memcmp(ptr_i, item, _elemsize) = 0 then
            removeAt(i)
            exit sub
        end if
    next
end sub

sub CtlArray.trimCapacity()
    if _index = _cap then exit sub
    dim as any ptr newData = allocate(_index * _elemsize)
    if _index > 0 then
        memcpy(newData, _data, _elemsize * _index)
    end if
    deallocate _data
    _data = newData
    _cap = _index
end sub

sub CtlArray.clear()
    _index = 0
end sub

property CtlArray.capacity() as integer
    return _cap
end property

property CtlArray.count() as integer
    return _index
end property

property CtlArray.index() as integer
    return _index - 1
end property

property CtlArray.arrayPointer() as any ptr
    return _data
end property

operator CtlArray.[](byval i as integer) as any ptr
    if i < 0 or i >= _index then return 0
    return _data + (i * _elemsize)
end operator
