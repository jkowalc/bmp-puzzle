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
; 	[ebp+8] - address of ImgInfo descriptor
;	[ebp+12] - n parameter
;	[ebp+16] - m parameter
; return:
; 	none
spread_tiles:
    push ebp
    mov ebp, esp

    push ebx
    push esi

    mov ecx, [ebp+8] ; load ImgInfo
    push ecx ; push ImgInfo for exchange_puzzles

    mov esi, [ebp+16] ; load m
    mov eax, [ecx] ; load width
    cmp esi, eax
    jg spread_tiles_exit ; if m > width exit (not allowed)
    xor edx, edx ; edx = 0
    div esi ; width // m
    push esi ; push m for exchange_puzzles
    lea eax, [eax + 2*eax] ; eax = 3 * (width // m)
    push eax ; push width of one puzzle for exchange_puzzles

    mov ebx, [ebp+12] ; load n
    mov eax, [ecx+4] ; load height
    cmp ebx, eax
    jg spread_tiles_exit ; if n > height exit (not allowed)
    xor edx, edx
    div ebx ; height // n
    push eax ; push height for exchange_puzzles

	; Fisher–Yates shuffle algorithm
	; int j;
	; for (int i = max_puzzle_num + 1; i>1; i--)
	; {
	; 	j = RandIntRange(0, i - 1)
	;	exchange_puzzles(i, j)
	; }

    imul ebx, esi ; ebx - i

spread_tiles_loop:
    call rand
    xor edx, edx
    div ebx ; edx = randint % i
    push edx ; push second puzzle for exchange_puzzles
    dec ebx ; temp decrement ebx
    push ebx ; push first puzzle for exchange_puzzles
    inc ebx ; restore ebx

    call exchange_puzzles
    add esp, 8 ; pop first and second puzzle

    dec ebx ; i--
    cmp ebx, 1
    jg spread_tiles_loop

spread_tiles_exit:
    add esp, 16 ; pop other exchange_puzzles arguments
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    ret


;============================================================================
; exchange_puzzles
; arguments:
;   [ebp+8] - number of first puzzle
;	[ebp+12] - number of second puzzle
;	[ebp+16] - height of one puzzle in pixels
;	[ebp+20] - width of one puzzle in bytes
;	[ebp+24] - m parameter
;   [ebp+28] - address of ImgInfo image descriptor
; return value:
;	none
exchange_puzzles:
    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi

    mov eax, [ebp+8] ; load num of first puzzle
    mov esi, [ebp+24] ; load m
    xor edx, edx ; edx = 0
    div esi ; puzzle_num // m
    mov esi, [ebp+16] ; (num//m) * height_1_puzzle
    mul esi
    mov ecx, [ebp+28] ; load ImgInfo
    mov esi, [ecx+8] ; load linebytes
    mul esi ; linebytes * height_1_puzzle * (num//m)
    mov ebx, eax ; save result

    mov eax, [ebp+8] ; load num of first puzzle
    mov esi, [ebp+24] ; load m
    xor edx, edx
    div esi
    mov eax, edx ; puzzle_num % m
    mov esi, [ebp+20] ; load width of one puzzle
    mul esi ; width_1_puzzle_in_bytes * (num % m)
    add ebx, eax

    ; the same calculation for second puzzle
    mov eax, [ebp+12] ; load num of second puzzle
    mov esi, [ebp+24] ; load m
    xor edx, edx ; edx = 0
    div esi ; puzzle_num // m
    mov esi, [ebp+16] ; (num//m) * height_1_puzzle
    mul esi
    mov esi, [ecx+8] ; load linebytes
    mul esi
    mov esi, eax ; save result

    mov eax, [ebp+12] ; load num of second puzzle
    mov edi, [ebp+24] ; load m
    xor edx, edx ; edx = 0
    div edi ; puzzle_num % m
    mov eax, edx
    mov edi, [ebp+20] ; load width of one puzzle
    mul edi ; width_1_puzzle_in_bytes * (num % m)
    add esi, eax

    mov ecx, [ecx+12] ; load pImg
    add ebx, ecx ; address = base + offset
    add esi, ecx ; address = base + offset

    mov ecx, [ebp+16] ; init height counter
    mov edi, [ebp+20] ; init width counter

; ebx - address of current pixel of first puzzle
; esi - address of current pixel of first puzzle
; ecx - height counter (in pixels)
; edi - width counter (in bytes)

exchange_line:
    mov edi, [ebp+20] ; reset width counter

exchange_byte:
    ; exchange bytes
    mov al, [ebx]
    mov dl, [esi]
    mov [ebx], dl
    mov [esi], al

    ; update addresses
    inc ebx
    inc esi

    dec edi ; update width counter
    jg exchange_byte

    mov eax, [ebp+28] ; load ImgInfo
    mov edx, [eax+8] ; load linebytes
    add ebx, edx
    add esi, edx

    mov edx, [ebp+20] ; load width of one puzzle
    sub ebx, edx
    sub esi, edx

    dec ecx ; update height counter
    jg exchange_line

exchange_puzzles_exit:
    pop edi
    pop esi
    pop ebx

    mov esp, ebp
    pop ebp
    ret