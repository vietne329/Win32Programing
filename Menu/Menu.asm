.386
.model flat,stdcall
option casemap:none

include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\gdi32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\gdi32.lib

.data
	msgEr		db		"Error",0
	class_name	db		"Simple Window",0
	win_name		db		"Reverse Text",0
	menu_name		db		"MyMenu",0
	Test_string	db		"You selected Test menu item",0
	Hello_string	db		"Hello,my friend",0
	Goodbye_string db		"See you again, bye",0

.data?
	hInstance		HINSTANCE		?
	CommandLine	LPSTR		?
	wc			WNDCLASSEX	<?>
	msg			MSG			<?>
	hwnd			HWND			?
	
 
.const
	IDM_TEST		equ  1
	IDM_HELLO		equ	2
	IDM_GOODBYE	equ	3
	IDM_EXIT		equ	4



.code
start:
	push		0
	call		GetModuleHandle
	mov		hInstance,eax

	call		GetCommandLine
	mov		CommandLine,eax

	push		SW_SHOWDEFAULT
	push		CommandLine
	push		0
	push		hInstance
	call		WinMain

	xor		eax,eax
	ret

WinMain proc
	mov   wc.cbSize,SIZEOF WNDCLASSEX
     mov   wc.style, CS_HREDRAW or CS_VREDRAW
     mov   wc.lpfnWndProc, OFFSET WndProc
     mov   wc.cbClsExtra,NULL
     mov   wc.cbWndExtra,NULL
     push  hInstance
     pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,OFFSET menu_name       ; Put our menu name here
     mov   wc.lpszClassName,OFFSET class_name

	push	 IDI_APPLICATION
	push	 0
	call	 LoadIcon
	mov	 wc.hIcon,eax
     mov   wc.hIconSm,eax
     
	push	 IDC_ARROW
	push	 0
	call	 LoadCursor
	mov   wc.hCursor,eax
	
	push	 offset wc
	call	 RegisterClassEx

	;Define a variable of type HMENU to store our menu handle.
	;push	 offset menu_name
	;push	 hInstance
	;call  LoadMenu
    ; mov    hMenu,eax

	push	 0
	push	 hInstance
	push  0
     push  0
	push	 CW_USEDEFAULT
	push	 CW_USEDEFAULT
	push	 CW_USEDEFAULT
	push	 CW_USEDEFAULT
	push	 WS_OVERLAPPEDWINDOW
	push	 offset win_name
	push  offset class_name
	push	 0
	call	 CreateWindowEx
	mov	 hwnd,eax
	push	 SW_SHOWNORMAL
	push  hwnd
	call  ShowWindow

	push	 hwnd
	call  UpdateWindow
	
	infinite_loop:
	
	push	0
	push 0
	push 0
	lea	eax,msg
	push	eax
	call	GetMessage

	or	eax,eax
	jz   break_infinite_loop

	lea	eax,msg
	push	eax
	call TranslateMessage

	lea	eax,msg
	push	eax
	call DispatchMessage
	jmp infinite_loop

	break_infinite_loop:
	mov eax,msg.wParam
	ret	

	
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	cmp	uMsg,WM_DESTROY
	je	window_destroy

	cmp	uMsg,WM_COMMAND
	je	window_command

	push	lParam
	push	wParam
	push	uMsg
	push	hWnd
	call	DefWindowProc
	ret

	window_destroy:
	push		0
	call		PostQuitMessage
	jmp		window_finish

	window_command:
	mov		eax,wParam
	cmp		ax,IDM_TEST
	je		idm_test
	
	cmp		ax,IDM_HELLO
	je		idm_hello

	cmp		ax,IDM_GOODBYE
	je		idm_goodbye

	push	lParam
	push	wParam
	push	uMsg
	push	hWnd
	call	DefWindowProc
	ret
	
	idm_test:
	push		MB_OK
	push		offset win_name
	push		offset Test_string
	push		0
	call		MessageBox
	jmp		window_finish
	
	idm_hello:
	push		MB_OK
	push		offset win_name
	push		offset Hello_string
	push		0
	call		MessageBox
	jmp		window_finish
	
	idm_goodbye:
	push		MB_OK
	push		offset win_name
	push		offset Goodbye_string
	push		0
	call		MessageBox
	jmp		window_finish

	window_finish:
	xor		eax,eax
	ret
WndProc endp
end start