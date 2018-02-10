#Student: LEILA ERBAY
#ID: 260672158
# fileio.asm
	
.data

#Must use accurate file path.
#These file paths are EXAMPLES, 
#should not work for you
str1:	.asciiz "/Users/LeilaErbay/Desktop/U2/COMP273/Assignment4/test1.txt"
str2:	.asciiz "/Users/LeilaErbay/Desktop/U2/COMP273/Assignment4/test2.txt"
str3:	.asciiz "/Users/LeilaErbay/Desktop/test.pgm"	
#used as output

err1:	.asciiz "file cannot be opened\n\n"
err2:	.asciiz "file cannot be read\n\n"
err3:	.asciiz "file cannot be written to\n\n"
err4: 	.asciiz "file cannot be closed properly to\n\n"

extra: .asciiz "P2\n24 7\n15\n"

buffer:  .space 2048		# buffer for upto 2048 bytes

	.text
	.globl main

main:	la $a0,str1		#readfile takes $a0 as input
	jal readfile

	la $a0, str3		#writefile will take $a0 as file location
	la $a1,buffer		#$a1 takes location of what we wish to write.
	la $a2, extra
	jal writefile

exit:	
	li $v0,10		# exit
	syscall

readfile:

#Open the file to be read,using $a0: OPEN FILE
	li $v0, 13		#syscall to open file
	#a0 already points to file name
	li $a1, 0		#a1 = 0 = flag for read only
	li $a2, 0		# mode is ignored
	syscall
	move $s0, $v0		#s0 = file descriptor		

#Conduct error check, to see if file exists OPEN FAIL
	bge $s0, $0, continue
	li $v0, 4
	la $a0, err1			#if fd < 0 then there is problem opening the file
	syscall
	
	li $v0, 17
	li $a0, 1	#exit 1 on fail
	syscall

continue: 
# You will want to keep track of the file descriptor* s0

# read from file  FILE READ
	li $v0, 14	#syscall for reading in file
	move $a0, $s0	# use correct file descriptor, and point to buffer: a0 holds fd
	la $a1, buffer	#a1 points to buffer
	li $a2, 2000	# hardcode maximum number of chars to read
	syscall

	bge $v0,0,readDone	#if v0 < 0 then there is problem reading the file
	li $v0, 4
	la $a0, err2		
	syscall
	
	li $v0, 17
	li $a0, 1	#exit 1 on fail
	syscall
	
readDone:
	#li $v0, 4
	#la $a0, buffer
	#syscall
	la $v1, buffer	# address of the ascii string you just read is returned in $v1.
			# the text of the string is in buffer

Close:
	li $v0, 16	#syscall for closing file
	move $a0, $s0	#a0 holds fd
	syscall
	
	bgt $v0, $0, closeDone
	li $v0, 4
	la $a0, err4
	syscall
	
	li $v0, 17		
	li $a0, 1
	syscall

closeDone:
	jr $ra
# close the file (make sure to check for errors)


writefile:
#open file to be written to, using $a0. FILE OPEN
	move $t1, $a1
	move $t2, $a2

	li $v0, 13 	#syscall to open file
	# a0 already points to the file to be written to
	li $a1, 1	#flag to open file
	li $a2, 0	#mode is ignored
	syscall
	move $s1, $v0	#s1 = file descriptor
	
	bgt $v0, $0, Write
	li $v0, 4
	la $a0, err1		
	syscall
	
	li $v0, 17
	li $a0, 1	#exit 1 on fail
	syscall
	

#write the specified characters as seen on assignment PDF:
#P2
#24 7
#15
Write:	#write P2 24 7 15 to file
	move $a1, $t2
	
	li $v0, 15	#syscall to write to file
	move $a0, $s1	#a0 holds fd
		#a1 points to string of P2\n 24 7\n 15
	li $a2, 12 	#a2 holds size of extra
	syscall
	
fstChk:
	bge $v0,0,contWrite	#if v0 < 0 then there is problem reading the file
	li $v0, 4
	la $a0, err3		
	syscall
	
	li $v0, 17
	li $a0, 1	#exit 1 on fail
	syscall
	
contWrite:	#write rest of buffer to file
	move $a1, $t1 	#addr of buffer in a1
	li $v0, 15
		#a0 already holds fd
		#a1 points to buffer 
	li $a2, 2000	#a2 holds size of buffer
	syscall	

sndChk:
	bge $v0,0, closeWrite	#if v0 < 0 then there is problem reading the file
	li $v0, 4
	la $a0, err3		
	syscall
	
	li $v0, 17
	li $a0, 1	#exit 1 on fail
	syscall

closeWrite:
	li $v0, 16
	move $a0, $s1
	syscall
	
	bgt $v0, $0, writeDone
	li $v0, 4
	la $a0, err4
	syscall
	
	li $v0, 17		
	li $a0, 1
	syscall
	
writeDone:
	move $v0, $t1
	jr $ra

#close the file (make sure to check for errors)
