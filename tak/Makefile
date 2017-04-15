tak: prog.asm
	nasm -felf64 prog.asm -o tak.o
	gcc tak.o -o tak

clean:
	find -name "*~" -type f -exec rm -vf '{}' \;
