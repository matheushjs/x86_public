	section	.bss
	align	4
hashTable:	resb 8 ; Points to the hash entries.
hashSize:	resb 4 ; Current capacity of the hash table
hashCount:	resb 4 ; Current elements in the hash table
numBuf:		resb 4 ; Buffer for reading integers


	section .data
	
	align	1
print_str1:	db `%d: `, 0
print_str2:	db `%d `, 0
main_str1:	db `Type a command.\n\t1: insert\n\t2: remove\n\t3: search\n\t4: print\n\t5: exit\n>> `, 0
main_str2:	db `Type a number (-1 to exit): `, 0
main_str3:	db `\nInvalid. Try again.\n\n`, 0
str_newline:	db `\n`, 0
d_format:	db `%d`, 0
s_format:	db `%s`, 0
lf_format:	db `%lf`, 0
	align	4
upper_double:	dq 0.66
lower_double:	dq 0.3


	section .text
	extern	printf
	extern	scanf
	extern	malloc
	extern	free
	global	main

main:
	add	rsp, -8	; 16-align calls
	call	hash_init

main_nextOp:
	mov	rdi, s_format
	mov	rsi, main_str1
	call	printf

	mov	rdi, d_format
	mov	rsi, numBuf
	call	scanf	; Number read is on numBuf

	cmp	DWORD [numBuf], 1
	je	main_insert
	cmp	DWORD [numBuf], 2
	je	main_remove
	cmp	DWORD [numBuf], 3
	je	main_search
	cmp	DWORD [numBuf], 4
	je	main_print
	cmp	DWORD [numBuf], 5
	je	main_exit

	mov	rdi, s_format
	mov	rsi, main_str3
	call	printf
	jmp	main_nextOp

main_insert:
	mov	rdi, s_format
	mov	rsi, main_str2
	call	printf

	mov	rdi, d_format
	mov	rsi, numBuf
	call	scanf

	cmp	DWORD [numBuf], -1
	je	main_nextOp
	
	mov	edi, [numBuf]
	call	hash_insert

	jmp	main_insert

main_remove:
	mov	rdi, s_format
	mov	rsi, main_str2
	call	printf

	mov	rdi, d_format
	mov	rsi, numBuf
	call	scanf

	cmp	DWORD [numBuf], -1
	je	main_nextOp

	mov	edi, [numBuf]
	call	hash_remove
	
	jmp	main_remove

main_search:
	mov	rdi, s_format
	mov	rsi, main_str2
	call	printf

	mov	rdi, d_format
	mov	rsi, numBuf
	call	scanf

	cmp	DWORD [numBuf], -1
	je	main_nextOp

	mov	edi, [numBuf]
	call	hash_search
	
	mov	rdi, d_format
	mov	rsi, rax
	call	printf

	mov	rdi, str_newline
	call	printf

	jmp	main_search

main_print:
	call	hash_print
	jmp	main_nextOp

main_exit:
	call	hash_free
	add	rsp, 8
	ret


; Initializes the hashTable
hash_init:
	add	rsp, -8	; 16-align
	
	mov	DWORD [hashSize], 0x10
	mov	DWORD [hashCount], 0
	
	mov	edi, DWORD [hashSize]
	imul	rdi, 8	; size of pointers
	call	malloc
	mov	QWORD [hashTable], rax
	
	call	hash_set

	add	rsp, 8
	ret

; Sets all entries in the hashTable to NULL
hash_set:
	mov	rax, [hashTable]
	mov	ecx, DWORD [hashSize]
	dec	rcx
	imul	rcx, 8		; size of pointers
	add	rcx, rax	; rcx = hashTable + hashSize

hash_set_L1:
	mov	QWORD [rcx], 0
	add	rcx, -8
	cmp	rcx, rax	; cmp (rcx, hashTable)
	jge	hash_set_L1	; jmp if rcx >= hashTable

	ret


; Return:
;	rax: address of newly allocated node
node_new:
	add	rsp, -8

	mov	rdi, 12
	call	malloc
	mov	QWORD [rax + 4], 0
	; Return value already in rax

	add	rsp, 8
	ret


; Args:
;	edi: integer to hash
; Return:
;	eax: hashing of the integer
hashing:
	mov	eax, [hashSize]
	add	eax, -1
	and	eax, edi

	; return already on rax
	ret



; Args:
;	edi: key to insert
;	esi: if 0, does not increment hashSize when inserting.
;	     if != 0, increments hashSize and grows the hash if needed.
hash_insert_op:
	add	rsp, -24
	; rsp+0: key
	; rsp+4: inc
	; rsp+8: index
	mov	[rsp], edi
	mov	[rsp+4], esi

	call	hashing
	mov	[rsp+8], eax

	mov	edi, [rsp] ; edi = key
	mov	rcx, 0 ; prev = NULL
	mov	rsi, [hashTable]
	mov	rax, [rsi + rax*8] ; rax = hashTable[index]
hash_insert_L1:
	; edi: key
	; rcx: prev
	; rax: curr
	cmp	rax, 0
	je	hash_insert_L2
	cmp	DWORD [rax], edi ; cmp(curr->key, key)
	jge	hash_insert_L2
	mov	rcx, rax
	mov	rax, [rax+4]	; curr = curr->next
	jmp	hash_insert_L1
hash_insert_L2:
	cmp	rax, 0
	je	hash_insert_L3
	cmp	DWORD [rax], edi
	jne	hash_insert_L3
	jmp	hash_insert_exit
hash_insert_L3:
	push	rdi
	push	rcx
	push	rax
	call	node_new
	mov	rdx, rax
	pop	rax
	pop	rcx
	pop	rdi
	
	; rdx: new
	mov	[rdx], edi	; new->key = key
	mov	[rdx+4], rax	; new->next = curr
	cmp	rcx, 0		; cmp(prev, 0)
	je	hash_insert_L4
	mov	[rcx+4], rdx	; prev->next = new
	jmp	hash_insert_L5
hash_insert_L4:
	; esi = index
	mov	esi, [rsp+8]
	mov	r8, [hashTable]
	mov	[r8 + rsi*8], rdx ; hashTable[index] = new
hash_insert_L5:
	; esi = inc
	mov	esi, [rsp+4]
	cmp	esi, 0
	je	hash_insert_exit
	inc	DWORD [hashCount]
	
	cvtsi2sd	xmm0, DWORD [hashCount]
	cvtsi2sd	xmm1, DWORD [hashSize]
	divsd	xmm0, xmm1
	movsd	xmm1, QWORD [upper_double]
	ucomisd	xmm0, xmm1
	jbe	hash_insert_exit
	call	hash_grow
hash_insert_exit:
	add	rsp, 24
	ret

; Removes a key from the hashTable.
; Args:
;	edi: integer to remove
hash_remove:
	push	rbx ;curr
	push	r12 ;prev
	push	r13 ;key
	push	r14 ;index
	push	r15 ; [hashTable]

	mov	r13d, edi
	call	hashing
	mov	r14d, eax ;r14d = hashing(key)
	
	mov	r12, 0
	mov	r15, [hashTable]
	mov	rbx, [r15 + r14*8] ;curr = hashTable[index]
hash_remove_L1:
	cmp	rbx, 0
	je	hash_remove_L2
	mov	eax, [rbx] ;eax = curr->key
	cmp	eax, r13d ;curr->key #cmp# key
	jg	hash_remove_L2
	jne	hash_remove_L3
	;if(curr->key == key) do:
	mov	rax, [rbx+4] ;rax = curr->next
	cmp	r12, 0
	je	hash_remove_L4 ;if(prev == NULL) goto L4
	mov	[r12+4], rax ;prev->next = rax = curr->next
	jmp	hash_remove_L5
hash_remove_L4:
	mov	[r15 + r14*8], rax
hash_remove_L5:
	mov	rdi, rbx
	call	free
	dec	DWORD [hashCount]

	cvtsi2sd	xmm0, DWORD [hashCount]
	cvtsi2sd	xmm1, DWORD [hashSize]
	divsd	xmm0, xmm1
	movsd	xmm1, QWORD [lower_double]
	ucomisd	xmm0, xmm1
	jae	hash_remove_L2
	call	hash_shrink
	jmp	hash_remove_L2
hash_remove_L3:
	mov	r12, rbx
	mov	rbx, [rbx+4]
	jmp	hash_remove_L1
hash_remove_L2:
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	ret



; Wrapper function for user insertion
; Args:
;	eax: key to be inserted
hash_insert:
	add	rsp, -8
	mov	esi, 1
	call	hash_insert_op
	add	rsp, 8
	ret



; Prints the whole table
hash_print:
	add	rsp, -24
	mov	[rsp], rbx

	; rax: i
	mov	rax, 0
hash_print_L1:
	; rbx: node (caller-saved)
	mov	rbx, [hashTable]
	mov	rbx, [rbx + rax*8]
	
	mov	rdi, print_str1
	mov	rsi, rax
	mov	[rsp+8], rax
	call	printf
hash_print_L2:
	cmp	rbx, 0
	je	hash_print_L3
	mov	rdi, print_str2
	mov	esi, [rbx]
	call	printf
	mov	rbx, [rbx+4]
	jmp	hash_print_L2
hash_print_L3:
	mov	rdi, str_newline
	call	printf
	
	mov	rax, [rsp+8]
	inc	rax
	cmp	eax, [hashSize]
	jne	hash_print_L1
	
	mov	rbx, [rsp]
	add	rsp, 24
	ret


; Frees memory allocated for the whole hashTable
hash_free:
	add	rsp, -24
	mov	[rsp], rbx
	mov	[rsp+8], r12

	; rbx: i
	; r12: node
	mov	rbx, 0
hash_free_L1:
	mov	r12, [hashTable]
	mov	r12, [r12 + rbx*8]
hash_free_L2:
	cmp	r12, 0
	je	hash_free_L3
	mov	rdi, r12
	mov	r12, [r12+4]
	call	free
	jmp	hash_free_L2
hash_free_L3:
	inc	rbx
	cmp	ebx, [hashSize]
	jne	hash_free_L1

	mov	rdi, [hashTable]
	call	free

	mov	rbx, [rsp]
	mov	r12, [rsp+8]
	add	rsp, 24
	ret



hash_grow:
	push	rbx ; old
	push	r12 ; oldSize
	push	r13 ; oldCount
	push	r14 ; i
	push	r15 ; node
	
	mov	rbx, [hashTable]
	mov	r12d, [hashSize]
	mov	r13d, [hashCount]

	shl	DWORD [hashSize], 1
	mov	edi, [hashSize]
	imul	rdi, 8
	call	malloc
	mov	[hashTable], rax

	call	hash_set

	mov	r14, 0
hash_grow_L1:
	mov	r15, [rbx + r14*8]
hash_grow_L2:
	cmp	r15, 0
	je	hash_grow_L3
	mov	edi, [r15]
	mov	esi, 0
	call	hash_insert_op

	mov	rdi, r15
	mov	r15, [r15+4]
	call	free
	jmp	hash_grow_L2
hash_grow_L3:
	inc	r14
	cmp	r14d, r12d
	jne	hash_grow_L1

	mov	rdi, rbx
	call	free
	mov	[hashCount], r13d

	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	ret


hash_shrink:
	push	rbx
	mov	ebx, [hashSize]
	cmp	rbx, 0x10
	jne	hash_shrink_L1
	pop	rbx
	ret
hash_shrink_L1:
	; rbx: oldSize
	push	r12 ; old
	push	r13 ; oldCount
	push	r14 ; i
	push	r15 ; node

	mov	r12, [hashTable]
	mov	r13d, [hashCount]

	shr	DWORD [hashSize], 1 ;hashSize >>= 1

	mov	edi, [hashSize]
	imul	edi, 8
	call	malloc
	mov	[hashTable], rax ;hashTable = malloc(...)

	call	hash_set

	mov	r14, 0 ;i = 0
hash_shrink_L2:
	mov	r15, [r12 + r14*8]
hash_shrink_L3:
	cmp	r15, 0 ;while(node != NULL)
	je	hash_shrink_L4
	mov	edi, DWORD [r15]
	mov	esi, 0
	call	hash_insert_op
	
	mov	rdi, r15
	mov	r15, [r15 + 4] ;node = aux
	call	free ;free(node)

	jmp	hash_shrink_L3
hash_shrink_L4:
	inc	r14
	cmp	r14, rbx
	jne	hash_shrink_L2

	mov	rdi, r12
	call	free
	
	mov	[hashCount], r13d

	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	ret



; Checks if 'key' is within the hashtable
; Args:
;	rdi: integer to search for
; Return:
;	eax: -1 if search failed. The hashing of the integer, if found.
hash_search:
	push	rbx ;key
	
	mov	rbx, rdi
	call	hashing
	; rax: index

	mov	rcx, [hashTable]
	mov	rcx, [rcx + rax*8]
	; rcx: curr

hash_search_L1:
	cmp	rcx, 0
	je	hash_search_failed
	mov	edx, [rcx]
	cmp	edx, ebx ;cmp(curr->key, key)
	jg	hash_search_failed
	je	hash_search_end ;index is already on rax
	mov	rcx, [rcx+4] ;curr = curr->next
	jmp	hash_search_L1
hash_search_failed:
	mov	eax, -1
hash_search_end:
	pop	rbx
	ret
