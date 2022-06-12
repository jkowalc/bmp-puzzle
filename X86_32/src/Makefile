CC=gcc
CFLAGS=-m32 -Wall

all:	cc asm
		$(CC) $(CFLAGS) main.o spread_tiles.o -o main

cc:		main.c
		$(CC) $(CFLAGS) -c main.c -o main.o

asm:	spread_tiles.asm
		nasm -f elf spread_tiles.asm

clean:
	rm -f *.o
	rm main