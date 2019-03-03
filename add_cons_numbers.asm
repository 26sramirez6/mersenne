	# add_cons_numbers.asm-- adds all numbers between input low and high
	.data
input1:	.asciiz "Enter low number: "
input2:	.asciiz "Enter high number: "
	.text
main:	
# prompt for low number
	la $a0, input1	
	li $v0, 4
	syscall
# read
	li $v0, 5
	syscall
	move $t0, $v0      #t0 is low value
# prompt for high number
	la $a0, input2
	li $v0, 4
	syscall
# read 
	li $v0, 5
	syscall
	move $t1, $v0
# use $t2 to accumulate. start with lower number
	move $t2, $t0    
loop:	
	addi $t0, $t0, 1    
	add $t2,$t0,$t2
	bne $t0,$t1,loop
# print result
	move $a0, $t2
	li $v0, 1
	syscall
# exit	
	li $v0, 10
	syscall


