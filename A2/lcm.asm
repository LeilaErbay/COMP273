# Program to calculate the least common multiple of two numbers

	.data		# variable declarations follow this line
first: 	.word 10	# the first integer
second: .word 15    	# the second integer                  
														
	.text		# instructions follow this line	
																	                    
main:     		# indicates start of code to test lcm the procedure
	la $t0, first			# store first and second numbers in registers
	la $t1, second
	
	lw $a0, 0($t0)			# load value from t0 & t1 (pointers pointing to 2 input numbers)
	lw $a1, 0($t1)			# and access the value with a0 and a1
	
	add $t0, $zero, $zero		#set lcm1 to zero
	add $t1, $zero, $zero		#set lcm2 to zero
	jal lcm
	
	add $t0, $v0, 0
	li $v0, 1			#syntax for printing a number
	add $a0, $t0, 0
	syscall	
	
	j end
	

lcm:	     		# the “lcm” procedure
	add $t0, $t0, $a0		# add a0 (10) to t0 (lcm1) and divide by 15
	div $t0, $a1
	mflo $t2			#quotient in lo
	mfhi $t3 			#remainder in hi
				
	add $t1, $t1, $a1		#add a1 (15) to t1 (lcm2) and divide by 10
	div $t1, $a0		
	mflo $t4			#quotient in lo
	mfhi $t5 			#remainder in hi
				
	bne $t3, 0, check		#if remainders (s3, s5) != 0, then incremement both lcm again
 check:	bne $t5, 0, lcm	
 	
 	add $v0, $t1, 0			# if remainder = zero for both lcm1 and lcm2 (ie t3 = t5) then answer lies in lcm1 and lcm2 (i
	jr $ra				#then answer lies in lcm1 and lcm2 (ie either t0 or t1 since both will contain same lcm)
	
end: 	nop






									
# End of program
