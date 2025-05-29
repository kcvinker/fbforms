'// Created on 02-Apr-2025 14:08


constructor WideString( ) 
	' print "wide string def ctor"
end	constructor	

constructor WideString(byref sValue as string, bprint as boolean = false)
	this._inputLen = len(sValue)
	this._inputStr = sValue 
	this._convertToUTF16()
	this._printMsg = bprint
	' print "wide string param ctor - str"
end constructor

constructor WideString(rhs as WideString ptr)
	this._inputLen = rhs->_inputLen
	this._inputStr = rhs->_inputStr
	this._wcharLen = rhs->_wcharLen
	this._bytes = rhs->_bytes
	this._data = allocate(this._bytes )	
	fb_memcopy(this._data, rhs->_data, this._bytes)
end constructor

sub WideString.init(byref sValue as string, bprint as boolean = false)
	this._inputLen = len(sValue)
	this._inputStr = sValue 
	this._convertToUTF16()
	this._printMsg = bprint
	' print "wide string init - str"
end sub
	
constructor WideString(nChars as integer)
	'// Allocate space only
	this._inputStr = "0"
	this._wcharLen = nChars
	this._bytes = (nChars + 1) * 2
	this._data = allocate(this._bytes)
end constructor

operator WideString.Let(byref rhs as WideString)
	this._inputLen = rhs._inputLen
	this._inputStr = rhs._inputStr
	if this._wcharLen > rhs._wcharLen then '// We have enough space in our buffer.
		fb_memcopy(this._data, rhs._data, rhs._bytes)
	else '// We need to free current buffer and allocate new space
		if this._data > 0 then deallocate(this._data)
		this._data = allocate(rhs._bytes)
		fb_memcopy(this._data, rhs._data, rhs._bytes)
	end if
	this._wcharLen = rhs._wcharLen
	this._bytes = rhs._bytes	
end operator

destructor WideString()	
	' print "Going to destroy "; this._inputStr
	' print "wide string data "; this._data
	if this._data <> NULL then 
		deallocate(this._data)
		this._data = 0
		' if this._printMsg then 
		print "WideString "; this._inputStr ; " destroyed" 
	end if
end destructor 


sub WideString._convertToUTF16()
	' print "_convertToUTF16 "; this._printMsg
	if this._printMsg then print "WideString is allocating for "; this._inputStr 
	if this._inputLen = 0 then 
		print("Empty string")
	else		 	
		var sp = strptr(this._inputStr)
		this._wcharLen = MultiByteToWideChar(CP_UTF8, 0, sp, this._inputLen, 0, 0)
		
		if this._wcharLen = 0 then 
			print("Empty string")
			exit sub
		end if   
		this._bytes = (this._wcharLen + 1) * 2		 
		this._data = allocate(this._bytes )
		MultiByteToWideChar(CP_UTF8, 0, sp, this._inputLen, this._data, this._wcharLen)
		this._data[this._wcharLen] = 0 		 
	end if	    
end sub       
  
const property WideString.constPtr() as LPCWSTR	
	return this._data 
end property 
const property WideString.dataPtr() as LPWSTR	
	return this._data
end property
const property WideString.byteLen() as const integer 
	return this._bytes 
end property 
const property WideString.wcharLen() as const integer 
	return this._wcharLen
end property

property WideString.strLen() as integer
	return this._inputLen
end property

property WideString.toStr() byref as string 
	this._buffer = string(this._wcharLen + 1, 0)
	dim slen as integer = WideCharToMultiByte(CP_UTF8, 0, this._data, this._wcharLen, 0, 0, 0, 0 )
	' print "slen "; slen
	slen = WideCharToMultiByte(CP_UTF8, 0, this._data, this._wcharLen, strptr(this._buffer), slen, 0, 0 )
	property =  this._buffer
end property 

static function WideString.getStr(pwchar as const ushort ptr, tlen as integer) as string	
	dim slen as integer = WideCharToMultiByte(CP_UTF8, 0, pwchar, tlen, 0, 0, 0, 0 )
	if slen > 0 then 
		dim sbuff as string = space(slen)
		WideCharToMultiByte(CP_UTF8, 0, pwchar, tlen, strptr(sbuff), slen, 0, 0 )
		return sbuff
	else
		return space(0)
	end if
end function

static sub WideString.fillBuffer(pwchar as ushort ptr, txt as string) 
	var sptr = strptr(txt)
	var slen = len(txt)
	dim wlen as integer = MultiByteToWideChar(CP_UTF8, 0, sptr, slen, 0, 0)
	if wlen > 0 then 
		MultiByteToWideChar(CP_UTF8, 0, sptr, slen, pwchar, wlen)
	end if
end sub

sub WideString.updateBuffer(byref txt as string)
	this._inputLen = len(txt)
	this._inputStr = txt
	if this._inputLen > 0 then
		var sptr = strptr(this._inputStr)
		dim wlen as integer = MultiByteToWideChar(CP_UTF8, 0, sptr, this._inputLen, 0, 0)
		if not this._wcharLen > wlen then '// We need to allocate new buffer
			deallocate(this._data)
			this._bytes = (wlen + 1) * 2		 
			this._data = allocate(this._bytes)
		end if
		MultiByteToWideChar(CP_UTF8, 0, sptr, this._inputLen, this._data, wlen)
		this._data[wlen] = 0
		this._wcharLen = wlen
	end if
end sub


sub WideString.ensureSize(charCount as integer)
	if charCount < 1 then exit sub 
	if this._wcharLen < charCount then 
		deallocate(this._data)
		this._bytes = (charCount + 1) * 2
		this._wcharLen = charCount		 
		this._data = allocate(this._bytes)
	end if
end sub 