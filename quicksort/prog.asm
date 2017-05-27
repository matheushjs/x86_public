; vim: expandtab

	section	.bss
vector:		resq 1
	
	section	.data
int_format1:	db `%d`, 0
int_format2:	db `%d `, 0 ; With white space
str_newline:	db `\n`, 0
vector_size:	dq 0

	section	.text
	extern  printf
	extern  scanf
    extern  malloc
    extern  free
	global  main

main:
    add    rsp, -8 ; 16-align calls

    mov    rdi, 4000 ; 1000 numbers
    call   malloc
    mov    [vector], rax

    mov    rbx, rax
    mov    r12, [vector_size]
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
    mov    [vector_size], r12

    ;quicksort(vector, 0, size-1)
    mov    rdi, [vector]
    xor    esi, esi
    mov    edx, [vector_size]
    add    edx, -1
    call   quicksort

    mov    r13, 0
    mov    rbx, [vector]
print_vector:
    cmp    r13, r12
    je     print_exit
    mov    rdi, int_format2
    mov    esi, [rbx]
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

    cmp    rsi, rdx
    jle    quicksort_return

    ; call partition here

    ;quicksort(vec, left, i)
    mov    rdi, [rsp+8]
    mov    esi, DWORD[rsp+16]
    mov    edx, DWORD[rsp]
    call   quicksort

    ;quicksort(vec, j, right)
    mov    rdi, [rsp+8]
    mov    esi, DWORD[rsp+16]
    mov    edx, DWORD[rsp]
    call   quicksort

quicksort_return:
    add    rsp, 24
    ret
