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
	ClassName		db		"SimpleWindow",0
	AppName		db		"Simple Window",0

.data?
	hInstance		HINSTANCE		?
	CommandLine	LPSTR		?
	wc			WNDCLASSEX	<?>
	msg			MSG			<?>
	hwnd			HWND			?

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

	;set up wc
	mov	wc.cbSize, SIZEOF WNDCLASSEX
	mov	wc.style, CS_HREDRAW or CS_VREDRAW
	mov	wc.lpfnWndProc, OFFSET WndProc
	mov	wc.cbClsExtra,NULL
	mov  wc.cbWndExtra,NULL
	push	hInstance
	pop	wc.hInstance
	mov	wc.hbrBackground,COLOR_WINDOW+1
	mov	wc.lpszMenuName,NULL
	mov  wc.lpszClassName, OFFSET ClassName
	
	;set up Icon
	push	IDI_APPLICATION
	push NULL
	call	LoadIcon
	mov	wc.hIcon,eax
	mov	wc.hIconSm,eax
	
	;set up Cusor
	push	IDC_ARROW
	push NULL
	call	LoadCursor
	mov	wc.hCursor,eax

	lea	eax,wc
	push	eax
	call	RegisterClassEx		; register our window class

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

	@endE:
        push MB_OK
        push 0
        push 0
        push 0
        call MessageBox
        ret

WinMain endp

;WndProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
WndProc proc  hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

	cmp		uMsg,WM_DESTROY
	je		window_destroy
	
	push lParam
	push wParam
	push uMsg
	push hWnd
	call 	DefWindowProc
	ret

	window_destroy:
	push		NULL
	call		PostQuitMessage
	xor		eax,eax
	ret

WndProc endp

end start