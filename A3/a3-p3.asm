# Name: Leila Erbay	
# Student ID: 260672158

# Problem 3
# Numerical Integration with the Floating Point Coprocessor
###########################################################
.data
N: .word 100

two: .word 2
one: .word 1

a: .float 0
b: .float 1
error: .asciiz "error: must have low < hi\n"

.text 
###########################################################
main:
	# set argument registers appropriately
	#a = low = f12
	#b = hi = f13
	
	la $a1, a		#a0 holds value of a
	lwc1 $f12, 0($a1)	#f12 holds a
	
	la $a2, b		#f13 holds value of b	
	lwc1 $f13, 0($a2)	#f13 holds b
	

	
	# call integrate on test function 
	la $a0, ident	#a0 points to the address of ident 
	jal integrate
	
	# print result and exit with status 0	
	#f0 = result
end: 	li $v0, 2
	mov.s $f12, $f0
	syscall

exit: 
	li $v0, 10		# system call code for exit = 10
	addi $a0, $0, 0		#a0 set to 0 on successful exit
	syscall	
###########################################################
# float integrate(float (*func)(float x), float low, float hi)
# integrates func over [low, hi]
# $f12 gets low, $f13 gets hi, $a0 gets address (label) of func
# $f0 gets return value
integrate: 
	

	jal check			#checks if a < b
	
	# initialize $f4 to hold N
	# since N is declared as a word, will need to convert 
	
	la $t0, N  			#t0 = ptr to N
	lwc1 $f3, 0($t0)		#f3 holds the content at t0, N
	cvt.s.w $f4, $f3		#convert f3 which holds an int to float to be stored at f4
	

	sub.s $f0, $f13, $f12		#f0 = b-a
	div.s $f1 $f0, $f4		# w = f1 --> (b-a) /N
	
#result = f2 = 0
#f10 = i = 0 to start
	la $t0, two
	lwc1 $f6, 0($t0)		#f6 holds content of t0 = 2
	cvt.s.w $f5, $f6		#f5 holds float 2.0
	
	la $t0, one
	lwc1 $f6, 0($t0)
	cvt.s.w $f20, $f6		#f20 = 1.0
	
#f5= 2.0	

	move $t0, $0			#t0 = 0
	add $t1, $0, 1			#t1 = 0
	
	div.s $f6, $f1, $f5		#f6 = h/2.0		
	add.s $f7, $f6, $f12		#f7 = a + (h/2.0)
	
	
#f1 = w;  	f2 = result;;  	f4 = N;   	   
#f7 = a+(h/2.0) f10 = i;  	f12 = a;    	f13 = b;   
#a0 = ptr to ident;   		f20 = 1.0    

loop: 	c.lt.s $f10, $f4		#for ( i = 0; i < N (100); i++); f0 = i, f4 = N 
	bc1f done		#if !(i<N) then done
		

	mul.s $f8, $f10, $f1		#f8 = i*w
	add.s $f9, $f7, $f8		#f9 = (a+(h/2.0)) + i*w)
	
	mov.s $f12, $f9			# f12 = f9 = ((a+h)/2.0) + i*w)
	
	addi $sp,$sp,-4		# create space for a0  on the stack (save original a0 in case a0 gets used in other function)
	sw $a0,0($sp)
	
	jalr $a0			#call ident with f12		
	mov.s $f11, $f0			#f11 holds value of f((a+h)/2.0) + i*h)
	add.s $f2, $f2, $f11		#result = result + f((a+h)/2.0) + i*h) --> f2 = f2 + f11
	
	lw $a0, 0($sp)			#load original a0 back
	addi $sp, $sp, 4

	add.s $f10, $f10, $f20		# i++ --> i = i+1 --> f10 = f10 + f20
	j loop

done:	
	mul.s $f2, $f2, $f1		#result = result * w --> f2 = f2 * f1
	mov.s $f0, $f2			#f0 gets result
	j end 

###########################################################
# void check(float low, float hi)
# checks that low < hi
# $f12 gets low, $f13 gets hi
# # prints error message and exits with status 1 on fail
check:
	
	c.lt.s $f12, $f13		#if a < b, cc 0 set t0 to $t1 (ie set t0 to 1 = true)
	bc1f false		#if  !(a<b) then exit on error
	jr $ra

false: 		#prints error message
		
	
	li $v0, 55	#fancy error
	la $a0, error
	add $a1, $0, 0
	syscall
	
	
	li $v0, 17		# system call code for exit = 17
	addi $a0, $0, 1
	syscall 
	
	
	

	
	
###########################################################
# float ident(float x) { return x; }
# function to test your integrator
# $f12 gets x, $f0 gets return value
ident:	
	mov.s $f0, $f12
	jr $ra

