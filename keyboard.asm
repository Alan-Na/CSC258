##############################################################################
# Example: Keyboard Input
#
# This file demonstrates how to read the keyboard to check if a key was pressed.
##############################################################################
    .text
    .globl main2

poll_keyboard:
    addi    $sp, $sp, -4          # Allocate stack space for $t1
    sw      $ra, 0($sp)  
    li      $v0, 32
    li      $a0, 1
    syscall

    lw      $t0, ADDR_KBRD        # $t0 = keyboard base address
    lw      $t8, 0($t0)           # 读取键盘状态
    jal     save_grid        # 每次调用都先保存当前显示的bitmap
    bne     $t8, 1, poll_keyboard_return  # 如果键盘状态不为1，则没有按键，直接返回
    # 如果 $t8 == 1，说明有按键，继续处理：
    
    jal     check_if_yellow
    jal     wipe_capsule     # 擦除移动中的胶囊（根据需求操作）
    j       keyboard_input   # 跳转到键盘输入处理函数

poll_keyboard_return:
    lw      $ra, 0($sp)          # Restore $t1
    addi    $sp, $sp, 4  
    jr      $ra              # 返回调用者

keyboard_input:                   # A key is pressed
    lw      $t0, ADDR_KBRD         # $t0 = keyboard base address
    lw      $a0, 4($t0)            # Load second word (key code)
    beq     $a0, 0x71, respond_to_Q   # If 'q' pressed
    beq     $a0, 0x61, respond_to_A   # If 'a' pressed
    beq     $a0, 0x64, respond_to_D   # If 'd' pressed
    beq     $a0, 0x73, respond_to_S   # If 's' pressed
    beq     $a0, 0x77, respond_to_W   # If 'w' pressed
    li      $v0, 1
    syscall

    j       poll_keyboard              # Loop back
check_if_yellow:
    la $t1, DRMARIO_GRID
    lw $t5, COLOR_YELLOW
    move $a0, $s0
    sll $t2, $v1, 7
    add $t3, $t1, $t2
    sll $t4, $a0, 2
    add $t3, $t3, $t4

    lw  $t6, 0($t3)
    beq $t6, $t5, wipe_capsule_outline
    jr $ra
##############################################################################
respond_to_A:
    # Respond to key 'a': move capsule left
    # 根据 $s4 判断移动方向
    beq     $s4, $zero, vertical_A
    beq     $s4, 1, horizontal_A
    j       End_A                # 默认退出

horizontal_A:
    move $a0, $s0
    move $a1, $s1
    jal horizontal_collision_when_horizontal_left
    beq $v0, 1, End_A
    addi    $s0, $s0, -1          # move X position right by 1
    j       check_drawable_A

vertical_A:
    move $a0, $s0
    move $a1, $s1
    jal horizontal_collision_when_vertical_left
    beq $v0, 1, End_A
    addi    $s0, $s0, -1          # move X position right by 1 (logic per original)
    j       check_drawable_A

check_drawable_A:
    la $t1, DRMARIO_GRID
    lw $t5, COLOR_BLACK
    sll $t2, $s1, 7
    add $t3, $t1, $t2
    sll $t4, $s0, 2
    add $t3, $t3, $t4

    lw  $t6, 384($t3)
    beq $t6, $t5, check_drawable_horizontal_A
    j  End_A

check_drawable_horizontal_A:
    la $t1, DRMARIO_GRID
    lw $t5, COLOR_BLACK
    sll $t2, $s1, 7
    add $t3, $t1, $t2
    sll $t4, $s0, 2
    add $t3, $t3, $t4

    lw  $t6, 388($t3)
    beq $t6, $t5, draw_capsule_outline_A
    j  End_A

    
End_A:
    jal    save_capsule
    j      poll_keyboard_return

draw_capsule_outline_A:
  move $a0, $s0
  move $t1, $s1
  addi $a1, $t1, 2
  jal capsule_outline
  jal save_capsule_ouline
  j End_A

##############################################################################
respond_to_D:
    # Respond to key 'd': move capsule right
    # 根据 $s4 判断移动方向
    beq     $s4, $zero, vertical_D
    beq     $s4, 1, horizontal_D
    j       End_D                # 默认退出

horizontal_D:
    move $a0, $s0
    move $a1, $s1
    jal horizontal_collision_when_horizontal_right
    beq $v0, 1, End_D
    addi    $s0, $s0, 1          # move X position right by 1
    j       check_drawable_D

vertical_D:
    move $a0, $s0
    move $a1, $s1
    jal horizontal_collision_when_vertical_right
    beq $v0, 1, End_D
    addi    $s0, $s0, 1          # move X position right by 1 (logic per original)
    j       check_drawable_D

End_D:
  jal save_capsule
  j      poll_keyboard_return

check_drawable_D:
    la $t1, DRMARIO_GRID
    lw $t5, COLOR_BLACK
    sll $t2, $s1, 7
    add $t3, $t1, $t2
    sll $t4, $s0, 2
    add $t3, $t3, $t4

    lw  $t6, 384($t3)
    beq $t6, $t5, draw_capsule_outline_D
    j  End_D

draw_capsule_outline_D:
  move $a0, $s0
  move $t1, $s1
  addi $a1, $t1, 2
  jal capsule_outline
  jal save_capsule_ouline
  j End_D
##############################################################################
respond_to_S:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    move $a0, $s0
    move $a1, $s1
    jal Detect_vertical_collision
    beq $v0, $zero, increase_Y_coordinate
    j  End_S

increase_Y_coordinate:
    addi    $s1, $s1, 1          # move Y position down by 1
    j       End_S

End_S:
   jal save_capsule
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    j      poll_keyboard_return
  
##############################################################################
respond_to_W:
    # Respond to key 'w': rotate capsule
    move    $a0, $s0
    move    $a1, $s1
    jal     Detect_rotation_collision
    li      $t1, 1
    beq     $v0, $t1, End_W
    beq     $s4, $zero, vertical_capsule   # if capsule is vertical
    beq     $s4, 1, horizontal_capsule     # if capsule is horizontal

vertical_capsule:
    addi    $s1, $s1, 1          # move Y position down by 1
    move    $t8, $s2             # temporarily save s2
    move    $t9, $s3             # temporarily save s3
    move    $s2, $t9             # swap s2 and s3
    move    $s3, $t8
    li      $s4, 1              # set capsule orientation to horizontal (1)
    j       check_drawable_W

horizontal_capsule:
    addi    $s1, $s1, -1         # move Y position up by 1
    li      $s4, 0              # set capsule orientation to vertical (0)
    j       check_drawable_W

check_drawable_W:
    la $t1, DRMARIO_GRID
    lw $t5, COLOR_BLACK
    sll $t2, $s1, 7
    add $t3, $t1, $t2
    sll $t4, $s0, 2
    add $t3, $t3, $t4

    lw  $t6, 256($t3)
    beq $t6, $t5, draw_capsule_outline_W
    j  End_W

draw_capsule_outline_W:
  move $a0, $s0
  move $t1, $s1
  addi $a1, $t1, 2
  jal capsule_outline
  jal save_capsule_ouline
  j End_W

End_W:
    jal save_capsule
    j      poll_keyboard_return

##############################################################################
respond_to_Q:
    # Respond to key 'q': quit gracefully
    li      $v0, 10
    syscall

##############################################################################
# Function: save bitmap to DRMARIO_GRID
save_grid:

    lw      $t0, ADDR_DSPL        # $t0 = source (display) base address
    la      $t1, DRMARIO_GRID     # $t1 = storage area base address
    lw      $t2, GRID_SIZE      # bits to be copied
save_loop:
    beq     $t2, $zero, save_end  # Loop exit condition
    lw      $t3, 0($t0)           # Read one word from display
    sw      $t3, 0($t1)           # Store it in DRMARIO_GRID
    addi    $t0, $t0, 4           # Next word in display
    addi    $t1, $t1, 4           # Next word in storage
    addi    $t2, $t2, -1          # Decrement counter
    j       save_loop
save_end:
    jr      $ra

##############################################################################
# Function: wipe the capsule in last second
wipe_capsule:
    la      $t1, DRMARIO_GRID     # $t1 = storage base address
    lw      $t5, COLOR_BLACK      # $t5 = black color

    beq     $s4, $zero, do_wipe_vertical   # if $s4 == 0, vertical wipe
    beq     $s4, 1, do_wipe_horizontal      # if $s4 == 1, horizontal wipe
    j       wipe_capsule_exit     # Otherwise, exit

do_wipe_vertical:
    sll     $t2, $s1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $s0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer
    sw      $t5, 0($t3)          # Write black color at current pixel
    sw      $t5, 128($t3)          # Write black to next pixel
    j       wipe_capsule_exit

do_wipe_horizontal:
    sll     $t2, $s1, 7          # Compute Y offset
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $s0, 2          # Compute X offset
    add     $t3, $t3, $t4        # Final address
    sw      $t5, 0($t3)          # Write black color
    sw      $t5, 4($t3)        # Write black color at horizontal offset (256 bytes)
    j       wipe_capsule_exit

wipe_capsule_exit:
    jr      $ra
##############################################################################
wipe_capsule_outline:
    la      $t1, DRMARIO_GRID     # $t1 = storage base address
    lw      $t5, COLOR_BLACK      # $t5 = black color

    beq     $s4, $zero, do_wipe_outline_vertical   # if $s4 == 0, vertical wipe
    beq     $s4, 1, do_wipe_outline_horizontal      # if $s4 == 1, horizontal wipe
    j       wipe_capsule_outline_exit     # Otherwise, exit

do_wipe_outline_vertical:
    sll     $t2, $v1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $s0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer
    sw      $t5, 0($t3)          # Write black color at current pixel
    sw      $t5, 128($t3)          # Write black to next pixel
    j       wipe_capsule_outline_exit

do_wipe_outline_horizontal:
    sll     $t2, $v1, 7          # Compute Y offset
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $s0, 2          # Compute X offset
    add     $t3, $t3, $t4        # Final address
    sw      $t5, 0($t3)          # Write black color
    sw      $t5, 4($t3)        # Write black color at horizontal offset (256 bytes)
    j       wipe_capsule_outline_exit

wipe_capsule_outline_exit:
    jr      $ra

##############################################################################
## save current capsule into buffer
save_capsule:
    la      $t1, DRMARIO_GRID     # $t1 = storage base address
    
  # 根据 $s4 判断移动方向
    beq     $s4, $zero, vertical_save
    beq     $s4, 1, horizontal_save
    j       End_Save                # 默认退出

horizontal_save:
    sll     $t2, $s1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $s0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer
    move    $t5, $s2             # load color of capsule
    sw      $t5, 0($t3)          # Write black color at current pixel
    move    $t5, $s3             # load next color of capsule
    sw      $t5, 4($t3)          # Write black to next pixel
    j       End_Save

vertical_save:
    sll     $t2, $s1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $s0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer
    move    $t5, $s2             # load color of capsule
    sw      $t5, 0($t3)          # Write black color at current pixel
    move    $t5, $s3             # load next color of capsule
    sw      $t5, 128($t3)          # Write black to next pixel
    j       End_Save

End_Save:
    jr      $ra
##############################################################################
save_capsule_ouline:
    la      $t1, DRMARIO_GRID     # $t1 = storage base address
    
  # 根据 $s4 判断移动方向
    beq     $s4, $zero, vertical_save_outline
    beq     $s4, 1, horizontal_save_outline
    j       End_Save_outline                # 默认退出

horizontal_save_outline:
    sll     $t2, $v1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $s0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer
    lw    $t5, COLOR_YELLOW            # load color of capsule
    sw      $t5, 0($t3)          # Write black color at current pixel
    lw    $t5, COLOR_YELLOW          # load next color of capsule
    sw      $t5, 4($t3)          # Write black to next pixel
    j       End_Save_outline

vertical_save_outline:
    sll     $t2, $v1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $s0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer
    lw    $t5, COLOR_YELLOW           # load color of capsule
    sw      $t5, 0($t3)          # Write black color at current pixel
    lw    $t5, COLOR_YELLOW       # load next color of capsule
    sw      $t5, 128($t3)          # Write black to next pixel
    j       End_Save_outline

End_Save_outline:
    jr      $ra

#############################################################################
check_for_deletion:
##############################################################################
## The vertical collision detect function
## $a0: the x coordinate of the capsule
## $a1: the y coordinate of the capsule
## $v0: return value--0 means no collision, 1 means collision happens
## 把探测碰撞分为三部分，这部分是垂直方向的碰撞检测，分为$s4为0或1两种情况
## 玩家使用S键时程序调用这个函数检测
Detect_vertical_collision:
  la $t1, DRMARIO_GRID           # $t1 = storage base address
  lw $t5, COLOR_BLACK

  # 根据 $s4 判断移动方向
  beq  $s4, $zero, vertical_collision_when_vertical
  beq  $s4, 1, vertical_collision_when_horizontal
  j    End_Vertical_Detect_1              # 默认退出

vertical_collision_when_vertical:
    sll     $t2, $a1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $a0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer
    
    lw      $t6, 256($t3)
    bne     $t6, $t5, not_black_1

    j all_black_1

not_black_1:
  li $v0, 2
  j End_Vertical_Detect_1
all_black_1:
  li $v0, 0
  j End_Vertical_Detect_1
  
End_Vertical_Detect_1:
  jr $ra

vertical_collision_when_horizontal:
    sll     $t2, $a1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $a0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer

    lw      $t6, 128($t3)
    bne     $t6, $t5, not_black_2

    lw      $t6, 132($t3)
    bne     $t6, $t5, not_black_2

    j all_black_2

not_black_2:
  li $v0, 2
  j End_Horizontal_Detect_1
all_black_2:
  li $v0, 0
  j End_Horizontal_Detect_1
  
End_Horizontal_Detect_1:
  jr $ra
#############################################
## The horizontal collision detect function
## $a0: the x coordinate of the capsule
## $a1: the y coordinate of the capsule
## $v0: return value--0 means no collision, 1 means collision happens
## 这部分是水平方向的碰撞检测，也分为$s4为0或1两种情况
## 玩家使用A/D键时程序调用这个函数检测
horizontal_collision_when_vertical_left:
    la $t1, DRMARIO_GRID           # $t1 = storage base address
    lw $t5, COLOR_BLACK
    
    sll     $t2, $a1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $a0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer
    
    lw      $t6, -4($t3)
    bne     $t6, $t5, not_black_3

    lw      $t6, 124($t3)
    bne     $t6, $t5, not_black_3

    j all_black_3

horizontal_collision_when_vertical_right:
    la $t1, DRMARIO_GRID           # $t1 = storage base address
    lw $t5, COLOR_BLACK
  
    sll     $t2, $a1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $a0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer  

    lw      $t6, 4($t3)
    bne     $t6, $t5, not_black_3

    lw      $t6, 132($t3)
    bne     $t6, $t5, not_black_3

    j all_black_3
    
not_black_3:
  li $v0, 1
  j End_Vertical_Detect_2
all_black_3:
  li $v0, 0
  j End_Vertical_Detect_2
  
End_Vertical_Detect_2:
  jr $ra
  
horizontal_collision_when_horizontal_left:
    la $t1, DRMARIO_GRID           # $t1 = storage base address
    lw $t5, COLOR_BLACK
    
    sll     $t2, $a1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $a0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer
    
    lw      $t6, -4($t3)
    bne     $t6, $t5, not_black_4

    j all_black_4
horizontal_collision_when_horizontal_right:
    la $t1, DRMARIO_GRID           # $t1 = storage base address
    lw $t5, COLOR_BLACK
    
    sll     $t2, $a1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $a0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer  
    
    lw      $t6, 8($t3)
    bne     $t6, $t5, not_black_4

    j all_black_4
    
not_black_4:
  li $v0, 1
  j End_Horizontal_Detect_2
all_black_4:
  li $v0, 0
  j End_Horizontal_Detect_2
  
End_Horizontal_Detect_2:
  jr $ra
#############################################
## The rotation collision detect function
## $a0: the x coordinate of the capsule
## $a1: the y coordinate of the capsule
## $v0: return value--0 means no collision, 1 means collision happens
## 这部分是旋转的碰撞检测，也分为$s4为0或1两种情况
## 玩家使用W键时程序调用这个函数检测
Detect_rotation_collision:
  la $t1, DRMARIO_GRID           # $t1 = storage base address
  lw $t5, COLOR_BLACK
  
  # 根据 $s4 判断移动方向
  beq  $s4, $zero, vertical_rotate
  beq  $s4, 1, horizontal_rotate
  j    End_Rotate_Detect                # 默认退出

vertical_rotate:
    sll     $t2, $a1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $a0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer
    
    lw      $t6, 4($t3)
    bne     $t6, $t5, not_black_5

    lw      $t6, 132($t3)
    bne     $t6, $t5, not_black_5

    j all_black_5
    
not_black_5:
    li $v0, 1
    j End_Rotate_Detect
all_black_5:
    li $v0, 0
  j End_Rotate_Detect
horizontal_rotate:
    sll     $t2, $a1, 7          # Compute Y offset: t2 = a1 * 128
    add     $t3, $t1, $t2        # t3 = DRMARIO_GRID + Y offset
    sll     $t4, $a0, 2          # Compute X offset: t4 = a0 * 4
    add     $t3, $t3, $t4        # Final address in display buffer
    
    lw      $t6, -128($t3)
    bne     $t6, $t5, not_black_6

    j all_black_6

not_black_6:
    li $v0, 1
    j End_Rotate_Detect
all_black_6:
    li $v0, 0
    j End_Rotate_Detect
End_Rotate_Detect:
    jr $ra
##############################################################################
##############################################################################
# check_horizontal_4_region:
# 扫描区域：Y:6~29，X:3~16（检测连续4个像素：覆盖 X: col, col+1, col+2, col+3）
# 如果找到匹配，则将这4个像素涂为黑色
# 并返回：$v0 = 当前检测到的X坐标, $v1 = 当前检测到的Y坐标。
# 如果未找到，则返回 $v0=0, $v1=0

check_horizontal_4_region:
    li    $t0, 6             # $t0 = 当前 Y 坐标，从6开始
    lw    $t9, ADDR_DSPL     # $t9 = 位图基地址

row_loop_h:
    bgt   $t0, 29, no_match_horizontal  # 如果当前 Y > 29，区域扫描完毕

    li    $t1, 3             # $t1 = 当前 X 坐标，从3开始

col_loop_h:
    bgt   $t1, 16, next_row_horizontal  # 如果当前 X > 16，跳到下一行

    # 计算像素地址
    li    $t2, 32          
    mul   $t3, $t0, $t2      # t3 = Y * 32
    add   $t3, $t3, $t1      # t3 = Y*32 + X
    sll   $t3, $t3, 2        # 字节偏移 = t3 * 4
    add   $t4, $t9, $t3      # t4 = 当前像素地址 (X,Y)

    # 加载连续4个像素的颜色
    lw    $t5, 0($t4)        # pixel (X,Y)
    # 如果当前像素颜色为黑色，则不计入匹配，跳转
    lw    $t6, COLOR_BLACK        # t6 = 黑色数值
    beq   $t5, $t6, not_match_horizontal

    lw    $t7, 4($t4)        # pixel (X+1,Y)
    lw    $t8, 8($t4)        # pixel (X+2,Y)
    lw    $t9, 12($t4)       # pixel (X+3,Y)
    bne   $t5, $t7, not_match_horizontal
    bne   $t5, $t8, not_match_horizontal
    bne   $t5, $t9, not_match_horizontal

    # 匹配成功：将这4个像素涂成黑色
    lw    $t2, COLOR_BLACK   # 重新加载黑色数值到 $t2
    sw    $t2, 0($t4)        # (X,Y)
    sw    $t2, 4($t4)        # (X+1,Y)
    sw    $t2, 8($t4)        # (X+2,Y)
    sw    $t2, 12($t4)       # (X+3,Y)

    # 返回检测到的坐标：将 X 存入 $v0, Y 存入 $v1
    move  $v0, $t1
    move  $v1, $t0
    jr    $ra

not_match_horizontal:
    addi  $t1, $t1, 1        # X++
    j     col_loop_h

next_row_horizontal:
    addi  $t0, $t0, 1        # Y++
    j     row_loop_h

no_match_horizontal:
    li    $v0, 0
    li    $v1, 0
    jr    $ra
##############################################################################
# check_vertical_4_region:
# 扫描区域：Y 从 6 到 26，X 从 3 到 19
# 对于每个像素 (X, Y)，检测 (X, Y), (X, Y+1), (X, Y+2), (X, Y+3) 是否颜色相同
# 如果相同，则将它们全部涂为 COLOR_BLACK，并返回:
#    $v0 = X 坐标, $v1 = Y 坐标（这一组最上面的像素坐标）
# 如果未找到，则返回 $v0 = 0, $v1 = 0
check_vertical_4_region:
    li    $t0, 6             # $t0 = 当前 Y 坐标，从6开始（保证 Y+3 ≤29，所以最大 Y 为26）
    lw    $t9, ADDR_DSPL     # $t9 = 位图基地址

row_loop_v:
    bgt   $t0, 26, no_match_vertical   # 如果 Y > 26，则区域扫描完毕

    li    $t1, 3             # $t1 = 当前 X 坐标，从3开始

col_loop_v:
    bgt   $t1, 19, next_row_vertical   # 如果 X > 19，则本行扫描完毕

    # 计算当前像素地址
    li    $t2, 32
    mul   $t3, $t0, $t2      # t3 = Y * 32
    add   $t3, $t3, $t1      # t3 = Y*32 + X
    sll   $t3, $t3, 2        # 字节偏移
    add   $t4, $t9, $t3      # t4 = 当前像素 (X,Y) 地址

    lw    $t5, 0($t4)        # pixel (X,Y)
    # 如果当前像素为黑色，则跳过检测
    lw    $t6, COLOR_BLACK
    beq   $t5, $t6, not_match_vertical

    # 对同一列下连续3个像素：由于每行32个像素，每行占 32*4 = 128 字节
    addi  $t7, $t4, 128      # pixel (X, Y+1)
    lw    $t7, 0($t7)
    addi  $t8, $t4, 256      # pixel (X, Y+2)
    lw    $t8, 0($t8)
    addi  $t9, $t4, 384      # pixel (X, Y+3)
    lw    $t9, 0($t9)
    bne   $t5, $t7, not_match_vertical
    bne   $t5, $t8, not_match_vertical
    bne   $t5, $t9, not_match_vertical

    # 匹配成功：将这4个像素涂为黑色
    lw    $t2, COLOR_BLACK   # 重新加载黑色数值
    sw    $t2, 0($t4)        # (X,Y)
    addi  $t3, $t4, 128      # (X, Y+1)
    sw    $t2, 0($t3)
    addi  $t3, $t4, 256      # (X, Y+2)
    sw    $t2, 0($t3)
    addi  $t3, $t4, 384      # (X, Y+3)
    sw    $t2, 0($t3)

    # 返回检测到的坐标：返回最上面方块的坐标（X存入$v0, Y存入$v1）
    move  $v0, $t1
    move  $v1, $t0
    jr    $ra

not_match_vertical:
    addi  $t1, $t1, 1        # X++
    j     col_loop_v

next_row_vertical:
    addi  $t0, $t0, 1        # Y++
    j     row_loop_v

no_match_vertical:
    li    $v0, 0
    li    $v1, 0
    jr    $ra
##############################################################################
# check_2x2_region:
# 在区域内（X: 3～18, Y: 6～28）检测2×2的方块是否颜色相同，
# 并忽略如果左上角像素已经为黑色的情况。
# 如果找到，将该2×2块全部涂成黑色（COLOR_BLACK），
# 返回检测到的左上角坐标：X 存入 $v0, Y 存入 $v1；
# 如果没有找到，则返回 $v0=0, $v1=0。
check_2x2_region:
    li    $t0, 6           # $t0 = 当前 Y 坐标（从6开始）
    lw    $t9, ADDR_DSPL   # $t9 = 位图基地址

    # 预先加载黑色值到 $a3（此后在每次检测中用于比较与填色）
    la    $a3, COLOR_BLACK
    lw    $a3, 0($a3)      # $a3 = 黑色

row_loop_2x2:
    bgt   $t0, 28, no_match_2x2   # 如果当前 Y > 28，则区域扫描完毕

    li    $t1, 3           # $t1 = 当前 X 坐标（从3开始）

col_loop_2x2:
    bgt   $t1, 18, next_row_2x2   # 如果当前 X > 18，则该行扫描完毕

    # 计算像素 (X, Y) 的地址
    li    $t2, 32          # 每行 32 个像素
    mul   $t3, $t0, $t2    # $t3 = Y * 32
    add   $t3, $t3, $t1    # $t3 = Y*32 + X
    sll   $t3, $t3, 2      # $t3 = (Y*32 + X)*4
    add   $t4, $t9, $t3    # $t4 = 当前像素 (X,Y) 的地址

    # 加载2×2方块的4个像素：
    lw    $t5, 0($t4)      # top-left pixel (X, Y) → $t5
    lw    $t6, 4($t4)      # top-right pixel (X+1, Y) → $t6

    addi  $t7, $t4, 128    # 每行32×4=128字节后
    lw    $t7, 0($t7)

    addi  $t8, $t4, 132    # bottom-right pixel (X+1, Y+1)
    lw    $t8, 0($t8)

    # 如果左上角像素为黑色，则不认为是有效匹配，跳转
    beq   $t5, $a3, not_match_2x2

    # 检测4个像素颜色是否一致
    bne   $t5, $t6, not_match_2x2
    bne   $t5, $t7, not_match_2x2
    bne   $t5, $t8, not_match_2x2

    # 匹配成功：将这2×2区域涂为黑色
    sw    $a3, 0($t4)      # top-left (X,Y) 设为黑色
    sw    $a3, 4($t4)      # top-right (X+1,Y)
    addi  $t3, $t4, 128    # bottom-left地址 = (X,Y)地址 + 128
    sw    $a3, 0($t3)
    addi  $t3, $t4, 132    # bottom-right地址 = (X,Y)地址 + 132
    sw    $a3, 0($t3)

    # 返回检测到的坐标：X 存入 $v0, Y 存入 $v1
    move  $v0, $t1
    move  $v1, $t0
    jr    $ra

not_match_2x2:
    addi  $t1, $t1, 1      # X++
    j     col_loop_2x2

next_row_2x2:
    addi  $t0, $t0, 1      # Y++
    j     row_loop_2x2

no_match_2x2:
    li    $v0, 0
    li    $v1, 0
    jr    $ra






