CC=gcc
CFLAGS=-Wall -g

all:	cc_img cc_main asm add clean
add:
		$(CC) $(CFLAGS) main.o spread_tiles.o image.o -o main

cc_img:	image.c image.h
		$(CC) $(CFLAGS) -c image.c -o image.o

cc_main:		main.c
		$(CC) $(CFLAGS) -c main.c -o main.o

asm:	spread_tiles.asm
		nasm -f elf64 spread_tiles.asm

clean:
	rm -f *.o