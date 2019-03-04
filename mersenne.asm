MAX_DIGITS = 350
BIG_INT_BYTES = 1404

	.data
	# little endian format
BigInt3Padded: .word 3 0 0 0
BigInt3PaddedSize: .word 4

BigInt3: .word 3
BigInt3Size: .word 1

BigInt42: .word 2 4
BigInt42Size: .word 2

BigInt30: .word 0 3
BigInt30Size: .word 2

BigInt7000: .word 0 0 0 7
BigInt7000Size: .word 4

SmallPrimeTestsArray: .word 7 81 127

NEWLINE:		.asciiz "\n"
PRINT_BIGINT1:	.asciiz "BigInt("
PRINT_BIGINT2: 	.asciiz ", Size="
PRINT_BIGINT3: 	.asciiz ")"

CompressTestString: 	.asciiz "::::::::Compress Tests::::::::\n"
ShiftRightTestString: 	.asciiz ":::::::Shift Right Test:::::::\n"
ShiftLeftTestString: 	.asciiz ":::::::Shift Left Test::::::::\n"
SmallPrimeTestString: 	.asciiz ":::::::Small Prime Tests::::::\n"
CompareTestString:	 	.asciiz ":::::::Comparison Tests:::::::\n"
	.text

main:
	jal small_prime_tests				# run small prime tests
	jal compress_tests					# run compress tests
	jal shift_right_tests				# run shift right tests
	jal shift_left_tests				# run shift left tests
	jal compare_tests					# run comparison tests

	# EXIT
	li $v0, 10			# exit code
	syscall				# exit

shift_left_tests:
	move $s2, $ra						# store return address

	la $a0, ShiftLeftTestString			# load test string into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the msg

	la $a0, BigInt7000					# a0 = &arr (ptr to big int array)
	lw $a1, BigInt7000Size				# a1 = the size of this big int
	jal big_int_push_stack				# construct the big int on stack and put in v0
	move $a0, $v0						# copy the big int address to a0
	move $s0, $v0						# also copy the big int address to s0 for later use
	jal big_int_full_print				# print the big integer uncompressed
	move $a0, $s0						# move big int back to a0 for shifting
	jal big_int_shift_left				# shift left first time
	move $a0, $s0						# move big int back to a0 for shifting
	jal big_int_shift_left				# shift left second time
	move $a0, $s0						# move big into back to a0 for printing
	jal big_int_full_print				# print the big integer
	jal big_int_pop_stack				# pop the big int from stack since no longer needed
	move $ra, $s2						# restore return address
	jr $ra

shift_right_tests:
	move $s2, $ra						# store return address

	la $a0, ShiftRightTestString		# load test string into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the msg

	la $a0, BigInt3						# a0 = &arr (ptr to big int array)
	lw $a1, BigInt3Size					# a1 = the size of this big int

	jal big_int_push_stack				# construct the big int on stack and put in v0
	move $a0, $v0						# copy the big int address to a0
	move $s0, $v0						# also copy the big int address to s0 for later use
	jal big_int_full_print				# print the big integer uncompressed
	move $a0, $s0						# move big int back to a0 for shifting
	jal big_int_shift_right				# shift right first time
	move $a0, $s0						# move big int back to a0 for shifting
	jal big_int_shift_right				# shift right second time
	move $a0, $s0						# move big int back to a0 for shifting
	jal big_int_shift_right				# shift right third time
	move $a0, $s0						# move big into back to a0 for printing
	jal big_int_full_print				# print the big integer
	jal big_int_pop_stack				# pop the big int from stack since no longer needed
	move $ra, $s2						# restore return address
	jr $ra

compress_tests:
	move $s2, $ra
	la $a0, CompressTestString			# load test string into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the msg
	la $a0, BigInt3Padded				# a0 = &arr (ptr to big int array)
	lw $a1, BigInt3PaddedSize			# a1 = the size of this big int
	jal big_int_push_stack				# construct the big int on stack and put in v0
	move $a0, $v0						# copy the big int address to a0
	move $s0, $v0						# also copy the big int address to s0 for later use
	jal big_int_full_print				# print the big integer uncompressed
	move $a0, $s0						# move big int back to a0 for compressing
	jal big_int_compress				# compress the big integer
	move $a0, $s0						# move big int back to a0 for printing
	jal big_int_full_print				# print the big integer
	jal big_int_pop_stack				# pop the big int from stack since no longer needed
	move $ra, $s2						# restore return address
	jr $ra

compare_tests:
	move $s2, $ra						# store return address
	la $a0, CompareTestString			# load test string into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the msg

	# construct and print big int 42
	la $a0, BigInt42					# a0 = &arr (ptr to big int array)
	lw $a1, BigInt42Size				# a1 = the size of this big int
	jal big_int_push_stack				# construct the big int on stack and put in v0
	move $s0, $v0						# save big int a
	move $a0, $v0						# copy the big int address to a0 for printing
	jal big_int_full_print				# print the big integer

	# construct and print big int 30
	la $a0, BigInt30					# a0 = &arr (ptr to big int array)
	lw $a1, BigInt30Size				# a1 = the size of this big int
	jal big_int_push_stack				# construct the big int on stack and put in v0
	move $s1, $v0						# save big int b
	move $a0, $v0						# copy big int b address to a0 for printing
	jal big_int_full_print				# print the big integer

	# run comparison 42 > 30
	move $a0, $s0						# copy big int a to a0
	move $a1, $s1						# copy big int b to a1
	jal big_int_compare					# compare size, store result in v0
	move $a0, $v0						# move result to a0 for printing
	li $v0, 1							# load print call
	syscall								# print
	la $a0, NEWLINE     				# load linefeed into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the new line

	# run comparison 42 < 30
	move $a0, $s1						# copy big int a to a0
	move $a1, $s0						# copy big int b to a1
	jal big_int_compare					# compare size, store result in v0
	move $a0, $v0						# move result to a0 for printing
	li $v0, 1							# load print call
	syscall								# print
	la $a0, NEWLINE     				# load linefeed into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the new line

	# run comparison 42 == 42
	move $a0, $s0						# copy big int a to a0
	move $a1, $s0						# copy big int b to a1
	jal big_int_compare					# compare size, store result in v0
	move $a0, $v0						# move result to a0 for printing
	li $v0, 1							# load print call
	syscall								# print
	la $a0, NEWLINE     				# load linefeed into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the new line

	jal big_int_pop_stack				# pop the big int from stack since no longer needed
	jal big_int_pop_stack				# pop the big int from stack since no longer needed
	move $ra, $s2						# restore return address
	jr $ra


small_prime_tests:
	move $s2, $ra							# store return address
	la $s0, SmallPrimeTestsArray			# store address of array in t0
	la $a0, SmallPrimeTestString			# load test string into $a0 for printing
	li $v0, 4          						# load print string syscall code
	syscall             					# print the msg

	lw $t1, ($s0)							# load SmallPrimeTests[0]
	move $a0, $t1           				# move the value to be tested into parameter
	jal is_small_prime						# check if prime
	move $a0, $v0							# move return value to be printed
	li $v0, 1								# load print int call
	syscall
	la $a0, NEWLINE     					# load linefeed into $a0 for printing
	li $v0, 4          						# load print string syscall code
	syscall             					# print the new line

	lw $t1, 4($s0)							# load SmallPrimeTests[1]
	move $a0, $t1           				# move the value to be tested into parameter
	jal is_small_prime						# check if prime
	move $a0, $v0							# move return value to be printed
	li $v0, 1								# load print int call
	syscall
	la $a0, NEWLINE     					# load linefeed into $a0 for printing
	li $v0, 4          						# load print string syscall code
	syscall             					# print the new line

	lw $t1, 8($s0)							# load SmallPrimeTests[2]
	move $a0, $t1           				# move the value to be tested into parameter
	jal is_small_prime						# check if prime
	move $a0, $v0							# move return value to be printed
	li $v0, 1								# load print int call
	syscall
	la $a0, NEWLINE     					# load linefeed into $a0 for printing
	li $v0, 4          						# load print string syscall code
	syscall             					# print the new line

	move $ra, $s2							# store return address
	jr $ra

	# PARAMETERS:
	# a0 = integer to be tested for primality
	# VARS:
	# t0 = i (loop incrementer)
	# t1 = p (prime input)
	# t2 = p - 1 (loop exit condition)
	# t3 = p % i
	# RETURNS:
	# v0 = 1 if prime, 0 else
is_small_prime:
	li $t0, 2								# initialize loop counter
	move $t1, $a0 							# copy a0 into t1
	move $t2, $a0 							# copy a0 into t2
	addi $t2, $t2, -1 						# subtract 1 for exit condition
	blt $t1, 2, is_small_prime_exit_0		# initial condition check

	is_small_prime_loop:
		div $t1, $t0						# mod operation
		mfhi $t3							# move remainder into t3
		beq $t3, $0, is_small_prime_exit_0 	# if ( p % i == 0 )
		addi $t0, $t0, 1 					# increment counter
		blt $t0, $t2, is_small_prime_loop	# go back to loop

	# prime
	is_small_prime_exit_1:
		li $v0, 1
		jr $ra
	# not a prime
	is_small_prime_exit_0:
		li $v0, 0
		jr $ra


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
	# t4 = offset to the bottom of the stack
	# t5 = 4 (size of word)
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
		addi $t0, $t0, -4					# move down the stack a word in the big int array
		bne $t1, $t3, big_int_compress_loop # if t1(bigint.size)==1, exit

	big_int_compress_exit:
		sw $t1, ($a0)						# store the new size into the top of the big_int struct
		jr $ra

	# PARAMETERS:
	# a0 = the address of the big int
	# VARS:
	# t0 = pointer to the big int (copied from a0)
	# t1 = size of the big int
	# t2 = bigint.digits[i]
	# t3 = i (loop decrementer)
	# t4 = offset to the bottom of the stack
	# t5 = 4 (size of word)
	# RETURNS:
	# nothing, alters bigint directly in stack
big_int_shift_right:
	move $t0, $a0							# t0 = a0 copy big int address into t0
	lw $t1, ($t0)							# t1 = bigint.size
	li $t5, 4								# set t5=4 (size of word)
	mul $t4, $t1, $t5   					# t4 = offset to bottom of the stack
	add $t0, $t0, $t4						# set t0 to address of most significant digit
	big_int_shift_right_loop:
		lw $t2, ($t0)							# t2 = bigint.digits[i-1]
		sw $t2, 4($t0)							# bigint.digits[i] = bigint.digits[i-1]
		addi $t4, $t4, -4						# decrease the original offset by a word
		addi $t0, $t0, -4						# move down the stack a word in the big int array
		bne $t4, 0, big_int_shift_right_loop	# if t4(offset)==0, exit

	sw $0, 4($t0)						# bigint.digits[0] = 0 (set lowest digit to 0)
	addi $t1, $t1, 1					# increment size of big int by 1 since right shift
	sw $t1, ($a0)						# store the new size into the top of the big_int struct
	jr $ra

	# PARAMETERS:
	# a0 = the address of the big int
	# VARS:
	# t0 = pointer to the big int (copied from a0)
	# t1 = size of the big int
	# t2 = bigint.digits[i]
	# t3 = loop counter
	# t4 = bigint.size - 1 (exit condition)
	# RETURNS:
	# nothing, alters bigint directly in stack
big_int_shift_left:
	move $t0, $a0							# t0 = a0 copy big int address into t0
	lw $t1, ($t0)							# t1 = bigint.size
	addi $t0, $t0, 4						# skip over size, set t0 bigint.digits[0]
	li $t3, 0								# loop counter
	subu $t4, $t1, 1						# (i<bigint.size-1) exit condition
	big_int_shift_left_loop:
		lw $t2, 4($t0)								# bigint.digits[i] = bigint.digits[i+1]
		sw $t2, ($t0)								# t2 = bigint.digits[i]
		addi $t3, $t3, 1							# increment i (loop counter)
		addi $t0, $t0, 4							# increment bigint.digits pointer by a word
		bne $t3, $t4, big_int_shift_left_loop		# if i==bigint.size-1, exit

	addi $t1, $t1, -1					# decrement size of big int by 1 since left shift
	sw $t1, ($a0)						# store the new size into the top of the big_int struct
	jr $ra


	# PARAMETERS:
	# a0 = the address of the big int "a"
	# a1 = the address of the big int "b"
	# VARS:
	# t0 = pointer to big int "a" (copied from a0)
	# t1 = pointer to big int "b" (copied from a0)
	# t2 = size of the big int "a"
	# t3 = size of the big int "b"
	# t4 = offset to reference next most significant digit
	# t5 = a.digits[i]
	# t6 = b.digits[i]
	# RETURNS:
	# v0 = 1 if "a" > "b", -1 if "b" > "a", 0 if "a"=="b"
big_int_compare:
	move $t0, $a0							# t0 = a0 copy 1st big int address into t0
	move $t1, $a1							# t1 = a1 copy 2nd big int address into t1
	lw $t2, ($t0)							# t2 = 1st bigint.size
	lw $t3, ($t1)							# t3 = 2nd bigint.size
	blt $t2, $t3, big_int_compare_exit_b	# if a.size < b.size
	bgt $t2, $t3, big_int_compare_exit_a	# if a.size > b.size

	li $t4, 4								# load the size of a word into t4
	mul $t4, $t4, $t2						# multiply 4*number of digits to get offset
	add $t0, $t0, $t4						# add offset to t0 to get most sig digit in a
	add $t1, $t1, $t4						# add offset to t1 to get most sig digit in b

	big_int_compare_loop:
		lw $t5, ($t0)							# load the next most sig digit in a
		lw $t6, ($t1)							# load the next most sig digit in b
		blt $t5, $t6, big_int_compare_exit_b	# if a[i] < b[i], exit to return -1
		bgt $t5, $t6, big_int_compare_exit_a	# if a[i] > b[i], exit to return 1
		addi $t4, $t4, -4						# decrease the offset, used as exit condition
		addi $t0, $t0, -4						# move to next sig digit
		addi $t1, $t1, -4						# move to next sig digit
		bne $t4, $0, big_int_compare_loop		# if offset 0, exit

	big_int_compare_exit_e:
		li $v0, 0							# return 0
		jr $ra

	big_int_compare_exit_b:
		li $v0, -1							# return -1
		jr $ra

	big_int_compare_exit_a:
		li $v0, 1
		jr $ra								# return 1
