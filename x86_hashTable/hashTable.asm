; Struct Node organization:
;	size: 24 bytes
;	DWORD [p + 0]: key being stored
;	QWORD [p + 8]: pointer to next node
;	QWORD [p + 16]: pointer to previous node

	section	.data
	align	4
hashTable:	dq 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	align	1
print_str1:	db `%d: `, 0
print_str2:	db `%d `, 0
main_str1:	db `Digite um comando.\n\t1: inserir\n\t2: remover\n\t3: buscar\n\t4: imprimir\n\t5: sair\n>> `, 0
main_str2:	db `Digite um numero: `, 0
main_str3:	db `Invalido.\n`, 0
main_format:	db "%d", 0
str_newline:	db `\n`, 0


	section	.text
	align	4
	global	main
	extern	printf
	extern	scanf
	extern	malloc
main:
	add	rsp, -8
main_continue:
	mov	rdi, main_str1
	call	printf

	mov	rdi, main_format
	mov	rsi, rsp
	call	scanf
	mov	eax, [rsp]
	; op is on eax

	cmp	eax, 1
	je	main_op1
	cmp	eax, 2
	je	main_op2
	cmp	eax, 3
	je	main_op3
	cmp	eax, 4
	je	main_op4
	cmp	eax, 5
	je	main_op5
	mov	rdi, main_str3
	call	printf
	jmp	main_continue

main_op1:
	; insert
	mov	rdi, main_str2
	call	printf

	mov	rdi, main_format
	mov	rsi, rsp
	call	scanf
	mov	eax, [rsp]

	cmp	eax, -1
	je	main_continue

	mov	edi, eax
	call	insert

	jmp	main_op1

main_op2:
	; remove
	mov	rdi, main_str2
	call	printf

	mov	rdi, main_format
	mov	rsi, rsp
	call	scanf
	mov	eax, [rsp]

	cmp	eax, -1
	je	main_continue

	mov	edi, eax
	call	remove

	jmp	main_op2

main_op3:
	; search
	mov	rdi, main_str2
	call	printf

	mov	rdi, main_format
	mov	rsi, rsp
	call	scanf
	mov	eax, [rsp]

	cmp	eax, -1
	je	main_continue

	mov	edi, eax
	call	search

	mov	rdi, main_format
	mov	esi, eax
	call	printf

	mov	rdi, str_newline
	call	printf

	jmp	main_op3

main_op4:
	; print
	call	print
	jmp	main_continue

main_op5:
	add	rsp, 8
	ret




; Args:
;	edi: key to insert
; Return:
;	eax: hashing of the key
hashing:
	mov	eax, edi
	and	eax, 0x0000000F
	ret

; Args:
;	N/A
; Return:
;	rax: address of new node
node_new:
	mov	rdi, 24
	add	rsp, -8
	call	malloc
	add	rsp, 8
	mov	QWORD [rax + 8], 0
	mov	QWORD [rax + 16], 0
	ret


; Args:
;	edi: key to insert
; Return:
;	N/A
insert:
	; rsp+0: int key
	; rsp+4: int index
	; rsp+8: Node *curr
	; rsp+16: Node *prev
	; rsp+24: Node *new
	add	rsp, -40
	mov	[rsp], edi
	call	hashing
	mov	[rsp+4], eax

	mov	QWORD [rsp+16], 0
	mov	eax, [rsp+4]
	mov	rax, [hashTable + eax*8]
	mov	QWORD [rsp+8], rax
insert_while:
	cmp	QWORD[rsp+8], 0
	je	insert_leaveWhile
	mov	rax, [rsp+8]
	mov	eax, DWORD [rax]
	cmp	eax, DWORD [rsp]
	jge	insert_leaveWhile
	mov	rax, [rsp+8]
	mov	[rsp+16], rax
	mov	rax, [rax + 8]
	mov	[rsp+8], rax
	jmp	insert_while

insert_leaveWhile:
	cmp	QWORD[rsp+8], 0
	je	insert_L1
	mov	rax, [rsp+8]
	mov	eax, [rax]
	cmp	eax, DWORD [rsp]
	jne	insert_L1
	jmp	insert_return

insert_L1:
	call	node_new
	mov	[rsp+24], rax
	mov	ecx, DWORD [rsp]
	mov	DWORD [rax], ecx
	mov	rcx, [rsp+8]
	mov	QWORD[rax+8], rcx
	mov	rcx, [rsp+16]
	mov	QWORD[rax+16], rcx
	cmp	QWORD[rsp+8], 0
	je	insert_L2
	mov	rax, [rsp+8]
	mov	rcx, [rsp+24]
	mov	[rax+16], rcx
insert_L2:
	cmp	QWORD[rsp+16], 0
	je	insert_L3
	mov	rax, [rsp+16]
	mov	rcx, [rsp+24]
	mov	[rax+8], rcx
	jmp	insert_return
insert_L3:
	mov	eax, [rsp+4]
	mov	rcx, [rsp+24]
	mov	[hashTable + eax*8], rcx
insert_return:
	add	rsp, 40
	ret


; Args:
;	edi: key to remove
; Return:
;	N/A
remove:
	; rsp+0: int key
	; rsp+4: int index
	; rsp+8: Node *curr
	; rsp+16: Node *prev
	add	rsp, -24
	mov	[rsp], edi
	call	hashing
	mov	[rsp+4], eax
	mov	QWORD [rsp+16], 0
	mov	rax, [hashTable + eax*8]
	mov	[rsp+8], rax
remove_whileIn:
	mov	rax, [rsp+8]
	cmp	rax, 0
	je	remove_whileOut
	mov	eax, [rax]	;curr->key
	mov	ecx, [rsp]	;key
	cmp	eax, ecx
	jg	remove_whileOut
	jne	remove_prepNext
	; rax: Node *next
	mov	rcx, [rsp+8]
	mov	rax, [rcx+8]
	cmp	rax, 0
	je	remove_L1
	mov	rcx, [rsp+16]
	mov	[rax+16], rcx
remove_L1:
	mov	rcx, [rsp+16]
	cmp	rcx, 0
	je	remove_L2
	mov	[rcx+8], rax
	jmp	remove_whileOut
remove_L2:
	mov	ecx, [rsp+4]
	mov	[hashTable + ecx*8], rax
	jmp	remove_whileOut

remove_prepNext:
	mov	rax, [rsp+8]
	mov	[rsp+16], rax
	mov	rax, [rax+8]
	mov	[rsp+8], rax
	jmp	remove_whileIn

remove_whileOut:
	add	rsp, 24
	ret


; Args:
;	edi: key to search
; Return:
;	eax: -1 if search fails, hashing of given key if successful.
search:
	; rsp+0: int key
	; rsp+4: int index
	; rsp+8: Node *curr
	add	rsp, -24
	mov	[rsp], edi
	call	hashing
	mov	[rsp+4], eax
	mov	rcx, [hashTable + eax*8]
	mov	QWORD [rsp+8], rcx
search_whileIn:
	mov	rcx, [rsp+8]
	cmp	rcx, 0
	je	search_fail
	mov	ecx, [rcx]
	mov	eax, [rsp]
	cmp	ecx, eax
	jg	search_fail
	je	search_success
	mov	rcx, [rsp+8]
	mov	rcx, [rcx+8]
	mov	[rsp+8], rcx
	jmp	search_whileIn

search_success:
	mov	eax, [rsp+4]
	add	rsp, 24
	ret

search_fail:
	mov	eax, -1
	add	rsp, 24
	ret



; Args:
;	N/A
; Return:
;	N/A
print:
	; rsp+0: int i
	; rbx: Node *node
	add	rsp, -8
	mov	[rsp], DWORD 0
print_doWhile:
	mov	rdi, print_str1
	mov	esi, DWORD [rsp]
	call	printf

	mov	eax, [rsp]
	mov	rbx, [hashTable + eax*8]
print_while:
	cmp	rbx, 0
	je	print_leaveWhile
	mov	rdi, print_str2
	mov	esi, DWORD [rbx]
	call	printf
	mov	rbx, [rbx + 8]
	jmp	print_while

print_leaveWhile:
	mov	rdi, str_newline
	call	printf
	inc	DWORD [rsp]
	cmp	DWORD [rsp], 16
	jne	print_doWhile

	add	rsp, 8
	ret
