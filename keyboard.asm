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
    beq $a0, 0x61, respond_to_A
    beq $a0, 0x64, respond_to_D
    beq $a0, 0x73, respond_to_S
    beq $a0, 0x77, respond_to_W
    li $v0, 1                       # ask system to print $a0
    syscall

    b testmain2

respond_to_A:
  jal move_left

respond_to_D:
  jal move_right

respond_to_S:
  j move_down

respond_to_W:
  jal rotate
  
respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall
