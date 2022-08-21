    .org 0x0
    .global _start;


_start:
    li x1, 0x10000034
    csrrw x0, mtvec, x1
    csrrwi x0, mstatus, 0x00000008
    and x1, x2, x3
    mul x2, x2, x1
    add x5, x6, x7
    lb x4, 0(x0)
    ecall    
    bne x1, x2, bb
    ori x1, x2, 0x4
    and x1, x2, x3
    csrrw x1, mcause, x0
aa:
    andi x1, x2, 0x4
    addi x1, x2, 0x6
    mret
bb:
    div x1, x2, x3
    ori x1, x2, 0x4
