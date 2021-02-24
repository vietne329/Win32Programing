.386
.model flat, stdcall
option casemap:none

include C:\masm32\include\windows.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\gdi32.inc
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\gdi32.lib

.data
	class_name	db	"SimpleWindow",0
	win_name		db	"Reverse Text",0

	buffer		db	1000 dup (0)
	class_in		db	"edit",0
	class_out		db	"static",0

.data?
	hInstance		HINSTANCE		?
	CommandLine	LPSTR		?
	wc			WNDCLASSEX	<?>
	msg			MSG			<?>

	hwnd_parent			HWND			?
	hwnd_in				HWND			?
	hwnd_out				HWND			?

.const
	IDM_in		equ		1
	IDM_out		equ		2

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
	mov   wc.cbSize, SIZEOF WNDCLASSEX
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra, 0
	mov   wc.cbWndExtra, 0

	push  hInstance
	pop   wc.hInstance
	
	mov   wc.hbrBackground, COLOR_WINDOW + 1
	mov   wc.lpszMenuName, 0
	mov   wc.lpszClassName, OFFSET class_name

	push IDI_APPLICATION
	push 0
	call LoadIcon

	mov   wc.hIcon, eax
	mov   wc.hIconSm, eax

	push IDC_ARROW
	push 0
	call LoadCursor
	mov  wc.hCursor, eax

	lea ecx, wc
	push ecx
	call RegisterClassEx

	push 0                          ;lpParam
     push hInstance                      ;handle instance of the module to be associated with the window.
	push 0                                ;hMenu: hande to a menu  -> child-window indentifier
     push 0                                 ;handle to the parent or owner window
     push 300    
     push 800                                ; nwith  
     push 200                                ;y upper-left conner
     push 300                                ;x upper-left conner
     push WS_OVERLAPPEDWINDOW or WS_THICKFRAME           ;win style
     push offset win_name
     push offset class_name
     push 0                              ;extend window style
     call CreateWindowEx
	mov hwnd_parent, eax

	;create input box
     push 0                            ;lpParam
     push hInstance                        ;handle instance of the module to be associated with the window.
	push IDM_in                       ;hMenu: hande to a menu  -> child-window indentifier
     push hwnd_parent                       ;handle to the parent or owner window
     push 50    
     push 760                           ; nwith  
     push 50                            ;y upper-left conner
     push 20                            ;x upper-left conner
     push WS_CHILD or WS_VISIBLE or WS_BORDER or ES_AUTOHSCROLL            ;win style
     push 0
     push offset class_in
     push WS_EX_CLIENTEDGE                              ;extend window style
     call CreateWindowEx

     mov hwnd_in, eax

	push 0                                 ;lpParam
     push hInstance                             ;handle instance of the module to be associated with the window.
	push IDM_out                           ;hMenu: hande to a menu  -> child-window indentifier
     push hwnd_parent                           ;handle to the parent or owner window
     push 50   
     push 760                                ; nwith  
     push 150                                 ;y upper-left conner
     push 20                                 ;x upper-left conner
     push WS_CHILD or WS_VISIBLE or WS_BORDER or ES_AUTOHSCROLL            ;win style
     push 0
     push offset class_out
     push WS_EX_CLIENTEDGE                              ;extend window style
     call CreateWindowEx

     mov hwnd_out,eax

	push SW_SHOWDEFAULT
	push hwnd_parent
	call ShowWindow

	push hwnd_parent
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
	je	exit_proc

	cmp uMsg,WM_COMMAND
     je window_command

	push lParam
	push wParam
	push uMsg
	push hWnd
	call DefWindowProc					;default message processing
		
	ret

	window_command:
	mov	eax,wParam
	cmp	ax,IDM_in
	jne	@return

	;get input text
	push 1000
	push offset buffer
	push	hwnd_in
	call GetWindowText

	  mov esi, offset buffer
       call reverseText

	push offset buffer
	push hwnd_out
	call SetWindowText
	ret

	exit_proc:
	push 0
	call PostQuitMessage				;quit application
	xor	eax,eax

	@return:
	ret
WndProc endp


reverseText proc 

        mov	edi,esi
        xor	eax,eax
        dec	edi

@end_text:
        inc	edi
        mov	al, byte ptr [edi]
        or	al,al
        jnz	@end_text
        dec	edi                                                 ;edi points to end char (not null) of text
        
@swap:
        cmp	esi,edi
        jge	@fi

        mov	al, byte ptr [edi]
        xchg	al, byte ptr [esi]
        mov	byte ptr [edi],al

        inc	esi
        dec	edi
        jmp	@swap
@fi:
        ret

reverseText endp

end start