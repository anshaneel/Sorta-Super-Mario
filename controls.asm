################################################ Input Functions #######################################################
################ Check for Key Press #################
check_press:
	# Fetch keyboard input
	li $t9, 0xffff0000
	lw $t1, 0($t9)
	beq $t1, 1, keypress_happened
	j inner_loop

############ Check which Key is Pressed ##############
keypress_happened:
	
	lw $t2, 4($t9)

	# Check if 'a' is pressed
	li $t4, 0x61 # ASCII code for 'a'
	beq $t2, $t4, respond_to_a

	# Check if 'd' is pressed
	li $t4, 0x64 # ASCII code for 'd'
	beq $t2, $t4, respond_to_d

	# Check if 'space' is pressed
	li $t4, 0x20 # ASCII code for space
	beq $t2, $t4, respond_to_space
	
	# Check if 's' is pressed
    	li $t4, 0x73 # ASCII code for 's'
    	beq $t2, $t4, respond_to_s

	# Check if 'p' is pressed
	li $t4, 0x70 # ASCII code for 'p'
	beq $t2, $t4, respond_to_p
	
	j end_of_actions





############ Respond to Key Presses ##############
respond_to_a:
    # Actions for 'a' keypress
    la $t0, character_movement  # Load the address of character_movement array into $t0
    li $t1, 1
    sw $zero, 4($t0)  # Set character_movement[1] to 1 (right enabled on)
    sw $t1, 0($t0)    # Set character_movement[0] to 0 (left enabled on)
    
    move_left:
    	# left collisions
    	# Check for right collisions
    	lw $t0, CharX
    	lw $t1, CharY
    	
    	beq $t0, 0, game_vertical
    	
    	add $t1, $t1, CHAR_HEIGHT
    	addi $t1, $t1, -1
    	addi $t0, $t0, -1
    	li $t2, 0x10008000   		# Load the base address of the bitmap
    	mul $t3, $t1, 128    		# Calculate y_offset = y_position * 512
    	add $t3, $t3, $t0    		# Calculate total_offset = y_offset + x_position
    	mul $t3, $t3, 4	 		# starting address = total_offset * 4
    	add $t2, $t2, $t3    		# Add the total_offset to the base address
	
    	lw $t4, 0($t2)			# set $t4 to the value of the pixel at the top right
    	bne $t4, 0x00000000, game_vertical
    	addi $t2, $t2, -3584
    	lw $t4, 0($t2)
    	bne $t4, 0x00000000, game_vertical
    	addi $t2, $t2, -3584
    	lw $t4, 0($t2)
    	bne $t4, 0x00000000, game_vertical
    
    
    	jal erase_character # erase character in current position
    	la $t0, CharX   # Load the address of CharX into $t0
    	lw $t1, 0($t0)  # Load the value stored at CharX into $t1
    	addi $t1, $t1, -1 # Increment the value in $t1 by -1
    	sw $t1, 0($t0)  # Store the updated value in $t1 back to CharX
    	jal draw_character
    
    j game_vertical

respond_to_d:
    # Actions for 'd' keypress
    la $t0, character_movement  # Load the address of character_movement array into $t0
    li $t1, 1
    sw $zero, 0($t0)    # Set character_movement[1] to 1 (left enabled off)
    sw $t1, 4($t0)  # Set character_movement[0] to 0 (right enabled off)
    
    move_right:
    	# Check for right collisions
    	lw $t0, CharX
    	lw $t1, CharY
    	
    	beq $t0, 119, game_vertical
    	
    	add $t0, $t0, CHAR_WIDTH
    	add $t1, $t1, CHAR_HEIGHT
    	addi $t1, $t1, -1
    	li $t2, 0x10008000   		# Load the base address of the bitmap
    	mul $t3, $t1, 128    		# Calculate y_offset = y_position * 512
    	add $t3, $t3, $t0    		# Calculate total_offset = y_offset + x_position
    	mul $t3, $t3, 4	 		# starting address = total_offset * 4
    	add $t2, $t2, $t3    		# Add the total_offset to the base address
	
    	lw $t4, 0($t2)			# set $t4 to the value of the pixel at the top right
    	bne $t4, 0x00000000, game_vertical
    	addi $t2, $t2, -3584
    	lw $t4, 0($t2)
    	bne $t4, 0x00000000, game_vertical
    	addi $t2, $t2, -3584
    	lw $t4, 0($t2)
    	bne $t4, 0x00000000, game_vertical
    
    
    	# Move right
    	jal erase_character # erase character in current position
    	la $t0, CharX   # Load the address of CharX into $t0
    	lw $t1, 0($t0)  # Load the value stored at CharX into $t1
    	addi $t1, $t1, 1 # Increment the value in $t1 by 1
    	sw $t1, 0($t0)  # Store the updated value in $t1 back to CharX
    	jal draw_character
    
    j game_vertical

respond_to_space:
    # Actions for 'space' keypress
    # Set down enabled to 0
    la $t0, character_movement    # Load the address of character_movement into $t0
    lw $t1, 12($t0)
    beqz $t1, end_of_actions
    sw $zero, 12($t0)             # Store the value 0 at the "down enabled" element's address
   
    move_up:
    	# Move the character one pixel up
    	la $t0, character_movement    # Load the address of character_movement into $t0
    	lw $t1, 8($t0)             
    	beq $t1, 18, end_jump
    	
    	lw $t0, CharX
    	lw $t1, CharY
    	li $t4, CHAR_WIDTH
    	addi $t1, $t1, -1    # Get the Y value one above the character
    	li $t2, 0x10008000   # Load the base address of the bitmap
    	mul $t3, $t1, 128    # Calculate y_offset = y_position * 512
    	add $t3, $t3, $t0    # Calculate total_offset = y_offset + x_position
    	mul $t3, $t3, 4	     # starting address = total_offset * 4
    	add $t2, $t2, $t3    # Add the total_offset to the base address
    
    	mul $t4, $t4, 4

    	lw $t4, 0($t2)
    	bne $t4, 0x00000000, end_jump
    	add $t2, $t2, $t4
    	lw $t4, 0($t2)
    	bne $t4, 0x00000000, end_jump
    	
   	jal erase_character 	# erase character in current position
    	la $t0, CharY   	# Load the address of CharX into $t0
    	lw $t1, 0($t0)  	# Load the value stored at CharX into $t1
    	addi $t1, $t1, -1 	# Increment the value in $t1 by 1
    	sw $t1, 0($t0)  	# Store the updated value in $t1 back to CharX
    	jal draw_character
    	
    	la $t0, character_movement    # Load the address of character_movement into $t0
    	lw $t1, 8($t0)             
    	addi $t1, $t1, 1	      # add 1 to the jump counter
    	sw $t1, 8($t0)
    
    
    j end_of_actions

end_jump:
    la $t0, character_movement    # Load the address of character_movement into $t0
    li $t1, 1
    sw $t1, 12($t0)
    sw $zero, 8($t0)           
    
    j end_of_actions
	
respond_to_s:
    # Actions for 's' keypress
    la $t0, character_movement  # Load the address of character_movement array into $t0
    sw $zero, 0($t0)  # Set character_movement[0] to 0
    sw $zero, 4($t0)  # Set character_movement[1] to 0

    j end_of_actions

respond_to_p:
    # Actions for 'p' keypress
    j main

move_down:
   
    lw $t0, CharX
    lw $t1, CharY
    li $t4, CHAR_WIDTH
    add $t1, $t1, CHAR_HEIGHT
    li $t2, 0x10008000   # Load the base address of the bitmap
    mul $t3, $t1, 128    # Calculate y_offset = y_position * 512
    add $t3, $t3, $t0    # Calculate total_offset = y_offset + x_position
    mul $t3, $t3, 4	 # starting address = total_offset * 4
    add $t2, $t2, $t3    # Add the total_offset to the base address


    lw $t4, 0($t2)
    
    # Print the value of $t4 as hexadecimal
    li $v0, 34   # Set syscall 34 (print hexadecimal)
    move $a0, $t4  # Move the value of $t4 to $a0 (syscall argument)
    syscall
    
    beq $t4, 0x00d22700, damage_taken    # If lava colour then call damage taken function
    beq $t4, 0x00233705, next_level
    beq $t4, 0x004abd1b, next_level
    beq $t4, 0x0061c124, next_level
    
    bne $t4, 0x00000000, end_of_actions
    addi $t2, $t2, 36
    lw $t4, 0($t2)
    # Print the value of $t4 as hexadecimal
    li $v0, 34   # Set syscall 34 (print hexadecimal)
    move $a0, $t4  # Move the value of $t4 to $a0 (syscall argument)
    syscall
    beq $t4, 0x00d22700, damage_taken	# If lava colour then call damage taken function
    beq $t4, 0x00233705, next_level
    beq $t4, 0x004abd1b, next_level
    beq $t4, 0x0061c124, next_level
    
    bne $t4, 0x00000000, end_of_actions
    
    jal erase_character # erase character in current position
    la $t0, CharY   # Load the address of CharX into $t0
    lw $t1, 0($t0)  # Load the value stored at CharX into $t1
    addi $t1, $t1, 1 # Increment the value in $t1 by 1
    sw $t1, 0($t0)  # Store the updated value in $t1 back to CharX
    jal draw_character
    
    j end_of_actions

############### End of the Check Press #################
end_of_actions:
    j sleep      # Jumps back to location of function call






