
'// Created on 21-Mar-2025 15:16

#include "fbforms\fbforms.bi"
using FbForms

print("Testing Okay 134...")

Const N = 500000
Const g = 76.9 
print "app.hins "; appinfo._hIns

Dim As Integer dummy =  0
sub clickForm(s as Control ptr, ea as MouseEventArgs)
	print "mea X: "; ea.xpos; ", Y: "; ea.ypos
	ea.handled = true
end sub
sub onclick(s as Control ptr, ea as EventArgs)
	'ea.cancel = true
	print "I am closing"
end sub

sub onFocus(s as Control ptr, ea as EventArgs)
	print "I got focus"
end sub
sub test() 
	var frm  = Form("My FBForms Window", 900, 550)
	frm.createHandle()
	frm.createChilds = true
	' frm.onLeftMouseDown = @clickForm
	' frm.onClosing = @onclick
	 
	var b1 = Button(frm, "Normal") 
	var b2 = Button(frm, "Flat Color", 10, 100, 120, 30) 
	var b3 = Button(frm, "Gradient", 10, 150, 120, 30)
	__arrangeX(10, 10, 10, @b1, @b2, @b3)
	 
	b2.backColor = &hAABBDD
	b3.setGradientColor(&hff9f1c, &hdddf00)

	var cal = Calendar(frm, 10, 55)
	var cb1 = CheckBox(frm, "Check Me", 10, 55)
	cb1.placeRightTo(cal)
	 
	
	var cmb = ComboBox(frm, cpos(cal, cb1) ) 'cal.rpos(90))
	__comboAddItems(cmb, "Windows", "MacOS", "Linux", "ReactOS", str(5))
	cmb.selectedIndex = 0
	cmb.addItem("Malayalam")

	var dtp = DateTimePicker(frm, cpos(cal, cmb))
	var gb1 = GroupBox(frm, "Compiler Options", 10, cal.bottom, 250) 
	gb1.foreColor = &h007f5f
	var lb1 = Label(frm, "Thread Count:", gb1.left(), gb1.top(30))
	var lbx = ListBox(frm, cal.right(40), dtp.bottom(10), 200, 250)
	__listBoxAddItems(lbx, "Windows", "MacOS", "Linux", "ReactOS")
	 

	var lv = ListView(frm, lbx.right(20), 10, 3, 300, 300)
	__listViewAddColumns(lv, false, "Windows", "Linux", "MacOS")
	__listViewAddRow(lv, "Windows11", "Debian", "Sequoia")
	frm.show() 
end sub       
test()   


print "successful run--------------"  
sleep     
 
