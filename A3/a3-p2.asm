# Name: Leila Erbay
# Student ID: 260672158

# Problem 2 - Dr. Ackermann or: How I Stopped Worrying and Learned to Love Recursion
###########################################################
.data
	error: .asciiz "error: m, n must be non-negative integers\n"
	str1: .asciiz "please enter a positive integer for m\n"
	str2: .asciiz "please enter a positive integer for n\n"
	str_fin: .asciiz "your final Ackermann value is \n"

.text 
###########################################################
main:
# get input from console using syscalls

  li $v0, 4         		# system call code for print_str
  la $a0, str1      		# address of string to print
  syscall          		# print the string

  li $v0, 5			#syscall for read_int
  syscall
  move $t0, $v0			#t0 holds value of m
  
  li $v0, 4 			#syscall for print_str
  la $a0, str2			
  syscall

  li $v0, 5			#syscall for read_int
  syscall
  move $t1, $v0			#t1 holds value of n
  
  
  move $a0, $t0			#a0 holds value of m to be used as input to A
  move $a1, $t1			#a1 holds value of n to be used as input to A

	
# compute A on inputs 
	jal check
	jal A

done:  
	move $t0, $v0
	
	li $v0, 4 			#syscall for print_str
  	la $a0, str_fin			
  	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 10
	addi $a0, $0,0
	syscall
	
# print value to console and exit with status 0

###########################################################
# int A(int m, int n)
# computes Ackermann function

	#a0 = m, a1 = n
A: 
	#jal check		#jump to check and make sure m and n are valid inputs
	#move $v0, $zero
	#move $v1, $zero	
				
Loop:	addi $sp, $sp, -12		#make room on stack for 3 items: m (ie a0), n (ie a1), return addr (ie jr)
	sw $ra, 8($sp)	
	sw $a0, 4($sp)
	sw $a1, 0($sp)
	
	 	 	 
base: 	beq $a0, $zero, BASE		#if m = 0 then n+1
	bgt $a0, $zero, case2		#if m > 0 then second case or third case
		
BASE:   addi $a1, $a1, 1		#n+1		
	move $v0, $a1
	addi $sp, $sp, 12
	jr $ra

	

case2: 	beq $a1, $zero, CASE2		#if n = 0 and m > 0
	bgt $a1, $zero, case3		#if n >0 and m>0 then it goes to case3
	
CASE2:	addi $a1, $zero, 1		#set n to 1		
	addi $a0, $a0, -1		#set m to m-1			
	jal Loop				# call ackerman with m-1 and 1
	j return
	
	
	
case3:	#a0 = m
	#a1 = n-1
	#j Loop
	#pop m off of stack, a1 <- v0 and call A with a0 and a1
	
	addi $a1, $a1, -1				#set a1 to n-1
	add $a0, $a0, $0				# call Loop with a1 = n-1 and a0 = m
	jal Loop				#jump to A with a0 = m and a1 = n-1
		
	move $a1, $v0				#store A(m, n-1) in a1 and call Loop
	addi $a0,$a0, -1	 		
	jal Loop
	
	
return:
	lw $ra, 8($sp)			
	lw $a0, 4($sp)
	lw $a1, 0($sp)				
	addi $sp,$sp,12	
				# pop 3 items off the stack
	jr $ra
	

	
###########################################################
# void check(int m, int n)
# checks that n, m are natural numbers
# prints error message and exits with status 1 on fail
check:
	blt $a0, 0, arg1_fail		#check if m < 0 if it is then jump to its label, else check n
	blt $a1, 0, arg2_fail		#check if n <0 if it is then jump to its label. This check occurs if m > 0
	move $v0, $a0			# if !(n< 0) and !(m < 0) then place the m and n into return reg(s) 
	move $v1, $a1
	jr $ra


arg1_fail:      move $t0, $a0		#if m < 0 then error & exit
		j exit
		
arg2_fail: 	move $t1, $a1		#if n < 0 then error & exit
		j exit
			
  	
exit: 				# call operating sys
	

	li $v0, 55		# system call code for exit with value 1 = 17
	la $a0, error
	addi $a1, $0, 0
	syscall
	
	li $v0, 17		#syscall for error
	addi $a0, $0, 1		#a0 exits on 1
	syscall
	