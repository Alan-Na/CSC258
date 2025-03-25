######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 2
# - Unit height in pixels: 2
# - Display width in pixels: 64
# - Display height in pixels: 64
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
.text

testmain1:
##############################################################################

## Draw the capsule in preparing area(right) --------Sample cases for drmario.asm
    # Generate a random upper colour
    li $v0, 42          # system call：Generate a random number
    li $a0, 0           # reset generator id to 0
    li $a1, 3           # upperbound：3（0, 1, 2）
    syscall
    move $t8, $a0       # load the generated number to $t8
    sll $t8, $t8, 2     # number * 4（index of COLORS array）
    lw $t1, COLORS($t8) # load the upper color into $t1

    # Generate a random lower colour
    li $v0, 42          
    li $a0, 0          
    li $a1, 3      
    syscall
    move $t9, $a0       # load the generated number to $t9
    sll $t9, $t9, 2     # number * 4（index of COLORS array）
    lw $t2, COLORS($t9) # load the lower color into $t2

    ## Paint the capsule
    lw $t3, ADDR_DSPL   # load bm address
    li $t4, 26          # preparing area X coordinate
    li $t5, 7          # preparing area Y coordinate
    # test case
    move $a0, $t4       # X = 26
    move $a1, $t5       # Y = 7
    move $a2, $t1       # upper capsule color
    move $a3, $t2
    jal paint_capsule
    
    j main

##############################################################################
  ## The pixel painting function ##
  # - $a0: X coordinate of the pixel
  # - $a1: Y coordinate of the pixel
  # - $a2: color of the pixel
paint_pixel:
  lw $t0, ADDR_DSPL
  sll $t7, $a1, 7           # offset of Y
  add $t8, $t0, $t7         # calculate Y offset
  sll $t3, $a0, 2           # offset of X
  add $t8, $t8, $t3         # calculate bm address
  sw $a2, 0($t8)            # paint
  jr $ra                    # return

  ## The capsule drawing function ##
  # - $a0: X coordinate of the capsule
  # - $a1: Y coordinate of the capsule
  # - $a2: upper capsule color
  # - $a3: lower capsule color
paint_capsule:
  addi $sp, $sp, -4         # adjust stack pointer
  sw $ra, 0($sp)            # save $ra
  lw $t3, ADDR_DSPL         # load bm address
  jal paint_pixel           # paint upper part
  addi $a1, $a1, 1          # update pixel location
  move $a2, $a3             # update pixel color
  jal paint_pixel           # paint lower part
  lw $ra, 0($sp)            # recover $ra
  addi $sp, $sp, 4          # recover sp
  jr $ra                    # return
  
##############################################################################
  ## The medicine bottle drawing function
draw_bottle:
    addi $sp, $sp, -4         # adjust stack pointer
    sw $ra, 0($sp)            # save $ra
      
    addi $a2, $zero, 7      # Length = 7
    addi $a0, $zero, 2      # X = 2
    addi $a1, $zero, 5      # Y = 5
    jal draw_horizontal_line

    addi $a2, $zero, 7      # Length = 7
    addi $a0, $zero, 13     # X = 13
    addi $a1, $zero, 5      # Y = 5
    jal draw_horizontal_line

    addi $a2, $zero, 18     # Length = 18
    addi $a0, $zero, 2      # X = 2
    addi $a1, $zero, 30     # Y = 30
    jal draw_horizontal_line

    ## Draw vertical lines ##
    addi $a2, $zero, 26     # Length = 26
    addi $a0, $zero, 2      # X = 2
    addi $a1, $zero, 5      # Y = 5
    jal draw_vertical_line

    addi $a2, $zero, 26      # Length = 26
    addi $a0, $zero, 20      # X = 20
    addi $a1, $zero, 5       # Y = 5
    jal draw_vertical_line

    addi $a2, $zero, 3      # Length = 3
    addi $a0, $zero, 9      # X = 9
    addi $a1, $zero, 3      # Y = 3
    jal draw_vertical_line

    addi $a2, $zero, 3      # Length = 3
    addi $a0, $zero, 13      # X = 13
    addi $a1, $zero, 3      # Y = 3
    jal draw_vertical_line

    lw $ra, 0($sp)            # recover $ra
    addi $sp, $sp, 4          # recover sp

    jr $ra                 #return

##############################################################################
## The honrizontal line drawing function ##
  # - $a0: X coordinate of the start of the honrizontal line
  # - $a1: Y coordinate of the start of the honrizontal line
  # - $a2: Length of the line
draw_horizontal_line:
  lw $t0, ADDR_DSPL       # load bitmap address
  add $t5, $zero, $zero   # loop variable $t5 = 0
  sll $t8, $a1, 7         # temporary register $t8 = offset of Y
  add $t7, $t0, $t8       # calculate Y offset
  sll $t9, $a0, 2         # temporary register $t9 = offset of X
  add $t7, $t7, $t9       # calculate initial bm address

pixel_draw_horizontal_start:
  lw $t1, COLOR_GREY      # load grey to $t1
  sw $t1, 0($t7)          # paint(Grey)
  addi $t5, $t5, 1
  addi $t7, $t7, 4
  beq $t5, $a2, pixel_draw_horizontal_end
  j pixel_draw_horizontal_start

pixel_draw_horizontal_end:
  jr $ra

  ## The vertical line drawing function ##
  # - $a0: X coordinate of the start of the vertical line
  # - $a1: Y coordinate of the start of the vertical line
  # - $a2: Length of the line
draw_vertical_line:
  lw $t0, ADDR_DSPL       # load bitmap address
  add $t5, $zero, $zero   # loop variable $t5 = 0
  sll $t8, $a1, 7         # temporary register $t8 = offset of Y
  add $t7, $t0, $t8       # calculate Y offset
  sll $t9, $a0, 2         # temporary register $t9 = offset of X
  add $t7, $t7, $t9       # calculate initial bm address
  
pixel_draw_vertical_start:           # the starting label for the pixel drawing loop  
  lw $t1, COLOR_GREY        # load grey to $t1
  sw $t1, 0( $t7 )            # paint the current bitmap location.
  addi $t5, $t5, 1            # increment the loop variable
  addi $t7, $t7, 128            # move to the next pixel in the column.
  beq $t5, $a2, pixel_draw_vertical_end    # break out of the loop if you hit the final pixel in the column
  j pixel_draw_vertical_start          # otherwise, jump to the top of the loop
  
pixel_draw_vertical_end:             # the label for the end of the pixel drawing loop
  jr $ra                      # return to calling program









