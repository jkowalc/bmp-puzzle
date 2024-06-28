CC=gcc
CFLAGS=-m32 -Wall -g

all:	create_dir cc_img cc_main asm add clean
build:	create_dir cc_img cc_main asm add
create_dir:
		mkdir -p dist
add:
		$(CC) $(CFLAGS) dist/main.o dist/spread_tiles.o dist/image.o -o dist/main

cc_img:	src/image.c src/image.h
		$(CC) $(CFLAGS) -c src/image.c -o dist/image.o

cc_main:		src/main.c
		$(CC) $(CFLAGS) -c src/main.c -o dist/main.o

asm:	src/spread_tiles.asm
		nasm -f elf src/spread_tiles.asm -o dist/spread_tiles.o

clean:
	rm -f dist/*.o