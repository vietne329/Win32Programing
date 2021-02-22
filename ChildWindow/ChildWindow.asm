.386
.model flat, stdcall
option casemap:none


include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib

.data
	ClassName			db	"ParentWindow",0
	AppName			db	"Parent Window",0
	MenuName			db	"FirstMenu",0
	ButtonClassName	db	"button",0
	ButtonText		db	"Press Me!",0
	EditClassName		db	"edit",0
	TestString		db	"Wow! i'm an edit box now.",0

.data?
	hInstance		HINSTANCE		?
	CommandLine	LPSTR		?
	hwndButton	HWND			?
	hwndEdit		HWND			?
	buffer		db			1000	DUP (?)

	hwnd			HWND			?
	msg			MSG			<?>
	wc			WNDCLASSEX	<?>

.const
	ButtonID		equ		1		;The control ID of the button control
	EditID		equ		2		;The control ID of the edit control
	IDM_HELLO		equ		1
	IDM_CLEAR		equ		2
	IDM_GETTEXT	equ		3
	IDM_EXIT		equ		4

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
	mov		wc.cbSize, SIZEOF WNDCLASSEX
	mov		wc.style, CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc, OFFSET WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	push		hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_WINDOW+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,OFFSET ClassName

	push		IDI_APPLICATION
	push		NULL
	call		LoadIcon
	mov		wc.hIcon,eax
	mov       wc.hIconSm,eax

	push		IDC_ARROW
	push		NULL
	call		LoadCursor
	mov		wc.hCursor,eax

	lea		eax,wc
	push		eax
	call		RegisterClassEx

	;createWindow
	push	NULL
	push hInstance
	push NULL
	push NULL
	push CW_USEDEFAULT
	push CW_USEDEFAULT
	push CW_USEDEFAULT
	push CW_USEDEFAULT
	push WS_OVERLAPPEDWINDOW
	push	offset AppName
	push	offset ClassName
	push NULL
	call CreateWindowEx
	mov	hwnd,eax

	;display window on screen
	push SW_SHOWDEFAULT
	push hwnd
	call ShowWindow	

	;refresh the client area
	push hwnd
	call UpdateWindow

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
	push		0
	push		hInstance
	push		8
	push		hWnd
	push		25
	push		200
	push		35
	push		50
	push		WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL
	push      0
	push		offset EditClassName
	push		WS_EX_CLIENTEDGE
	call		CreateWindowEx
	mov		hwndButton,eax

	push		hwndEdit
	call		SetFocus
	
	push		0
	push		hInstance
	push		ButtonID
	push		hWnd
	push		25
	push		140
	push		70
	push		75
	push		WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON
	push      offset ButtonText
	push		offset ButtonClassName
	push		0
	call		CreateWindowEx
	mov		hwndButton,eax
	ret

	window_command:
	mov		eax,wParam
	cmp		lParam,0
	jne		continue_exe
	
	cmp	ax,IDM_HELLO
		je	idm_hello
		cmp	ax,IDM_CLEAR
		je	idm_clear
		cmp	ax,IDM_GETTEXT
		
		push	hWnd
		call	DestroyWindow

		idm_hello:
		push	offset TestString
		push	hwndEdit
		call	SetWindowText
		ret

	continue_exe:
	cmp		ax,ButtonID
	je		buttonId

	buttonId:
	shr		eax,16
	cmp		ax,BN_CLICKED
	je		exe_click
	exe_click:
	push		0
	push		IDM_GETTEXT
	push		WM_COMMAND
	push		hWnd
	call		SendMessage
	ret

	
		

		idm_clear:
		push	0
		push	hwndEdit
		call	SetWindowText
		ret

		idm_gettext:
		push	1000
		push	offset buffer
		push	0
		call	MessageBox
		ret

	window_destroy:
	push		0
	call		PostQuitMessage
	xor		eax,eax
	ret
	
WndProc endp

end start