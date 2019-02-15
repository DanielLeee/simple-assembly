.386
.model flat, stdcall
option casemap :none			; case sensitive

.data

assume fs:nothing
.code
main:
	CLD							;clear flag DF
	
	;store hash
	push	01E380A6AH			;hash of MessageBoxA
	push	04FD18963H			;hash of ExitProcess
	push	00C917432H			;hash of LoadLibraryA
	mov		esi, esp			;esi = addr of first function hash
	lea		edi, [esi-0CH]		;edi = addr to start writing function

	;make some stack space
	xor		ebx, ebx
	mov		bh, 04H
	sub		esp, ebx
	
	;push a pointer to "user32" onto stack
	mov		bx, 03233H
	push	ebx
	push	072657375H
	push	esp

	;find base addr of kernel32.dll
	xor		edx, edx			;edx = 0
	mov		ebx, fs:[edx+000000030H]	;ebx = addr of PEB
	mov		ecx, [ebx+0CH]		;ecx = pointer to loader data
	mov		ecx, [ecx+01CH]		;ecx = first entry in initialization order list
	mov		ecx, [ecx]			
	;mov		ecx, [ecx]			;ecx = third entry in list (kernel32.dll) ?
	mov		ebp, [ecx+08h]		;ebp = base addr of kernel32.dll
	
find_lib_functions:
	lodsd
	cmp		eax, 01E380A6AH		;compare to hash of MessageBoxA
	jne		find_functions
	xchg	eax, ebp
	call	DWORD PTR [edi-08H]	;LoadLibraryA("user32.dll")
	xchg	eax, ebp
	
find_functions:
	pushad						;preserve registers
	mov		eax, [ebp+03CH]		;eax = start of PE header    (offset in a file)
	mov		ecx, [ebp+eax+078H]	;ecx = relative offset of export table
	add		ecx, ebp			;ecx = absolute addr of export table
	mov		ebx, [ecx+020H]		;ebx = relative offset of names table
	add		ebx, ebp			;ebx = absolute addr of names table
	xor		edi, edi			;edi will count through the functions
	dec		edi
	
next_function_loop:
	inc		edi
	mov		esi, [ebx + edi*4]	;esi = relative offset of current function name
	add		esi, ebp			;esi = absolute addr of current function name
	cdq
	
hash_loop:
	movsx	eax, byte ptr[esi]
	cmp		al, ah
	jz		compare_hash
	ror		edx, 7
	add		edx, eax
	inc		esi
	jmp		hash_loop
	
compare_hash:
	cmp		edx, [esp+01CH]		;compare to the requested hash EAX reg
	jnz		next_function_loop
	mov		ebx, [ecx+024H]		;ebx = relative offset of ordinals table
	add		ebx, ebp			;ebx = absolute offset of ordinals table
	mov		di, [ebx+edi*2]		;di = ordinal number of matched function
	mov		ebx, [ecx + 01CH]	;ebx = relative offset of address table
	add		ebx, ebp			;ebx = absolute offset of address table
	add		ebp, [ebx + edi*4]	;the address of matched function
	xchg	eax, ebp			;mov func addr into eax
	pop		edi					;edi is the last onto stack in pushad
	stosd						;write function addr to [edi] and increment edi
	push	edi
	popad
	
	cmp		eax, 01E380A6AH
	jne		find_lib_functions
	
function_call:
	xor		ebx,ebx
	push	ebx					;cut string
	push	074736577H
	push	06C696166H			;push failwest
	mov		eax, esp			;eax = addr of string failwest
	push	ebx
	push	eax
	push	eax
	push	ebx
	call	DWORD PTR [edi-04H]	;call MessageBoxA
	push	ebx
	call	DWORD PTR [edi-08H]	;call ExitProcess
	nop
	nop
	nop
	nop
	
end main