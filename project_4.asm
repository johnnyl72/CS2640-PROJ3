# Who: Johnny Lam
# What: project_4.asm
# Why:  PROJECT 4
# When: Created when? 5/1/2019 Due when? 5/5/2019
# How:  List the uses of registers

.data

.eqv		STR_BUFFER_SZ		256
STR_BUFFER_SRC:	.space			STR_BUFFER_SZ
STR_BUFFER_DST:	.space			STR_BUFFER_SZ
.eqv		PW_BUFFER_SZ		257
PW_BUFFER:	.space			PW_BUFFER_SZ
PROMPT:		.asciiz			"Enter String: "
OUT_PROMPT:	.asciiz			"Out_Prompt: "
.align 2

.text

.globl main

main:	# program entry
	jal get_paths
	jal main_key_wait
	jal file_copy_main

li $v0, 10		# terminate the program
syscall

# Get Paths to files and store to buffer,
# syscall null terminates automatically when sized passed in
get_paths:

	la $a0, PROMPT
	li $v0, 4
	syscall
	
	la $a0, STR_BUFFER_SRC
	li $a1, STR_BUFFER_SZ
	li $v0, 8
	syscall
	
	la $a0, STR_BUFFER_DST
	li $a1, STR_BUFFER_SZ
	li $v0, 8
	syscall
	
	jr $ra
	
# IO programming
# Read chars from keyboard
# echo them to the console
# exit if thie c har = Enter Key (newline)
.data
.eqv	ISO_LF		0xA # Line Feed (newline)
.eqv	SYS_PRINT_CHAR	0XB
.eqv	ASTERISK	0X2A # *
.eqv	EXIT_Q		0x51
.eqv	EXIT_q		0x71
PW_PROMPT:	.asciiz		"Enter encrpytion password: "

# Receiver control. 1 in bit 0 means new char has arrived. This bit
# is read-only, and resets to 0 when CONSOLE_RECEIVER_DATA is read.
# 1 in bit 1 enables harddware interrupt at interrupt level 1.
# Interrupts must also be enabled in the coprocessor 0 status register.

.eqv	CONSOLE_RECEIVER_CONTROL	0xffff0000
.eqv	CONSOLE_RECEIVER_READY_MASK	0x00000001
.eqv	CONSOLE_RECEIVER_DATA           0xffff0004

#Main body
.text
main_key_wait:
	la $a0, PW_PROMPT
	li $v0, 4
	syscall
	
	li $t1, ISO_LF
	li $t2, 0
	key_wait:
	
	lw $t0, CONSOLE_RECEIVER_CONTROL
	andi $t0, $t0, CONSOLE_RECEIVER_READY_MASK	#Isolate ready bit
	beqz $t0, key_wait
	
	# Read in new character from keyboard to low byte of $a0
	# and clear other 3 bytes of $a0
	lbu $a0, CONSOLE_RECEIVER_DATA
	beq $a0, $t1, exit_key_wait
	
	# Todo: push char to buffer
	sb $a0, PW_BUFFER($t2)
	add $t2, $t2, 1
	# ------------------------------
	# Exit at 256 or before and add null terminator
	#-------------------------------
	
	# Print asterisk
	li $a0, ASTERISK
	li $v0, SYS_PRINT_CHAR
	syscall
	
	b key_wait
	
exit_key_wait:
	jr $ra
	
.data
.eqv	FILE_BUFFER_SZ				1024	
.eqv	FILE_OPEN_CODE				13
.eqv	FILE_READ_CODE				14
.eqv	FILE_WRITE_CODE				15
.eqv	FILE_CLOSE_CODE				16

FILE_BUFFER:	.space		FILE_BUFFER_SZ	# 1024
SRC_PATH:		.asciiz		"og.txt"
DST_PATH:		.asciiz		"copy.txt"

.text

file_copy_main:
#open source file
	la $a0, SRC_PATH	# ""
	li $a1, 0		# a1 = 0
	li $a2, 0		# a2 = 0
	li $v0, FILE_OPEN_CODE	# Value = 13 (Open file)
	syscall

#test the descriptor for fault
	move $s0, $v0		# s0 = 13
	slt $t0, $s0, $0	# if s0 is less than 0, exit program, else
	bne $t0, $0, EXIT_FILE_COPY

#open destination file
	la $a0, DST_PATH	# ""
	li $a1, 1		# a1 = 1
	li $a2, 0		# a2 = 0
	li $v0, FILE_OPEN_CODE	# Value = 13 (Open file)
	syscall

#test the descriptor for fault
	move $s1, $v0		# s1 = 13
	slt $t0, $s1, $0	# if s1 is less than 0, exit program, else
	bne $t0, $0, EXIT_FILE_COPY	

COPY_LOOP:
	#read buffer load of stuff
	li $v0, FILE_READ_CODE	# Value = 14
	move $a0, $s0		#a0 = 13
	la $a1, FILE_BUFFER
	li $a2, FILE_BUFFER_SZ	#a2 = 1024
	syscall	

	beq $0, $v0, CLOSE_RESOURCES	#if v0 = 0 jump to close resources
	
	move $a0, $s1		#a0 = 13
	la $a1, FILE_BUFFER
	move $a2, $v0		#a2 = 14
	li $v0, FILE_WRITE_CODE # Value = 15 (Write File)
	syscall	
	
	j COPY_LOOP	#repeat loop


EXIT_COPY_LOOP:


CLOSE_RESOURCES:

	li $v0, FILE_CLOSE_CODE		#v0 = 16
	move $a0, $s0
	syscall

	li $v0, FILE_CLOSE_CODE		#v0 = 16
	move $a0, $s1
	syscall
	EXIT_FILE_COPY:
jr $ra
