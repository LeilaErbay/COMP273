# Program to capitalize the first letter of a string

	.data		# variable declarations follow this line
str: 		.asciiz "Enter the string to capitalize: "
userInput: 	.space    128
														
	.text		# instructions follow this line	
																	                    
main:     		# indicates start of code to test "upper" the procedure
				
	li $v0, 4		#print to screen: "Enter the string to capitalize: "
	la $a0, str	
	syscall
				
	li $v0, 8		#taking in user input
	la $a0, userInput	#a0 contains address of first char of userInput
	li $a1, 128
	syscall

	la $t0, 0($a0)		#t0 and t1 point to first char in string
	la $t1, 0($a0)	
	
	addi $t1, $t1, 1	#t1 points to second char in string
	
	lb $t2, 0($t0)		#load the value at t0 into t2
	lb $t3, 0($t1)		#load value at t1 into t3
	jal upper		#jump to upper
	 
	
	li $v0, 4
	la $a0, userInput	# initial string has been altered since t0 & t1 pointed to a0 which pointed to userInput
	syscall			# thus only need to load address of userInput to a0
	
	j exit

upper:	     		# the “upper” procedure
		
	 if:   ble $t2, 64, goto		#if first char is a special character (ie between 0 and 64)
	 goto: bgt $t2, 122, save		# and greater than 122
	 save:	sb $t2, 0($t0)			# then load value into char
		j increment			# else increment to next char
	
	first: 	bge $t2, 97, plus		#checking first char of string
	 plus:	ble $t2, 122, cap1stchar 	#if char is ASCII between 97-122
	 
						# increment if special char
	loop: 	beq $t3, $0, end1		#if 2nd pointer hits NULL, we're done
	end1:	beq $t3, 10, end
		
		lb $t2, 0($t0)			#else load value from t0 to t2
		lb $t3, 0($t1)			# and load value from t1 to t3
		
		
		beq $t2, 32, chk1		# check if t2 has a space, check if next char is lower case (chk1)
		bne $t2, 32, increment 		# if t2 is not lower case, increment both pointers
	chk1:	bge $t3, 97, chk2		# checking if 2nd char is lower case, if so capitalize it
	chk2: 	ble $t3, 122, capitalize	# if not, jump to increment
		j increment
	
  cap1stchar:	
  		addi $t2, $t2, -32		# for first char change the ASCII value held at t2
  		sb $t2, ($t0)			# store that ASCII value into t0
  		j increment
	
  capitalize:	
  		addi $t3, $t3, -32		#  if char after a space is lower case, change it to capital letter
  		sb $t3, 0($t1)			# store that value into $t3 
  		j increment			# then increment
  		
  increment:	addi $t0, $t0, 1		#increment address of poiners t0 and t1
  		addi $t1, $t1, 1
  		j loop				#restart the loop
  		
	
	end: 		#return final string in v0
 		jr $ra	
				
	exit: 
		nop





									
# End of program
