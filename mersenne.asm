MAX_DIGITS = 350
BIG_INT_BYTES = 1404

	.data
	# little endian format

BigInt3Padded: .word 3 0 0 0
BigInt3PaddedSize: .word 4

BigInt0: .word 0
BigInt0Size: .word 1

BigInt1: .word 1
BigInt1Size: .word 1

BigInt2: .word 2
BigInt2Size: .word 1

BigInt3: .word 3
BigInt3Size: .word 1

BigInt4: .word 4
BigInt4Size: .word 1

BigInt7: .word 7
BigInt7Size: .word 1

BigInt11: .word 1 1
BigInt11Size: .word 2

BigInt12: .word 2 1
BigInt12Size: .word 2

BigInt30: .word 0 3
BigInt30Size: .word 2

BigInt42: .word 2 4
BigInt42Size: .word 2

BigInt48: .word 8 4
BigInt48Size: .word 2

BigInt67: .word 7 6
BigInt67Size: .word 2

BigInt7000: .word 0 0 0 7
BigInt7000Size: .word 4

BigInt9e6: .word 0 0 0 0 0 0 9
BigInt9e6Size: .word 7

BigInt1e7: .word 0 0 0 0 0 0 0 1
BigInt1e7Size: .word 8

BigInt9e9: .word 0 0 0 0 0 0 0 0 0 9
BigInt9e9Size: .word 10

BigInt7654321: .word 1 2 3 4 5 6 7
BigInt7654321Size: .word 7

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
MultiplyTestString:	 	.asciiz "::::::::Multiply Tests::::::::\n"
PowerTestString:	 	.asciiz "::::::::::Power Tests:::::::::\n"
SubtractTestString:	 	.asciiz "::::::::Subtract Tests::::::::\n"
ModTestString:	 		.asciiz ":::::::::Modulus Tests::::::::\n"
LLTTestString:	 		.asciiz ":::::::::::LLT Tests::::::::::\n"
MersenneScanString:		.asciiz ":::::::::Mersenne Scan::::::::\n"
MersenneTestingString:	.asciiz "Testing p = "
MersennePrimeString:	.asciiz " Found prime Mp = "
MersenneNotPrimeString:	.asciiz " Mp not prime\n"
	.text

main:
	jal small_prime_tests				# run small prime tests
	jal compress_tests					# run compress tests
	jal shift_right_tests				# run shift right tests
	jal shift_left_tests				# run shift left tests
	jal compare_tests					# run comparison tests
	jal multiply_tests					# run multiply tests
	jal power_tests						# run power tests
	jal subtract_tests					# run subtraction tests
	jal mod_tests						# run modulus tests
	jal llt_tests						# run llt tests
	jal mersenne_scan					# run the mersenne scan
	# EXIT
	li $v0, 10			# exit code
	syscall				# exit

mersenne_scan:
	move $s7, $ra						# store return address
	la $a0, MersenneScanString			# load test string into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the msg

	# load bigint 1 into s1
	la $a0, BigInt1					# a0 = &bigint1
	lw $a1, BigInt1Size				# a1 = bigint1.size
	jal big_int_push_stack			# v0 = create new big int on stack
	move $s1, $v0					# s1 = &1.size

	# load bigint 2 into s2
	la $a0, BigInt2					# a0 = &bigint2
	lw $a1, BigInt2Size				# a1 = bigint2.size
	jal big_int_push_stack			# v0 = create new big int on stack
	move $s2, $v0					# s2 = &2.size

	li $s0, 3	# t0 = p
	mersenne_scan_loop:
		move $a0, $s0 # a0 = p
		jal is_small_prime
		bne $v0, 1, mersenne_scan_not_mp_endif

		la $a0, MersenneTestingString	# load testing string into $a0 for printing
		li $v0, 4          				# load print string syscall code
		syscall             			# print the msg

		move $a0, $s0					# a0 = p
		li $v0, 1						# load print int
		syscall 						# print int

		move $a0, $s0					# a0 = p
		jal lucas_lehmer_test			# run LLT

		bne $v0, 1, mersenne_scan_not_mp	# if (not mersenne prime)

		# if (is_prime)...
		la $a0, MersennePrimeString		# load testing string into $a0 for printing
		li $v0, 4          				# load print string syscall code
		syscall             			# print the msg

		# load big int Mp
		jal big_int_zero_push_stack			# c = Mp (new big int on stack)
		move $a1, $v0						# t0 = &c.size
		move $a0, $s2						# a0 = &2.size
		move $a2, $s0						# a2 = p
		# pow(a0 = &2.size; a1 = &result; a2 = p)
		jal big_int_pow
		move $s3, $v0						# s3 = Mp = 2^p


		jal big_int_zero_push_stack			# v0 = &subtract result
		move $a2, $v0						# a2 = subtract result
		move $a0, $s3						# a0 = &Mp.size
		move $a1, $s1						# a1 = &1.size
		jal big_int_subtract

		move $a0, $v0						# a0 = &(2^p-1)
		jal big_int_full_print				# print 2^p-1

		# pop the 2 results allocated since no longer needed
		jal big_int_pop_stack
		jal big_int_pop_stack
		b mersenne_scan_not_mp_endif

		mersenne_scan_not_mp:
			la $a0, MersenneNotPrimeString	# load not prime string into $a0 for printing
			li $v0, 4          				# load print string syscall code
			syscall             			# print the msg

		mersenne_scan_not_mp_endif:
		addi $s0, $s0, 1
		bne $s0, 550, mersenne_scan_loop

	# pop bigint 1 and 2
	jal big_int_pop_stack
	jal big_int_pop_stack
	move $ra, $s7
	jr $ra


llt_tests:
	move $s2, $ra						# store return address
	la $a0, LLTTestString				# load test string into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the msg

	# BEGIN TEST LLT(11)
	li $a0, 3
	jal lucas_lehmer_test
	move $a0, $v0
	li $v0, 1							# load print integer syscall code
	syscall

	la $a0, NEWLINE     				# load linefeed into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the new line

	# BEGIN TEST LLT(67)
	li $a0, 67
	jal lucas_lehmer_test
	move $a0, $v0
	li $v0, 1							# load print integer syscall code
	syscall

	la $a0, NEWLINE     				# load linefeed into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the new line

	move $ra, $s2
	jr $ra

mod_tests:
	move $s2, $ra						# store return address
	la $a0, ModTestString				# load test string into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the msg

	# BEGIN TEST 7 % 4
	la $a0, BigInt7						# a0 = bigint7[0]
	lw $a1, BigInt7Size					# a1 = bigint7.size
	jal big_int_push_stack				# v0 = create new big int on stack
	move $s0, $v0						# s0 = &a.size

	la $a0, BigInt3						# a0 = bigint3[0]
	lw $a1, BigInt3Size					# a1 = bigint3.size
	jal big_int_push_stack				# v0 = create new big int on stack
	move $s1, $v0						# s1 = &b.size
	
	jal big_int_zero_push_stack			# c = new big int on stack
	move $s3, $v0						# t0 = &c.size

	move $a0, $s0						# a0 = &a.size
	move $a1, $s1						# a1 = &b.size
	move $a2, $s3						# a2 = &c.size
	jal big_int_mod

	move $a0, $v0
	jal big_int_full_print

	jal big_int_pop_stack				# pop c from stack
	jal big_int_pop_stack				# pop b from stack
	jal big_int_pop_stack				# pop a from stack

	# BEGIN TEST 48 % 12
	la $a0, BigInt48					# a0 = &bigint48[0]
	lw $a1, BigInt48Size				# a1 = bigint48.size
	jal big_int_push_stack				# v0 = create new big int on stack
	move $s0, $v0						# s0 = &a.size

	la $a0, BigInt12					# a0 = &bigint12[0]
	lw $a1, BigInt12Size				# a1 = bigint12.size
	jal big_int_push_stack				# v0 = create new big int on stack
	move $s1, $v0						# s1 = &b.size
	
	jal big_int_zero_push_stack			# c = new big int on stack
	move $s3, $v0						# t0 = &c.size

	move $a0, $s0						# a0 = &a.size
	move $a1, $s1						# a1 = &b.size
	move $a2, $s3						# a2 = &c.size
	jal big_int_mod

	move $a0, $v0
	jal big_int_full_print

	jal big_int_pop_stack				# pop c from stack
	jal big_int_pop_stack				# pop b from stack
	jal big_int_pop_stack				# pop a from stack

	# BEGIN TEST 9e9 - 7654321
	la $a0, BigInt9e9					# a0 = &bigint9e9[0]
	lw $a1, BigInt9e9Size				# a1 = bigint9e.size
	jal big_int_push_stack				# v0 = create new big int on stack
	move $s0, $v0						# s0 = &a.size

	la $a0, BigInt7654321				# a0 = &bigint7654321[0]
	lw $a1, BigInt7654321Size			# a1 = bigint7654321.size
	jal big_int_push_stack				# v0 = create new big int on stack
	move $s1, $v0						# s1 = &b.size
	
	jal big_int_zero_push_stack			# c = new big int on stack
	move $s3, $v0						# t0 = &c.size

	move $a0, $s0						# a0 = &a.size
	move $a1, $s1						# a1 = &b.size
	move $a2, $s3						# a2 = &c.size
	jal big_int_mod

	move $a0, $v0
	jal big_int_full_print

	jal big_int_pop_stack				# pop c from stack
	jal big_int_pop_stack				# pop b from stack
	jal big_int_pop_stack				# pop a from stack

	move $ra, $s2
	jr $ra

subtract_tests:
	move $s2, $ra						# store return address
	la $a0, SubtractTestString			# load test string into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the msg

	# BEGIN TEST 7 - 3
	la $a0, BigInt7						# a0 = bigint7[0]
	lw $a1, BigInt7Size					# a1 = bigint7.size
	jal big_int_push_stack				# v0 = create new big int on stack
	move $s0, $v0						# s0 = &a.size

	la $a0, BigInt3						# a0 = bigint3[0]
	lw $a1, BigInt3Size					# a1 = bigint3.size
	jal big_int_push_stack				# v0 = create new big int on stack
	move $s1, $v0						# s1 = &b.size
	
	jal big_int_zero_push_stack			# c = new big int on stack
	move $s3, $v0						# t0 = &c.size

	move $a0, $s0						# a0 = &a.size
	move $a1, $s1						# a1 = &b.size
	move $a2, $s3						# a2 = &c.size
	jal big_int_subtract

	move $a0, $v0
	jal big_int_full_print

	jal big_int_pop_stack				# pop c from stack
	jal big_int_pop_stack				# pop b from stack
	jal big_int_pop_stack				# pop a from stack

	# BEGIN TEST 42 - 12
	la $a0, BigInt42					# a0 = &bigint42[0]
	lw $a1, BigInt42Size				# a1 = bigint42.size
	jal big_int_push_stack				# v0 = create new big int on stack
	move $s0, $v0						# s0 = &a.size

	la $a0, BigInt12					# a0 = &bigint12[0]
	lw $a1, BigInt12Size				# a1 = bigint12.size
	jal big_int_push_stack				# v0 = create new big int on stack
	move $s1, $v0						# s1 = &b.size
	
	jal big_int_zero_push_stack			# c = new big int on stack
	move $s3, $v0						# t0 = &c.size

	move $a0, $s0						# a0 = &a.size
	move $a1, $s1						# a1 = &b.size
	move $a2, $s3						# a2 = &c.size
	jal big_int_subtract

	move $a0, $v0
	jal big_int_full_print

	jal big_int_pop_stack				# pop c from stack
	jal big_int_pop_stack				# pop b from stack
	jal big_int_pop_stack				# pop a from stack

	# BEGIN TEST 9e9 - 7654321
	la $a0, BigInt9e9					# a0 = &bigint9e9[0]
	lw $a1, BigInt9e9Size				# a1 = bigint9e.size
	jal big_int_push_stack				# v0 = create new big int on stack
	move $s0, $v0						# s0 = &a.size

	la $a0, BigInt7654321				# a0 = &bigint7654321[0]
	lw $a1, BigInt7654321Size			# a1 = bigint7654321.size
	jal big_int_push_stack				# v0 = create new big int on stack
	move $s1, $v0						# s1 = &b.size
	
	jal big_int_zero_push_stack			# c = new big int on stack
	move $s3, $v0						# t0 = &c.size

	move $a0, $s0						# a0 = &a.size
	move $a1, $s1						# a1 = &b.size
	move $a2, $s3						# a2 = &c.size
	jal big_int_subtract

	move $a0, $v0
	jal big_int_full_print

	jal big_int_pop_stack				# pop c from stack
	jal big_int_pop_stack				# pop b from stack
	jal big_int_pop_stack				# pop a from stack

	move $ra, $s2
	jr $ra

power_tests:
	move $s2, $ra						# store return address
	la $a0, PowerTestString				# load test string into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the msg

	# BEGIN TEST : 3 ^ 4
	la $a0, BigInt3						# a0 = bigint3[0]
	lw $a1, BigInt3Size					# a1 = bigint3.size
	move $s3, $a1						# s3 = bigint3.size (copy for later use)
	jal big_int_push_stack				# create new big int on stack
	move $s0, $v0						# s0 = bigint3 address

	jal big_int_zero_push_stack			# b = new big int on stack
	move $t0, $v0						# t0 = &b.size

	move $a0, $s0						# a0 = &a.size
	move $a1, $t0						# a1 = &b.size
	li $a2, 4							# a2 = 4
	jal big_int_pow

	move $a0, $v0
	jal big_int_full_print

	jal big_int_pop_stack				# pop b from stack
	jal big_int_pop_stack				# pop a from stack

	# BEGIN TEST : 42 ^ 42
	la $a0, BigInt42					# a0 = bigint42[0]
	lw $a1, BigInt42Size				# a1 = bigint42.size
	move $s3, $a1						# s3 = bigint42.size (copy for later use)
	jal big_int_push_stack				# create new big int on stack
	move $s0, $v0						# s0 = bigint42 address

	jal big_int_zero_push_stack			# b = new big int on stack
	move $t0, $v0						# t0 = &b.size

	move $a0, $s0						# a0 = &a.size
	move $a1, $t0						# a1 = &b.size
	li $a2, 42							# a2 = 42
	jal big_int_pow

	move $a0, $v0
	jal big_int_full_print

	jal big_int_pop_stack				# pop b from stack
	jal big_int_pop_stack				# pop a from stack

	move $ra, $s2
	jr $ra

multiply_tests:
	move $s2, $ra						# store return address

	la $a0, MultiplyTestString			# load test string into $a0 for printing
	li $v0, 4          					# load print string syscall code
	syscall             				# print the msg

	# BEGIN TEST : 3 * 7
	la $a0, BigInt3						# a0 = bigint3[0]
	lw $a1, BigInt3Size					# a1 = bigint3.size
	jal big_int_push_stack				# create new big int on stack
	move $s0, $v0						# s0 = bigint3 address

	la $a0, BigInt7						# a0 = bigint7[0]
	lw $a1, BigInt7Size					# a1 = bigint7.size
	jal big_int_push_stack				# create new big int "c" on stack
	move $s1, $v0						# s1 = bigint7 address
	
	jal big_int_zero_push_stack			# c = new big int on stack
	move $s3, $v0						# t0 = &c.size

	move $a0, $s0						# a0 = &a.size
	move $a1, $s1						# a1 = &b.size
	move $a2, $s3						# a2 = &c.size
	jal big_int_multiply

	move $a0, $v0
	jal big_int_full_print

	jal big_int_pop_stack				# pop c from stack
	jal big_int_pop_stack				# pop b from stack
	jal big_int_pop_stack				# pop a from stack

	# BEGIN TEST : 42 * 30
	la $a0, BigInt30					# a0 = bigint30[0]
	lw $a1, BigInt30Size				# a1 = bigint30.size
	jal big_int_push_stack				# create new big int on stack
	move $s0, $v0						# s0 = bigint30 address

	la $a0, BigInt42					# a0 = bigint42[0]
	lw $a1, BigInt42Size				# a1 = bigint42.size
	jal big_int_push_stack				# create new big int "c" on stack
	move $s1, $v0						# s1 = bigint42 address
	
	jal big_int_zero_push_stack			# c = new big int on stack
	move $s3, $v0						# t0 = &c.size

	move $a0, $s0
	move $a1, $s1						# a1 = &b.size
	move $a2, $s3						# a3 = &c.size
	jal big_int_multiply

	move $a0, $v0
	jal big_int_full_print

	jal big_int_pop_stack				# pop c from stack
	jal big_int_pop_stack				# pop b from stack
	jal big_int_pop_stack				# pop a from stack

	# BEGIN TEST : 9e6 * 1e7
	la $a0, BigInt9e6					# a0 = bigint30[0]
	lw $a1, BigInt9e6Size				# a1 = bigint30.size
	jal big_int_push_stack				# create new big int on stack
	move $s0, $v0						# s0 = bigint30 address

	la $a0, BigInt1e7					# a0 = bigint42[0]
	lw $a1, BigInt1e7Size				# a1 = bigint42.size
	jal big_int_push_stack				# create new big int "c" on stack
	move $s1, $v0						# s1 = bigint42 address
	
	jal big_int_zero_push_stack			# c = new bigint(0) on stack
	move $s3, $v0						# t0 = &c.size

	move $a0, $s0						# a0 = &a.size
	move $a1, $s1						# a1 = &b.size
	move $a2, $s3						# a2 = &c.size
	jal big_int_multiply

	move $a0, $v0
	jal big_int_full_print

	jal big_int_pop_stack				# pop c from stack
	jal big_int_pop_stack				# pop b from stack
	jal big_int_pop_stack				# pop a from stack

	move $ra, $s2						# restore return address
	jr $ra

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

	# construct and print big int 30
	la $a0, BigInt30					# a0 = &arr (ptr to big int array)
	lw $a1, BigInt30Size				# a1 = the size of this big int
	jal big_int_push_stack				# construct the big int on stack and put in v0
	move $s1, $v0						# save big int b

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
	# REGISTERS:
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

lucas_lehmer_test:
	subu $sp, $sp, 36					# make room for all saved registers
	sw $ra, ($sp)						# store return address on stack
	sw $s0, 4($sp)						# store s0 on stack
	sw $s1, 8($sp)						# store s1 on stack
	sw $s2, 12($sp)						# store s2 on stack
	sw $s3, 16($sp)						# store s3 on stack
	sw $s4, 20($sp)						# store s4 on stack
	sw $s5, 24($sp)						# store s5 on stack
	sw $s6, 28($sp)						# store s6 on stack
	sw $s7, 32($sp)						# store s7 on stack

	move $s0, $a0					# s0 = p

	la $a0, BigInt1					# a0 = &bigint1
	lw $a1, BigInt1Size				# a1 = bigint1.size
	jal big_int_push_stack			# v0 = create new big int on stack
	move $s1, $v0					# s1 = &1.size

	la $a0, BigInt2					# a0 = &bigint2
	lw $a1, BigInt2Size				# a1 = bigint2.size
	jal big_int_push_stack			# v0 = create new big int on stack
	move $s2, $v0					# s2 = &2.size

	jal big_int_zero_push_stack			# c = Mp (new big int on stack)
	move $a1, $v0						# t0 = &c.size
	move $a0, $s2						# a0 = &2.size
	move $a2, $s0						# a2 = p
	# pow(a0 = &2.size; a1 = &result; a2 = p)
	jal big_int_pow
	move $s4, $v0						# s4 = Mp = 2^p - 1

	jal big_int_zero_push_stack			# d = new big int on stack
	move $a2, $v0						# a2 = &d.size
	move $a0, $s4						# a0 = &Mp.size
	move $a1, $s1						# a1 = &1.size
	jal big_int_subtract
	# (we dont need big int 1 anymore)
	move $s1 , $v0						# s1 = &(Mp - 1) 

	la $a0, BigInt4					# a0 = &bigint4
	lw $a1, BigInt4Size				# a1 = bigint4.size
	jal big_int_push_stack			# v0 = create new big int on stack
	move $s4, $v0					# s4 = &4.size
	move $a0, $v0
	jal big_int_push_and_copy		# v0 = &4copy.size
	move $s3, $v0					# s3 = &4copy.size

	jal big_int_zero_push_stack		# v0 = mult result
	move $s5, $v0					# s5 = &mult result
	jal big_int_zero_push_stack		# v0 = sub result
	move $s6, $v0					# s6 = &sub result
	jal big_int_zero_push_stack		# v0 = mod result
	move $s7, $v0					# s7 = &mod result

	subu $sp, $sp, 4				# push p on top of stack
	sw $s0, ($sp)					# sp = s0 = p
	li $s0, 0						# i = 0
	lucas_lehmer_test_loop:
		# REMOVE ME
		# move $a0, $s4
		# jal big_int_full_print
		# move $a0, $s3
		# jal big_int_full_print
		# REMOVE ME

		move $a0, $s4					# a0 = &s
		move $a1, $s3					# a1 = &s copy
		move $a2, $s5					# a2 = a5 = &product result
		jal big_int_multiply			# s * s

		move $a0, $s5					# a0 = &product
		move $a1, $s2					# a1 = &2.size
		move $a2, $s6					# a2 = s6 = &sub result
		jal big_int_subtract

		move $a0, $s6					# a0 = &sub result
		move $a1, $s1					# a1 = &Mp
		move $a2, $s7					# a2 = &mod result 
		jal big_int_mod

		# copy mod result into s4
		move $a0, $s4					# a0 = &mult input
		move $a1, $s7					# a1 = &mod result
		jal big_int_copy				# s4 = mod result

		# copy mod result into s3
		move $a0, $s3					# a0 = &mult input
		move $a1, $s7					# a1 = &mod result
		jal big_int_copy				# v0 = &mod result

		addi $s0, $s0, 1				# i++
		lw $t1, ($sp)					# t1 = p
		subu $t1, $t1, 2				# t1 = p - 2
		bne $s0, $t1, lucas_lehmer_test_loop
	addi $sp, $sp, 4				# pop p from top of stack


	jal big_int_zero_push_stack		# bigint 0
	move $s0, $v0

	# REMOVE ME
	move $a0, $s7
	jal big_int_full_print
	move $a0, $s0
	jal big_int_full_print
	# REMOVE ME

	move $a0, $s7 
	move $a1, $s0
	jal big_int_compare
	
	beq $v0, $0, lucas_lehmer_return_1
	lucas_lehmer_return_0: # s!=zero --> not prime
		li $v0, 0
		b lucas_lehmer_endif
	lucas_lehmer_return_1: # if s==zero --> prime
		li $v0, 1
	lucas_lehmer_endif:

	# we pushed 10 big ints on stack, pop all them
	jal big_int_pop_stack # 1
	jal big_int_pop_stack # 2
	jal big_int_pop_stack # 3
	jal big_int_pop_stack # 4
	jal big_int_pop_stack # 5
	jal big_int_pop_stack # 6
	jal big_int_pop_stack # 7
	jal big_int_pop_stack # 8
	jal big_int_pop_stack # 9
	jal big_int_pop_stack # 10

	lw $ra, ($sp)						# restore ra from stack
	lw $s0, 4($sp)						# restore s0 from stack
	lw $s1, 8($sp)						# restore s1 from stack
	lw $s2, 12($sp)						# restore s2 from stack
	lw $s3, 16($sp)						# restore s3 from stack
	lw $s4, 20($sp)						# restore s4 from stack
	lw $s5, 24($sp)						# restore s5 from stack
	lw $s6, 28($sp)						# restore s6 from stack
	lw $s7, 32($sp)						# restore s7 from stack
	addi $sp, $sp, 36					# pop all the saved registers from stack
	jr $ra

	# PARAMETERS:
	# a0 = the address of the big int
	# REGISTERS:
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
	# REGISTERS:
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
	# REGISTERS:
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

	# PARAMETERS:
	# None
	# RETURNS:
	# v0 = &a.size (newly pushed big int of all zeros on stack)
big_int_zero_push_stack:
	subu $sp, $sp, BIG_INT_BYTES
	move $t0, $sp
	li $t2, 1
	sw $t2, ($t0)
	addi $t0, $t0, 4
	sw $0, ($t0)
	move $v0, $sp
	jr $ra

	# PARAMETERS
	# a0 = &a.size
	# REGISTERS
	# t0, t1
	# RETURNS
	# v0 = &a.size
big_int_assign_zero:
	lw $t0, ($a0)		# t0 = a.size
	li $t1, 0			# t1 = 0 (counter
	move $t2, $a0		# t2 = &a.size
	addi $t2, $t2, 4	# t2 = &a.digits[0]
	big_int_assign_zero_loop:
		sw $0, ($t2)		# a.digits[i] = 0
		addi $t2, $t2, 4	# t2 += 4	
		addi $t1, $t1, 1	# t1++
		bne $t1, $t0, big_int_assign_zero_loop # t1 != a.size
	move $v0, $a0
	jr $ra

	# short hand for popping stack
big_int_pop_stack:
	addi $sp, $sp, BIG_INT_BYTES
	jr $ra

big_int_copy:
	move $t4, $a0						# t4 = &a.size
	move $t3, $a1						# t3 = &b.size
	lw $t0, ($a1)						# t0 = b.size
	sw $t0, ($a0)						# a.size = b.size
	li $t2, 0							# t2 = 0 loop counter
	addi $t3, $t3, 4					# t3 = &b.digits[0]
	addi $t4, $t4, 4					# t4 = &a.digits[0]
	big_int_copy_loop:				
		lw $t5, ($t3)					# t5 = b.digits[i]
		sw $t5, ($t4)					# a.digits[i] = b.digits[i]
		addi $t3, $t3, 4				# t3++	
		addi $t4, $t4, 4				# t4++
		addi $t2, $t2, 1				# t2++
		bne $t2, $t0, big_int_copy_loop	# if i < b.size, continue
	jr $ra

big_int_push_and_copy:
	subu $sp, $sp, BIG_INT_BYTES		# allocate BigInt b  on stack
	move $t4, $a0						# t4 = &a.size
	lw $t0, ($a0)						# t0 = a.size
	sw $t0, ($sp)						# b.size = a.size 
	li $t2, 0							# t2 = 0 loop counter
	move $t3, $sp						# t3 = &b.size
	addi $t3, $t3, 4					# t3 = &b.digits[0]
	addi $t4, $t4, 4					# t4 = &a.digits[0]
	big_int_push_and_copy_loop:				
		lw $t5, ($t4)					# t5 = a.digits[i]
		sw $t5, ($t3)					# b.digits[i] = a.digits[i]
		addi $t3, $t3, 4				# t3++	
		addi $t4, $t4, 4				# t4++
		addi $t2, $t2, 1				# t5++
		bne $t2, $t0, big_int_push_and_copy_loop	# if i < a.size, continue
	move $v0, $sp
	jr $ra


	# PARAMETERS:
	# a0 = address of big int a
	# a1 = address of big int b (result)
	# a2 = int p
big_int_pow:
	move $v1, $ra
	jal big_int_push_and_copy	# v0 = a0 copy on stack
	move $ra, $v1
	move $t0, $v0				# t = &copy.size

	# push the s registers on the stack to get saved
	subu $sp, $sp, 32					# make room for all saved registers
	sw $s0, ($sp)						# store s0 on stack
	sw $s1, 4($sp)						# store s1 on stack
	sw $s2, 8($sp)						# store s2 on stack
	sw $s3, 12($sp)						# store s3 on stack
	sw $s4, 16($sp)						# store s4 on stack
	sw $s5, 20($sp)						# store s5 on stack
	sw $s6, 24($sp)						# store s6 on stack
	sw $s7, 28($sp)						# store s7 on stack

	move $s5, $t0 		# s5 = &copy.size
	move $s0, $a0		# s0 = &a.size
	move $s1, $a1		# s1 = &b.size
	move $s2, $a2		# s2 = p
	move $s4, $ra		# s4 = return address

	li $s3, 1
	big_int_pow_loop:
		move $a0, $s0		# a0 = &total product so far
		move $a1, $s5 		# a1 = &copy.size
		move $a2, $s1		# a2 = &b.size
		jal big_int_multiply

		move $a0, $s0		# a0 = "copy to" = previous product
		move $a1, $v0		# a1 = "copy from" = latest product
		jal big_int_copy	# a0 <--(copy into) a1

		addi $s3, $s3, 1
		bne $s3, $s2, big_int_pow_loop

	
	lw $s0, ($sp)						# restore s0 from stack
	lw $s1, 4($sp)						# restore s1 from stack
	lw $s2, 8($sp)						# restore s2 from stack
	lw $s3, 12($sp)						# restore s2 from stack
	lw $s4, 16($sp)						# restore s2 from stack
	lw $s5, 20($sp)						# restore s2 from stack
	lw $s6, 24($sp)						# restore s2 from stack
	lw $s7, 28($sp)						# restore s2 from stack
	addi $sp, $sp, 32					# pop all the saved registers from stack

	jal big_int_pop_stack			# pop the copy of a ($s5)
	move $ra, $v1
	jr $ra

	# PARAMETERS:
	# a0 = address of big int a
	# a1 = address of big int b
	# a2 = address of big int c
	# REGISTERS:
	# uses t0-t8, interchangebly
	# s0-s7 also used but saved and restored on stack
	# RETURNS:
	# v0 = address of (a * b) = &c
big_int_multiply:
	# push the s registers on the stack to get saved
	subu $sp, $sp, 32					# make room for all saved registers
	sw $s0, ($sp)						# store s0 on stack
	sw $s1, 4($sp)						# store s1 on stack
	sw $s2, 8($sp)						# store s2 on stack
	sw $s3, 12($sp)						# store s3 on stack
	sw $s4, 16($sp)						# store s4 on stack
	sw $s5, 20($sp)						# store s5 on stack
	sw $s6, 24($sp)						# store s6 on stack
	sw $s7, 28($sp)						# store s7 on stack

	move $s0, $ra		# s0 = return address
	move $s1, $a0		# s1 = &a.size
	lw $s3, ($s1)		# s3 = a.size
	move $s2, $a1		# s2 = &b.size
	lw $s4, ($s2)		# s4 = b.size

	move $s6, $a2		# s6 = &c.size
	add $s5, $s3, $s4  	# s5 = a.size + b.size 
	sw $s5, ($s6)		# c.size = a.size + b.size

	move $a0, $a2				# a0 = &c.size
	jal big_int_assign_zero		# zero out c

	addi $s1, $s1, 4	# s1 = &a.digits[0]
	addi $s2, $s2, 4	# s2 = &b.digits[0]
	addi $s6, $s6, 4	# s6 = &c.digits[0]
	li $t0, 0    		# t0 = i = 0
	li $s7, 10			# s7 = 10 used for division
	big_int_mulitply_outer_loop:
		li $t1, 0						# t1 = carry = 0
		move $t2, $t0					# t2=j=i
		add $t3, $s3, $t0				# t3=a.n+i
		mul $t6, $t0, 4					# t6 = i*4
		add $t6, $t6, $s2				# t6 = &b.digits[i]
		lw $t8, ($t6)					# t8 = b.digits[i]

		big_int_multiply_inner_loop:
			sub $t5, $t2, $t0			# t5 = j - i
			mul $t5, $t5, 4				# t5 = 4*(j - i)
			add $t5, $s1, $t5			# t5 = &a[j-i]
			lw $t5, ($t5)				# t5 = a[j-i]
			mul $t4, $t8, $t5			# t4 = b.digits[i] * a.digits[j-i]
			mul $t5, $t2, 4				# t5 = j * 4
			add $t5, $s6, $t5			# t5 = &c.digits[j]
			lw $t6, ($t5)				# t6 = c.digits[j]
			add $t7, $t6, $t4			# t7 = c.digits[j] + (b.digits[i] * a.digits[j-i])
			add $t7, $t7, $t1			# t7 = t7 + carry = val
			div $t7, $s7				# t7 / 10 --> val / 10
			mflo $t1					# t1 = val / 10
			mfhi $t4					# t4 = val % 10
			sw $t4, ($t5)				# c.digits[j] = t4 = val % 10
			addi $t2, $t2, 1			# t2 = t2 + 1 --> j++
			bne $t2, $t3, big_int_multiply_inner_loop

		ble $t1, $0, big_int_multiply_endif		# if ( carry <= 0 ) skip
		addi $t5, $t5, 4						# t5 = &c.digits[j]
		lw $t4, ($t5)							# t4 = c.digits[j]
		add $t7, $t4, $t1						# t7 = val = c.digits[j] + carry
		div $t7, $s7							# t7 / 10 --> val / 10
		mflo $t1								# t1 = carry = val / 10
		mfhi $t4								# t4 = val % 10
		sw $t4, ($t5)							# c.digits[j] = val % 10
		big_int_multiply_endif:
			addi $t0, $t0, 1					# t0 = i++
			bne $t0, $s4, big_int_mulitply_outer_loop 	# i < b.n

	
	addi $s6, $s6, -4					# s6 = &c.size
	move $a0, $s6						# a0 = &c.size, for compression
	jal big_int_compress				# compress and return c
	move $ra, $s0						# restore return address
	move $v0, $s6						# v0 = &c.size

	lw $s0, ($sp)						# restore s0 from stack
	lw $s1, 4($sp)						# restore s1 from stack
	lw $s2, 8($sp)						# restore s2 from stack
	lw $s3, 12($sp)						# restore s2 from stack
	lw $s4, 16($sp)						# restore s2 from stack
	lw $s5, 20($sp)						# restore s2 from stack
	lw $s6, 24($sp)						# restore s2 from stack
	lw $s7, 28($sp)						# restore s2 from stack
	addi $sp, $sp, 32					# pop all the saved registers from stack
	jr $ra

	# PARAMETERS:
	# a0 = address of big int a
	# a1 = address of big int b
	# a2 = address of big int c
	# REGISTERS:
	# uses t0-t8, interchangebly
	# s0-s7 also used but saved and restored on stack
	# RETURNS:
	# v0 = address of (a - b) = &c
big_int_subtract:
	# push the s registers on the stack to get saved
	subu $sp, $sp, 32					# make room for all saved registers
	sw $s0, ($sp)						# store s0 on stack
	sw $s1, 4($sp)						# store s1 on stack
	sw $s2, 8($sp)						# store s2 on stack
	sw $s3, 12($sp)						# store s3 on stack
	sw $s4, 16($sp)						# store s4 on stack
	sw $s5, 20($sp)						# store s5 on stack
	sw $s6, 24($sp)						# store s6 on stack
	sw $s7, 28($sp)						# store s7 on stack

	move $s0, $ra		# s0 = return address
	jal big_int_push_and_copy # v0 = &(copy of a).size
	move $s1, $v0		# s1 = &a.size
	lw $s3, ($s1)		# s3 = a.size
	move $s2, $a1		# s2 = &b.size
	move $t9, $s2		# t9 = &b.size
	lw $s4, ($s2)		# s4 = b.size

	move $s6, $a2		# s6 = &c.size
	move $s7, $s6		# s7 = &c.size

	sw $s3, ($s6)				# c.size = a.size
	move $a0, $a2				# a0 = &c.size
	jal big_int_assign_zero		# zero out c

	addi $s1, $s1, 4	# s1 = &a.digits[0]
	addi $s2, $s2, 4	# s2 = &b.digits[0]
	addi $s6, $s6, 4	# s6 = &c.digits[0]

	sub $t0, $s3, $s4	# t0 = a.size - b.size
	move $t3, $s2		# t3 = &b.digits[0]
	mul $t4, $s4, 4		# t4 = 4*(b.size)
	add $t3, $t3, $t4	# t3 = &b.digits[b.size]
	li $t1, 0			# t1 = 0 (counter)
	bge $t1, $t0, skip_assign_zero_loop
	big_int_sub_assign_zero_loop:
		sw $0, ($t3)		# b.digits[i+b.size] = 0
		addi $t3, $t3, 4	# t3 += 4	
		addi $t1, $t1, 1	# t1++
		bne $t1, $t0, big_int_sub_assign_zero_loop # t1 != a.size - b.size
	skip_assign_zero_loop:
	sw $s3 ($t9)		# b.size = a.size

	li $t0, 0		# t0 = i = 0
	li $t8, 9		# t8 = 9
	big_int_subtract_outer_loop:
		lw $t1, ($s1)			# t1 = a.digits[i]
		lw $t2, ($s2)			# t2 = b.digits[i]
		lw $t3, ($s6)			# t3 = c.digits[i]

		bge $t1, $t2, perform_subtract	# if (a.digits[i] >= b.digits[i])
		addi $t1, $t1, 10		# t1 = a.digits[i] + 10
		sw $t1, ($s1)			# a.digits[i] = a.digits[i] + 10

		add $t5, $t0, 1		# t5 = j = i + 1
		bge $t5, $s3, perform_subtract # if (j >= a.size)
		add $t6, $s1, 4		# t6 = &a.digits[j] = &a.digits[i+1]
		big_int_subtract_inner_loop:
			lw $t7, ($t6)			# t7 = a.digits[j]
			beq $t7, $0, set_to_9	# if (a.digits[i] == 0)
			addi $t7, $t7, -1		# t7 = a.digits[j] - 1
			sw $t7, ($t6)			# a.digits[j] -= 1
			b perform_subtract
			set_to_9:
				sw $t8, ($t6)

			addi $t6, $t6, 4	# t6 = a.digits[j+1]
			addi $t5, $t5, 1	# j++
			bne $t5, $s3, big_int_subtract_inner_loop	# j != a.size

		perform_subtract:
			sub $t4, $t1, $t2	# t4 = a.digits[i] - b.digits[i]
			sw $t4, ($s6)		# c.digits[i] = a.digits[i] - b.digits[i]

		addi $s1, $s1, 4		# s1 = &a.digits[i+1]
		addi $s2, $s2, 4		# s2 = &b.digits[i+1]
		addi $s6, $s6, 4		# s6 = &c.digits[i+1]
		addi $t0, $t0, 1		# i++
		bne $t0, $s3, big_int_subtract_outer_loop # i != a.size

	move $a0, $s7						# a0 = &c.size, for compression
	jal big_int_compress				# compress and return c
	jal big_int_pop_stack				# pop the copy of a from stack
	move $ra, $s0						# restore return address
	move $v0, $s7						# v0 = &c.size

	# restore the s registers
	lw $s0, ($sp)						# restore s0 from stack
	lw $s1, 4($sp)						# restore s1 from stack
	lw $s2, 8($sp)						# restore s2 from stack
	lw $s3, 12($sp)						# restore s2 from stack
	lw $s4, 16($sp)						# restore s2 from stack
	lw $s5, 20($sp)						# restore s2 from stack
	lw $s6, 24($sp)						# restore s2 from stack
	lw $s7, 28($sp)						# restore s2 from stack
	addi $sp, $sp, 32					# pop all the saved registers from stack
	jr $ra

	# PARAMETERS:
	# a0 = address of big int a
	# a1 = address of big int b
	# a2 = address of big int c
	# REGISTERS:
	# uses t0-t8, interchangebly
	# s0-s7 also used but saved and restored on stack
	# RETURNS:
	# v0 = address of (a % b) = &c
big_int_mod:
	# push the s registers on the stack to get saved
	subu $sp, $sp, 32					# make room for all saved registers
	sw $s0, ($sp)						# store s0 on stack
	sw $s1, 4($sp)						# store s1 on stack
	sw $s2, 8($sp)						# store s2 on stack
	sw $s3, 12($sp)						# store s3 on stack
	sw $s4, 16($sp)						# store s4 on stack
	sw $s5, 20($sp)						# store s5 on stack
	sw $s6, 24($sp)						# store s6 on stack
	sw $s7, 28($sp)						# store s7 on stack

	move $s0, $ra		# s0 = return address
	move $s1, $a0		# s1 = &a.size
	move $s2, $a1		# s2 = &b.size
	move $a0, $a1		# a0 = &b.size
	jal big_int_push_and_copy # v0 = &(copy of b).size
	move $s5, $v0		# s5 = &(copy of b).size		

	move $s6, $a2		# s6 = &c.size
	move $s7, $s6		# s7 = &c.size

	big_int_mod_shift_loop:
		move $a0, $s1	# a0 = &a.size
		move $a1, $s5	# a1 = &(copy of b).size
		jal big_int_compare
		bne $v0, 1, exit_big_int_mod_shift_loop
		move $a0, $s5	# a0 = &(copy of b).size
		jal big_int_shift_right
		b big_int_mod_shift_loop

	exit_big_int_mod_shift_loop:
	move $a0, $s5
	jal big_int_shift_left
	big_int_mod_sub_outer_loop:
		move $a0, $s5	# a0 = &bcopy.size
		move $a1, $s2	# a1 = &b.size
		jal big_int_compare
		beq $v0, -1, exit_big_int_mod_sub_outer_loop

		big_int_mod_sub_inner_loop:
			move $a0, $s1	# a0 = &a.size
			move $a1, $s5	# a1 = &bcopy.size
			jal big_int_compare
			beq $v0, -1, exit_big_int_mod_sub_inner_loop
			
			move $a0, $s1	# a0 = &a.size
			move $a1, $s5	# a1 = &bcopy.size
			move $a2, $s6	# a2 = &c.size
			
			jal big_int_subtract	# c = a - b

			move $a0, $s1	# a0 = &a.size (copy to)
			move $a1, $s6	# a1 = &c.size (copy from)
			jal big_int_copy	# a = c
			b big_int_mod_sub_inner_loop

		exit_big_int_mod_sub_inner_loop:
		move $a0, $s5
		jal big_int_shift_left
		b big_int_mod_sub_outer_loop

	exit_big_int_mod_sub_outer_loop:
	jal big_int_pop_stack 		# pop &bcopy
	move $v0, $s6		# v0 = &c.size
	move $ra, $s0		# s0 = return address
	# restore the s registers
	lw $s0, ($sp)					# restore s0 from stack
	lw $s1, 4($sp)					# restore s1 from stack
	lw $s2, 8($sp)					# restore s2 from stack
	lw $s3, 12($sp)					# restore s2 from stack
	lw $s4, 16($sp)					# restore s2 from stack
	lw $s5, 20($sp)					# restore s2 from stack
	lw $s6, 24($sp)					# restore s2 from stack
	lw $s7, 28($sp)					# restore s2 from stack
	addi $sp, $sp, 32				# pop all the saved registers from stack
	jr $ra

	# PARAMETERS:
	# a0 = the address of the big int
	# REGISTERS:
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
	# REGISTERS:
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
	# REGISTERS:
	# t0 = pointer to the big int (copied from a0)
	# t1 = size of the big int
	# t2 = bigint.digits[i]
	# t3 = loop counter
	# t4 = bigint.size - 1 (exit condition)
	# RETURNS:
	# nothing, alters bigint directly in stack
big_int_shift_left:
	move $t0, $a0							# t0 = a0 copy big int address into t0
	lw $t1, ($t0)							# t1 = a.size
	addi $t0, $t0, 4						# skip over size, set t0 a.digits[0]
	li $t3, 0								# loop counter
	subu $t4, $t1, 1						# t4 = a.size-1 exit condition
	ble $t4, 0, big_int_shift_left_exit		# exit if i>=a.size-1
	big_int_shift_left_loop:
		lw $t2, 4($t0)								# bigint.digits[i] = bigint.digits[i+1]
		sw $t2, ($t0)								# t2 = bigint.digits[i]
		addi $t3, $t3, 1							# increment i (loop counter)
		addi $t0, $t0, 4							# increment bigint.digits pointer by a word
		bne $t3, $t4, big_int_shift_left_loop		# if i==bigint.size-1, exit
	big_int_shift_left_exit:
	addi $t1, $t1, -1					# decrement size of big int by 1 since left shift
	sw $t1, ($a0)						# store the new size into the top of the big_int struct
	jr $ra


	# PARAMETERS:
	# a0 = the address of the big int "a"
	# a1 = the address of the big int "b"
	# REGISTERS:
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
