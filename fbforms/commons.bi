 
'// Created on 23-Mar-2025 14:43

dim CTLPOSFLAG as const DWORD = SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOZORDER
dim shared empty_str as string
dim shared CLR_WHITE as const integer = &hFFFFFF 
dim shared CLR_BLACK as const integer = &h000000 
'// This macro is useful to eliminate around 120 lines of code.
#macro __setControlMembers(ctType, cname)
	this._ctype = ctType
	this._cname = cast(LPCWSTR, @cname)
	this._parent = @parent    
    this._xpos = x 
    this._ypos = y  
    this._width = w  
    this._height = h      
    this._ctlID = appinfo._gCtlID	
	appinfo._gCtlID += 1    
#endmacro

' #macro __setCtlPos(c, x, y)
'     c.xpos = x 
'     c.ypos = y
'     SetWindowPos(c.handle, HWND_TOP, x, y, c.width, c.height, CTLPOSFLAG)
' #endmacro

' sub arrangeH(x as integer, y as integer, gap as integer, c1 as Control, c2 as Control, c3 as Control)
'     dim sx as integer = x 
'     dim sy as integer = y 
'     if c1.handle then __setCtlPos(c1, sx, sy)
'     sx += gap + c1.width
'     if c2.handle then __setCtlPos(c2, sx, sy)
'     sx += gap + c2.width
'     if c3.handle then __setCtlPos(c3, sx, sy)
' end sub

' #macro __arrangeX2(x, y, gap, args...)
'     scope
'         dim as double sp, ep
'         sp = Timer
'         dim sx as integer = x 
'         dim sy as integer = y 
'         #define count __FB_EVAL__( __FB_ARG_COUNT__(args) - 1)
'         dim as Control ptr arr(count) = {##args##}
'         ' dim params as string = trim(#args)
'         for i as integer = 0 to count
'             dim c as Control ptr = arr(i)
'             SetWindowPos(c->handle, HWND_TOP, sx, sy, c->width, c->height, CTLPOSFLAG)
'             sx += gap + c->width
'         next
'         ep = Timer - sp
'         print "duration****** "; (ep * 1000000) ; " micro seconds"
'     end scope
' #endmacro


sub arrangeCtlsX cdecl(x as integer, y as integer, gap as integer, count as integer, ...)
    Dim args As cva_list '' argument list object
    cva_start(args, count) '' constructor
    For i as integer = 0 To count - 1
        var c = cva_arg(args, Control ptr)
        SetWindowPos(c->handle, HWND_TOP, x, y, c->width, c->height, CTLPOSFLAG)
        x += gap + c->width
    Next
    cva_end(args) '' destructor
end sub

#macro __arrangeX(x, y, gap, args...)
        ' dim as double sp, ep
        ' sp = Timer
        arrangeCtlsX(x, y, gap, __FB_ARG_COUNT__(args), args)
        ' ep = Timer - sp
        ' print "duration****** "; (ep * 1000000) ; " micro seconds"
#endmacro

#define __setCtlPos(flag) SetWindowPos(this._handle, 0, this._xpos, this._ypos, this._width, this._height, flag)

function cpos(x as Control, y as Control) as POINT
    return type<POINT>((x.xpos + x.width + 10), (y.ypos + y.height + 10))
end function

' #macro __pos(x, y)
'     #if (typeof(x) = typeof(integer) )
'         type<POINT>(x, y)
'     #else
'         cpos(x, y)
'     #endif
' #endmacro


#define __comboCommandHandler(event) if self->event then self->event(self, gea)
            

sub _trackMouseMove(hw as HWND)
	dim tme as TRACKMOUSEEVENT
    tme.cbSize = sizeof(TRACKMOUSEEVENT)
    tme.dwFlags = TME_HOVER or TME_LEAVE
    tme.dwHoverTime = HOVER_DEFAULT
    tme.hwndTrack = hw
    TrackMouseEvent(@tme)   
end sub  

sub DateTime._init(st as SYSTEMTIME)
    this.year = st.wYear
    this.month = st.wMonth
    this.day = st.wDay
    this.hour = st.wHour
    this.minute = st.wMinute
    this.second = st.wSecond
    this.milliSeconds = st.wMilliseconds
    this.dayOfWeek = cast(WeekDays, st.wDayOfWeek)
end sub

function makeSYSTEMTIME(dt as DateTime) as SYSTEMTIME
    dim st as SYSTEMTIME
    st.wYear         = dt.year
    st.wMonth        = dt.month
    st.wDay          = dt.day
    st.wHour         = dt.hour
    st.wMinute       = dt.minute
    st.wSecond       = dt.second
    st.wMilliseconds = dt.milliSeconds
    st.wDayOfWeek    = cast(ushort, dt.dayOfWeek) '// cast back to original type, assuming WeekDays is an enum
    return st
end function




  


Sub splitString(ByVal source As String, destination(Any) As String, ByVal delimitor As UByte)
    Do
        Dim As Integer position = InStr(1, source, Chr(delimitor))
        ReDim Preserve destination(UBound(destination) + 1)
        If position = 0 Then
            destination(UBound(destination)) = source
            Exit Do
        End If
        destination(UBound(destination)) = Left(source, position - 1)
        source = Mid(source, position + 1)
    Loop
End Sub

#define __us16Tos32(v) cast(long, cast(short, (v and &hFFFF)))

sub getMousePos(pt as POINT ptr, lpm as LPARAM) 
    if lpm = 0 then
        GetCursorPos(pt)
    else
        pt->x = __us16Tos32(LOWORD(lpm))
        pt->y = __us16Tos32(HIWORD(lpm))
    end if 
end sub

	
 


