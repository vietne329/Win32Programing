.386
.model flat, stdcall
option casemap:none


include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib

.data
	class_name		db		"SimpleWindow",0
	app_name			db		"ParentWindow",0
	menu_name			db		"menu",0
	button_class_name	db		"button",0
	button_text		db		"Press Me!",0
	edit_class_name	db		"edit",0
	test_string		db		"Wow! i'm in edit box now!",0

.data?
	hInstance			HINSTANCE		?
	CommandLine		LPSTR		?
	hwndButton		HWND			?
	hwndEdit			HWND			?
	buffer			db			512	dup(?)

	hwnd				HWND			?
	msg				MSG			<?>
	wc				WNDCLASSEX	<?>

.const
	ButtonID			equ		1
	EditID			equ		2
	IDM_HELLO			equ		1
	IDM_CLEAR			equ		2
	IDM_GETTEXT		equ		3
	IDM_EXIT			equ		4

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
	push		eax
	call		ExitProcess

WinMain proc
	mov   wc.cbSize,SIZEOF WNDCLASSEX
     mov   wc.style, CS_HREDRAW or CS_VREDRAW
     mov   wc.lpfnWndProc, OFFSET WndProc
     mov   wc.cbClsExtra,NULL
     mov   wc.cbWndExtra,NULL
     push  hInstance
     pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_BTNFACE+1
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

	push	0
	push	hInstance
	push	0
	push	0
	push	200
	push	300
	push	CW_USEDEFAULT
	push	CW_USEDEFAULT
	push	WS_OVERLAPPEDWINDOW
	push	offset app_name
	push	offset class_name
	push	WS_EX_CLIENTEDGE
	call	CreateWindowEx
	mov	hwnd,eax

	push	SW_SHOWNORMAL
	push	hwnd
	call	ShowWindow

	push	hwnd
	call	UpdateWindow

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

	cmp	uMsg,WM_CREATE
	je	window_create

	cmp	uMsg,WM_COMMAND
	je	window_command

	push	lParam
	push	wParam
	push	uMsg
	push	hWnd
	call	DefWindowProc
	ret

	window_create:
		push	0
		push	hInstance
		push	8
		push hWnd
		push	25
		push	200
		push 35
		push 50
		push WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL
		push 0
		push offset edit_class_name
		push WS_EX_CLIENTEDGE
		call CreateWindowEx

		mov hwndEdit,eax

		push 0
		push hInstance
		push ButtonID
		push	hWnd
		push 25
		push 140
		push 70
		push 75
		push WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON
		push offset button_text
		push offset button_class_name
		push 0
		call CreateWindowEx
		mov	hwndButton,eax
		ret

	;child window control sends notification to its parent window with WM_COMMAND.
	;The child window sends WM_COMMAND messages to the parent window with its control ID,
	; the notification code in the high word of wParam, and its window handle in lParam
	; in the low word of wParam
	window_command:
		mov	eax,wParam
		cmp  lParam,0
		jne  lparam_not_equal_0

		cmp  ax,IDM_HELLO
		je	idm_hello
		cmp  ax,IDM_CLEAR
		je	idm_clear
		cmp ax,IDM_GETTEXT
		je	idm_gettext

		push hWnd
		call DestroyWindow
		ret


		idm_hello:
		push	offset test_string
		push hwndEdit
		call	SetWindowText
		ret

		idm_clear:
		push	0
		push hwndEdit
		call	SetWindowText
		ret

		idm_gettext:
		push	512
		push	offset buffer
		push hwndEdit
		call	GetWindowText

		push MB_OK
		push offset app_name
		push offset buffer
		push 0
		call MessageBox
		ret

		lparam_not_equal_0:
		cmp ax,ButtonID
		je	continue_exe
		ret

		continue_exe:
		shr eax,16
		cmp ax,BN_CLICKED
		je	clicked
		ret

		clicked:
		push	0
		push IDM_GETTEXT
		push WM_COMMAND
		push hWnd
		call SendMessage
		ret

	window_destroy:
	push		0
	call		PostQuitMessage
	jmp		window_finish

	window_finish:
	xor		eax,eax
	ret

WndProc endp

end start