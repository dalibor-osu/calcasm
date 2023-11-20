section .data
	; Prompts
	GREET: db "Welcome to Calcasm!", 0xa, 0
	FIRST_NUMBER_PROMPT: db "Please input the first number: ", 0xa, 0
	SECOND_NUMBER_PROMPT: db "Please input the second number: ", 0xa, 0
	OPERATOR_PROMPT: db "Please select the operator (+, -, *, /): ", 0xa, 0 

	; Error messages
	INVALID_NUMBER_ERR: db "The number is invalid", 0xa, 0
	INVALID_OPERATOR_ERR: db "The operator is invalid", 0xa, 0
	NOT_IMPLEMENTED_ERR: db "This is not implemented yet", 0xa, 0

	; Other messages
	RESULT_MSG: db "Result: ", 0xa, 0
	INPUT: times 100 db 0		; User input buffer
	LF: db 10

section .text
	global _start

_start:
	push GREET			; print_message(GREET)
	call print_message		;
	sub rsp, 8			; reset stack pointer

	push FIRST_NUMBER_PROMPT	; print_message(FIRST_NUMBER_PROMPT)
	call print_message		;
	sub rsp, 8			; reset stack pointer to free space

	call read_user_int
	push rax

	push SECOND_NUMBER_PROMPT
	call print_message
	sub rsp, 8

	call read_user_int
	push rax

	push OPERATOR_PROMPT
	call print_message
	sub rsp, 8

	jmp _exit			; exit the program

read_user_int:
	push rbp
	mov rbp, rsp

	call read_user_input
	push INPUT
	call char_to_int

	mov rsp, rbp
	pop rbp
	ret

read_user_input:
	push rbp
	mov rbp, rsp

	mov rax, 0
	mov rdi, 1
	mov rsi, INPUT
	mov rdx, 100
	syscall

	mov rsp, rbp
	pop rbp
	ret

print_message:
	; Prologue
	push rbp
	mov rbp, rsp

	; Body of the function
	mov rsi, [rbp + 16]		; Move the passed variable to rsi
	push rsi
	call calculate_string_length	; Calculate the length of a given string
	sub rsp, 8
	mov rdx, rax			; Set the calculated string lenght
	mov rax, 1			; Setup printing
	mov rdi, 1			; Set std output
	syscall				; Make the print syscall

	; Epilogue
	mov rsp, rbp
	pop rbp
	ret

calculate_string_length:
	; Prologue
	push rbp
	mov rbp, rsp
	
	mov rdi, [rbp + 16]		; Move the string argument to rdi
	mov rax, 0			; Set rax (ret value) to 0 

.count_loop:

	cmp byte[rdi + rax], 0		; Compare character to 0x0
	je .return			; If the charcter is 0, break from loop

	inc rax				; otherwise increment return value
	jmp .count_loop			; Repeat with the next character
	
.return:
	; Epilogue
	mov rsp, rbp
	pop rbp
	ret

char_to_int:
	push rbp
	mov rbp, rsp

	xor ax, ax
	xor cx, cx
	mov bx, 10
	mov rsi, [rbp + 16]

.convert_loop:
	mov cl, [rsi]
	cmp cl, byte 0
	je .return

	cmp cl, 0x30
	jl _invalid_number
	cmp cl, 0x39
	jg _invalid_number

	sub cl, 48
	mul bx
	add ax, cx
	inc rsi

	jmp .convert_loop

.return:
	mov rsp, rbp
	pop rbp
	ret

_invalid_number:
	push INVALID_NUMBER_ERR
	call print_message
	jmp _exit_error

_not_implemented:
	push NOT_IMPLEMENTED_ERR	; print_message(NOT_IMPLEMENTED_ERR)
	call print_message		;
	jmp _exit			; Exit the program

_exit_error:
	mov rax, 60			; Set the exit syscall number
	mov rdi, 1			; Set the return value to 1 (error)
	syscall				; Call the syscall

_exit:
	mov rax, 60			; Set the exit syscall number
	mov rdi, 0			; Set the return value to 0
	syscall				; Call the syscall
