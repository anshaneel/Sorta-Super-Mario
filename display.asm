################################################### Display Functions ##########################################################
# Display function
# a0: pointer to image data
# a1: width of the image
# a2: height of the image
# $t0: x position
# $t1: y position
display_image:
    addi $sp, $sp, -16   # Allocate space for 4 saved registers
    sw $ra, 12($sp)      # Save return address
    sw $a0, 0($sp)       # Save image pointer
    sw $a1, 4($sp)       # Save width
    sw $a2, 8($sp)       # Save height

    li $t2, 0x10008000   # Load the base address of the bitmap
    mul $t3, $t1, 128    # Calculate y_offset = y_position * 512
    add $t3, $t3, $t0    # Calculate total_offset = y_offset + x_position
    mul $t3, $t3, 4	 # starting address = total_offset * 4
    add $t2, $t2, $t3    # Add the total_offset to the base address

    li $t4, 0            # Row counter
    li $t5, 0            # Column counter

    loop_row:
        beq $t4, $a2, exit_display # If all rows are processed, exit
	
    loop_col:
        beq $t5, $a1, next_row  # If all columns are processed, go to the next row
	
        lw $t6, 0($a0)          # Load pixel data from the image
        sw $t6, 0($t2)          # Store pixel data to the screen memory
        
        addi $a0, $a0, 4
        addi $t2, $t2, 4
        
        addi $t5, $t5, 1        # Increment column counter
        j loop_col

    next_row:
        addi $t4, $t4, 1        # Increment row counter
        li $t5, 0               # Reset column counter
        
        add $t3, $t1, $t4
    	mul $t3, $t3, 128    	# Calculate y_offset = y_position * 512
    	add $t3, $t3, $t0    	# Calculate total_offset = y_offset + x_position
    	mul $t3, $t3, 4	     	# starting address = total_offset * 4
    	addi $t2, $t3, 0x10008000
    	
        j loop_row
    
    exit_display:
    	lw $ra, 12($sp)      # Restore return address
    	addi $sp, $sp, 16    # Restore stack pointer
	
    	jr $ra               # Return from function

################################################ Draw Character Function #######################################################
draw_character:
    
    # Save the return address on the stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Set up the arguments for display_image
    la $a0, character   # Replace image_start with the label of the image data in memory
    li $a1, CHAR_WIDTH           
    li $a2, CHAR_HEIGHT 
    lw $t0, CharX
    lw $t1, CharY        

    # Call display_image
    jal display_image
    
    # Restore the return address from the stack
    lw $ra, 0($sp)
    addi $sp, $sp, 4
	
    # Return from the function
    jr $ra



erase_character:

    # Save the return address on the stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    # Set up the arguments for display_image
    la $a0, character_background   # Replace image_start with the label of the image data in memory
    li $a1, CHAR_WIDTH           
    li $a2, CHAR_HEIGHT 
    lw $t0, OldX
    lw $t1, OldY        

    # Call display_image
    jal display_image

    # Restore the return address from the stack
    lw $ra, 0($sp)
    addi $sp, $sp, 4
	
    # Return from the function
    jr $ra
    
    
print_fireball:

    la $a0, erase_fireball   # Replace image_start with the label of the image data in memory
    li $a1, 11           
    li $a2, 7
    lw $t0, fireballX
    lw $t1, fireballY        

    # Call display_image
    jal display_image
    
    lw $t0, fireballX  # Load the current value of "fireball_x" into register $t0
    addi $t0, $t0, -1     # Add 1 to the value in $t0
    sw $t0, fireballX   # Store the updated value back to "fireball_x" in memory
    
    la $a0, fireball   # Replace image_start with the label of the image data in memory
    li $a1, 11           
    li $a2, 7
    lw $t0, fireballX
    lw $t1, fireballY  
    
    beq $t0, 0, reset_fireball

    cont:
    # Call display_image
    jal display_image
    
    j continue

reset_fireball:
	li $t0, 50
	sw $t0, fireballX
	j cont


