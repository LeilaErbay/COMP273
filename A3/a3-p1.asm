#StudentID: Leila Erbay
#Name: 260672158

.data
	str:	.asciiz	"please enter a char you would like to add to the linked list \n"
	nl: 	.asciiz "\n"
	orig: 	.asciiz "Original linked list\n"
	revd: 	.asciiz 
	
.text
#There are no real limit as to what you can use
#to implement the 3 procedures EXCEPT that they
#must take the specified inputs and return at the
#specified outputs as seen on the assignment PDF.
#If convention is not followed, you will be
#deducted marks.

main:
	#build a linked list
		j build			#build the linked list

	next:
#print "Original linked list\n"
#print the original linked list
		move $a1, $v1
		li $v0, 4
		la $a0, orig	
		syscall
		
		jal print		#print the linked list
		
	rev:
#reverse the linked list
		li $v0, 4
		la $a0, nl
		syscall
		
		move $a1, $v1
		j reverse		# reverse linked list
		
print_rev: 	
		move $a1, $v1
		jal print	#print linked list
#On a new line, print "reversed linked list\n"
#print the reversed linked list
	
		
	end: 	li $v0, 10		# system call code for exit = 10
		addi $a0, $a0, 0
		syscall	
		
#terminate program

build:
#continually ask for user input UNTIL user inputs "*"
	
	
	li $v0, 4	#get char from user
	la $a0, str
	syscall

	li $v0, 12
	syscall
	
	move $t0, $v0		#t0 holds inputted char
	
	li $v0,4
	la $a0, nl
	syscall
	
	
	beq $t0, 42, done		#check if char is equal to *, if so then done
	beq $s7, $0, head		#have a counter to determine if 
	bgt $s7, $0, body		#this is the first node being added to the list or an aditional node
 	
					
 head:
 	addi $s7, $s7, 1	#incrememnt ctr by 1 so after this, head will not be visited
 	la $a0, 8	
 	jal malloc			#make a new node
 	
 		
 	move $s0, $v0			#s0 = addr of head
 	sw $s1, 0($s0)
 	sw $t0, 4($s0)			#load char into 2nd 4 bytes
 	move $v1, $s0			

	move $s1, $s0			# s1 the addr of current
 	j build

body: 
	addi $s7, $s7, 1
	la $a0, 8
	jal malloc		#make a new node
	
	move $s0, $v0		#s0 points to first addr of node
	
	sw $t0, 4($s0)		#char stored in second part of ndoe
	sw $s0, 0($s1)		#store addr of prev ptr in first space of node
	
	move $s1, $s0		#s1 gets addr of current
 	j build



malloc: li $v0, 9		# dynamically create space for node
	syscall
	jr $ra 

done:   			
	move $s1, $s0
	sw $zero, 0($s1)	#last node points to null
	j next

#FOR EACH user inputted character inG, create a new node that hold's inG AND an address for the next node
#at the end of build, return the address of the first node to $v1

print:
	
#$a0 takes the address of the first node
	
	move $s0, $a1			#ptr = head
	move $s5, $ra
	
loop:	beq $s0, $zero, over		#if at the last node then we're done
	li $v0, 11			#code for printing char
	lw $t2, 4($s0)			# put char in node into t2
	move $a0, $t2			#place char in t2 into a0
	syscall				#print char
	
	lw $s1, 0($s0)			#place address of next node into s1
	move $s0, $s1			#place address of next nodes into s0
	j loop	
	
over: 
	move $v0, $s0
	move $ra, $s5
	jr $ra				
#prints the contents of each node in order

reverse:
	move $s0, $a1		#s0 points to current node
	
	#s1= current
	#s2 = next
	#s3 = prev
	
	move $s3, $0		#prev set to null
	move $s1, $s0		#set current to head 
	
	
while:	beq $s1, $zero, end_loop 
	lw $s2, 0($s1)		#next <-- current.next
	sw $s3, 0($s1)		#current.next <-- prev
	move $s3, $s1		# prev <-- current
	move $s1, $s2		#current  <--next
	
	j while

end_loop: 
	move $v1, $s3		#v1 gets address
	j print_rev	

	
#$a1 takes the address of the first node of a linked list
#reverses all the pointers in the linked list
#$v1 returns the address
