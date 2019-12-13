.data 0x0
  maze:			.space 625	# allocates bytes of memory for a 25x25 maze; 25x25 
  wasHere:		.space 625	# maze that keeps track of dot history
  correctPath:		.space 625	# correct and final maze
  .align 2
  width:		.space 4 
  height:		.space 4
  startX:		.space 4
  endX:			.space 4

  newline:		.asciiz "\n"	
   
.text 0x3000
.globl main

main:
  ori     $sp, $0, 0x3000     		# Initialize stack pointer to the top word below .text
                              		# The first value on stack will actually go at 0x2ffc
                                	# because $sp is decremented first.
                                	
  addi    $fp, $sp, -4       		# Set $fp to the start of main's stack frame
    
  ########################################################################################################  
    
  addi	$v0, $0, 5			# system call 5 is for reading an integer
  syscall 				# integer value read is in $v0
  add $a1, $0, $v0			# copy the width into $8
  sw $a1, width				# stores val of width to variable width
  
  addi $v0, $0, 5			# system call 5 is for reading an integer
  syscall 				# integer value read is in $v0
  add $a2, $0, $v0			# copy the width into $8
  sw $a2, height			# stores val of width to variable 
 
  mult $a1, $a2
  mflo $t0				# t0 holds the max amt of array inputs
  
  add $t1, $0, $0			# t1 - initializing variable to 0 for max maze size
  
  loop:
    slt $t5, $t1, $t0			# checks if length of current index of array is greater than maze max size provided
    beq $t5, $0, prepsRecurSolve		# if current index is greater than maze max size, solves recursively
    
    add $t4, $0, $0			# t4 - initializing variable to 0 for max width size; will revert back 0  
    					# once it becomes greater than a1 (width max)
    widthCheck: 
      slt $t6, $t4, $a1			# checks if length of current index of width is greater than width max provided
      beq $t6, $0, cont			# if current index is greater than width max, leaves loop
      #Reading Char:
      li $v0, 12			# system call 12 is for reading a charecter; 
      syscall		
      sb $v0, maze($t1)			# Adding Char to Maze; stores byte value into V0 and inserts
      					# it into maze with respect to index value (t1)
      
     # checking for S and F location
     li $t7, 'S'			#checking for index of S 
     beq $v0, $t7, storeStartX
   
     li $t7, 'F'			#checking for index of F
     beq $v0, $t7, storeEndX     
     
    Incrementing:
    
     li $t7, '0'
     sb $t7, wasHere($t1)		#stores 0 in 1-D maze array
     sb $t7, correctPath($t1)		#stores 0 in 1-D maze array
     
      addi $t4, $t4, 1			# increments value of width index variable by 1
      addi $t1, $t1, 1			# increments value of maze index variable by 1
      
    j widthCheck
    cont:
     li $v0, 12			# system call 12 is for reading a charecter; ENSURES THAT NEW LINE IS EATEN
     syscall
  j loop 
  storeEndX:
       sw $t1, endX 			# t1 holds index values for items in maze, places index where F is located
       j Incrementing
  storeStartX:
       add $a3, $t1, $0			# puts index where S is located with respect to the array
       sw $a3, startX
       j Incrementing			
  prepsRecurSolve:
 
   jal recursiveSolve			# solves recursively and recursively
  
 # Prints final maze 
 
      add $t0, $0, $0
      add $t1, $0, $0
      add $t2, $0, $0
      add $t3, $0, $0	
      add $t4, $0, $0  
      add $t5, $0, $0     
      add $t6, $0, $0  
      add $t7, $0, $0  
                 
  lw $t7, startX
  mult $a1, $a2				# a1 - width; a2 - height
  mflo $t0				# t0 holds the max amt of array inputs
  
  add $t1, $0, $0			# t1 - initializing variable to 0 for max maze size
 
  loopPrint:
    slt $t5, $t1, $t0			# checks if length of current index of array is greater than maze max size provided
    beq $t5, $0, end			# if current index is greater than maze max size, ends program
 
    add $t4, $0, $0			# t4 - initializing variable to 0 for max width size; will revert back 0  
    					# once it becomes greater than a1 (width max)
    widthCheck2: 
      slt $t6, $t4, $a1			# checks if length of current index of width is greater than width max provided
      beq $t6, $0, cont2		# if current index is greater than width max, leaves loop
     
      #Printing Char:			# before print char, must check values of different arrays
     
      lb $t2, correctPath($t1)		# loads val of correct path
      li $t3, '1'			# loads '1' into $t3
      bne $t2, $t3, notCorrectPath	#if index of correctpath does not equal '1'; goes to print item in maze array
      
      bne $t1, $t7, notStartX
         li $v0, 11			# system call 11 is for printing a charecter; 
         li $a0, 'S'
         syscall

	j Incra

        notStartX:
          li $v0, 11			# system call 11 is for printing a charecter; 
          li $a0, '.'     
          syscall
          
         j Incra

     notCorrectPath:
      li $v0, 11			# system call 11 is for printing a charecter; 
      lb $a0, maze($t1)			# Print Char from Maze; loads byte value into V0 and inserts
      					# with respect to index value (t1)
      syscall		
     
      Incra:			
      addi $t4, $t4, 1			# increments value of width index variable by 1
      addi $t1, $t1, 1			# increments value of maze index variable by 1
      j widthCheck2
     	 cont2: 
     	 li $v0, 11			# system call 11 is for printing a charecter; 
     	 lb $a0, newline		# Print Char from Maze; loads byte value into V0 and inserts
  	  				# with respect to index value (t1)
     	 syscall		
    	
  j loopPrint
 

recursiveSolve:
  
  addi    $sp, $sp, -8        # Make room on stack for saving $ra and $fp
  sw      $ra, 4($sp)         # Save $ra
  sw      $fp, 0($sp)         # Save $fp

  addi    $fp, $sp, 4         # Set $fp to the start of proc1's stack frame

                                # From now on:
                                #     0($fp) --> $ra's saved value
                                #    -4($fp) --> caller's $fp's saved value
                    
    # =============================================================
    # Save any $sx registers that proc1 will modify
                                # Save any of the $sx registers that proc1 modifies
    addi    $sp, $sp, -4       # e.g., $s0, $s1, $s2, $s3
    sw      $a3, 0($sp)         # Save $s3
 
                                # From now on:
                                #    -8($fp) --> $s0's saved value
   

    # =============================================================
    
    
    # BODY OF proc1
   lw $t0, endX			#loads in index value where 'F' is located
   beq $a3, $t0, setRV1 	# if the starting point is equal to the end value, 
   				# we are outta here (Base-Case)
   
   lb $t1, maze($a3)		# reads value at a3
   li $t2, '*'			# loads imediately ascii code for '*'
   beq $t1, $t2, setRV0		# checks if value at index (s0)
   				# of array maze equals '*', indicates that we are at a wall
   				
   lb $t1, wasHere($a3)
   li $t2, '1'
   beq $t1, $t2, setRV0		# checks if value at index (s0)
      				# of array wasHere equals '1', indicates that we were already here
   
   search:
     li $t1, '1'		# loads '1' to t1 
     sb $t1, wasHere($a3)	# stores a '1' to wasHere to keep track where we are
    
     lw $t4, width
     div $a3, $t4   
     mfhi $t5
    
      bne $t5, $0, subOneX	# if arg does not equal to 0, begins search reading array leftwards
      j nope1
        subOneX:
           addi $a3, $a3, -1		# subtracts 1 from a3 val
           jal recursiveSolve		# recursion!
           beq $v0, $0, nope1 		# if return value equals to 0 (false), leaves if statement 'if (recursiveSolve(x-1, y))'
           li $t1, '1'			# loads '1' to $t1
           sb $t1, correctPath($a3)	# stores a '1' to indicate correct path at index of $s0
           li $v0, 1			# puts a 1 for return value
           j recurDone
     nope1:

     lw $t2, width		# loads width from memory
     div $a3, $t2   		# divides $a3 by $t2 in order to select x in 2-D demension 
     mfhi $t5			# current location of x val (2-D convention)
     addi $t2, $t2, -1		# equivilant to width - 1
     
     bne $t5, $t2, addOneX	# if arg does not equal (width - 1), begins search reading array rightwards
     j nope2
     	addOneX:
     	add $a3, $a3, 1
     	jal recursiveSolve	
     	beq $v0, $0, nope2 		# if return value equals to 0 (false), leaves if statement 'if (recursiveSolve(x-1, y))'
        li $t1, '1'			# loads '1' to $t1
        sb $t1, correctPath($a3)	# stores a '1' to indicate correct path at index of $s0
        li $v0, 1			# puts a 1 for return value
        j recurDone
   nope2:
  
     lw $t4, width			# gets width from height
     div $a3, $t4   			# divides current 1-D index ($a3) by height ($t4) 
     mflo $t5				# $t5 holds y value in 2-D demension format

      bne $t5, $0, subOneY		# if arg does not equal to 0, begins search reading array leftwards
      j nope3
        subOneY:
           lw $t2, width
           sub $a3, $a3, $t2		# subtracts width val from a3 val to search down y value
           jal recursiveSolve		# recursion!
           beq $v0, $0, nope3		# if return value equals to 0 (false), leaves if statement 'if (recursiveSolve(x-1, y))'
           li $t1, '1'			# loads '1' to $t1
           sb $t1, correctPath($a3)	# stores a '1' to indicate correct path at index of $s0
           li $v0, 1			# puts a 1 for return value
           j recurDone
     nope3:
       
     lw $t2, width		# loads width from memory to $t2
     div $a3, $t2   		# divides
     mflo $t5			# gets y value in 2-D demension
     									
     lw $t2, height		# uses $t2 to store height
     addi  $t2, $t2, -1		# subtracts 1 from $t2
     
     bne $t5, $t2, addOneY	# if startY does not equal to 0, begins search reading array 
      j nope4
        addOneY:
           lw $t2, width
           add $a3, $a3, $t2		# adds width to current arg
           jal recursiveSolve		# recursion!
           beq $v0, $0, nope4 		# if return value equals to 0 (false), leaves if statement 'if (recursiveSolve(x-1, y))'
           li $t1, '1'			# loads '1' to $t1
           sb $t1, correctPath($a3)	# stores a '1' to indicate correct path at index of $s0
           li $v0, 1			# puts a 1 for return value
           j recurDone
    # =============================================================
    # put return values, if any, in $v0-$v1
  setRV1:
    li $v0, 1			# loads 1 in $v0
    j recurDone			# if we get here, we finished recursion? Originates from base case... 
  setRV0:
    li $v0, 0			# loads 0 in $v0
    j recurDone			# goes back to search mazes 
    
  nope4:

    li $v0, 0			# returns 0 - last line in recurssion function

    
    # =============================================================
    # Restore $fp, $ra, and shrink stack back to how we found it,
    #   and return to caller.
    recurDone:
    addi    $sp, $fp, 4     # Restore $sp
    lw      $ra, 0($fp)     # Restore $ra
    lw      $fp, -4($fp)    # Restore $fp
    lw      $a3,  -8($fp)           # Restore $s0
    jr      $ra             # Return from procedure

 end: 
  ori $v0, $0, 10       		# system call code 10 for exit
  syscall               		# exit the program
 
 
 
  
  

  
