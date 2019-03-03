	.data
is_prime_msg: .asciiz " : Prime\n"
is_not_prime_msg: .asciiz " : Not Prime\n"
newline: .asciiz "\n"
array:	.word 7 81 127
	.text
	# s0: array pointer
	# s1: loop counter 0->10
	# s2: array[s0]
main:
	la $s0, array				# store address of array in s1
	li $s1, 0					# loop counter for exit condition

	main_loop:
		lw $s2, ($s0)				# load each value of the array using counter
		move $a0, $s2           	# move the value to be tested into parameter
		jal F_IS_SMALL_PRIME		# check if prime
		addi $s1, $s1, 1			# increment loop counter
		addi $s0, $s0, 4			# increment address
		bne $s1, 3, main_loop		# test loop condition (10 elements * 4)
	# EXIT
	li $v0, 10            		# 10 is the exit syscall.
	syscall               		# exit

	# $t0 = i (loop incrementer)
	# $t1 = p (prime input)
	# $t2 = p - 1 (loop exit condition)
	# $t3 = p % i
	# $t4 = saves the return address for F_PRINT_PRIME
	# returns 0 if prime, 1 else
F_IS_SMALL_PRIME:
	move $t4, $ra					# save the return address

	loop_init:
		li $t0, 2					# initialize loop counter
		move $t2, $a0 				# copy a0 into t2
		move $t1, $a0 				# copy a0 into t1
		addi $t2, $t2, -1 			# subtract 1 for exit condition
		bge $t0, $t2, exit_prime	# initial condition check
	loop:
		div $t1, $t0				# mod operation
		mfhi $t3					# move remainder into t3
		beq $t3, $0, exit_not_prime # if ( p % i == 0 )
		b endif
	exit_not_prime:					# prime found
		move $a0, $t1				# move the prime into parameter a0 for printing
		jal F_PRINT_NOT_PRIME		# print the prime in function
		li $v0, 0					# return 0
		move $ra, $t4				# restore the return address
		jr $ra
	endif:
		addi $t0, $t0, 1 			# increment counter
		blt $t0, $t2, loop 			# go back to loop
	exit_prime:
		move $a0, $t1				# move the non-prime into parameter a0 for printing
		jal F_PRINT_PRIME			# print the non-prime in function
		li $v0, 1					# return 1
		move $ra, $t4				# restore the return address
		jr $ra

	# does not use any temporary registers
F_PRINT_PRIME:
	li $v0, 1			  		# load print integer syscall code
	syscall				  		# print the prime in a0
	la $a0, is_prime_msg  		# print prime message
	li $v0, 4             		# 4 is the print_string syscall.
	syscall               		# print string
	jr $ra

	# does not use any temporary registers
F_PRINT_NOT_PRIME:
	li $v0, 1			  		# load print integer syscall code
	syscall				  		# print the non-prime in a0
	la $a0, is_not_prime_msg  	# print not prime message
	li $v0, 4             		# 4 is the print_string syscall.
	syscall               		# print string
	jr $ra
