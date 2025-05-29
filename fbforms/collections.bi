
'// Created on 23-Apr-2025 15:09
'// List & Dictionary for FBForms
'// Usage ------------------
'// __makeDictionaryOf(integer, string, IntStrDict) '// Run the macro to generate code for dict/list
'// __makeListOf(String, StrList) '// This will generate code for a list of string.
'// var dict = IntStrDict(10) '// Declare the instance of dict with initial capacity.
'// var lst = StrList(5) '// A string list with initial capacity 5, you can grow the size.



#macro __each?(__iter__, __arr__)
	__i as Integer = 0 To __arr__.count - 1
	#define __iter__ (__arr__[__i])
#endmacro

#macro __each_kvp_in?(__arr__)
	__i as Integer = 0 To __arr__.count - 1
	#define kvp __arr__.getKeyValuePair(__i)	 
#endmacro

#Define in ,


#ifndef ResizePolicy
	enum ResizePolicy
		lineaer
		exponential
	end enum
#endif


#macro __makeListOf(dtype, listName) 
	' #if typeof(dtype)="STRING"
	' 	#define BREF byref
	' #endif

	type listName
		declare constructor
		declare constructor(cap as integer, rp as ResizePolicy = lineaer, growth as single = 10)
		declare constructor(anArray(any) as dtype)
		declare constructor(byref same_type as listName)
		declare destructor

		#if typeof(dtype)="STRING"
			declare sub append(byref item as dtype)
			declare sub insert(byref item as dtype, indx as integer)
			declare sub remove (byref item as dtype) 
			
		#else
			declare sub append(item as dtype)
			declare sub insert(item as dtype, indx as integer)
			declare sub remove (item as dtype)
			' declare operator [](indx as integer) as dtype
		#endif
		declare operator [](indx as integer) byref as dtype
		declare function getItem(indx as integer) byref as dtype
		declare sub ensureCapacity(iSize as integer)
		' declare sub printArray(tilSize as boolean = false) deprecated because user needs to overload toString method 
		declare sub addRange(arr(any) as dtype )
		declare sub removeAt (idx as integer)       ' Remove by index
    	
		declare sub trimCapacity()
		declare sub clear()
		
		declare operator Let(byref rhs as listName)		
		declare property capacity() as integer
		declare property capacity(value as integer)		
		declare property arrayPtr() as dtype ptr
		declare property count() as integer		 
		declare sub init(cap as integer, rp as ResizePolicy = lineaer, growth as single = 10)

		private:
			_data(any) as dtype
			_capacity as integer = 0
			_index as integer = -1
			_policy as ResizePolicy
			_growthFactor as single = 1.5
			_erased as boolean
			declare function _calcSize() as integer	
			declare function _getHeadRoom() as integer  
			declare sub _privateInit(cap as integer, rp as ResizePolicy, growth as single)
	end type	 

	sub listName._privateInit(cap as integer, rp as ResizePolicy, growth as single)
		this._capacity = cap
		this._index = -1
		this._policy = rp
		this._growthFactor = growth
		redim this._data(this._capacity - 1)
		' print "cmb list cap "; this._capacity; ", index "; this._index
	end sub
  	
  	sub listName.init(cap as integer, rp as ResizePolicy = lineaer, growth as single = 10)
  		this._privateInit(cap, rp, growth)
  	end sub

	constructor listName(cap as integer, rp as ResizePolicy = lineaer, growth as single = 10)	
		this._privateInit(cap, rp, growth)
		' print "main ctor: index: "; this._index; ", capacity: "; this._capacity		
	end constructor
	
	constructor listName(byref obj as listName)
		if obj.count > this._capacity then			
			this._capacity = obj.count - 1
			redim this._data(this._capacity - 1)
		end if
		for i as integer = 0 to obj.count - 1
			this._data(i) = obj._data(i)
		next
		this._index = obj._index
		' print "copy ctor: index: "; this._index; ", capacity: "; this._capacity		
	end constructor

	constructor listName(anArray(any) as dtype)		
		constructor(UBound(anArray) + 1, lineaer, 10)
		for i as integer = 0 to UBound(anArray)
			this._data(i) = anArray(i)
		next
	end constructor
  
	constructor listName() 
		redim this._data(0)	
		' print "List def ctor worked"
	end constructor

	destructor listName
		erase this._data
		print #listName ##"'s memory freed!"
	end destructor

	property listName.arrayPtr() as dtype ptr
		return @this._data(0)
	end property

	sub listName.ensureCapacity(iSize as integer)		
		dim currGap as integer = this._capacity - (this._index + 1)
		if currGap < iSize or this._capacity < iSize Then
			this._capacity += iSize - currGap
			if this._index = -1 then 				
				redim this._data(this._capacity - 1)
			else
				redim preserve this._data(this._capacity - 1)
			end if
		end if		
	end sub
	
	' #if typeof(dtype)="STRING"
	operator listName.[](indx as integer) byref as dtype
	' #else
	' operator listName.[](indx as integer) as dtype
	' #endif
	
		if indx < 0 or indx > this._index then
			print "Error: Index is out of range...."
			exit operator
		end if
		return cast(dtype, this._data(indx))
	end operator

	function listName.getItem(indx as integer) byref as dtype
		if indx < 0 or indx > this._index then
			print "Error: Index is out of range...."
			exit function
		end if
		return this._data(indx)
	end function
	
	property listName.capacity(value as integer)
		if value < 0 then 
			print "Error: Capacity value must be greater than zero..."
			exit property
		end if
		this._capacity = value
		if value = 0 then
			this.clear()
		else
			if this._erased then
				redim this._data(this._capacity - 1)
				this._erased = false
			else
				redim preserve this._data(this._capacity - 1)
			end if
		end if
		' print "capa index: "; this._index; ", capacity: "; this._capacity
	end property

	sub listName.trimCapacity()
		'// this deleted the empty space between array index and capacity
		if this._index > -1 then 
			redim preserve this._data(this._index)
			this._capacity = this._index + 1
		end if
	end sub
	
	#if typeof(dtype)="STRING"
	sub listName.append(byref item as dtype)
	#else
	sub listName.append(item as dtype)
	#endif
	
		if (this._capacity - 1) <= this._index or this._erased then			
			this._capacity = this._calcSize()	  
			redim preserve this._data(this._capacity)
			this._erased = false			
		end if
		this._index += 1
		this._data(this._index) = item
	end sub
	
	#if typeof(dtype)="STRING"
	sub listName.insert(byref item as dtype, indx as integer)
	#else
	sub listName.insert(item as dtype, indx as integer)
	#endif
		if indx < 0 or indx > this._index then
			print "Error: Index is out of range...."
			exit sub
		end if
		if (this._capacity - 1) <= this._index or this._erased then
			this._capacity = this._calcSize()
			redim preserve this._data(this._index + 1) 'Increase array size one
			this._erased = false
		end if
		For i As Integer = this._index To indx Step -1
		    this._data(i + 1) = this._data(i) 'Shifting items to next index
		Next
		this._data(indx) = item
		this._index = iif(indx > this._index, indx, this._index + 1)
		' print "insert index: "; this._index; ", capacity: "; this._capacity
	end sub

	sub listName.addRange(arr(any) as dtype )
		dim itemCount as integer = UBound(arr) 
		this.ensureCapacity(itemCount + 1)
		for i as integer = 0 to itemCount
			this.append(arr(i)) 
		next		
	end sub
  
	function listName._calcSize() as integer
		dim result as integer
		if this._erased and this._capacity = 0 then return 10
		select case this._policy
		case lineaer
		 	result = this._capacity + CInt(this._growthFactor)
		case exponential
		  	if this._growthFactor >= 1.0 then this._growthFactor = 1.5
		  	result = CInt(this._capacity * this._growthFactor)		
		end select
		return result
	end function

	function listName._getHeadRoom() as integer 
		if this._index = -1 then return 0
		return (this._capacity - (this._index + 1))
	end function
  
	property listName.capacity() as integer
		return this._capacity
	end property
  
	property listName.count() as integer
		return this._index + 1
	end property

	operator listName.Let(byref rhs as listName)
		if rhs._capacity <> this._capacity then 
			redim this._data(rhs._capacity - 1)
		end if  
		this._index = rhs._index
		this._capacity = rhs._capacity
		this._erased = rhs._erased
		this._policy = rhs._policy
		this._growthFactor = rhs._growthFactor
		for i as integer = 0 to this._index
            this._data(i) = rhs._data(i)
        next
		' print "Let worked"
	end operator
	
	' sub listName.printArray(tilSize as boolean = false)
	' 	dim maxPos as integer = iif(tilSize, this._index, this._capacity - 1)
	' 	print "[";
	' 	for i as integer = 0 to maxPos
	' 		If i > LBound(this._data) Then
	' 			Print ", ";
	' 		End If
	' 		Print this._data(i);
	' 	next
	' 	print "]"
	' end sub

	sub listName.removeAt(idx as integer)
		if idx < 0 or idx > this._index then
			print "RemoveAt error: Index out of range."
			exit sub
		end if
		if idx <= this._index then 	'// Shift left to fill the gap
			for i as integer = idx to this._index
				this._data(i) = this._data(i + 1)
			next
		end if 	
		'// We are not freeing the last block, because it's harmless.
		'// User can't access that data because the current max index...
		'// is reducing here. If user want's to put something there...
		'// the old value be gone for ever. 
		this._index -= 1
		' print "remAt index: "; this._index; ", capacity: "; this._capacity
	end sub

	' We only need this sub if dtype is a primitive type.
	#if typeof(dtype)="STRING"
	sub listName.remove(byref item as dtype)
	#else
	sub listName.remove(item as dtype)
	#endif
		for i as integer = 0 to this._index
			if this._data(i) = item then
				this.removeAt(i)   '// Call the removeAt method
				exit sub    '// Remove only the first match
			end if
		next
		' print "Remove error: Item not found."
		' print "Rem index: "; this._index; ", capacity: "; this._capacity
	end sub
	
  
	sub listName.clear()
		erase this._data
		this._capacity = 0
		this._index = -1
		this._erased = true
	end sub
  
#endmacro	

'// Dictionry is not tested properly. Use list with dedicated type instead.
#macro __makeDictionaryOf(ktype, vtype, dictName)
	#ifndef Kvp_##ktype##_##vtype
	type Kvp_##ktype##_##vtype
		key as ktype
		value as vtype
	end type
	
	type dictName
		declare constructor
		declare constructor(cap as integer, rp as ResizePolicy = lineaer, growth as single = 10)
		declare destructor
		declare sub add(keyItem as ktype, valueItem as vtype)
		declare sub remove(keyItem as ktype)
		declare sub clear()
		declare operator [](indx as ktype) byref as vtype
		declare function get(keyItem as ktype, byref defItem as vtype) byref as vtype
		declare const property count() as integer
		declare property getKeyValuePair(indx as integer) as Kvp_##ktype##_##vtype
		declare sub init(cap as integer, rp as ResizePolicy = lineaer, growth as single = 10)
		private:		
		_data(any) as Kvp_##ktype##_##vtype
		_capacity as integer
		_index as integer
		_policy as ResizePolicy
		_growthFactor as single
		_erased as boolean
		declare function _calcSize() as integer
		declare sub _internalInit(cap as integer, rp as ResizePolicy, growth as single)
	end type

	sub dictName._internalInit(cap as integer, rp as ResizePolicy, growth as single)
		this._capacity = iif(cap < 1, 10, cap)
		this._index = -1
		this._policy = rp
		this._growthFactor = growth
		redim this._data(this._capacity - 1)
		
	end sub

	constructor dictName(cap as integer, rp as ResizePolicy = lineaer, growth as single = 10)
		this._internalInit(cap, rp, growth)
		print "prm Ctor: capacity: "; this._capacity
	end constructor

	constructor dictName()
		redim this._data(0)
		print "def ctor"
	end constructor

	sub dictName.init(cap as integer, rp as ResizePolicy = lineaer, growth as single = 10)
		this._internalInit(cap, rp, growth)
		print "init called"
	end sub

	destructor dictName()
		erase this._data
		print "dict erased"
	end destructor

	sub dictName.add(keyItem as ktype, valueItem as vtype)
		if UBound(this._data) = (this._capacity - 1) or this._erased Then
			this._capacity = this._calcSize()
			if this._erased Then
				redim this._data(this._capacity - 1)
			else
				redim preserve this._data(this._capacity - 1)
			end if 
		end if
		dim hasItem as boolean = false
		dim tempIndex as integer = -1
		if this._index > -1 then 
			for i as integer = 0 to this._index
				if this._data(i).key = keyItem then 
					this._data(i).value = valueItem
					exit sub
				end if
			next
		end if
		this._index += 1
		dim kvp as Kvp_##ktype##_##vtype
		kvp.key = keyItem
		kvp.value = valueItem
		this._data(this._index) = kvp
	end sub

	operator dictName.[](keyItem as ktype) byref as vtype		
		if this._index > -1 then 
			for i as integer = 0 to this._index
				if this._data(i).key = keyItem then 
					return this._data(i).value
				end if
			next
		end if
	end operator

	function dictName.get(keyItem as ktype, byref defItem as vtype) byref as vtype
		dim notFound as boolean = false
		if this._index > -1 then 
			for i as integer = 0 to this._index
				if this._data(i).key = keyItem then 
					return this._data(i).value
				end if
			next
			notFound = true
		end if
		if notFound then 
			'// We need to return a default item
			return defItem
		end if
	end function

	sub dictName.remove(keyItem as ktype)
		if this._index > -1 then
			dim remIndex as integer = -1 
			for i as integer = 0 to this._index
				if this._data(i).key = keyItem then 
					remIndex = i 
					exit for
				end if 
			next 
			if remIndex > -1 then 
				for i as integer = remIndex to this._index
					this._data(i) = this._data(i + 1)
				next
				this._index -= 1

			end if 
		end if 
	end sub	 

	sub dictName.clear()
		erase this._data
		this._capacity = 0
		this._index = -1
		this._erased = true
	end sub

	const property dictName.count() as integer
		return this._index + 1
	end property

	property dictName.getKeyValuePair(indx as integer) as Kvp_##ktype##_##vtype
		return this._data(indx)
	end property

	function dictName._calcSize() as integer
		dim result as integer
		if this._erased and this._capacity = 0 then return 10
		select case this._policy
		case lineaer
		 	result = this._capacity + CInt(this._growthFactor)
		case exponential
		  	if this._growthFactor >= 1.0 then this._growthFactor = 1.5
		  	result = CInt(this._capacity * this._growthFactor)		
		end select
		return result
	end function
	#else
		#print "Cant create dictName. A disctionary with <"ktype, vtype> is already generated"
	#endif
#endmacro

'====================================PTRLIST==========================================

dim shared dummyNullPtr as any ptr
enum GrowthPolicy
    growByOne
    linearGrowth
    growByFactor
end enum

enum ClearMode 
    none 
    fullClear
    reusableClear
end enum

type PtrList 
    declare constructor
    declare destructor
    declare constructor(cap as uinteger)

    declare sub append(item as any ptr)
    declare sub insert(item as any ptr, index as integer)
    declare sub remove(item as any ptr)
    declare sub removeAt(index as integer)
    declare sub clear(reUsable as boolean = false)
    declare sub addRange(arr(any) as any ptr)
    declare sub setGrowthMode(gmode as GrowthPolicy, gvalue as single)

    declare operator [] (byval index as integer) as any ptr
	declare function getItem(index as integer) as any ptr

    declare property capacity(value as uinteger)
    declare property capacity() as uinteger

    declare property growthMode(value as GrowthPolicy)
    declare property growthMode() as GrowthPolicy

    declare property linearGrowth(value as integer)
    declare property linearGrowth() as integer

    declare property expGrowth(value as single)
    declare property expGrowth() as single

    declare property count() as integer
    declare property dataPtr() as any ptr ptr
    private:
        _data(any) as any ptr
        _index as integer = -1
        _capacity as uinteger = 0
        _policy as GrowthPolicy = GrowthPolicy.linearGrowth
        _linGrowth as integer = 16
        _expGrowth as single = 1.5
        _clearMode as ClearMode = ClearMode.none

        declare sub _resizeInternal()
end type

constructor PtrList()
    redim this._data(0)
end constructor

constructor PtrList(cap as uinteger)
    dim cap1 as uinteger = iif(cap < 1, 0, cap - 1)
    this._capacity = cap
    redim this._data(cap1)
	' ? "this cap "; this.capacity ; ", this count "; this.count
end constructor

destructor PtrList()
    erase this._data
    ' print "erased PtrList"
end destructor

sub PtrList.setGrowthMode(gmode as GrowthPolicy, gvalue as single)
	this._policy = gmode
	select case gmode
	case GrowthPolicy.linearGrowth
		this._linGrowth = cast(integer, gvalue)
	case GrowthPolicy.growByFactor
		this._expGrowth = gvalue
	end select
end sub

sub PtrList.append(item as any ptr) '[0][0][]
	if (this._capacity - this._index) < 2 then this._resizeInternal()
    this._index += 1
    this._data(this._index) = item
end sub

sub PtrList.remove(item as any ptr)
    for i as integer = 0 to this._index
        if this._data(i) = item then
            this.removeAt(i)   '// Call the removeAt method
            exit sub    '// Remove only the first match
        end if
    next
end sub

sub PtrList.removeAt(index as integer)
    if index < 0 or index > this._index then
        print "PtrList Error at RemoveAt: Index out of range."
        exit sub
    end if
    if index <= this._index then 	'// Shift left to fill the gap
        for i as integer = index to this._index
            this._data(i) = this._data(i + 1)
        next
    end if 
    '// We are not freeing the last block, because it's harmless.
    '// User can't access that data because the current max index...
    '// is reducing here. If user want's to put something there...
    '// the old value be gone for ever. 
	this._index -= 1	
end sub

sub PtrList._resizeInternal()
    select case this._policy
    case GrowthPolicy.growByOne
        this._capacity += 1
    case GrowthPolicy.linearGrowth
        this._capacity += this._linGrowth
    case GrowthPolicy.growByFactor
        if this._capacity = 0 then 
            this._capacity = 1
        else
		    this._capacity = cuint(csng(this._capacity) * this._expGrowth)
        end if
    end select
    if this._index > -1 then
        redim preserve this._data(this._capacity - 1)
    else
        redim this._data(this._capacity - 1)
    end if
end sub

sub PtrList.insert(item as any ptr, index as integer)
    if index < 0 orelse index > (this._index + 1) then
        print "PtrList Error: Can't insert, Index is out of range...."
        exit sub
    end if

    '// We are allowing last entry as an insert, it's just an append in effect.
    dim lastEntry as boolean = iif(index = (this._index + 1), true, false)
    if (this._capacity - this._index) < 2 then this._resizeInternal()
    if this._index > -1 orelse lastEntry then        
    '[0][0][0][0][][]
        this._index += 1
        this._data(this._index) = item  
    else
        For i As Integer = this._index To index Step -1
            this._data(i + 1) = this._data(i) 'Shifting items to next index
        Next
        this._data(index) = item
        this._index += 1
    end if
end sub

sub PtrList.addRange(arr(any) as any ptr)
    dim itemCount as integer = UBound(arr) 
    dim newCap as integer = this.capacity + itemCount
    this.capacity = newCap
    for i as integer = 0 to itemCount - 1
        this.append(arr(i))         
    next
end sub

sub PtrList.clear(reUsable as boolean = false)
    this._clearMode = iif(reUsable, ClearMode.reusableClear, ClearMode.fullClear)
    if reUsable then 
        redim this._data(0)
    else
        erase this._data
    end if
    this._capacity = 0
    this._index = -1
end sub

operator PtrList.[] (byval index as integer) as any ptr
    if index > -1 andalso index <= this._index then
        return this._data(index)
    else
        return dummyNullPtr
    end if
    
end operator

function PtrList.getItem(index as integer) as any ptr
	if index > -1 andalso index <= this._index then
        return this._data(index)
    else
        return dummyNullPtr
    end if
end function

property PtrList.capacity(value as uinteger)
    if value > 0 then
        if this._index > -1 then
            redim preserve this._data(value - 1)
        else
            redim this._data(value - 1)
        end if
        this._capacity = value
    else 
        this.clear(true) '// Clearing but reusable
    end if
end property

property PtrList.capacity() as uinteger
    return this._capacity
end property

property PtrList.count() as integer
    return this._index + 1
end property

property PtrList.dataPtr() as any ptr ptr
    return @this._data(0)
end property

property PtrList.growthMode() as GrowthPolicy
    return this._policy
end property

property PtrList.growthMode(value as GrowthPolicy)
    this._policy = value
end property

property PtrList.linearGrowth() as integer
    return this._linGrowth
end property

property PtrList.linearGrowth(value as integer)
    this._linGrowth = value
end property

property PtrList.expGrowth() as single
    return this._expGrowth
end property

property PtrList.expGrowth(value as single)
    this._expGrowth = value
end property