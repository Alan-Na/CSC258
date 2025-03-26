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
# Immutable Data
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
    lw $s0, X_position   # Save the x positon in s0
    lw $s1, Y_position   # Save the y position in s1
    lw $s4, Horizontal   # Save the horizontal status in s4
    jal draw_bottle      # Draw the bottle
    lw $t0, ADDR_DSPL    
    lw $a0, X_position
    lw $a1, Y_position
    add $a2, $s2, $zero
    add $a3, $s3, $zero
    jal paint_capsule   # Draw the capsules
    
game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    jal testmain2
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
    jal reset              # reset the canvas to black
    jal draw_bottle        # Draw the bottle
    lw $t0, ADDR_DSPL      # Give the display address
    add $a0, $s0, $zero    # Give the X_position
    add $a1, $s1, $zero    # Give the Y_position
    add $a2, $s2, $zero    # Give the first color
    add $a3, $s3, $zero    # Give the second color
    jal paint_capsule
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop



    