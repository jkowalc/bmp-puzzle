section .text
global spread_tiles
extern rand
;============================================================================
; ImgInfo structure (if in ecx)
;   [ecx] - width
;   [ecx+4] - height
;   [ecx+8] - linebytes
;   [ecx+12] - pImg
;============================================================================
; spread_tiles
; arguments:
; 	rdi - address of ImgInfo descriptor
;	rsi - n parameter (32bit int)
;	rdx - m parameter (32bit int)
; return:
; 	none
spread_tiles:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi ; save ImgInfo address for exchange_puzzles
    mov r13d, edx ; save m for exchange_puzzles

    mov eax, [rdi] ; load width
    cmp edx, eax
    jg spread_tiles_exit ; if m > width exit (not allowed)
    xor edx, edx ; edx = 0
    div r13d ; width // m
    lea eax, [eax + 2*eax] ; eax = 3 * (width // m)
    mov r14d, eax ; save width for exchange_puzzles

    mov eax, [rdi+4] ; load height
    cmp esi, eax
    jg spread_tiles_exit ; if n > height exit (not allowed)
    xor edx, edx
    div esi ; height // n
    mov r15d, eax ; save height for exchange_puzzles

	; Fisher–Yates shuffle algorithm
	; int j;
	; for (int i = max_puzzle_num + 1; i>1; i--)
	; {
	; 	j = RandIntRange(0, i - 1)
	;	exchange_puzzles(i, j)
	; }
    mov ebx, r13d
    imul ebx, esi ; ebx - i

spread_tiles_loop:
    call rand
    xor edx, edx
    div ebx ; edx = randint % i
    mov esi, edx ; num of second puzzle for exchange_puzzles
    dec ebx ; temp decrement ebx
    mov edi, ebx ; num of first puzzle for exchange_puzzles
    inc ebx ; restore ebx

    ; other arguments
    mov edx, r15d
    mov ecx, r14d
    mov r8d, r13d
    mov r9d, r12d
    call exchange_puzzles

    dec ebx ; i--
    cmp ebx, 1
    jg spread_tiles_loop

spread_tiles_exit:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret


;============================================================================
; exchange_puzzles
; arguments:
;   rdi - number of first puzzle
;	rsi - number of second puzzle
;	rdx - height of one puzzle in pixels
;	rcx - width of one puzzle in bytes
;	r8 - m parameter
;   r9 - address of ImgInfo image descriptor
; return value:
;	none
exchange_puzzles:
    push rbx
    push r12
    push r13

    mov r13d, edx ; save height of one puzzle

    mov eax, edi ; load num of first puzzle
    xor edx, edx ; edx = 0
    div r8d ; puzzle_num // m
    mul r13d ; (num//m) * height_1_puzzle
    mov r10d, [r9+8] ; load linebytes
    mul r10d ; linebytes * height_1_puzzle * (num//m)
    mov r11d, eax ; save result

    mov eax, edi ; load num of first puzzle
    xor edx, edx
    div r8d
    mov eax, edx ; puzzle_num % m
    mul ecx ; width_1_puzzle_in_bytes * (num % m)
    add r11d, eax

    ; the same calculation for second puzzle
    mov eax, esi ; load num of second puzzle
    xor edx, edx ; edx = 0
    div r8d ; puzzle_num // m
    mul r13d ; (num//m) * height_1_puzzle
    mov r10d, [r9+8]
    mul r10d
    mov r12d, eax ; save result

    mov eax, esi ; load num of second puzzle
    xor edx, edx ; edx = 0
    div r8d ; puzzle_num % m
    mov eax, edx
    mul ecx ; width_1_puzzle_in_bytes * (num % m)
    add r12d, eax

    mov rbx, [r9+12] ; load pImg
    add r11, rbx ; address = base + offset
    add r12, rbx ; address = base + offset

    mov r8d, edx ; init height counter
    mov r13d, ecx ; init width counter

; r11 - address of current pixel of first puzzle
; r12 - address of current pixel of second puzzle
; r8d - height counter (in pixels)
; r13d - width counter (in bytes)

exchange_line:
    mov r13d, ecx ; reset width counter

exchange_byte:
    ; exchange bytes
    mov al, [r11]
    mov dl, [r12]
    mov [r11], dl
    mov [r12], al

    ; update addresses
    inc r11
    inc r12

    dec r13d ; update width counter
    jg exchange_byte

    mov edx, [r9+8] ; load linebytes
    add r11, edx
    add r12, edx

    sub r11, ecx
    sub r12, ecx

    dec r8d ; update height counter
    jg exchange_line

exchange_puzzles_exit:
    pop r13
    pop r12
    pop rbx
    ret