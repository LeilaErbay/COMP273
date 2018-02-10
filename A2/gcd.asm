# Program to implement the Dijkstra's GCD algorithm

	.data		# variable declarations follow this line
str1: 	.asciiz "Enter the first integer: "
str2: 	.asciiz "Enter the second integer: "                  
														
	.text		# instructions follow this line	
	
main:     		# indicates start of code to test lcm the procedure

	li $v0, 4		#print Str1
	la $a0, str1
	syscall
	
	li $v0, 5		#take in Int1													                    
	syscall
	move $s0, $v0		#s0 holds input int 1
	
	li $v0, 4		#print in Str2
	la $a0, str2
	syscall
	
	li $v0, 5
	syscall
	move $s1, $v0		#s1 holds input int 2
	
	move $a0, $s0		# a0 holds int1 to be used in gcd 
	move $a1, $s1		# a1 holds int2 to be used in gcd 
	jal gcd
	
	move $s0, $v0		# place value from v0 into s0 so value is not overwritten
	li $v0, 1
	move $a0, $s0		# printing final int (ie gcd value)
	syscall
	
	j exit
	
gcd:	     		# the “gcd” procedure
	addi $sp,$sp,-4		# create space for ra  on the stack
	sw $ra,0($sp)		# save ra onto stack
	
base: 	beq $a0, $a1, return	# Base case: if int1 = int2 then go to return

if: 	bgt $a0,$a1, gtr	# if int1 > int2 then go to gtr
else: 	blt $a0, $a1,less	# if int1 < int2 then go to less

gtr:	sub $a0, $a0, $a1	# if int1 > int2, int1 = int1 - int2 & jump to gcd
	jal gcd
	
	addi $sp,$sp,4		#restore stack when we are coming out of recursion
	lw $ra,0($sp)		#pop off ra from stack when we are coming out of recursion
	jr $ra
	
less: 	sub $a1, $a1, $a0	#if int1 < int 2, int2 = int 2 - int1 & jump to gcd
	jal gcd
	
	addi $sp,$sp,4		#restore stack when we are coming out of recursion
	lw $ra,0($sp)		#pop off ra from stack when we are coming out of recursion
	jr $ra
return:		
	addi $sp,$sp,4		#base case: restore stack
	move $v0, $a0		# move final value into v reg
	lw $ra,0($sp)		#load stack pointer into ra
	jr $ra			# return to first jump (ie call from main)
	

exit: 
	nop			




									
# End of program
