	# add2.asm-- A program that computes the sum of two user-input integers
	#            and prints the result
	# Registers used:
	# t0 - used to hold the result.
	# t1 - used to hold the constant 1.
	# v0 - syscall parameter.

	.data
newline:	.asciiz "\n"
	.text
main:
	li $v0, 5           # read first number
	syscall 
	move $t0, $v0       # copy to t0
	li $v0, 5           # read second number
	syscall 
	move $t1, $v0       # copy to t1
	add $t2, $t0, $t1   # compute the sum in t2

	move $a0, $t2       # load result into $a0 for printing
	li $v0, 1           # load print syscall code
	syscall             # print
	la $a0, newline     # load linefeed into $a0 for printing
	li $v0, 4           # load print string syscall code
	syscall             # print the new line
	li $v0, 10          # load exit syscall code
	syscall             # exit