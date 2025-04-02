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
    jal draw_panel
    jal draw_drmario
    jal draw_virus
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
    
    jal save_grid
    move $a0, $s0
    move $t1, $s1
    addi $a1, $t1, 2
    jal capsule_outline

   ###############################################################################
    # Generate 4 viruses in random places in the bottle
    jal generate_viruses
    move $a0, $t1
    move $a1, $t2
    move $a2, $t3
    jal paint_pixel

    jal generate_viruses
    move $a0, $t1
    move $a1, $t2
    move $a2, $t3
    jal paint_pixel

    jal generate_viruses
    move $a0, $t1
    move $a1, $t2
    move $a2, $t3
    jal paint_pixel

    jal generate_viruses
    move $a0, $t1
    move $a1, $t2
    move $a2, $t3
    jal paint_pixel

    
game_loop:
  jal play_background_music
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    jal poll_keyboard
    # 2a. Check for collisions
    
	# 2b. Update locations (capsules)
	# 3. Draw the screen
    jal restore_grid        # restore the screen
    lw $t0, ADDR_DSPL # Give the display address
    li $t1, 2
    beq $v0, $t1, make_new_capsule
    li $t1, 2
	# 4. Sleep
# delay_loop:
#     li   $t0, 10000000   # 设定延时计数（数值可根据需要调整）
# delay:
#     addi $t0, $t0, -1
#     bgtz $t0, delay
    # 5. Go back to Step 1
    j game_loop
##############################################################################

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
############################################################################
make_new_capsule:
    lw $s0, X_position
    lw $s1, Y_position
    lw $s4, Horizontal
    move $s2, $s5
    move $s3, $s6
    lw $t0, ADDR_DSPL    
    lw $a0, X_position
    lw $a1, Y_position
    add $a2, $s2, $zero
    add $a3, $s3, $zero
    jal paint_capsule   # Draw the capsules

    jal generate_new_capsule # Genarate random colors for capsule on the right side
    add $s5, $t1, $zero      # store the color in $s4
    add $s6, $t2, $zero      # store the color in $s5
    lw $t0, ADDR_DSPL
    lw $a0, X_position_side
    lw $a1, Y_position_side
    add $a2, $s5, $zero
    add $a3, $s6, $zero
    jal paint_vertical_capsule   # Draw side capsule    

    move $a0, $s0
    move $t1, $s1
    addi $a1, $t1, 2
    jal capsule_outline

    j game_loop

#########################################################################################
capsule_outline_loop:
  jal Detect_vertical_collision
  beq $v0, 0, outline_plus
  j draw_outline

outline_plus:
  addi $a1, $a1, 1
  j capsule_outline_loop

capsule_outline:
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $v0, 4($sp)
    j capsule_outline_loop


End_outline_loop:
    lw $ra, 0($sp)
    lw $v0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

  draw_outline:
    move $v1, $a1
    lw $t0, ADDR_DSPL
    lw $a2, COLOR_YELLOW
    lw $a3, COLOR_YELLOW
    jal paint_capsule   # Draw the capsules
    j End_outline_loop

##############################################################################
# Function: play_background_music
# Description: Plays background music using MIDI syscalls  
play_background_music:
    # Save registers we'll use
    addi $sp, $sp, -24
    sw $ra, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)
    
    # Get current system time
    li $v0, 30
    syscall                 # Time in milliseconds in $a0
    
    # Check if base_time is initialized
    lw $t0, base_time
    bnez $t0, check_note
    
    # Initialize base_time if it's 0
    sw $a0, base_time
    j music_done

check_note:
    # Calculate elapsed time
    lw $t0, base_time
    sub $t1, $a0, $t0      # Current elapsed time
    # Load music state
    lw $t0, lastTime
    lw $t2, noteCount  
    # Check if we've played all notes
    bge $t0, $t2, music_done  
    # Calculate current note address
    sll $t2, $t0, 2        # Multiply index by 4  
    # Load timing data
    la $t3, times
    add $t3, $t3, $t2
    lw $t4, 0($t3)         # Current note's timing
    # Compare with elapsed time
    bgt $t1, $t4, play_current_note
    j music_done

play_current_note:
    # Load and play note
    la $t3, notes
    add $t3, $t3, $t2
    lw $a0, 0($t3)         # Note pitch 
    la $t3, duration
    add $t3, $t3, $t2
    lw $a1, 0($t3)         # Duration
    lw $a2, instrument     # Load instrument
    la $t3, velocity
    add $t3, $t3, $t2
    lw $a3, 0($t3)         # Velocity
    # Play the note
    li $v0, 31             # MIDI out syscall
    syscall
    # Increment music index
    lw $t0, lastTime
    addi $t0, $t0, 1
    sw $t0, lastTime

music_done:
    # Restore registers
    lw $ra, 0($sp)
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    addi $sp, $sp, 24
    
    jr $ra

####################################################################################
generate_viruses:
    # Generate random number in range [3,19]
    li $a0, 0              # ID of random number generator
    li $a1, 17             # Upper bound (exclusive) of range (19-3+1=17)
    li $v0, 42             # Syscall 42: random int range
    syscall
    
    addi $a0, $a0, 3       # Add 3 to shift range from [0,16] to [3,19]
    move $t1, $a0
    
 # Generate random number in range [6,29]
    li $a0, 0              # ID of random number generator
    li $a1, 24             # Upper bound (exclusive) of range (29-6+1=24)
    li $v0, 42             # Syscall 42: random int range
    syscall
    
    addi $a0, $a0, 6       # Add 6 to shift range from [0,23] to [6,29]
    move $t2, $a0
    
 # Generate a random color
    li $v0, 42          # system call：Generate a random number
    li $a0, 0           # reset generator id to 0
    li $a1, 3           # upperbound：3（0, 1, 2）
    syscall             # $a0 holds the generated number
    
    sll $a0, $a0, 2     # number * 4（index of COLORS array）
    lw $t3, COLORS($a0) # load the upper color into $t1

    jr $ra
    
  