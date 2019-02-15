#include <windows.h>

int main()
{
	HINSTANCE LibHandle;
	char dllbuf[11] = "user32.dll";
	LibHandle = LoadLibrary(dllbuf);
	__asm{
			sub sp, 0x440
			xor ebx, ebx
			push ebx
			push 0x74736577
			push 0x6C696166

			mov eax, esp
			push ebx
			push eax
			push eax
			push ebx

			mov eax, 0x769ED000
			call eax

			push ebx
			mov eax, 0x76EFEF50
			call eax
	}

}
