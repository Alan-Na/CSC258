 ##############################################################################
# Example: Keyboard Input
#
# This file demonstrates how to read the keyboard to check if the keyboard
# key q was pressed.
##############################################################################
    .text
	.globl main2

testmain2:
	li 		$v0, 32
	li 		$a0, 1
	syscall

    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input      # If first word 1, key is pressed
    b testmain2

keyboard_input:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
    beq $a0, 0x61, respond_to_A     # Check if the key a was pressed
    beq $a0, 0x64, respond_to_D     # Check if the key d was pressed
    beq $a0, 0x73, respond_to_S     # Check if the key s was pressed
    beq $a0, 0x77, respond_to_W     # Check if the key w was pressed
    li $v0, 1                       # ask system to print $a0
    syscall

    b testmain2

respond_to_A:
  addi $t1, $s0, -1
  beq $t1, 2, End_A
  addi $s0, $s0, -1      # Move the X_position 1 left
  jr $ra

End_A:
  jr $ra
  
respond_to_D:
  addi $t1, $s0, 1
  beq $s4, 0, vertical_D
  beq $s4, 1, horizontal_D
  addi $s0, $s0, 1       # Move the X_position 1 right
  jr $ra

horizontal_D:
  beq $t1, 19, End_D
  addi $s0, $s0, 1       # Move the X_position 1 right
  jr $ra

vertical_D:
  beq $t1, 20, End_D
  addi $s0, $s0, 1       # Move the X_position 1 right
  jr $ra  
  
End_D:
  jr $ra
  
respond_to_S:
  addi $s1, $s1, 1       # Move the Y_position 1 down
  jr $ra
  
respond_to_W:
  beq $s4, 0, vertical_capsule     # Check if the capsule is vertical
  beq $s4, 1, horizontal_capsule   # Check if the capsule is horizontal

vertical_capsule:
  addi $s1, $s1, 1         # Move y position down by 1
  add $t8, $s2, $zero      # Switch both colors
  add $t9, $s3, $zero
  add $s2, $t9, $zero
  add $s3, $t8, $zero
  li $s4, 1                # Change the horizontal status to 1
  jr $ra

horizontal_capsule:
  addi $s1, $s1, -1        # Move y position up by 1
  li $s4, 0                # Change the horizontal status to 0
  jr $ra

  
respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall
