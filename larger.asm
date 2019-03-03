	# larger.asm-- prints the larger of two numbers specified
	# at runtime by the user.
	# Registers used:
	# $t0 - used to hold the first number.
	# $t1 - used to hold the second number.
	# $t2 - used to store the larger of $t1 and $t2.
	# $v0 - syscall parameter and return value.
	# $a0 - syscall parameter.
	.text
main:	
	li $v0, 5               # read int
	syscall            
	move $t0, $v0           # move into $t0.
	li $v0, 5               # read second int
	syscall 
	move $t1, $v0           # move into $t1
	bgt $t0, $t1, t0_bigger # If $t0 > $t1, branch to t0_bigger,
	move $t2, $t1           # otherwise, copy $t1 into $t2.
	b endif                 # and then branch to endif
t0_bigger:
	move $t2, $t0           # copy $t0 into $t2
endif:
	move $a0, $t2           # print $t2
	li $v0, 1               # syscall 1 for printing ints
	syscall 
	li $v0, 10              # exit
	syscall 
	# end of larger.asm.