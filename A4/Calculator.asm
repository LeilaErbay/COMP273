#Student: LEILA ERBAY
#ID: 260672158

#Calculator
#You will recieve marks based
#on functionality of your calculator.
#REMEMBER: invalid inputs are ignored.


#Have fun!
.data
str:    	.asciiz "Calculator for Mips \n"
str1:   	.asciiz "press 'c' for clear and 'q' for quit:\n"
str2:   	.asciiz "Result: \n"
goodBye: 	.asciiz "I hope you enjoyed using this calulator. Goodbye :) \n"
errorStr: 	.asciiz "You started an equation with an operator. This is incorrect. You can either enter a number, clear, or quit. \n"
option:    	.asciiz  "You can either enter an operation, clear, or quit. \n"
nL: 		.asciiz "\n"
opError:	.asciiz "You've entered too many operators\n"
str3:   	.asciiz "Enter your MMIO Simulator"
errorZero:	.asciiz "You entered an expression that is divison by zero. This is not allowed. You can either enter a number clear or quit.\n"
enterStrError: 	.asciiz "You pressed enter at an improper time. Please enter a proper expression, clear, or quit \n"
option2: 	.asciiz "You can either clear or quit\n"
option3:	.asciiz "You can enter a proper expression, clear or quit.\n"

.text
    .globl main

#TODO:
#main procedure, that will call your calculator
main:
    
    
   	li $v0, 4       # single print statement    
    	la $a0, str3
    	syscall
    
    	la $a1, str	#display "Calculator for Mips \n"
    	jal Strings
    
    	la $a1, str1	#display "press 'c' for clear and 'q' for quit:\n"
    	jal Strings
    
    	jal Calculator

Strings:				#Strings: process for displaying strings to MMIO (a1 should string to display)
    	lui $t0, 0xffff #ffff0000
loopStr:lw $t1, 8($t0) #control
    	andi $t1,$t1,0x0001
    	beq $t1, $0, loopStr
    
    	lb $t3, 0($a1)
    	sw $t3, 12($t0) #data
    	beq $t3, 10, strDone
    	addi $a1, $a1, 1
    
    	j Strings
strDone: jr $ra  
    
     	#s6 = multiDigit counter
  	#s5 = counter for NUM op NUM
    	#s2 = counter for how many times result occurs
    	#s1 = flag to tell how to handle an operation
    
    
Calculator:
   		jal fstDigit        	#first digit of a number has its own operation	
	Next:   add $a0,$v0,$zero   	# in an infinite loop
   		jal Write 	    	# writing the digit
    		j otherDigits		#other digits will either be an operator,c,q, or digit that will be added to first digit of a number

otherDigits:
    		jal Read        
    		add $a0,$v0,$zero   # in an infinite loop
    		jal Write
    		j otherDigits

fstDigit: 	lui $t0, 0xffff #ffff0000		#Special Read for first Digit
loop:   	lw $t1, 0($t0) #control
    		andi $t1,$t1,0x0001
    		beq $t1,$zero,loop
    		lb $v0, 4($t0) #data    
    
    		#check if the char is -
    		beq, $v0, 45, negative  #need to add a negative to the stack (if this is the first digit of a number and there is a negative sign, that the number must be negative)
    		#all operators (except negative) must check that the operator is not be used stupidly (ie * num1 does not make sense as the first expr)
    		beq $v0, 42, chkMC      # op fo * 
    		beq $v0, 43, chkMC      #op for +
    		beq $v0, 47, chkMC      # op for /
   		beq $v0, 99, clear      #no errors for clearing
    		beq $v0, 113, quit      #no errors for quitting
    		beq $v0, 10, chkCtr     #checking result
    		blt $v0, 48, loop       #if ascii <48 or >57 then it's not a number so keep reading until a number is entered
    		bgt $v0, 57, loop
    
    		addi $s5, $s5, 1	#if it's the first number then num_op_num counter increases: s5 = s5+1
    		addi $s6, $s6, 1	#if it's a number then MultiDigit counter (s6) increases : s6 = s6 +1
   
    		move $s0, $v0           
   		addi $s0, $s0, -48      	#convert number to ascii
    		bgt $s6, 1, multiDigit      #if multiDigit ctr > 1 then there are 2+ digits in the number, MIGHT NOT NEED THIS LINE
   		beq $t3, 1, negate
    
    		addi $sp, $sp, -4       #if it's not a multidigit then add single number to stack
    		sw $s0, 0($sp)
    
    		j Next			#then write out digit

chkCtr: 	beq $s5, 0, error       #if there is no result to calculate then error 
		beq $s5, 2, error   	#if we have Num + then result, this is an error
    		j result		#else determine result 
            
chkMC: 		beq $s5, 0, assumeZero       #if you do an operation like *, -, / without any number in front of the operator, this is wrong
    		j op
    
#read for the later digits of the number
Read:   	lui $t0, 0xffff #ffff0000
Loop1:  	lw $t1, 0($t0) #control
   		andi $t1,$t1,0x0001
   		beq $t1,$zero,Loop1
    		lw $v0, 4($t0) #data    
    
    		beq $v0, 42, chkOpCtr       # * operator for multiplication
    		beq $v0, 43, chkOpCtr       #op for +
   		beq $v0, 45, chkOpCtr       #op for -
    		beq $v0, 47, chkOpCtr       # op for /

    		beq $v0, 10, chkOpC 	    #result
    		beq $v0, 99, clear
    		beq $v0, 113, quit
    		blt $v0, 48, Read	  #if value read is not a number/operator/c/q then read until a valid input is read
    		bgt $v0, 57, Read

    		move $s0, $v0 		  #s0 holds ascii val of int
    		addi $s0, $s0, -48  	  #convert ascii to int
   		addi $s6,$s6, 1     	  #add 1 to multiDigit counter if the input is read as the second digit of a number
    		bgt $s6, 1, multiDigit    #check if multiDigit counter > 1, this means that it's 2+ digits in a row
    
    		addi $s5, $s5, 1    	#assuming this is the num2 of Num1 op Num2 (then we will  calculate the result)
    		addi $sp, $sp, -4   	#add num to stack
    		sw $s0, 0($sp)
    
    		
    		beq $s5, 3, result  	#if this is the final num  (ie Num1 op Num2) then calculate the result
    		jr $ra

chkOpC: 	beq $s5, 2, error   	#if we have Num + then result, this is an error
    		j result        	#else it's valid to press enter 

chkOpCtr:	beq $s5, 2, error   #if the expr is like num1 op and the new input is an op then error (ie num1 op op = wrong (except for negatives))
    		j op     	
    
multiDigit:
		lw $t6, 0($sp)
    		addi $sp, $sp, 4    #pop stack
   		mul $t6, $t6, 10    #multiply first digit by 10
    		add $s0, $s0, $t6   #add it to the next and store in stack
    		addi $sp, $sp, -4   #else it's a number
    		sw $s0, 0($sp)      #save number to the stack
        
    		jr $ra

Write:  lui $t0, 0xffff #ffff0000	#WRITING DIGITS/OPERATORS to MMIO display
Loop2:  lw $t1, 8($t0) #control
    	andi $t1,$t1,0x0001
    	beq $t1,$zero,Loop2
    	sw $a0, 12($t0) #data   
    	jr $ra

op: 	#if it's an op need to add space, op, space
    		add $s6, $0, $0     #set counter for multiDigits to 0 since an operator has been placed
    		addi $s5, $s5, 1    #add 1 to Num_Op_Num counter
    		
    		#bgt $s5, 3, OperationError	 ##MUST CHECK		
    											
    		addi $a0, $0, 32    #write space
    		jal Write
    		move $a0, $v0
    		addi $sp, $sp, -4
    		sw $a0, 0($sp)      #save operator on stack
    		jal Write           #write operator
    		addi $a0, $0, 32
    		jal Write           #write space
    
    		j fstDigit      #go to fstDigit bc now we are at a new number
    
    
    
    #determines the result after s5 = 3 
    #at this time num1, op, num2 are all on the stack
    #is the remainder of a stack needed?
cumulativeResult:
    		li $s4, 100 #s4 = 100 in int
    		mtc1 $s4, $f5   
    		cvt.s.w $f5, $f5    #f5 = 100 in fp 
    
   
    popNLoad:	addi $sp, $sp, -4   
    		lw $t5, 0($sp)      #load the remainder of a divisor, DONT NEED THE REMAINDER...
    		addi $sp, $sp, 4
    		lw $t9, 0($sp)      #last thing that was on stack (ie Num2)
    		addi $sp, $sp, 4
    		lw $t8, 0($sp)      #t8 = operator
    		addi $sp, $sp, 4
    		lw $t7,0($sp)       #t7 = num1
    		addi $sp, $sp, 4    
        	#move ptr to the front of the stack
 
    		
    	skip:	beq $t5, 0, math	#if there is no remainder
    	
    		
                #at this point f10 will have the remainder (either 0._ or 0._ _)
                
math:   	beq $t8, 43, plus
    		beq $t8, 42, multiply
    		beq $t8, 47, divide
    		beq $t8, 45, minus
		
plus:
   	add $t6, $t7, $t9   	#t6 = num1 + num2
   	move $s0, $t6
   	blt $t6, 0, showSign	#checks if final result is negative
    	add $t7, $0, $0     	#set num1 to 0, no longer needed
    	j stack

minus:
    	sub $t6, $t7, $t9   	#t6 = num1-num2	
    	move $s0, $t6
    	blt $t6, 0, showSign
    	add $t7, $0, $0     	#set num1 to 0, no longer needed
    	j stack

    
multiply:
    	mult $t7, $t9
    	mflo $t6    		#t6 = num1 * num2
    	move $s0, $t6
    	blt $t6, 0, showSign
    	add $t7, $0, $0     	#set num1 to 0, no longer needed
    	j stack

showSign: 
	   addi $s1, $0, 1		#hit flag that result will be negative	
	   add $t7, $0, $0 	#set any decimal part to 0 bc integer addition, minus, multiplication must be rounded
	   j stack

#if t6 is negative at this point then s1 = 1


divide: 
    	beq $t9, 0, DivByZero	#division by 0 is error
    	
convertInttoFp:         	#CONVERT num1 and num2 to FP
   	mtc1 $t7, $f7
   	cvt.s.w $f7, $f7	
   	mtc1 $t9, $f9   
    	cvt.s.w $f9, $f9    	
#need to move both t7 and t9 to floats --> f7 = num1 , f9 = num2

#ACTUAL DIVIDING
    	div.s $f4, $f7, $f9 	#f4 = f7/ f9    
    	mul.s $f4, $f4, $f5     #t4 *100 (you have all the digits you need)
    
convert:	
	cvt.w.s $f1, $f4        #converting numbers needed from fp to int
    	mfc1 $t6, $f1           #t6 = int value with decimal included at end of int (ie 1.50 = 150)

    	div $t6, $s4            #value /100
    	mfhi $t7            	#remainder (ie decimal values)
   	mflo $t6            	#quotient
   	move $s0, $t6
   	bge $t6, 0, stack
   	
   	addi $s1, $0, 1
    	j stack


  
stack:
    	beq $s1, 1, stackNeg	#if s1 = 1 then there negatives will be displayed
    	
    	#else only positive values will needed to be stacked
    	addi $sp, $sp, -16
    	sw $t7, 0($sp)      #store the decimal remainder in the stack
    	addi $sp, $sp, 12   
    	sw $t6, 0($sp)      # store the important value in the stack (ie it represents num1 )
    	j printResult       #front of stack

stackNeg:
	jal chkT6		#this will be necessary for multiplication, addition, minus (need to check if t6 is negative so i can add it to the stack)
	jal chkT7
	#STORING POSITIVE NUMBER ON A STACK, EVEN IF IT"S A NEGATIVE NUMBER
    	addi $sp, $sp, -16
    	sw $t7, 0($sp)      #store the decimal remainder in the stack
    	addi $sp, $sp, 12   
    	sw $t6, 0($sp)      # store the important value in the stack (ie it represents num1 )

    	j printResult
   
printResult:    			# need to load each bit of the number( num1) and the remainder
       					#check that we finished reading the int????
    addi $t4, $0, 10    		#will be used to access each individual char
    add $t5, $0, $0			#don't want a previous remainder affecting the new one?		
  	
  #t6 has whole number, t7 has decimal,  if it's a negative decimal then display negative decimal
  #checking different cases: -num,-0._, 0._,  
 otherChecks:
 	beq $s1, 1, needNegSign		#s1 = 1 negative exists; ; 
 	beq $s1, 2, needNegSign		#s1 = 2, t6 is negative
 	beq $s1, 3, needNegSign		# s1 = 3, t7 is negative,
 	beq $s1, 4, needNegSign		#s1 = 4 both t6 and t7 are negative (ie whole number/decimal are neg)
 	j noSign
 needNegSign:
 	jal negativeSign		#prints negative sign
 	
 noSign:
 	jal checkIfDecimalNeeded		#will print 0._ or - 0._
 	beq $s2, 9, done			
 	
   	jal checkIfBothAreZero					#check if t6 and t7 are 0
   	beq $s2, 3, done
   	
   #either just decimals have been printed or just zeros have been printed 
   #else we need to print negatives numbers or positive numbers
   	move $t6, $t6
    	jal charInt
    	bgt $t7, 0, printDot
    	
    	addi $t6, $t5, -48
    	beq $s1, 2, convertT6		#if s1 = 2 then only t6 was negative  so need to negate t6 to store on the stack
	beq $s1, 3, convertT7		#if s1 = 3 then only t7 was negative so need to negate t7 to store on the stack
	beq $s1, 4, convertBoth		#if s1 = 4 then t6 and t7 were negative
					#if t6 = 0, is because of charInt division, s0 should have final result

convertDone:	
	move $t6, $s0
	sw $t6, 0($sp)			#storing final value (positive or negative in stack)
	j done

printDot:
    	beq $t7, 0, done
    	addi $a0, $0, 46	#prints the decimal point
    	jal Write
    	
    
printRemainder:
    	move $t6, $t7		#prints decimal portion if this part exists
    	jal charInt
 
 #at this point t6, t7 are positive versions if they needed to be negated
	beq $s1, 2, convertT6		#if s1 = 2 then only t6 was negative  so need to negate t6 to store on the stack
	beq $s1, 3, convertT7		#if s1 = 3 then only t7 was negative so need to negate t7 to store on the stack
	beq $s1, 4, convertBoth		#if s1 = 4 then t6 and t7 were negative
	
	move $t6, $s0
	sw $t6, 0($sp)			#storing final value (positive or negative in stack)

done:   j rDone
    
negative:		# need to write negative sign first
    	move $a0, $v0       #write writes a0
    	jal Write       #write negative sign
    	addi $t3, $0, 1     #a flag for negative
    	j fstDigit      #read digit
negate: #number is already converted to int
    	mul $s0, $s0,-1
    	addi $sp, $sp, -4       #add single digit to stack
    	sw $s0, 0($sp) 
    	add $t3, $0, $0 
    	j Next


error:
	beq $v0, 10, enterError	
	la $a1, nL
    	jal Strings	
    	la $a1, errorStr		#errors if enter is pressed improperly
    	jal Strings
    	la $a1, nL
    	jal clearStack
    	j fstDigit

 enterError:
 	la $a1, nL
    	jal Strings			#if enter is pressed as the first thing, i consider this an error
 	la $a1, enterStrError
    	jal Strings
    	la $a1, nL
    	jal Strings
    	jal clearStack
    	add $s6, $0, $0	#reset multiDigit Counter
   	add $s5, $0, $0		#set num1_op_num2 counter to 1, bc we already num1
    	add $s1, $0, $0	
    	j fstDigit

clear:			#clear everything including first digit
    addi $a0, $0, 12
    jal Write
    add $s6, $0, $0     #set multiDigit counter to 0
    add $s5, $0, $0     #set Num_Op_Num counter to 0
    add $s2, $0, $0     #reset result counter
    jal clearStack
    addi $sp, $sp, 4
    sw $0, 0($sp)	#clear all values on the stack
    
    la $a1, str
    jal Strings
    la $a1, str1
    jal Strings
    j Calculator
    
quit:
    la $a1, goodBye		#if user enters quit, display nice message and exit
    jal Strings
    
    li $v0, 10
    syscall

result:
    	addi $s2, $0, 1    #increase result counter
    	addi $t4, $0, 10
    	bgt $s5, 3, OperationError	 #checks if user enters something weird like 1 +*9, doesn't find 1+ -1 as an error though
    	
    	la $a1, nL		#print newlin
    	jal Strings
    	
    	la $a1, str2	#print "Result:"
    	jal Strings 
	jal cumulativeResult	#finds the result

rDone:  la $a1, nL
    	jal Strings
    	bge $t7,50, increment		#if a decimal exists that is >= 0.5, increment whole number
 
cL: 	jal clearStack
    	la $a1, option
    	jal Strings
    
   	 add $s6, $0, $0	#reset multiDigit Counter
   	 addi $s5, $0, 1		#set num1_op_num2 counter to 1, bc we already num1
    	add $s1, $0, $0		#set flag for ops to 0	
    	j otherDigits
    
charInt:		#my method to display each number (recurisve stack and pop)
baseCase:
    beq $t6, 0, popStack        #quotient  = 0  
    

    div $t6, $t4
    mfhi $t5    #remainder		#remainders are placed on the stack, and will be popped which will display the correct digits
    mflo $t2    #quotient
    move $t6, $t2

    addi $sp, $sp -8
    sw $ra, 4($sp)
    sw $t5, 0($sp)
    
    jal charInt

popStack:		#pop stack to dsiplay the digits
    lw $ra 4($sp)
    lw $t5, 0($sp)
    addi $t5, $t5, 48
    move $a0, $t5
    jal Write
    lw $ra 4($sp)
    addi $sp, $sp, 8
    
    jr $ra
    
clearStack:		#clears all but the first digit so that it can be reused for the next expression
    addi $sp, $sp, -16
    sw $0, 0($sp)
    addi $sp, $sp, 4
    sw $0, 0($sp)
    addi $sp, $sp, 4
    sw $0, 0($sp)
    addi $sp, $sp, 4
    sw $0, 0($sp)
    addi $sp, $sp, 4
    jr $ra
	
DivByZero:
	la $a1, nL
    	jal Strings		#if user tries to divide by zero, error pops up
	la $a1, errorZero
    	jal Strings
    	la $a1,nL
    	jal Strings
    	jal clearStack
    	add $s6, $0, $0	#reset multiDigit Counter
   	add $s5, $0, $0		#set num1_op_num2 counter to 1, bc we already num1
    	add $s1, $0, $0		#set flag for ops to 0	
    	j fstDigit
  
 increment: 			#if decimal portion is >= 0.5 increment counter
 	blt $t6, 0, decrement
 	addi $t6, $t6, 1
 	sw $t6, 0($sp)
 	j cL
 decrement:			# decrement negatives
 	addi $t6, $t6, -1
 	sw $t6, 0($sp)
 	j cL

checkIfBothAreZero:
	beq $t6, 0, T7	#if t6 is zero then check if t7 is zero, else if it's not , return
	jr $ra
  T7:	beq $t7, 0, writeZeros		#if t7 is also a zero then write zeros
  	jr $ra
		
writeZeros:
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	move $a0, $0
	addi $a0, $a0, 48		#write zeros to display
	jal Write
	lw $ra, 0($sp)
	addi $sp, $sp, 24
	addi $s2, $0, 3	#if s2 = 3 then both are zero, flag to finish
	jr $ra

#should print 0.___ or -0.____
checkIfDecimalNeeded:
	beq $t6, 0, AND				#checks if t6 is 0 and there are values in t7
	jr $ra		#not a 0._ decimal
AND:	blt $t6, $t7, decimalNeeded
	beq $s1, 3, decimalNeeded
	beq $s1, 1, decimalNeeded
	jr $ra			
decimalNeeded: 
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	addi $a0, $0, 48	#write 0
	jal Write
	jal printDecimalPoint	#write .
	move $t6, $t7		#display the decimal point
	jal charInt
	addi $s2, $0, 9		#flag to show that a decimal point has been printed
	lw $ra, 0($sp)
	addi $sp, $sp, 24
	jr $ra


negativeSign:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	addi $a0, $0, 45	#print negative sign
 	jal Write
 	lw $ra, 0($sp)
 	addi $sp, $sp, 20
 	jr $ra
  
printDecimalPoint:	#prints the decimal point
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	addi $a0, $0, 46 
	jal Write
	lw $ra 0($sp)
	addi $sp, $sp, 28
	jr $ra
	
#checking if t6 and t7 (after division are negative)
# this will be used to display on negatives by converting them to positives
chkT6:
 	blt $t6, 0, negateT6
 	jr $ra
 negateT6:
 	mul $t6, $t6, -1
	addi $s1, $0, 2
	jr $ra
		
chkT7:
	blt $t7, 0, negateT7
	jr $ra
negateT7:
	mul $t7, $t7, -1
	beq $s2, 2, negateT6T7
	addi $s1, $0, 3
	jr $ra
negateT6T7:
	addi $s1, $0, 4
	jr $ra
	
#CONVERTING t6 or t7 or both t6 and t7 to it's negated value
#if t6 and or t7 are negative, i've converted them to positive to display, then need to negate them back
convertT6:	mul $t6, $t6, -1
		j convertDone
		
convertT7:	mul $t7, $t7, -1
		j convertDone

convertBoth:	mul $t6, $t6, -1
		mul $t7, $t7, -1
		j convertDone
		
#Invalid Number of Operators
OperationError:
		la $a1, nL
		jal Strings
		la $a1, opError
		jal Strings
		
		jal clearStack
    		la $a1, option2
    		jal Strings
		add $s6, $0, $0	#reset multiDigit Counter
   		add $s5, $0, $0		#set num1_op_num2 counter to 1, bc we already num1
    		add $s1, $0, $0	
    		j Calculator

assumeZero:			#used for when the user enter +5, /10, *0 at the beginning. Assumes that a zero exists before the operator
		addi $sp, $sp, -4	
		sw $0, 0($sp)
		move $a0, $0
		addi $a0, $a0, 48	#store zero on stack and print zero to display
		sw $a0, 12($t0)
		
		
		addi $sp, $sp, -4	
		sw $v0, 0($sp)			#save operator on stack
		addi $a0, $0, 32		#print space, operator, space
		jal Write
		move $a0, $v0
		jal Write
		addi $a0, $0, 32
		jal Write
		
		jal Read		#read in next integer
		add $a0,$v0,$zero	#write
		jal Write
		
		add $s5, $0, 3		#normal opertions
		jal Read
		j otherDigits



