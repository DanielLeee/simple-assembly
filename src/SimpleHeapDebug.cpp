#include <windows.h>

char shellcode[] = "\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90";

void main()
{
	HLOCAL h1 = 0, h2 = 0;
	HANDLE hp;
	hp = HeapCreate(0, 0x1000, 0x10000);
	h1 = HeapAlloc(hp, HEAP_ZERO_MEMORY, 200);
	__asm int 3
	memcpy(h1, shellcode, 0x200);
	h2 = HeapAlloc(hp, HEAP_ZERO_MEMORY, 8);

	return;
}