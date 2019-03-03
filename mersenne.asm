	.data
is_prime_msg: .asciiz "Prime\n"
is_not_prime_msg: .asciiz "Not Prime\n"
	.text
main:
	li $v0, 5               	# read int
	syscall
	move $a0, $v0           	# move into $t0.
	jal F_IS_SMALL_PRIME
	li $v0, 10            		# 10 is the exit syscall.
	syscall               		# exit

	# $t0 = i (loop incrementer)
	# $t1 = p (prime input)
	# $t2 = p - 1 (loop exit condition)
	# $t3 = p % i
F_IS_SMALL_PRIME:
	li $t0, 2
	move $t2, $a0 				# copy a0 into t2
	move $t1, $a0 				# copy a0 into t1
	addi $t2, $t2, -1 			# subtract 1 for exit condition
loop:
	addi $t0, $t0, 1 			# increment counter
	div $t1, $t0				# mod operation
	mfhi $t3					# move remainder into t3
	beq $t3, $0, exit_prime 	# if ( p % i == 0 )
	b endif
exit_prime:
	la $a0, is_prime_msg		# print "is prime"
	jal F_PRINT
	li $v0, 0					# prime found, return 0
	jr $ra
endif:
	blt $t0, $t2, loop 			# loop condition
	la $a0, is_not_prime_msg	# print "is not prime"
	jal F_PRINT
	li $v0, 1
	jr $ra

F_PRINT:
	li $v0, 4             # 4 is the print_string syscall.
	syscall               # print string
	jr $ra
