#function to add two 32-bit integers and print result adding some
#	null-parameter function calls

	.data		
result_msg:	.asciiz "the result is: "
enter_msg1:	.asciiz "enter the first number: "
enter_msg2:	.asciiz "enter the second number: "
	.text
main:	
#prompt for first integer
	la $a0, enter_msg1
	jal print_message
# read first integer 	
	jal read_integer
	move $t0, $v0
#prompt for second integer
	la $a0, enter_msg2
	jal print_message
# read second integer
	jal read_integer
	move $t1, $v0
# add the two
	add $t1, $t0, $t1
# print result
	li $v0, 1
	move $a0, $t1
	syscall
# exit		
	li $v0, 10          # 10 is code for exit
	syscall
print_message:	
	li $v0, 4           # 4 is code for print 
	syscall             # call print
	jr $ra
read_integer:
	li $v0, 5           # 5 is code to read input
	syscall
	jr $ra
	
