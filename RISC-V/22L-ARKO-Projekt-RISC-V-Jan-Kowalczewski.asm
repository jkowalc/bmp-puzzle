.eqv ImgInfo_fname	0
.eqv ImgInfo_hdrdat 	4
.eqv ImgInfo_imdat	8
.eqv ImgInfo_width	12
.eqv ImgInfo_height	16
.eqv ImgInfo_lbytes	20

.eqv MAX_IMG_SIZE 	230400

.eqv BMPHeader_Size 54
.eqv BMPHeader_width 18
.eqv BMPHeader_height 22


.eqv system_OpenFile	1024
.eqv system_ReadFile	63
.eqv system_WriteFile	64
.eqv system_CloseFile	57
.eqv system_RandIntRange 42

	.data
imgInfo: .space	24

	.align 2
dummy:		.space 2
bmpHeader:	.space	BMPHeader_Size

	.align 2
imgData: 	.space	MAX_IMG_SIZE

ifname:	.asciz "source.bmp"
ofname: .asciz "result.bmp"

n:		.word	3
m:		.word	4

	.text
main:
	la a0, imgInfo
	la t0, ifname
	sw t0, ImgInfo_fname(a0)
	la t0, bmpHeader
	sw t0, ImgInfo_hdrdat(a0)
	la t0, imgData
	sw t0, ImgInfo_imdat(a0)
	jal	read_bmp
	bnez a0, main_failure

	la a0, imgInfo
	lw a1, n
	lw a2, m
	jal spread_tiles

	la a0, imgInfo
	la t0, ofname
	sw t0, ImgInfo_fname(a0)
	jal save_bmp

main_failure:
	li a7, 10
	ecall

#============================================================================
# spread_tiles
# arguments:
# 	a0 - address of ImgInfo image descriptor
#	a1 - n parameter
#	a2 - m parameter
# return:
# 	none
spread_tiles:
	addi sp, sp, -4
	sw ra, 0(sp) # push ra
	mv s0, a0 # save a0 for later

	lw a3, ImgInfo_height(a0)
	bgt a1, a3, spread_tiles_exit
	div a3, a3, a1 # a3 - height of one puzzle in pixels

	lw t0, ImgInfo_width(a0)
	bgt a2, t0, spread_tiles_exit
	div t0, t0, a2
	add a4, t0, t0
	add a4, a4, t0 # a4 - width of one puzzle in bytes
	mv a5, a2
	li a7, system_RandIntRange
	mul a1, a1, a2
	addi a1, a1, -1

spread_tiles_loop:
	li a0, 0
	ecall
	mv a2, a0
	mv a0, s0
	jal exchange_puzzles
	addi a1, a1, -1
	bgt a1, zero, spread_tiles_loop


spread_tiles_exit:
	lw ra, 0(sp) # pop ra
	addi sp, sp, 8
	jr ra


#============================================================================
# exchange_puzzles
# arguments:
#	a0 - address of ImgInfo image descriptor
#	a1 - number of first puzzle
#	a2 - number of second puzzle
#	a3 - height of one puzzle in pixels
#	a4 - width of one puzzle in bytes
#	a5 - m parameter
# return value:
#	none
exchange_puzzles: # address = column * width_1_puzzle + row * height_1_puzzle * linebytes
	lw t5, ImgInfo_lbytes(a0)
	div t3, a1, a5 # t3 (row) = n // m
	mul t3, t3, a3 # t3 = height * row
	mul t3, t3, t5 # t3 = linebytes * height * row

	rem t4, a1, a5 # t4 (column) = n % m
	mul t4, t4, a4 # t4 = width_in_bytes * column
	add t0, t3, t4
	lw t3, ImgInfo_imdat(a0)
	add t0, t0, t3 # t0 - address of first pixel of first puzzle

	div t3, a2, a5 # t3 (row) = n // m
	mul t3, t3, a3 # t3 = height * row
	mul t3, t3, t5 # t3 = linebytes * height * row

	rem t4, a2, a5 # t4 (column) = n % m
	mul t4, t4, a4 # t4 = width_in_bytes * column
	add t1, t3, t4
	lw t3, ImgInfo_imdat(a0)
	add t1, t1, t3 # t1 - address of first pixel of second puzzle
	mv t3, a3
	mv t4, a4

# variables
# t0 - address of current pixel of first puzzle
# t1 - address of current pixel of second puzzle
# t3 - height counter (in pixels)
# t4 - width counter (in bytes)

exchange_line:
	mv t4, a4 # reset width counter

exchange_byte:
	lb t5, (t0)
	lb t6, (t1)
	sb t5, (t1)
	sb t6, (t0)

	addi t0, t0, 1 # update addresses
	addi t1, t1, 1

	addi t4, t4, -1 # update width counter
	bgt t4, zero, exchange_byte

	lw t5, ImgInfo_lbytes(a0)
	add t0, t0, t5 # update addresses
	add t1, t1, t5
	sub t0, t0, a4
	sub t1, t1, a4
	addi t3, t3, -1 # update height counter

	bgt t3, zero, exchange_line

exchange_puzzles_exit:
	jr ra

#============================================================================
# read_bmp:
#	reads the content of a bmp file into memory
# arguments:
#	a0 - address of image descriptor structure
#		input filename pointer, header and image buffers should be set
# return value:
#	a0 - 0 if successful, error code in other cases
read_bmp:
	mv t0, a0	# preserve imgInfo structure pointer

#open file
	li a7, system_OpenFile
    lw a0, ImgInfo_fname(t0)	#file name
    li a1, 0					#flags: 0-read file
    ecall

	blt a0, zero, rb_error
	mv t1, a0					# save file handle for the future

#read header
	li a7, system_ReadFile
	lw a1, ImgInfo_hdrdat(t0)
	li a2, BMPHeader_Size
	ecall

#extract image information from header
	lw a0, BMPHeader_width(a1)
	sw a0, ImgInfo_width(t0)

	# compute line size in bytes - bmp line has to be multiple of 4
	add a2, a0, a0
	add a0, a2, a0	# pixelbytes = width * 3
	addi a0, a0, 3
	srai a0, a0, 2
	slli a0, a0, 2	# linebytes = ((pixelbytes + 3) / 4 ) * 4
	sw a0, ImgInfo_lbytes(t0)

	lw a0, BMPHeader_height(a1)
	sw a0, ImgInfo_height(t0)

#read image data
	li a7, system_ReadFile
	mv a0, t1
	lw a1, ImgInfo_imdat(t0)
	li a2, MAX_IMG_SIZE
	ecall

#close file
	li a7, system_CloseFile
	mv a0, t1
    ecall

	mv a0, zero
	jr ra

rb_error:
	li a0, 1	# error opening file
	jr ra

# ============================================================================
# save_bmp - saves bmp file stored in memory to a file
# arguments:
#	a0 - address of ImgInfo structure containing description of the image`
# return value:
#	a0 - zero if successful, error code in other cases

save_bmp:
	mv t0, a0	# preserve imgInfo structure pointer

#open file
	li a7, system_OpenFile
    lw a0, ImgInfo_fname(t0)	#file name
    li a1, 1					#flags: 1-write file
    ecall

	blt a0, zero, wb_error
	mv t1, a0					# save file handle for the future

#write header
	li a7, system_WriteFile
	lw a1, ImgInfo_hdrdat(t0)
	li a2, BMPHeader_Size
	ecall

#write image data
	li a7, system_WriteFile
	mv a0, t1
	# compute image size (linebytes * height)
	lw a2, ImgInfo_lbytes(t0)
	lw a1, ImgInfo_height(t0)
	mul a2, a2, a1
	lw a1, ImgInfo_imdat(t0)
	ecall

#close file
	li a7, system_CloseFile
	mv a0, t1
    ecall

	mv a0, zero
	jr ra

wb_error:
	li a0, 2 # error writing file
	jr ra
