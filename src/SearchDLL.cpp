#include <windows.h>
#include <stdio.h>
#define DLL_NAME "user32.dll"

int main()
{
	BYTE *ptr;
	int position;
	HINSTANCE handle;
	BOOL done_flag = FALSE;
	handle = LoadLibrary(DLL_NAME);

	if (!handle)
	{
		printf("load dll error!");
		return 1;
	}

	ptr = (BYTE *)handle;

	/*   typedef int (WINAPI *MSGBOX)(HWND,LPSTR,LPSTR,UINT);

	MSGBOX messagebox = (MSGBOX) GetProcAddress(handle, "MessageBoxA" );

	printf("MessageBox GetProcAddress:%p\n", MessageBoxA);*/


	for (position = 0; !done_flag; position++)
	{
		int address = (int)ptr + position;

		try
		{
			printf("Base address at 0x%x\n", address);
			done_flag = TRUE;

			/*if(ptr[position] == 0xFF && ptr[position + 1] == 0xE4)
			{
			// 0xFFE4 is the opcode for jmp esp

			printf("OPCODE found at 0x%x\n", address);
			done_flag = TRUE;
			}*/

		}
		catch (...)
		{
			printf("ERROR or END  0x%x\n", address);
			done_flag = TRUE;
		}

	}

	system("pause");

	return 0;
}
