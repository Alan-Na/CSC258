################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Xineng Na, 1010194424
# Student 2: Yi Chen Liu，1009894232
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       2
# - Unit height in pixels:      2
# - Display width in pixels:    64
# - Display height in pixels:   64
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
  .include "common.asm"
  .include "bitmap_display.asm"
  .include "keyboard.asm"
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
# The address of the keyboard. Don't forget to connect it!

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
    # Run the game.
main:
    # Initialize the game
    lw $s0, X_position       # Save the x positon in s0
    lw $s1, Y_position       # Save the y position in s1
    jal generate_new_capsule # Generate random colors for capsule
    add $s2, $t1, $zero      # store the color in $s2
    add $s3, $t2, $zero      # store the color in $s3
    jal generate_new_capsule # Genarate random colors for capsule on the right side
    add $s5, $t1, $zero      # store the color in $s4
    add $s6, $t2, $zero      # store the color in $s5
##############################################################################
    lw $s4, Horizontal   # Save the horizontal status in s4
    jal draw_bottle      # Draw the bottle
    lw $t0, ADDR_DSPL    
    lw $a0, X_position
    lw $a1, Y_position
    add $a2, $s2, $zero
    add $a3, $s3, $zero
    jal paint_capsule   # Draw the capsules

    # Draw the preparing capsule
    lw $t0, ADDR_DSPL
    lw $a0, X_position_side
    lw $a1, Y_position_side
    add $a2, $s5, $zero
    add $a3, $s6, $zero
    jal paint_vertical_capsule   # Draw side capsule    
  
game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    jal poll_keyboard
    # 2a. Check for collisions
    
	# 2b. Update locations (capsules)
	# 3. Draw the screen
    # jal reset              # reset the canvas to black
    # jal draw_bottle        # Draw the bottle
    jal restore_grid        # restore the screen
    lw $t0, ADDR_DSPL      # Give the display address
    add $a0, $s0, $zero    # Give the X_position
    add $a1, $s1, $zero    # Give the Y_position
    add $a2, $s2, $zero    # Give the first color
    add $a3, $s3, $zero    # Give the second color
    jal paint_capsule
	# 4. Sleep
# delay_loop:
#     li   $t0, 10000000   # 设定延时计数（数值可根据需要调整）
# delay:
#     addi $t0, $t0, -1
#     bgtz $t0, delay
    # 5. Go back to Step 1
    j game_loop

##############################################################################
## generating new capsule function
generate_new_capsule:
    # Upper part
    li $v0, 42          # system call：Generate a random number
    li $a0, 0           # reset generator id to 0
    li $a1, 3           # upperbound：3（0, 1, 2）
    syscall             # $a0 holds the generated number
    sll $a0, $a0, 2     # number * 4（index of COLORS array）
    lw $t1, COLORS($a0) # load the upper color into $t1
    # Lower part
    li $v0, 42          # system call：Generate a random number
    li $a0, 0           # reset generator id to 0
    li $a1, 3           # upperbound：3（0, 1, 2）
    syscall             # $a0 holds the generated number
    sll $a0, $a0, 2     # number * 4（index of COLORS array）
    lw $t2, COLORS($a0) # load the upper color into $t1
    jr $ra              # return
##############################################################################
# recover bitmap
restore_grid:
    la   $t0, DRMARIO_GRID   # Saving address：DRMARIO_GRID
    lw   $t1, ADDR_DSPL      # target address
    lw   $t2, GRID_SIZE      # bits to be copied
restore_loop:
    beq  $t2, $zero, restore_end  # exit when finish
    lw   $t3, 0($t0)         # read a bit from DRMARIO_GRID
    sw   $t3, 0($t1)         # into memory
    addi $t0, $t0, 4         # next bit
    addi $t1, $t1, 4
    addi $t2, $t2, -1        # count - 1
    j    restore_loop
restore_end:
    jr   $ra                 # return


