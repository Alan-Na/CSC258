

##############################################################################

    .data

ADDR_DSPL:      .word  0x10008000  # Bitmap address

ADDR_KBRD:      .word  0xffff0000  # Keyboard address

X_position:     .word  11          # capsule initial x position

Y_position:     .word  3           # capsule initial y position

X_position_side: .word 26          # side capsule initial x position

Y_position_side: .word 7           # side capsule initial y position

Horizontal:    .word   0           # orientation of the capsule

COLOR_GREY:     .word  0x808080    # Grey

COLOR_RED:      .word  0xFF0000    # Red

COLOR_GREEN:    .word  0x00FF00    # Green

COLOR_BLUE:     .word  0x0000FF    # Blue

COLOR_BLACK:    .word  0x000000    # Black

COLORS:         .word  0xFF0000, 0x00FF00, 0x0000FF  # Colours array

DRMARIO_GRID:   .space   16384     # space allocated for bitmap storing (64*64*4)

GRID_SIZE:      .word    1024      # size of grid (64*64/2*2)

X_prepare:      .word  26          # capsule in preparing area

Y_prepare:      .word  7           # capsule in preparing area