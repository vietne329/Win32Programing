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

RGB macro red,green,blue
	xor eax,eax
	mov	ah,blue
	shl	eax,8
	mov	ah,green
	mov	al,red
endm

.data
	ClassName		db		"PaintingWithRBG",0
	AppName		db		"Painting2",0
	TestString	db		"She is a beautiful girl, i love her!",0
	len_TestString	equ		$-TestString
	FontName		db		"script",0

.data
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

	@endE:
        push MB_OK
        push 0
        push 0
        push 0
        call MessageBox
        ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL hdc:HDC
    LOCAL ps:PAINTSTRUCT
    LOCAL hfont:HFONT

    cmp	uMsg,WM_DESTROY
    je	window_destroy
    cmp	uMsg,WM_PAINT
    je	window_painting
   
    push lParam
    push wParam
    push uMsg
    push hWnd
    call DefWindowProc					;default message processing
    ret

    window_painting:
    lea	eax,ps
    push	eax
    push	hWnd
    call	BeginPaint
    mov	hdc,eax
    
    lea	eax,FontName
    push	eax
    push	FF_SCRIPT or DEFAULT_PITCH
    push	DEFAULT_QUALITY
    push	CLIP_DEFAULT_PRECIS
    push	OUT_DEFAULT_PRECIS
    push	OEM_CHARSET
    push	0
    push	0
    push	0
    push	FW_MEDIUM
    push	0
    push	0
    push	15
    push	30
    call	CreateFont

    push	eax
    push	hdc
    call	SelectObject
    mov	hfont,eax
    RGB   255,0,0
    push	eax
    push	hdc
    call	SetTextColor
    RGB	0,0,255
    push	eax
    push	hdc
    call	SetBkColor

    push	dword ptr[len_TestString]
    lea	eax,TestString
    push	eax
    push	0
    push	0
    push	hdc
    call	TextOut
    
    push	hfont
    push	hdc
    call	SelectObject

    lea	eax,ps
    push	eax
    push	hWnd
    call	EndPaint
    ret

    window_destroy:
    push	0
    call	PostQuitMessage
    xor   eax,eax
    ret

WndProc endp


end start