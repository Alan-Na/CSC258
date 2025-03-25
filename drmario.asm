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
    lw $s0, X_position
    lw $s1, Y_position
    li $s2, 0x00FF00
    li $s3, 0xFF0000
    jal draw_bottle
    li $t0, 0x10008000
    lw $a0, X_position
    lw $a1, Y_position
    li $a2, 0x00FF00
    li $a3, 0xFF0000
    jal paint_capsule
    
game_loop:
    # 1a. Check if key has been pressed
    jal keyboard_input
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop

move_down:
  addi $s1, $s1, 1
  lw $t0, ADDR_DSPL
  add $a0, $s0, $zero
  add $a1, $s1, $zero
  li $a2, 0x00FF00
  li $a3, 0xFF0000
  jal paint_capsule
  j game_loop
move_right:

move_left:

rotate:
  