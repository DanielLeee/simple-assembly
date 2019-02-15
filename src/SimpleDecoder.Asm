.386
.model flat, stdcall
option casemap :none			; case sensitive

.data

assume fs:nothing
.code
main:
	add		eax, 014H
	xor		ecx, ecx
	
decode_loop:
	mov		bl, [eax + ecx]
	xor		bl, 044H
	mov		[eax + ecx], bl
	inc		ecx
	cmp		bl, 090H
	jne		decode_loop
	
end main