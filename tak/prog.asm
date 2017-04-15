	section	.data
str_error:	db `Usage: ./tak (x) (y) (z)\n`, 0
str_ans:	db `Ans: %d\n`, 0
	section	.text
	extern	printf
	extern	atoi
	global	main

main:
	add	rsp, -24
	cmp	edi, 4
	jne	main_failure

	mov	r15, rsi

	mov	rdi, [r15+8]
	call	atoi
	mov	[rsp], eax
	
	mov	rdi, [r15+16]
	call	atoi
	mov	[rsp+4], eax
	
	mov	rdi, [r15+24]
	call	atoi
	mov	[rsp+8], eax

	mov	edi, [rsp]
	mov	esi, [rsp+4]
	mov	edx, [rsp+8]
	call	tak

	mov	rdi, str_ans
	mov	esi, eax
	call	printf

	jmp	main_return

main_failure:
	mov	rdi, str_error
	call	printf

main_return:
	add	rsp, 24
	ret

; Arguments received on (edi,esi,edx)
; Returns on eax
tak:
	; rsp+0: x
	; rsp+4: y
	; rsp+8: z
	; rsp+12: call 1
	; rsp+16: call 2
	cmp	esi, edi
	jge	tak_retz
	add	rsp, -24

	mov	[rsp], edi
	mov	[rsp+4], esi
	mov	[rsp+8], edx

	; call 1
	mov	edi, [rsp]
	dec	edi
	mov	esi, [rsp+4]
	mov	edx, [rsp+8]
	call	tak
	mov	[rsp+12], eax

	; call 2
	mov	edi, [rsp+4]
	dec	edi
	mov	esi, [rsp+8]
	mov	edx, [rsp]
	call	tak
	mov	[rsp+16], eax

	; call 3
	mov	edi, [rsp+8]
	dec	edi
	mov	esi, [rsp]
	mov	edx, [rsp+4]
	call	tak
	
	; call 4
	mov	edx, eax
	mov	edi, [rsp+12]
	mov	esi, [rsp+16]
	call	tak

	add	rsp, 24
	ret

tak_retz:
	mov	eax, edx
	ret
