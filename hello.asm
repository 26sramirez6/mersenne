	# hello.asm-- A "Hello World" program.
	# Registers used:
	# $v0 - syscall parameter and return value.
	# $a0 - syscall parameter-- the string to print.
	#
	.data
msg: .asciiz "Hello World\n"
	.text
main:
	la $a0, msg           # load the addr of msg into $a0 ($a0 is required)
	li $v0, 4             # 4 is the print_string syscall.
	syscall               # print string
	li $v0, 10            # 10 is the exit syscall.
	syscall               # exit
