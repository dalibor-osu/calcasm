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
	;INPUT: db "123", 0
	LF: db 10
	CONVERTED: db "Converted", 0xa, 0
	const10: dd 10

section .bss
	e1_len resd 1
	dummy resd 1

section .text
	global _start

_start:
	push GREET			; print_message(GREET)
	call print_message		;
	sub rsp, 8			; reset stack pointer

	push FIRST_NUMBER_PROMPT	; print_message(FIRST_NUMBER_PROMPT)
	call print_message		;
	sub rsp, 8			; reset stack pointer to free space

	call read_user_int		; read user input as integer
	mov r10, rax			; save it on stack

	push SECOND_NUMBER_PROMPT	; print_message(SECOND_NUMBER_PROMPT)
	call print_message		; 
	sub rsp, 8			; reset stack pointer to free space

	call read_user_int		; read the second user input
	add r11, rax			; save it on stack

	push OPERATOR_PROMPT		; print_message(OPERATOR_PROMPT)
	call print_message		; 
	sub rsp, 8			; reset stack pointer to free space

	call read_user_input
	
	cmp byte[INPUT], 0x2A
	je _multiplication
	cmp byte[INPUT], 0x2B
	je _addition
	cmp byte[INPUT], 0x2D
	je _subtraction
	cmp byte[INPUT], 0x2F
	je _division

_addition:
	mov rax, r10
	add rax, r11
	jmp _print_result

_subtraction:
	mov rax, r10
	sub rax, r11
	jmp _print_result

_multiplication:
	mov ax, r10w
	mul r11w
	jmp _print_result

_division:
	mov ax, r10w
	div r11w
	jmp _print_result

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

	mov [e1_len], rax
	cmp rax, rdx
	jb .return
	mov bl, [rsi + rax - 1]
	cmp bl, 10
	je .return
	inc DWORD [e1_len]

.loop:
	mov rax, 0
	mov rdi, 1
	mov rsi, dummy
	mov rdx, 1
	syscall

	test rax, rax
	jz .return
	mov al, [dummy]
	cmp al, 10
	jne .loop

.return:
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
	
	xor rax, rax
	xor rcx, rcx
	mov rbx, INPUT

.loop:
	mov cl, [rbx]   ; cl = *rbx 
        cmp rcx, 0      ; check for nul THIS IS WRONG
        cmp rcx, 10     ; we have to check for NL ascii code 
        je .return          ; if rcx == 0 goto end
        imul rax, 10    ; rax *= 10
        sub rcx, 48     ; rcx -= 48 (48 is acii for '0')
        add rax, rcx    ; rax += rcx
        inc rbx         ; rbx++
        jmp .loop

.return:
	mov rsp, rbp
	pop rbp
	ret

divide_by_ten:
	div 10
	ret

print_number:
	mov rcx, 10
loop1:   
	call divide_by_ten
        add rax, 0x30
        push rax
        mov rax, rdx
        dec rcx
        jne loop1
        mov rcx, 10        ;  digit count to print
loop2:   
	call print_message
	pop rax
        dec rcx
        jne loop2
	

_print_result:
	push RESULT_MSG
	call print_message
	add rbp, 8

	call print_number
	jmp _exit

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
	mov rdi, r10			; Set the return value to 0
	syscall				; Call the syscall
