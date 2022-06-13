CC=gcc
CFLAGS=-m32 -Wall

all:	cc_img cc asm add clean

add:
		$(CC) $(CFLAGS) main.o spread_tiles.o image.o -o main

cc_img:	image.c image.h
		$(CC) $(CFLAGS) -c image.c -o image.o

cc:		main.c
		$(CC) $(CFLAGS) -c main.c -o main.o

asm:	spread_tiles.asm
		nasm -f elf spread_tiles.asm

clean:
	rm -f *.o