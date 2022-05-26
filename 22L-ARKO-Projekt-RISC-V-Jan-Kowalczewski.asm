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

	.data
imgInfo: .space	24

	.align 2
dummy:		.space 2
bmpHeader:	.space	BMPHeader_Size

	.align 2
imgData: 	.space	MAX_IMG_SIZE

ifname:	.asciz "source.bmp"
ofname: .asciz "result.bmp"

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
# return:
# 	none
spread_tiles:
	addi sp, sp, -4
	sw ra, 0(sp) # push ra

spread_tiles_exit:
	lw ra, 0(sp) # pop ra
	addi sp, sp, 8
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
