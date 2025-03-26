##############################################################################
# Example: Keyboard Input
#
# This file demonstrates how to read the keyboard to check if a key was pressed.
##############################################################################
    .text
    .globl main2

testmain2:
    li      $v0, 32
    li      $a0, 1
    syscall

    lw      $t0, ADDR_KBRD         # $t0 = base address for keyboard
    lw      $t8, 0($t0)            # Load first word from keyboard
    beq     $t8, 1, keyboard_input # If key pressed, jump to handler
    j       testmain2              # Otherwise, loop back

keyboard_input:                   # A key is pressed
    # jal save_grid               # Save bitmap info
    # jal wipe_capsule            # Wipe the capsule in last second

    lw      $t0, ADDR_KBRD         # $t0 = keyboard base address
    lw      $a0, 4($t0)            # Load second word (key code)
    beq     $a0, 0x71, respond_to_Q   # If 'q' pressed
    beq     $a0, 0x61, respond_to_A   # If 'a' pressed
    beq     $a0, 0x64, respond_to_D   # If 'd' pressed
    beq     $a0, 0x73, respond_to_S   # If 's' pressed
    beq     $a0, 0x77, respond_to_W   # If 'w' pressed
    li      $v0, 1
    syscall

    j       testmain2              # Loop back

##############################################################################
respond_to_A:
    # Respond to key 'a': move capsule left
    subi    $t1, $s1, 5           # t1 = s1 - 5, check if capsule is at the top
    blez    $t1, End_A            # if t1 <= 0, exit
    addi    $t2, $s0, -1          # t2 = s0 - 1, potential new X position
    beq     $t2, 2, End_A         # if reached left boundary, exit
    addi    $s0, $s0, -1          # move X position left by 1
    j       End_A

End_A:
    jr      $ra

##############################################################################
respond_to_D:
    # Respond to key 'd': move capsule right
    addi    $sp, $sp, -4          # Allocate stack space for $t1
    sw      $t1, 0($sp)           # Save $t1

    subi    $t1, $s1, 5           # t1 = s1 - 5, check if capsule is at the top
    blez    $t1, End_D            # if t1 <= 0, exit
    addi    $t2, $s0, 1           # t2 = s0 + 1, potential new X position

    # 根据 $s4 判断移动方向
    beq     $s4, $zero, vertical_D
    beq     $s4, 1, horizontal_D
    j       End_D                # 默认退出

horizontal_D:
    beq     $t2, 19, End_D       # if reached right boundary, exit
    addi    $s0, $s0, 1          # move X position right by 1
    j       End_D

vertical_D:
    beq     $t2, 20, End_D       # if reached boundary, exit
    addi    $s0, $s0, 1          # move X position right by 1 (logic per original)
    j       End_D

End_D:
    lw      $t1, 0($sp)          # Restore $t1
    addi    $sp, $sp, 4          # Restore stack pointer
    jr      $ra

##############################################################################
respond_to_S:
    # Respond to key 's': move capsule down
    addi    $t1, $s1, 1          # t1 = s1 + 1, potential new Y position
    beq     $s4, $zero, vertical_s
    beq     $s4, 1, horizontal_s
    j       End_S               # 默认退出

horizontal_s:
    beq     $t1, 30, End_S       # if reached bottom boundary, exit
    addi    $s1, $s1, 1          # move Y position down by 1
    j       End_S

vertical_s:
    beq     $t1, 29, End_S       # if reached boundary, exit
    addi    $s1, $s1, 1          # move Y position down by 1
    j       End_S

End_S:
    jr      $ra

##############################################################################
respond_to_W:
    # Respond to key 'w': rotate capsule
    subi    $t1, $s1, 5          # t1 = s1 - 5, check if capsule is at the top
    blez    $t1, End_W           # if t1 <= 0, exit
    beq     $s0, 19, End_W       # if at right boundary, cannot rotate
    beq     $s4, $zero, vertical_capsule   # if capsule is vertical
    beq     $s4, 1, horizontal_capsule     # if capsule is horizontal

vertical_capsule:
    addi    $s1, $s1, 1          # move Y position down by 1
    move    $t8, $s2             # temporarily save s2
    move    $t9, $s3             # temporarily save s3
    move    $s2, $t9             # swap s2 and s3
    move    $s3, $t8
    li      $s4, 1              # set capsule orientation to horizontal (1)
    j       End_W

horizontal_capsule:
    addi    $s1, $s1, -1         # move Y position up by 1
    li      $s4, 0              # set capsule orientation to vertical (0)
    j       End_W

End_W:
    jr      $ra

##############################################################################
respond_to_Q:
    # Respond to key 'q': quit gracefully
    li      $v0, 10
    syscall

##############################################################################
# Function: save bitmap to DRMARIO_GRID
save_grid:
    addi    $sp, $sp, -4         # Allocate space for $ra
    sw      $ra, 0($sp)          # Save $ra

    la      $t0, ADDR_DSPL        # $t0 = source (display) base address
    la      $t1, DRMARIO_GRID     # $t1 = storage area base address
    lw      $t2, GRID_SIZE        # Load number of words to store
save_loop:
    beq     $t2, $zero, save_end  # Loop exit condition
    lw      $t3, 0($t0)           # Read one word from display
    sw      $t3, 0($t1)           # Store it in DRMARIO_GRID
    addi    $t0, $t0, 4           # Next word in display
    addi    $t1, $t1, 4           # Next word in storage
    addi    $t2, $t2, -1          # Decrement counter
    j       save_loop
save_end:
    lw      $ra, 0($sp)           # Restore $ra
    addi    $sp, $sp, 4           # Restore stack pointer
    jr      $ra

##############################################################################
# Function: wipe the capsule in last second
wipe_capsule:
    addi    $sp, $sp, -4         # Allocate space for $ra
    sw      $ra, 0($sp)          # Save $ra

    la      $t1, DRMARIO_GRID     # $t1 = storage base address
    lw      $t5, COLOR_BLACK      # $t5 = black color

    beq     $s4, $zero, do_wipe_vertical   # if $s4 == 0, vertical wipe
    beq     $s4, 1, do_wipe_horizontal      # if $s4 == 1, horizontal wipe
    j       wipe_capsule_exit     # Otherwise, exit

do_wipe_vertical:
    sll     $t2, $a1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $a0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer
    sw      $t5, 0($t3)          # Write black color at current pixel
    sw      $t5, 4($t3)          # Write black to next pixel
    j       wipe_capsule_exit

do_wipe_horizontal:
    sll     $t2, $a1, 7          # Compute Y offset
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $a0, 2          # Compute X offset
    add     $t3, $t3, $t4        # Final address
    sw      $t5, 0($t3)          # Write black color
    sw      $t5, 256($t3)        # Write black color at horizontal offset (256 bytes)
    j       wipe_capsule_exit

wipe_capsule_exit:
    lw      $ra, 0($sp)          # Restore $ra
    addi    $sp, $sp, 4          # Restore stack pointer
    jr      $ra
