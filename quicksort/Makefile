all: prog.asm
	nasm -felf64 prog.asm -o prog.o
	gcc prog.o -o prog
	gcc quicksort.c -o quicksort

clean:
	find -name "*~" -type f -exec rm -vf '{}' \;
