	# adds the values of a hardcoded array in data segment
	# uses registers t0,t1,t2,t3
	# uses conditional branch for looping and addressing mode
	.data
array:	.word 1 22 300 14 19 33 2 4 6 100
	.text	
main:	
	li $t3, 0         # loop counter for clarity
	li $t2, 0         # t2 will accumulate sum so init to zero
	la $t0, array     # store address of array in t0
loop:	
	lw $t1, ($t0)     # use t1 to load each value of array
	add $t2,$t2,$t1
	addi $t3, $t3, 1  # increment counter
	addi $t0, $t0, 4  # increment address
	bne $t3,10,loop   # test loop condition
# 
	li,$v0,10         # exit
	syscall
	