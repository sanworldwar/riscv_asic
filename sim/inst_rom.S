    .org 0x0
    .global _start;

_start:
    csrrwi x0, mtvec, 0x00000014
    csrrwi x0, mstatus, 0x00000008
    lw x1, 0x1(x0)
    ecall    
    bne x1, x2, aa
    ori x1, x2, 0x4
    and x1, x2, x3
    csrrw x1, mcause, x0
aa:
    addi x1, x2, 0x4
    ori x1, x2, 0x4


