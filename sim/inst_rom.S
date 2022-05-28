    .org 0x0
    .global _start;

_start:
    lw x1, 0x1(x0)
    bne x1, x2, EXIT
    ori x1, x2, 0x4
    and x1, x2, x3
EXIT:
    addi x1, x2, 0x4




