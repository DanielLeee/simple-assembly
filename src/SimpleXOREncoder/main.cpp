#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
using namespace std;

void encoder(char * inputFileName, char * outputFileName, unsigned char key)
{
	ifstream fin;
	ofstream fout;
	fin.open(inputFileName, ios::binary);
	fout.open(outputFileName, ios::binary);

	unsigned char ch;

	while (fin.read((char *)&ch, sizeof(unsigned char)))
	{
		ch ^= key;
		fout.write((char *)&ch, sizeof(unsigned char));
	}

	fin.close();
	fout.close();
	return;
}

int main()
{
	char * inputFileName = "input.txt";
	char * outputFileName = "output.txt";
	unsigned char key = 0x44;

	encoder(inputFileName, outputFileName, key);

	return 0;
}