MAX_DIGITS = 350
BIG_INT_BYTES = 1404

	.data
A_BIG_INT3: .word 0 2 0 0
A_BIG_INT_SIZE3: .word 4
NEWLINE:		.asciiz "\n"
PRINT_BIGINT1:	.asciiz "BigInt("
PRINT_BIGINT2: 	.asciiz ", Size="
PRINT_BIGINT3: 	.asciiz ")"
	.text

	# creates 2 big intergers on stack
	# prints them and pops
main:
	la $a0, A_BIG_INT3					# a0 = &arr (ptr to big int array)
	lw $a1, A_BIG_INT_SIZE3				# a1 = the size of this big int
	jal big_int_push_stack				# construct the big int on stack and put in v0
	move $a0, $v0						# copy the big int address to a0
	move $s0, $v0						# also copy the big int address to s0 for later use
	jal big_int_full_print				# print the big integer uncompressed
	move $a0, $s0						# move big int back to a0 for compressing
	jal big_int_compress				# compress the big integer
	move $a0, $s0						# move big int back to a0 for printing
	jal big_int_full_print				# print the big integer
	jal big_int_pop_stack				# pop the big int from stack since no longer needed

	# EXIT
	li $v0, 10			# exit code
	syscall				# exit

	# PARAMETERS:
	# a0 = the address of the big int
	# VARS:
	# t0 = pointer to the big int (copied from a0)
	# t1 = size of the big int
	# t2 = i (loop iterator starting at 0)
	# t3 = bigint.digits[i]
	# t4 = offset to get bottom of stack
	# t5 = 4 (size of word)
	#
	# RETURNS:
	# nothing
big_int_print:
	move $t0, $a0		# t0 = a0 copy big int address into t0
	lw $t1, ($t0)		# t1 = bigint.size
	li $t5, 4			# set t5=4 (size of word)
	mul $t4, $t1, $t5   # t4 = offset to bottom of the stack
	add $t0, $t0, $t4	# set t0 to address of most significant digit
	li $t2, 0			# initialize the counter
	big_int_print_loop:
		lw $t3, ($t0)						# t3 = bigint.digits[i]
		move $a0, $t3						# a0 = t3 (move t3 to a0 for printing)
		li $v0, 1							# load print integer syscall code
		syscall								# print the integer
		addi $t0, $t0, -4					# move down one word in the big int array
		addi $t2, $t2, 1					# t2++ increment the loop counter
		bne $t2, $t1, big_int_print_loop 	# if counter==size (last digit), exit

	jr $ra

	# PARAMETERS:
	# a0 has arr[0] of big int
	# VARS:
	# s0 = big int address
	# s1 = big int size
	# s2 = return address
	# calls big_int_print
big_int_full_print:
	subu $sp, $sp, 12					# make room for s0, s1, s2 on the stack to be restored later
	sw $s0, ($sp)						# store s0 on stack
	sw $s1, 4($sp)						# store s1 on stack
	sw $s2, 8($sp)						# store s2 on stack

	move $s0, $a0						# move the address of the bigint to s0
	lw $s1, ($s0)						# s1 = bigint.size
	move $s2, $ra						# move return address into s2

	la $a0, PRINT_BIGINT1  				# load msg1 into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the msg

	move $a0, $s0						# move back for printing
	jal big_int_print					# print the digits

	la $a0, PRINT_BIGINT2 				# load msg2 into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the msg

	move $a0, $s1						# copy the size into a0 for printing
	li $v0, 1          					# load print string syscall code
	syscall             				# print the msg

	la $a0, PRINT_BIGINT3 				# load msg3 into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall

	la $a0, NEWLINE     				# load linefeed into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the new line

	move $ra, $s2						# restore return address
	lw $s0, ($sp)						# restore s0 from stack
	lw $s1, 4($sp)						# restore s1 from stack
	lw $s2, 8($sp)						# restore s2 from stack
	addi $sp, $sp, 12					# pop s0, s1, s2 from stack
	jr $ra

	# PARAMETERS:
	# a0 has arr[0] of big int
	# a1 has size of big int (len(arr))
	# VARS:
	# t1 = arr[0]
	# t2 = loop counter
	# t3 = address of the stack pointer
	# t4 = current element in big int data segment
	# RETURNS:
	# v0 = address of big int on stack
big_int_push_stack:
	move $t1, $a0						# copy address of big int static array in t1
	move $t0, $a1						# copy size of big int into t0
	subu $sp, $sp, BIG_INT_BYTES		# allocate BigInt on stack
	sw $t0, ($sp)						# bigint.size = t0, the top of the stack is BigInt.size
	li $t2, 0							# loop counter
	move $t3, $sp						# copy top of stack to t3
	addi $t3, $t3, 4					# move t4 pointer up 1 word so size isnt overwritten
	big_int_push_stack_loop:					# fill the big int
		lw $t4, ($t1)							# get t4 = a_big_int[i]
		sw $t4, ($t3)							# stack.push(a_big_int[i])
		addi $t3, $t3, 4						# move the stack pointer one word up
		addi $t2, $t2, 1						# i++ increment loop counter
		addi $t1, $t1, 4						# a_big_int++ increment address
		bne $t2, $t0, big_int_push_stack_loop	# if i < bigint.size, continue
	move $v0 $sp						# move the top of the stack pointer into v0
	jr $ra

	# short hand for popping stack
big_int_pop_stack:
	addi $sp, $sp, BIG_INT_BYTES
	jr $ra

	# PARAMETERS:
	# a0 = the address of the big int
	# VARS:
	# t0 = pointer to the big int (copied from a0)
	# t1 = size of the big int
	# t2 = bigint.digits[i]
	# t3 = loop condition, bigint.size > 1
	# RETURNS:
	# nothing, alters size directly in stack
big_int_compress:
	move $t0, $a0							# t0 = a0 copy big int address into t0
	lw $t1, ($t0)							# t1 = bigint.size
	li $t5, 4								# set t5=4 (size of word)
	mul $t4, $t1, $t5   					# t4 = offset to bottom of the stack
	add $t0, $t0, $t4						# set t0 to address of most significant digit
	li $t3, 1								# loop exit condition (when i=1)
	bgt $t1, $t3, big_int_compress_loop 	# only start the loop if the size greater than 1
	big_int_compress_loop:
		lw $t2, ($t0)						# t2 = bigint.digits[i]
		bne $t2, $0, big_int_compress_exit	# if (bigint.digits[i]==0)
		addi $t1, $t1, -1					# bigint.size -= 1
		addi $t0, $t0, 4					# move up one word in the big int array
		bne $t1, $t3, big_int_compress_loop 	# if t1(bigint.size)==1, exit

	big_int_compress_exit:
		sw $t1, ($a0)						# store the new size into the top of the big_int struct
		jr $ra

