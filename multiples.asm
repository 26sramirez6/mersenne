 ## multiples.asm-- takes two numbers A and B, and prints out
 ## all the multiples of A from A to A * B.
 ## If B <= 0, then no multiples are printed.
 ## Registers used:
 ## $t0 - used to hold A.
 ## $t1 - used to hold B.
 ## $t2 - used to store S, the sentinel value A * B.
 ## $t3 - used to store m, the current multiple of A.
	.data
space: .asciiz " "
newline: .asciiz "\n"
	.text
main:		
	li $v0, 5         # read A
	syscall
	move $t0, $v0 
#
	li $v0, 5             # read B
	syscall
	move $t1, $v0 
#
	blez $t1, exit        # if B <= 0, exit.
#
	mul $t2, $t0, $t1     # S = A * B (upper value)
	move $t3, $t0         # m = A     (lower value)

 loop:
	move $a0, $t3         # print m.
	li $v0, 1 
	syscall 
#
	beq $t2, $t3, endloop # if m == S, we’re done.
	add $t3, $t3, $t0     # otherwise, m = m + A.
	la $a0, space         # print a space.
	li $v0, 4 
	syscall
	b loop                # iterate.
 endloop:
	la $a0, newline       # print a newline:
	li $v0, 4 
 syscall

 exit: 			      # exit the program:
	li $v0, 10 
	syscall 


