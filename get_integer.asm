 	# get_integer.asm--procedure to prompt the user to enter an
	# integer value. Read and return it. It takes no parameters.
	# Registers used:
	# s0 - used to save the result of procedure call
	# ra - jump-from address
	# v0 - syscall parameters.

	.data # Data declaration section
prompt:	 .asciiz "Enter an integer value\n"
	.text
main:	                            # Start of code section
	jal get_integer             # Call procedure
	move $s0, $v0               # Returned value v0 by convention. make copy.
	li $v0, 10                  # exit program
	syscall 
get_integer:
	li $v0, 4                   # prompt for input
	la $a0, prompt 
	syscall 
	li $v0, 5                   # system call to read keyboard int
	syscall 
	jr $ra                      # return to jump-from address
