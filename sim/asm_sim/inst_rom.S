    .org 0x0
    .global _start;


_start:
    li x1, 0x00000058
    csrrw x0, mtvec, x1
    csrrwi x0, mstatus, 0x00000008
    li x8, 0x10000000
    addi x9, x0, 0x27
    addi x10, x0, 0x6B
    sw x9, 0(x8)
    sw x10, 0(x8)
    li x8, 0x20000000
    sw x9, 0(x8)
    sw x10, 0(x8)
    li x8, 0x30000000
    sw x9, 4(x8)
    sw x9, 0(x8)
    sw x10, 0(x8)
    and x1, x2, x3
    mul x2, x2, x1
    add x5, x6, x7
    li x8, 0x10000000
    lb x4, 0(x8)
    ecall    
    bne x1, x2, bb
aa:
    andi x1, x2, 0x4
    addi x1, x2, 0x6
    mret
bb:
    li x8, 0x10000000
    lb x4, 0(x8)
    lb x4, 0(x8)
    div x1, x2, x3
    ori x1, x2, 0x4
    and x1, x2, x3
    mulh x1, x3, x2
    rem x2, x4, x1
    li x8, 0x20000000
    lbu x4, 0(x8)
    lbu x4, 0(x8)
    li x8, 0x30000000
    lbu x4, 0(x8)
    lbu x4, 0(x8)
    csrrw x1, mcause, x0
    xor x1, x2, x3
    and x1, x2, x3
    or x1, x2, x3
    sub x1, x2, x3

    
   
