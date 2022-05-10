//***********************
//全局宏定义
//***********************
`define CPU_CLOCK_HZ 10000000//cpu时钟10MHz
`define CPU_RESET_ADDR 0x00000000//cpu复位地址
`define INST_MEM_START_ADDR  32'h0           // 指令存储器起始地址
`define INST_MEM_END_ADDR    32'h0fffffff    // 指令存储器结束地址
`define RST_ENABLE 1'b0 //复位有效
`define RST_DISABLE 1'b1 //复位无效
`define ZERO_WORD 32'h00000000 //32位的数值0
`define WRITE_ENABLE 1'b1 //写使能
`define WRITE_DISABLE 1'b0 //写禁止
`define READ_ENABLE 1'b1 //读使能
`define READ_DISABLE 1'b0 //读禁止



//***********************
//具体指令的宏定义
//***********************

//***********************
//指令存储器ROM宏定义
//***********************
`define INST_ADDR_BUS 31:0 //指令地址总线宽度
`define DATA_BUS 31:0 //数据总线宽度
`define ROM_DEPTH 8192 //指令存储器的深度，单位为word(4字节)
`define RAM_DEPTH 4096 //数据存储器的深度，单位为word(4字节)

//***********************
//通用寄存器宏定义
//***********************
`define REG_ADDR_BUS 4:0 //regfile地址总线宽度
`define REG_BUS 31:0 //regfile数据总线宽度
`define REG_WIDTH 32 //regfile数据宽度