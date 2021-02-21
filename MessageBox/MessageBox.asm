.386
.model flat,stdcall
option casemap:none

include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\comctl32.lib

.data
MsgBoxCaption  db "Note",0
MsgBoxText       db "Hello My name is Mai Dac Viet",0

.code
start:
	
	push	MB_OK
	push	offset MsgBoxCaption
	push	offset MsgBoxText
	push	0
	call	MessageBox


	push 0
	call	ExitProcess

end start