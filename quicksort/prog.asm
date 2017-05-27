; vim: expandtab

	section	.bss
vector:		resq 1
	
	section	.data
int_format1:	db `%d`, 0
int_format2:	db `%d `, 0 ; With white space
str_newline:	db `\n`, 0
vector_size:	dw 0

	section	.text
	extern  printf
	extern  scanf
    extern  malloc
    extern  free
	global  main

main:
    add    rsp, -8 ; 16-align calls

    mov    rdi, 4000 ; 1000 integer numbers
    call   malloc
    mov    [vector], rax

    mov    rbx, rax
    mov    r12d, [vector_size]
read_integer:
    mov    rdi, int_format1
    mov    rsi, rbx
    call   scanf
    cmp    rax, 1
    jne    read_exit
    inc    r12
    add    rbx, 4
    jmp    read_integer

read_exit:
    mov    [vector_size], r12d

    ;quicksort(vector, 0, size-1)
    mov    rdi, [vector]
    xor    esi, esi
    mov    edx, r12d
    add    edx, -1
    call   quicksort

    mov    r13, 0
    mov    rbx, [vector]
print_vector:
    cmp    r13, r12
    je     print_exit
    mov    rdi, int_format2
    mov    esi, DWORD [rbx]
    call   printf
    inc    r13
    add    rbx, 4
    jmp    print_vector

print_exit:
    mov    rdi, str_newline
    call   printf

    mov    rdi, [vector]
    call   free
    add    rsp, 8
    ret

; rdi: int *vec
; esi: int left
; edx: int right
quicksort:
    add    rsp, -24 ;16-aligned
    mov    [rsp+8], rdi
    mov    DWORD [rsp+16], esi
    mov    DWORD [rsp+20], edx

    ; [rsp]   - int i
    ; [rsp+4] - int j

    cmp    edx, esi  ;cmp right, left
    jle    quicksort_return

    ;partition(vec, left, right, &i, &j)
    ;rdi already has 'vec'
    ;esi already has left
    ;edx already has right
    mov    rcx, rsp  ;rcx = &i
    mov    r8 , rsp
    add    r8 , 4    ;r8 = &j
    call   partition

    ;quicksort(vec, left, i)
    mov    rdi, [rsp+8]
    mov    esi, DWORD[rsp+16]
    mov    edx, DWORD[rsp]
    call   quicksort

    ;quicksort(vec, j, right)
    mov    rdi, [rsp+8]
    mov    esi, DWORD[rsp+4]
    mov    edx, DWORD[rsp+20]
    call   quicksort

quicksort_return:
    add    rsp, 24
    ret

; rdi: int *vec
; esi: int left
; edx: int right
; rcx: int *left_of_mid
; r8:  int *right_of_mid
partition:    
    ; The generated numbers will follow a uniform random distribution,
    ; so it suffices to take the middle as the pivot
    mov    ebx, esi ;ebx =  left
    add    ebx, edx ;ebx += right
    shr    ebx, 1   ;ebx >>= 1
    mov    ebx, [rdi + rbx*4] ;ebx = vec[ebx]

    ; ebx <-> int pivot

partition_while:
    cmp    esi, edx ;cmp left, right
    jg     partition_return

    ; traverse left -> right
partition_leftWhile:
    mov    r15d, DWORD [rdi + rsi*4]  ;r15 = vec[left]
    cmp    r15, rbx            ;cmp vec[left], pivot
    jge    partition_rightWhile
    add    esi, 1              ;left++
    jmp    partition_leftWhile

    ; traverse left <- right
partition_rightWhile:
    mov    r14d, DWORD [rdi + rdx*4]  ;r14 = vec[right]
    cmp    r14, rbx            ;cmp vec[right], pivot
    jle    partition_rightExit
    add    edx, -1             ;right--
    jmp    partition_rightWhile
partition_rightExit:
    
    ;if(left > right) break;
    cmp    rsi, rdx         ;cmp left, right
    jg     partition_return

    ;swap
    ;r15 already has vec[left]
    ;r14 already has vec[right]
    mov    DWORD [rdi + rsi*4], r14d ;vec[left] = r14
    mov    DWORD [rdi + rdx*4], r15d ;vec[right] = r15

    add    esi,  1 ;left++
    add    edx, -1 ;right--
    jmp    partition_while

partition_return:
    mov    DWORD [rcx], edx ;*left_of_mid = right
    mov    DWORD [r8] , esi ;*right_of_mid = left
    ret
