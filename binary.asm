# Who:  Johnny Lam
# What: bst_proj3.asm
# Why:  Project 3
# When: Created: 3/25/2019 Due: 4/2/2019
# How:  List the uses of registers

.data
array:			.space			160    # 40 integers max
promptSize:		.asciiz 		"How many integers?  "
promptSearch:	.asciiz 		"\nSearch for which integer?  "
blank:         	.asciiz 		" "


.text
.globl main


main:	# program entry
     la $a0, promptSize
     li $v0, 4
     syscall

     li $v0, 5
     syscall
     move $s0, $v0		#s0 = array size

     # Input validation
     blez $s0, exit
     li $t1, 40
     bgt $s0, $t1, exit

     li $t1, 0     # total items in array / counter
     li $t2, 0	   # index pointer for comparisons
     li $t3, 0	   # current integer in array to be compared with
     li $t4, 0	   # newly element that needs to be compared
   
getinputs:     # Grab an integer input
     la $s2, array
     li $v0, 5
     syscall

     move $t4, $v0     # t4 stores integer input

sort: 
     #if t2 = t1 we put t4 into last index ( done comparing with all )   
     beq $t2, $t1, push

     lw $t3, 0($s2)		#item to be compared with
     ble $t4, $t3, swap		#Note: Ascending order!

     addi $t2, $t2, 1		# Pointer
     addi $s2, $s2, 4		# Iterate array
     j sort

swap:     
     lw $t3, 0($s2)		#load old 
     sw $t4, 0($s2)		#Store input into old's spot
    
     move $t4, $t3		#Move old value into input value
     addi $t2, $t2, 1		# update pointer
     addi $s2, $s2, 4		#Iterate array
     j sort			#Now recurse with old's value 

push:
     sw $t4, 0($s2)		#Store input
     addi $t1, $t1, 1		#Counter for total current size
     li $t2, 0			#Set pointer back to 0
     blt $t1, $s0, getinputs	#If array size is max, our array is ready


     li $t1, 0			#Reuse counter for printing array until array size
     la $a0, '\n'
     li $v0, 11
     syscall			#New Line
     
     #Reset pointer of array address
     la $s2, array		

printarray:     # Print all array items
     lw $a0, 0($s2)
     li $v0, 1
     syscall
     
     la $a0, blank
     li $v0, 4
     syscall		#Space
     
     addi $s2, $s2, 4	#Iterate array
     addi $t1, $t1, 1	#Counter
     blt $t1, $s0, printarray	#Once done sorting and printing, begin search
    
    #s2 now points to end of array
#############################
finditem:     # Gather input for item to look for
     la $a0, promptSearch
     li $v0, 4
     syscall

     li $v0, 5
     syscall
     move $s3, $v0

     li $t0, 0		  # array length
     la $t1, array        # t1 = base address
     addiu $t2, $s2, 0    # t2 set to last - 1
     li $t5, 1            # Defaults to 1, which means value found, 0 not found

     jal binarysearch     # Do a binary search

     move $a0, $t5        # Load t5 in a0, output 1 or 0 whether or not value was found
     li $v0, 1
     syscall

     j finditem           # Repeat

binarysearch:
	
     #PUSH RA INTO STACK MEMORY
     addiu $sp, $sp, -4
     sw $ra, 0($sp)

     subu $t0, $t2, $t1
     #Array size not 1, we continue search 
     bne $t0, 0, search
	
     #Base case when front = end 
     #IF FRONT = END = VALUE RETURN TRUE
     move $t4, $t1
     lw $t0, 0($t4)           
     beq $s3, $t0, return     
     #ELSE RETURN FALSE
     li $t5, 0                # Set t5 to 0 if item is not found
     j return

search:
     srl $t0, $t0, 3		#end - start shifted 3 
     sll $t0, $t0, 2		#Divide by 2
     addu $t4, $t1, $t0         # Calculate midpoint, offset from left index
     lw $t0, 0($t4)             # Store value of midpoint of array
	
     # if (array[mid] == searchVal) 
     beq $s3, $t0, return
     
     # if (array[mid] > searchVal
     blt $s3, $t0, look_left
  
     # else return binarySearch(array, mid+1, end, searchVal); } 
look_right:
     addiu $t1, $t4, 4    # Right bsearch, left = mid+1
     jal binarysearch     # Recursive call to binary search
     j return             # Finished, return back to caller

look_left:
     move $t2, $t4        # Keep searching to the left
     jal binarysearch     # Recursive call to binary search
     
return:
     lw $ra, 0($sp)       # Obtain back return address from stack pointer
     addiu $sp, $sp, 4    # Release 4 bytes on stack

     jr $ra                # Return to caller

exit:
     li $v0, 10
     syscall

