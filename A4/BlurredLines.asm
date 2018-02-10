#student: LEILA ERBAY
#ID: 260672158
.data

#Must use accurate file path.
#These file paths are EXAMPLES, 
#should not work for you
str1:	.asciiz "/Users/LeilaErbay/Desktop/U2/COMP273/Assignment4/test1.txt"
str3:	.asciiz "/Users/LeilaErbay/Desktop/U2/COMP273/Assignment4/test-blur.pgm"	#used as output

err1:	.asciiz "file cannot be opened\n\n"
err2:	.asciiz "file cannot be read\n\n"
err3:	.asciiz "file cannot be written to\n\n"
err4: 	.asciiz "file cannot be closed properly to\n\n"

extra: .asciiz "P2\n24 7\n15\n"

buffer:  .space 2048		# buffer for upto 2048 bytes
dataArray: .space 672		#extra buffer to hold converted values

newbuff: .space 672
finalbuff: .space 2048

	.text
	.globl main

main:	la $a0,str1		#readfile takes $a0 as input
	la $a1, dataArray 
	jal readfile
	
	move $a3, $v1		#v1 pointed to dataArray buffer, which holds Int values of ascii chars
	#la $a1,buffer		#$a1 will specify the "2D array" we will be averaging
	la $a2,newbuff		#$a2 will specify the blurred 2D array.
	jal blur

	move $a2, $v1
	la $a0, str3		#writefile will take $a0 as file location
	la $a1,finalbuff		#$a1 takes location of what we wish to write.
	la $a3, extra
	jal writefile

exit:
	
	li $v0,10		# exit
	syscall

readfile:
#done in Q1
	move $s4, $a1		#have a pointer to the empty dataArray
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
	
	bgt $v0, $0, convert
	li $v0, 4
	la $a0, err4
	syscall
	
	li $v0, 17		
	li $a0, 1
	syscall
#File is closed


convert: 	#we loop through  buffer if convert ascii to decimal
	move $s0, $v1	#s0 points to the head of the buffer
	#s4 points to empty dataArray
	move $s5, $s4
	
# i = row, w = width =  24, j = column : (i*w )+j		
#[0,0] : i = 0, w = 0, j = 0
#[0,1] : i = 0, w = 0, j = 1
#[1,0] : i = 1, w = 24, j = 0

	#if we hit a space/newLine then we skip
	addi $s7, $s7, 10 	#10 used for positional notation
	
	
Loop: 	
	lb $t4, 0($s0)			#t4 holds contents of ascii val
	
	beq $t4, 32, skip		#skipping spaces/newlines
	beq $t4, 10, skip

	lb $t9, 1($s0)
	
	beq  $t9, 32 oneAscii		#if char is only 1 number then a space/newline after 
	beq  $t9, 10 oneAscii 	#it then just convert single digit and move on
	
	
		#if there is a char in the next slot (then this requires Positional Notation conversion)
	subi $t4, $t4, 48	#convert tens place to decimal
	subi $t9, $t9, 48 	#convert ones place to decimal
	
	blt $t9, 0, done
	bgt $t9, 9, done

	
	mult $t4, $s7	 	#multiply tens place by 10
	mflo $t6		#ex:(1*10), 2*10, 3*10...
	add $t8, $t6, $t9		#1*10 + 2
	sw $t8, 0($s4)
	
	addi $s0, $s0, 1	#s0 points to the snd ascii
	
	j increment		#now we skip to the next space in both the buffer/ new space in temp buffer
	
oneAscii:	#converts only 1 char if there is no second consecutive second digit
	subi $t4, $t4, 48	#convert ascii to decimal = ascii - 48
	sw $t4, 0($s4)		#writing to empty dataArray
	j increment
	
skip: 
	addi $s0, $s0, 1
	j Loop
increment:
	addi $s0, $s0, 1	
	addi $s4, $s4, 4	
	j Loop
	
done: 
	move $v1, $s5
	jr $ra



blur:
	#a3 = points to dataArray
	#a2 = points to newbuff
	
	#IMPORTANT REGISTERS: s0, s1, t0, t1, s2, t3, t4, t5
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $s0, $a3
	move $s1, $a2		#empty array
	
	add $t0, $t0, 0		#t0 = i
	add $s2, $s2, 24	#s2 = w = 24
	add $t1, $t1, 0		#t1 = j
	
	mult $s2, $t0	
	mflo $t3		#t3 = i * w
	add $t4, $t3, $t1	#t4 = (i*w) + j

skipFirstRow:
	move $s0, $a3
	move $s1, $a2
	
	
	jal index
	add $s0,$s0, $t4		#move pointers of s0 and s1
	add $s1,$s1, $t4
	
	beq $t1, 96, Then
Then: 	move $t1, $0
	addi $t0, $t0, 4
	j LoopAve
	
	lw $t5,0($s0)			#want to load word from dataArray into t5 = s0 points to dataArray
	sw $t5, 0($s1)			#want to load word into new buff and then change pointer
	
	addi $t1, $t1, 4	#only want to increment j
	
	
	addi $s0,$s0, 4			#increment pointer
	addi $s1,$s1, 4 
	
	j skipFirstRow


LoopAve:	
	#skipping outer rims of 2D array
			#check if i = 0 (ie first row)
AND:	beq $t1, 0, skipIndex	#skip first COLUMN			#check if j = 0 (ie first column) --> SKIPPING FIRST ROW
				#skip first COLUMN
	beq $t1, 92,skipCol	#check if j = 23 (ie last column)
	#beq $t1, 92, skipCol
	beq $t0, 24, skipLastRow

#where actual averaging takes place
MATH:	
	subi $t6, $t0, 4 	# t6 = i -1 	(ie prev row)
	subi $t7, $t1, 4	#t7 = j-4	(ie prev col)

	addi $t8, $0, 0	
	addi $t9, $0, 9
	move $s1, $a2	

UPPERROW:
	move $s0, $a3
	beq $t8,3, MIDROW
	mult $t6, $s2	
	mflo $t5	#(i-1)*24

	add $t4, $t5, $t7	#(i-1) *24 + (j-1) then + j then + (j+4)	
	add $s0,$s0, $t4		#have s0 and s1  point to index of t4
	lw $s5, 0($s0)
	

	
	add $s6,$s6, $s5 	#s6 = sum of first row (by the end)
	addi $t7, $t7, 4	
	addi $t8, $t8, 1
	j UPPERROW

		
MIDROW:
	move $t8, $0	#counter  = 0
	addi $t7, $t7, -12	#t7 = j-4
	addi $t6, $t6, 4
	
MidRowLoop:
	move $s0, $a3
	beq $t8,3, BOTTOMROW
	mult $t6, $s2	
	mflo $t5	#(i)*24

	add $t4, $t5, $t7	#(i) *24 + (j-4) then + j then + (j+4)	
	add $s0,$s0, $t4	#have s0 and s1  point to index of t4
	lw $s5, 0($s0)
	
	
	add $s6,$s6, $s5 	#sum of FIRST AND SECOND ROW
	addi $t7, $t7, 4	
	addi $t8, $t8, 1
	j MidRowLoop

BOTTOMROW:
	move $t8, $0	#counter  = 0
	addi $t7, $t7, -12	#t7 = j-4
	addi $t6, $t6, 4	#i = i+1	
	
LastRowLoop:
	beq $t8,3, Average
	move $s0, $a3
	mult $t6, $s2	
	mflo $t5	#(i)*24

	add $t4, $t5, $t7	#(i) *24 + (j-4) then + j then + (j+4)	
	add $s0,$s0, $t4	#have s0 and s1  point to index of t4
	lw $s5, 0($s0)
	 
	
	add $s6,$s6, $s5 	#sum of FIRST AND SECOND ROW and THIRD ROW
	addi $t7, $t7, 4	
	addi $t8, $t8, 1
	j LastRowLoop

Average:
	
	div $s6, $t9
	mflo $s6 		#$s6 = average of 9 cells
	
	jal index
	move $t4, $v0	
	add $s1, $s1, $t4
	sw $s6, 0($s1)	#store average into current index
	
	addi $t1, $t1, 4	#j++
	
	j LoopAve	


skipIndex: 
	#check if i = 7 (ie last row
	move $s0, $a3
	move $s1, $a2
	
	
	jal index
	add $s0,$s0, $t4		#move pointers of s0 and s1
	add $s1,$s1, $t4
	lw $t5,0($s0)			#want to load word from dataArray into t5 = s0 points to dataArray
	sw $t5, 0($s1)			#want to load word into new buff and then change pointer
	
	addi $t1, $t1, 4	#only want to increment j
				
	j LoopAve


skipCol: 
	move $s0, $a3
	move $s1, $a2
	
	jal index
	add $s0,$s0, $t4		#move pointers of s0 and s1
	add $s1,$s1, $t4
	
	lw $t5, 0($s0)			#want to load word from dataArray into t5 = s0 points to dataArray
	sw $t5, 0($s1)			#want to load word into new buff and then change pointer
	
	beq $t0, 24, doneAve
	addi $t0,$t0, 4			#want to increment i	
	addi $t1, $0, 0		#set j to 0 (we've moved to the next row)

	
	j LoopAve

skipLastRow:
	bgt $t1, 96, doneAve
	move $s0, $a3
	move $s1, $a2
	
	jal index
	add $s0,$s0, $t4		#move pointers of s0 and s1
	add $s1,$s1, $t4
	lw $t5,0($s0)			#want to load word from dataArray into t5 = s0 points to dataArray
	sw $t5, 0($s1)			#want to load word into new buff and then change pointer
	
	addi $t1, $t1, 4	#only want to increment j
	
	
	addi $s0,$s0, 4			#increment pointer
	addi $s1,$s1, 4 
	j LoopAve

index:
	mult $s2, $t0	
	mflo $t3		#t3 = i * w
	add $t4, $t3, $t1		#t4 = (i*w) + j
	
	move $v0, $t4
	jr $ra

doneAve:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	move $v1, $a2	
	jr $ra
#use real values for averaging.
#HINT set of 8 "edge" cases.
#The rest of the averaged pixels will 
#default to the 3x3 averaging method
#we will return the address of our
#blurred 2D array in #v1

writefile:
#done in Q1
#s0, s1, s2, s3, s4, t0, t1
	move $s6, $a0 	#file
	move $s0, $a2		#s0 points to (averagedArray)
	move $s1, $a1		#s1 points to finalBuff
	add $s2, $0, 32		#s2 = space
	add $s3, $0, 10		#s3 = newLine
	move $s4, $0		#s4 = counter (row)
	add $s5, $0, 10		#divide by 10
	move $s7, $0		#number of ints
	
IntToAscii:
	lw $t0, 0($s0)
	lw $t1, 4($s0)
	bge $t0, 10, gtTen	#checks if the int is >10 (requires positional notation)

singleInt:

	addi $s7, $s7, 1
	bge $s7, 169, toAsciiDone
	
	addi $t0, $t0, 48	#convert single value to ascii
	sb $t0, 0($s1)		#store 

	addi $s4, $s4, 1	#count++
	beq $s4, 24, newLine
	
	blt $t1, 10, addSpace	#if next int is <10 I add 2 spaces, else I add 1 space
	addi $s1, $s1, 1
	sb $s2, 0($s1)

	addi $s1, $s1, 1
	
	addi $s0, $s0, 4	#move to next byte
	j IntToAscii
	
gtTen:
	div $t0, $s5		#divide int by 10
	mflo $t3		#t3 = quotient
	mfhi $t4		#t4 = remainder
	addi $t3, $t3, 48	#convert 10s place to ascii
	addi $t4, $t4, 48	#convert 1s place to ascii
	
	addi $s7, $s7, 1
	bge $s7, 169, toAsciiDone
	
	sb $t3, 0($s1)		#store 10s place and 1s place in separate bit
	
	addi $s1, $s1, 1
	sb $t4, 0($s1)
	
	
	addi $s4, $s4, 1	#count++
	beq $s4, 24, newLine
	
	blt $t1, 10, addSpace
	addi $s1, $s1, 1
	sb $s2, 0($s1)
	addi $s0, $s0, 4

	
	addi $s1, $s1, 1
	j IntToAscii
	

addSpace:			#adding a space
	addi $s1, $s1, 1
	sb $s2, 0($s1)

	addi $s1, $s1, 1
	sb $s2, 0($s1)	
	
	addi $s1, $s1, 1	#move to next open bit for new loop
	addi $s0, $s0, 4	#move to the next byte
	j IntToAscii
	
newLine: 			#adding newLine char
	addi $s1, $s1, 1
	sb $s3, 0($s1)

	
	addi $s1, $s1, 1	#move to next open bit for new loop
	addi $s0, $s0, 4	#move to next byte
	move $s4, $0
	j IntToAscii

		
toAsciiDone:
	
	#open file to be written to, using $a0. FILE OPEN
	move $s1, $s6 	#file
	move $s0, $a3	#extra
	move $s2, $a1	#final buff


	li $v0, 13 	#syscall to open file
	move $a0, $s1 # a0 already points to the file to be written to
	li $a1, 1	#flag to open file
	li $a2, 0	#mode is ignored
	syscall
	move $s3, $v0	#s3 = file descriptor
	
	bgt $s3, $0, Write
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
	# $s0=	#extra
	
	
	li $v0, 15	#syscall to write to file
	move $a0, $s3	#a0 holds fd
	move $a1, $s0		#a1 points to string of P2\n 24 7\n 15
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
	#s2 = buffer
	move $a1, $s2 	#addr of buffer in a1
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
	move $a0, $s3
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



	
