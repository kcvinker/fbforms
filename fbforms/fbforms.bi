 '// Created on 23-Mar-2025 14:55

#define UNICODE
#Include Once "windows.bi" 
#Include Once "win\commctrl.bi" 
#include once "/crt/wchar.bi"


Namespace FbForms
#define __declare_static_wndproc(_proc) declare static function _proc(hwnd As HWND, umsg As UINT, wpm As WPARAM, lpm As LPARAM, uidsub As UINT_PTR, dwref As DWORD_PTR ) As LRESULT
#include once "collections.bi"
#include once "types.bi"

dim shared appinfo as AppData '// This global variable should be available in all modules
dim shared CMBINFOLS as const integer = 3
dim shared fbfClsName(14) as ushort => {70, 66, 70, 111, 114, 109, 115, 87, 105, 110, 100, 111, 119, 0} 'wstr("FBFormsWindow") 
' declare function mainWndProc(hw As HWND, uMsg As UINT, wp As WPARAM, lp As LPARAM) As LRESULT


#include once "graphics.bi"
#include once "font.bi"
#include once "widestring.bi"
#include once "color.bi"
#include once "commons.bi"
#include once "events.bi"
#include once "control.bi"
#include once "form.bi" 
#include once "button.bi"
#include once "calendar.bi"
#include once "checkbox.bi"
#include once "combobox.bi"
#include once "dtp.bi"
#include once "groupbox.bi"
#include once "label.bi"
#include once "listbox.bi"
#include once "listview.bi"




#inclib "Shcore"  
extern "Windows"
	declare function GetScaleFactorForDevice (byval dtype as integer) as integer
end extern
  
private sub getSysDPI()
	dim _hdc as HDC = GetDC(0) 
	appinfo._sysDPI = GetDeviceCaps(_hdc, LOGPIXELSY)
	ReleaseDC(0, _hdc)
end sub  
 
private sub registerWinClass()
	dim wc as WNDCLASSEXW
	wc.cbSize = sizeof(WNDCLASSEXW) 
	wc.style = CS_OWNDC or CS_HREDRAW or  CS_VREDRAW  
	wc.lpfnWndProc = @Form._wndProc
	wc.cbClsExtra = 0
	wc.cbWndExtra = 0
	wc.hInstance = appinfo._hIns
	wc.hIcon = LoadIcon(0, IDI_APPLICATION) 
	wc.hCursor = LoadCursor(0, IDC_ARROW)
	wc.hbrBackground = CreateSolidBrush(appinfo._defWinColor._cref)  
	'wc.lpszMenuName = (Lpcwstr)0; 
	wc.lpszClassName = cast(LPCWSTR, @fbfClsName(0)) 
	dim res as ATOM = RegisterClassExW(@wc) 
	
end sub 

'// Module constructor. We want to initialize some stuff here.
sub fbformsInitialize() constructor 
	print "FbForms initialized"
	appinfo._hIns = GetModuleHandleW(0)
	appinfo._screenWidth = GetSystemMetrics(0)
	appinfo._screenHeight = GetSystemMetrics(1)
	appinfo._scaleFactor = GetScaleFactorForDevice(0)
	appinfo._defWinColor = RgbColor(240, 240, 240) 'getColorRef(240, 240, 240) 
	appinfo._gCtlID = 100
	appinfo._gSubClsID = 1000
	getSysDPI()
 	registerWinClass()
	appinfo._sendMsgBuffer = new WideString(64)
end sub

sub fbformsFinalize() destructor
	if appinfo._lvItemBuffer > 0 then 
		delete appinfo._lvItemBuffer
	end if
	delete appinfo._sendMsgBuffer
end sub
 


 end Namespace
