#include <stdio.h>
#include <windows.h>
#include <cstring>
#include <cstdlib>
#include <iostream>
#include <string>
using namespace std;

DWORD GetHash(char *fun_name)
{
	DWORD digest = 0;
	while (*fun_name)
	{
		digest = ((digest << 25) | (digest >> 7));
		digest += *fun_name;
		fun_name++;
	}
	return digest;
}

int main()
{
	DWORD hash;
	char funNameString[100];

	while (true)
	{

		cout << "Input the function name:" << endl;
		cin >> funNameString;

		if (funNameString[0] == '0') break;

		hash = GetHash(funNameString);


		printf("The hash of the function is 0x%02X\n", hash);

		system("pause");

	}

	return 0;
}