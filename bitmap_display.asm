######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 2
# - Unit height in pixels: 2
# - Display width in pixels: 64
# - Display height in pixels: 240
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################

.text

test_main1:
##############################################################################
## Draw the capsule in preparing area(right) --------Sample code for drmario.asm
    # draw the bottle
    jal draw_bottle
    # Generate a random upper colour
    li $v0, 42          # system call：Generate a random number
    li $a0, 0           # reset generator id to 0
    li $a1, 3           # upperbound：3（0, 1, 2）
    syscall
    move $t8, $a0       # load the generated number to $t8
    sll $t8, $t8, 2     # number * 4（index of COLORS array）
    lw $t1, COLORS($t8) # load the upper color into $t1
    add $s2, $t1, $zero
    # Generate a random lower colour
    li $v0, 42          
    li $a0, 0          
    li $a1, 3      
    syscall
    move $t9, $a0       # load the generated number to $t9
    sll $t9, $t9, 2     # number * 4（index of COLORS array）
    lw $t2, COLORS($t9) # load the lower color into $t2
    add $s3, $t2, $zero

    ## Paint the capsule
    lw $t3, ADDR_DSPL   # load bm address
    li $t4, 11          # preparing area X coordinate
    li $t5, 3          # preparing area Y coordinate
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
  addi $sp, $sp, -20       
    sw   $t8, 0($sp)         # 保存 $t8 到 sp+0
    sw   $t7, 4($sp)         # 保存 $t7 到 sp+4
    sw   $t3, 8($sp)         # 保存 $t3 到 sp+8
    sw   $t0, 12($sp)        # 保存 $t0 到 sp+12
    sw   $ra, 16($sp)        # 保存 $ra 到 sp+16
  lw $t0, ADDR_DSPL         # load bitmap address
  sll $t7, $a1, 7           # offset of Y
  add $t8, $t0, $t7         # calculate Y offset
  sll $t3, $a0, 2           # offset of X
  add $t8, $t8, $t3         # calculate bm address
  sw $a2, 0($t8)            # paint
    lw   $ra, 16($sp)       # 恢复 $ra
    lw   $t0, 12($sp)       # 恢复 $t0
    lw   $t3, 8($sp)        # 恢复 $t3
    lw   $t7, 4($sp)        # 恢复 $t7
    lw   $t8, 0($sp)        # 恢复 $t8
    addi $sp, $sp, 20       # 释放栈空间
  jr $ra                    # return

  ## The capsule drawing function ##
  # - $a0: X coordinate of the capsule
  # - $a1: Y coordinate of the capsule
  # - $a2: upper capsule color
  # - $a3: lower capsule color
paint_capsule:
  beq $s4, 0, paint_vertical_capsule    # Check if the capsule is vertical
  beq $s4, 1, paint_horizontal_capsule  # Check if the capsule is horizontal
  
paint_vertical_capsule:
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

paint_horizontal_capsule:
  ## The horizontal capsule drawing function ##
  # - $a0: X coordinate of the left part of the capsule
  # - $a1: Y coordinate of the right part of the capsule
  # - $a2: left capsule color
  # - $a3: right capsule color
  addi $sp, $sp, -4         # adjust stack pointer
  sw $ra, 0($sp)            # save $ra
  lw $t0, ADDR_DSPL         # load bm address
  jal paint_pixel           # paint left part
  addi $a0, $a0, 1          # update pixel location
  move $a2, $a3             # update pixel color
  jal paint_pixel           # paint lower part
  lw $ra, 0($sp)            # recover $ra
  addi $sp, $sp, 4          # recover sp
  jr $ra                    # return
  
reset:
  ## The bitmap resetting function ##
  addi $sp, $sp, -4         # adjust sp
  sw $ra, 0($sp)            # save ra
  lw $t0, ADDR_DSPL         # load bitmap address
  li $t1, 4096              # loop = 64x64 = 4096
  lw $t2, COLOR_BLACK       # load black

reset_loop:
  sw $t2, 0($t0)            # paint black
  addi $t0, $t0, 4          # move to next bit
  addi $t1, $t1, -1         # remaining bits - 1
  bgtz $t1, reset_loop      # if remaining bits, keep looping
  lw $ra, 0($sp)            # recover ra
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
draw_panel:
  addi $sp, $sp, -4         # adjust stack pointer
    sw $ra, 0($sp)
    addi $a2, $zero, 6      # Length = 6
    addi $a0, $zero, 26      # X = 26
    addi $a1, $zero, 0      # Y = 1
    jal draw_vertical_line

    addi $a2, $zero, 15     # Length = 15
    addi $a0, $zero, 11      # X = 11
    addi $a1, $zero, 0     # Y = 0
    jal draw_horizontal_line

    addi $a2, $zero, 1     # Length = 1
    addi $a0, $zero, 11      # X = 11
    addi $a1, $zero, 1     # Y = 1
    jal draw_horizontal_line

    addi $a2, $zero, 5     # Length = 5
    addi $a0, $zero, 24      # X = 24
    addi $a1, $zero, 5     # Y = 0
    jal draw_horizontal_line

    addi $a2, $zero, 6      # Length = 6
    addi $a0, $zero, 24      # X = 26
    addi $a1, $zero, 5      # Y = 1
    jal draw_vertical_line

    addi $a2, $zero, 6      # Length = 6
    addi $a0, $zero, 28      # X = 26
    addi $a1, $zero, 5      # Y = 1
    jal draw_vertical_line

    addi $a2, $zero, 5     # Length = 15
    addi $a0, $zero, 24      # X = 11
    addi $a1, $zero, 10     # Y = 0
    jal draw_horizontal_line

    lw $ra, 0($sp)            # recover $ra
    addi $sp, $sp, 4
    jr $ra

##############################################################################
draw_pause:
    addi $sp, $sp, -4         # adjust stack pointer
    sw $ra, 0($sp) 
## P
    addi $a2, $zero, 7      # Length = 6
    addi $a0, $zero, 22      # X = 26
    addi $a1, $zero, 13      # Y = 1
    jal draw_vertical_line

    addi $a2, $zero, 3      # Length = 6
    addi $a0, $zero, 25      # X = 26
    addi $a1, $zero, 13      # Y = 1
    jal draw_vertical_line

    addi $a2, $zero, 4      # Length = 6
    addi $a0, $zero, 22      # X = 26
    addi $a1, $zero, 13      # Y = 1
    jal draw_horizontal_line

    addi $a2, $zero, 4      # Length = 6
    addi $a0, $zero, 22      # X = 26
    addi $a1, $zero, 16      # Y = 1
    jal draw_horizontal_line
## A
    la $a0, 29
    la $a1, 13
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 28
    la $a1, 14
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 28
    la $a1, 15
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 27
    la $a1, 16
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 27
    la $a1, 17
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 27
    la $a1, 18
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 27
    la $a1, 19
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 30
    la $a1, 14
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 30
    la $a1, 15
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 31
    la $a1, 16
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 31
    la $a1, 17
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 31
    la $a1, 18
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 31
    la $a1, 19
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 28
    la $a1, 16
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 29
    la $a1, 16
    lw $a2, COLOR_RED
    jal paint_pixel
    la $a0, 30
    la $a1, 16
    lw $a2, COLOR_RED
    jal paint_pixel

## U
    la $a0, 21
    la $a1, 21
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 21
    la $a1, 22
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 21
    la $a1, 23
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 21
    la $a1, 24
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 21
    la $a1, 25
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 21
    la $a1, 26
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 22
    la $a1, 26
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 23
    la $a1, 26
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 24
    la $a1, 21
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 24
    la $a1, 22
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 24
    la $a1, 23
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 24
    la $a1, 24
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 24
    la $a1, 25
    lw $a2, COLOR_BLUE
    jal paint_pixel
    la $a0, 24
    la $a1, 26
    lw $a2, COLOR_BLUE
    jal paint_pixel

## S
    la $a0, 25
    la $a1, 21
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 25
    la $a1, 22
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 25
    la $a1, 23
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 26
    la $a1, 21
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 27
    la $a1, 21
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 28
    la $a1, 23
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 26
    la $a1, 23
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 28
    la $a1, 21
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 27
    la $a1, 23
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 28
    la $a1, 24
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 28
    la $a1, 26
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 25
    la $a1, 26
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 26
    la $a1, 26
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 27
    la $a1, 26
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 28
    la $a1, 26
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 28
    la $a1, 25
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 27
    la $a1, 23
    lw $a2, COLOR_GREEN
    jal paint_pixel
    la $a0, 25
    la $a1, 23
    lw $a2, COLOR_GREEN
    jal paint_pixel
## E
    la $a0, 29
    la $a1, 21
    lw $a2, COLOR_YELLOW
    jal paint_pixel
    la $a0, 30
    la $a1, 21
    lw $a2, COLOR_YELLOW
    jal paint_pixel
    la $a0, 31
    la $a1, 21
    lw $a2, COLOR_YELLOW
    jal paint_pixel
    la $a0, 29
    la $a1, 22
    lw $a2, COLOR_YELLOW
    jal paint_pixel
    la $a0, 29
    la $a1, 23
    lw $a2, COLOR_YELLOW
    jal paint_pixel
    la $a0, 29
    la $a1, 24
    lw $a2, COLOR_YELLOW
    jal paint_pixel
    la $a0, 29
    la $a1, 25
    lw $a2, COLOR_YELLOW
    jal paint_pixel
    la $a0, 29
    la $a1, 26
    lw $a2, COLOR_YELLOW
    jal paint_pixel
    la $a0, 30
    la $a1, 23
    lw $a2, COLOR_YELLOW
    jal paint_pixel
    la $a0, 31
    la $a1, 23
    lw $a2, COLOR_YELLOW
    jal paint_pixel
    la $a0, 30
    la $a1, 26
    lw $a2, COLOR_YELLOW
    jal paint_pixel
    la $a0, 31
    la $a1, 26
    lw $a2, COLOR_YELLOW
    jal paint_pixel
    
    lw $ra, 0($sp)            # recover $ra
    addi $sp, $sp, 4

    jr $ra
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
##############################################################################
draw_drmario:
    addi $sp, $sp, -4         # adjust stack pointer
    sw $ra, 0($sp)            # save $ra
    # 加载三个数组的起始地址到临时寄存器中
    la   $t0, x_coords      # $t0 指向 x 坐标数组
    la   $t1, y_coords      # $t1 指向 y 坐标数组
    la   $t2, drmario_colors        # $t2 指向颜色数组

    li   $t3, 1108          # 循环计数器：数据总数

draw_drmario_loop:
    beq  $t3, $zero, draw_drmario_end  # 当计数器为0时结束循环

    lw   $a0, 0($t0)        # 取出当前的 x 坐标，传入 $a0
    lw   $a1, 0($t1)        # 取出当前的 y 坐标，传入 $a1
    lw   $a2, 0($t2)        # 取出当前的颜色，传入 $a2

    jal  paint_pixel        # 调用 paint_pixel（注意 paint_pixel 必须遵循 caller-saved 约定）

    # 更新指针，指向下一个数据
    addi $t0, $t0, 4        # 下一个 x 坐标（每个 .word 占4字节）
    addi $t1, $t1, 4        # 下一个 y 坐标
    addi $t2, $t2, 4        # 下一个颜色

    addi $t3, $t3, -1       # 循环计数器减1
    j    draw_drmario_loop  # 跳回循环开始

draw_drmario_end:
    lw $ra, 0($sp)            # recover $ra
    addi $sp, $sp, 4          # recover sp
    jr   $ra                # 返回调用者
##############################################################################
draw_virus:
  addi $sp, $sp, -4         # adjust stack pointer
  sw $ra, 0($sp)            # save $ra
  
  jal draw_red_virus
  jal draw_yellow_virus
  jal draw_blue_virus

  lw $ra, 0($sp)            # recover $ra
  addi $sp, $sp, 4          # recover sp
  jr $ra
## draw red
draw_red_virus:
  addi $sp, $sp, -4         # adjust stack pointer
    sw $ra, 0($sp)            # save $ra
    # 加载三个数组的起始地址到临时寄存器中
    la   $t0, x_coords_red      # $t0 指向 x 坐标数组
    la   $t1, y_coords_red      # $t1 指向 y 坐标数组
    la   $t2, colors_red        # $t2 指向颜色数组

    li   $t3, 125          # 循环计数器：数据总数

draw_red_loop:
    beq  $t3, $zero, draw_red_end  # 当计数器为0时结束循环

    lw   $a0, 0($t0)        # 取出当前的 x 坐标，传入 $a0
    lw   $a1, 0($t1)        # 取出当前的 y 坐标，传入 $a1
    lw   $a2, 0($t2)        # 取出当前的颜色，传入 $a2

    jal  paint_pixel        # 调用 paint_pixel（注意 paint_pixel 必须遵循 caller-saved 约定）

    # 更新指针，指向下一个数据
    addi $t0, $t0, 4        # 下一个 x 坐标（每个 .word 占4字节）
    addi $t1, $t1, 4        # 下一个 y 坐标
    addi $t2, $t2, 4        # 下一个颜色

    addi $t3, $t3, -1       # 循环计数器减1
    j    draw_red_loop  # 跳回循环开始

draw_red_end:
    lw $ra, 0($sp)            # recover $ra
    addi $sp, $sp, 4          # recover sp
    jr   $ra                # 返回调用者
## draw yellow
draw_yellow_virus:
  addi $sp, $sp, -4         # adjust stack pointer
    sw $ra, 0($sp)            # save $ra
    # 加载三个数组的起始地址到临时寄存器中
    la   $t0, x_coords_yellow      # $t0 指向 x 坐标数组
    la   $t1, y_coords_yellow      # $t1 指向 y 坐标数组
    la   $t2, colors_yellow       # $t2 指向颜色数组

    li   $t3, 105          # 循环计数器：数据总数

draw_yellow_loop:
    beq  $t3, $zero, draw_yellow_end  # 当计数器为0时结束循环

    lw   $a0, 0($t0)        # 取出当前的 x 坐标，传入 $a0
    lw   $a1, 0($t1)        # 取出当前的 y 坐标，传入 $a1
    lw   $a2, 0($t2)        # 取出当前的颜色，传入 $a2

    jal  paint_pixel        # 调用 paint_pixel（注意 paint_pixel 必须遵循 caller-saved 约定）

    # 更新指针，指向下一个数据
    addi $t0, $t0, 4        # 下一个 x 坐标（每个 .word 占4字节）
    addi $t1, $t1, 4        # 下一个 y 坐标
    addi $t2, $t2, 4        # 下一个颜色

    addi $t3, $t3, -1       # 循环计数器减1
    j    draw_yellow_loop  # 跳回循环开始

draw_yellow_end:
    lw $ra, 0($sp)            # recover $ra
    addi $sp, $sp, 4          # recover sp
    jr   $ra                # 返回调用者
## draw blue
draw_blue_virus:
  addi $sp, $sp, -4         # adjust stack pointer
    sw $ra, 0($sp)            # save $ra
    # 加载三个数组的起始地址到临时寄存器中
    la   $t0, x_coords_blue      # $t0 指向 x 坐标数组
    la   $t1, y_coords_blue      # $t1 指向 y 坐标数组
    la   $t2, colors_blue       # $t2 指向颜色数组

    li   $t3, 108          # 循环计数器：数据总数

draw_blue_loop:
    beq  $t3, $zero, draw_blue_end  # 当计数器为0时结束循环

    lw   $a0, 0($t0)        # 取出当前的 x 坐标，传入 $a0
    lw   $a1, 0($t1)        # 取出当前的 y 坐标，传入 $a1
    lw   $a2, 0($t2)        # 取出当前的颜色，传入 $a2

    jal  paint_pixel        # 调用 paint_pixel（注意 paint_pixel 必须遵循 caller-saved 约定）

    # 更新指针，指向下一个数据
    addi $t0, $t0, 4        # 下一个 x 坐标（每个 .word 占4字节）
    addi $t1, $t1, 4        # 下一个 y 坐标
    addi $t2, $t2, 4        # 下一个颜色

    addi $t3, $t3, -1       # 循环计数器减1
    j    draw_blue_loop  # 跳回循环开始

draw_blue_end:
    lw $ra, 0($sp)            # recover $ra
    addi $sp, $sp, 4          # recover sp
    jr   $ra                # 返回调用者
##############################################################################
draw_game_over:
    jal reset_memory
    # 加载三个数组的起始地址到临时寄存器中
    la   $t0, x_coords_over      # $t0 指向 x 坐标数组
    la   $t1, y_coords_over     # $t1 指向 y 坐标数组
    la   $t2, colors_over        # $t2 指向颜色数组

    li   $t3, 507          # 循环计数器：数据总数

draw_over_loop:
    beq  $t3, $zero, draw_over_end  # 当计数器为0时结束循环

    lw   $a0, 0($t0)        # 取出当前的 x 坐标，传入 $a0
    lw   $a1, 0($t1)        # 取出当前的 y 坐标，传入 $a1
    lw   $a2, 0($t2)        # 取出当前的颜色，传入 $a2

    jal  paint_pixel        # 调用 paint_pixel（注意 paint_pixel 必须遵循 caller-saved 约定）

    # 更新指针，指向下一个数据
    addi $t0, $t0, 4        # 下一个 x 坐标（每个 .word 占4字节）
    addi $t1, $t1, 4        # 下一个 y 坐标
    addi $t2, $t2, 4        # 下一个颜色
    addi $t3, $t3, -1       # 循环计数器减1
    j    draw_over_loop  # 跳回循环开始

draw_over_end:
    lw      $t0, ADDR_KBRD        # $t0 = keyboard base address
    lw      $t8, 0($t0)           # 读取键盘状态
    bne     $t8, 1, draw_over_end

    j       keyboard_input_over   # 跳转到键盘输入处理函数

keyboard_input_over:
    lw      $t0, ADDR_KBRD         # $t0 = keyboard base address
    lw      $a0, 4($t0)            # Load second word (key code)
    beq     $a0, 0x71, respond_to_Q   # If 'q' pressed
    beq     $a0, 0x20, complete_reset
    j       draw_over_end 


####################################
## The rectangle drawing function ##
####################################
# Input parameters:
# - $a0: X coordinate of the top left corner of the rectangle
# - #a1: Y coordinate of the top left corner of the rectangle
# - $a2: Width of the rectangle
# - $a3: Height of the rectangle
draw_rect:
add $t5, $zero, $zero           # set my loop variable to zero
line_draw_start:

addi $sp, $sp, -4               # Move the stack pointer to an empty location
sw $t5, 0($sp)                  # Store $t5 onto the stack
addi $sp, $sp, -4               # Move the stack pointer to an empty location
sw $a1, 0($sp)                  # Store $a1 onto the stack
addi $sp, $sp, -4               # Move the stack pointer to an empty location
sw $ra, 0($sp)                  # Store $ra onto the stack
addi $sp, $sp, -4               # Move the stack pointer to an empty location
sw $a0, 0($sp)                  # Store $a0 onto the stack

jal draw_line                   # draw a line (using the X, Y and width parameters)

lw $a0, 0($sp)                  # Restore $ra from the stack.
addi $sp, $sp, 4                # Move the stack pointer to the top of the stack.
lw $ra, 0($sp)                  # Restore $ra from the stack.
addi $sp, $sp, 4                # Move the stack pointer to the top of the stack.
lw $a1, 0($sp)                  # Restore $a1 from the stack.
addi $sp, $sp, 4                # Move the stack pointer to the top of the stack.
lw $t5, 0($sp)                  # Restore $t5 from the stack.
addi $sp, $sp, 4                # Move the stack pointer to the top of the stack.

addi $t5, $t5, 1                # increment the loop variable
addi $a1, $a1, 1                # move the Y coordinate to the next row
beq $t5, $a3, line_draw_end     # break out of the loop if you hit the final row
j line_draw_start               # jump to the start of the row drawing loop
line_draw_end:  
jr $ra                          # return to the calling program


## The line drawing function ##
# Input parameters:
# - $a0: X coordinate of the start of the line
# - #a1: Y coordinate of the start of the line
# - $a2: Length of the line
draw_line:
# Main line drawing loop
add $t5, $zero, $zero       # initialize the loop variable $t5 to zero
sll $a1, $a1, 7             # calculate the vertical offset 
add $t7, $t0, $a1           # add the vertical offset to $t0
sll $a0, $a0, 2             # calculate the horizontal offset 
add $t7, $t7, $a0           # add the horizontal offset to $t7
pixel_draw_start:           # the starting label for the pixel drawing loop 
lw $t4, COLOR_BLACK    
sw $t4, 0( $t7 )            # paint the current bitmap location.
addi $t5, $t5, 1            # increment the loop variable
addi $t7, $t7, 4            # move to the next pixel in the row.
beq $t5, $a2, pixel_draw_end    # break out of the loop if you hit the final pixel in the row
j pixel_draw_start          # otherwise, jump to the top of the loop
pixel_draw_end:             # the label for the end of the pixel drawing loop
jr $ra                      # return to calling program