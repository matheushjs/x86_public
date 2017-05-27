all: hashTable prog

prog: hashTable.c
	gcc -Wall -O3 -Wno-unused-result hashTable.c -o prog

hashTable: hashTable.asm
	nasm -felf64 hashTable.asm -o hashTable.o
	gcc hashTable.o -o hashTable

clean:
	find -name "*~" -type f -exec rm -vf '{}' \;
