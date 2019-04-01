# Who:  Johnny Lam
# What: project3_binary.asm
# Why:  Project 3, insertion sort and then a binary search
# When: Created when? 3/36/2019 Due when? 4/2/2019
# How:  Registers: $v1 (return), $t0, $t1, $t2, $t3, $s0, $s1, $s2 (8)

.data

array:			.space		160 # Array Size: 40 integers
promptSize:		.asciiz		"How many integers in the array: "
promptSearch:		.asciiz		"What number to search for: "
promptInsert:		.asciiz		"Enter an integer to the array: "
space:			.asciiz		" "
error:			.asciiz		"Please enter a proper number! \n"

.text
.globl main


main:	# program entry
	la $a0, promptSize
	li $v0, 4
	syscall				# How many integers in the array: 
	
	li $v0, 5
	syscall 			# Read input
	move $s0, $v0
	
	blez $s0, restart
	li $t0, 40
	bgt $s0, $t0, restart		
getInputs:
	la $a0, promptInsert
	li $v0, 4
	syscall				# Enter an integer to the array: 
	
	li $v0, 5
	syscall				# Read input
	move $t0, $v0			# t0 = User input
	
	la $s1, array			# s1 = base array address
	jal sort
		
	la $a0, '\n'
	li $v0, 11	
	syscall				# Print newline
	
	la $s1, array			# Reset array to base for printing
	li $t1, 0			# Reuse t1 for printing counter
printArray:
	lw $a0, 0($s1)
	li $v0, 1
	syscall				# Print element in array
	
	la $a0, space
	li $v0, 4
	syscall				# Print space
	
	addi $t1, $t1, 1		# Counter for printing
	addi $s1, $s1, 4		# Iterate array
	blt $t1, $s0, printArray
	#Note s1 is array end + 4
findItem:
	li $a0, '\n'
	li $v0, 11
	syscall
	
	la $a0, promptSearch
	li $v0, 4
	syscall				# What number to search for: 
	
	li $v0, 5
	syscall
	move $s2, $v0			# s2 = Search value

	la $t1, array			# t1 = start (base address)
	move $t2, $s1			# t2 = end   (end address)
	jal binarySearch
#RETURN TRUE OR FALSE
false:	
	move $a0, $v1			#Return value from v1 register
	li $v0, 1
	syscall
	
	j findItem
binarySearch:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $t0, 0
	subu $t0, $t2, $t1		# (end - start) = array length
	
	# if (start > end)
	bge $t1, $t2, else		#Return false
	j recurse
else:	
	# Basecase when last element is left to check
	lw $t0, 0($t1)			# t0 = array[mid]
	# if (array[mid] == searchVal)
	beq $t0, $s2, true		#Return true

	li $v1, 0
	j false				#Return false
recurse:
	# Obtain middle index, shift right and left to get index as a multiple of 4
	# because each element is aligned by 4 else error
	srl $t0, $t0, 3
	sll $t0, $t0, 2			# (end - start)/2
	
	# t3 = middle index , reassigned: t0 = array[mid] value
	addu $t3, $t1, $t0 		# middle index = start + (end - start) / 2;
	lw $t0, 0($t3)			# value at middle index
	# if (array[mid] == searchVal)
	beq $t0, $s2, true
	# if ( array[mid] > searchVal)
	bgt $t0, $s2, searchLeft	
	#return binarySearch(array, start, mid-1, searchVal); 
searchRight:
	addi $t1, $t3, 4		# start = mid + 1
	j binarySearch
searchLeft:
	addi $t2, $t3, -4		# end = mid - 1
	j binarySearch	
terminate:
	li $v0, 10			# terminate the program
	syscall
sort:
	beq $t2, $t1, push		#t1 counter for adding array
	
	lw $t3, 0($s1)			# t3 = old
	ble $t0, $t3, swap		# new < old we swap, we're doing ascending order
	
	addi $t2, $t2, 1		# Pointer for sorting
	addi $s1, $s1, 4		# Iterate next array
	j sort				# If here, it means newest input is largest
swap:
	lw $t3, 0($s1)			# Temp = old
	sw $t0, 0($s1)			# Store new into old's location
	
	move $t0, $t3			# New = old
	addi $t2, $t2, 1		# Pointer update
	addi $s1, $s1, 4		# Iterate next array
	j sort
push:
	sw $t0, 0($s1)			# Store array 
	addi $t1, $t1, 1		# Update counter for array size
	li $t2, 0			# Reset pointer to 0 for comparing
	blt $t1, $s0, getInputs		# Continue adding until full
	jr $ra	
restart:
	la $a0, error
	li $v0, 4
	syscall
	j main
true:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	li $v1, 1			# Return true
	jr $ra
