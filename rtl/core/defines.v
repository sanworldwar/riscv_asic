//***********************
//全局宏定义
//***********************
`define CPU_CLOCK_HZ        50000000        //cpu时钟10MHz
`define CPU_RESET_ADDR      32'h00000000    //cpu复位地址
`define RST_ENABLE          1'b0            //复位有效
`define RST_DISABLE         1'b1            //复位无效
`define ZERO_WORD           32'h00000000    //32位的数值0
`define WRITE_ENABLE        1'b1            //写使能
`define WRITE_DISABLE       1'b0            //写禁止
`define READ_ENABLE         1'b1            //读使能
`define READ_DISABLE        1'b0            //读禁止
`define EXCP_SYNC_ASSERT    2'b01           //同步异常
`define EXCP_ASYNC_ASSERT   2'b10           //异步异常1

//***********************
//IDU信息总线宏定义
//***********************

`define DEC_INST_OP_WIDTH       4                           //DEC指令类型信息宽度
`define DEC_INST_OP             `DEC_INST_OP_WIDTH-1:0      //DEC指令类型信息

//R instruction decode bus
`define DEC_INST_R              `DEC_INST_OP_WIDTH'd1      //R型指令
`define DEC_INST_R_ADD          `DEC_INST_OP_WIDTH         //ADD指令
`define DEC_INST_R_SUB          `DEC_INST_R_ADD+1          
`define DEC_INST_R_SLL          `DEC_INST_R_SUB+1 
`define DEC_INST_R_SLT          `DEC_INST_R_SLL+1 
`define DEC_INST_R_SLTU         `DEC_INST_R_SLT+1 
`define DEC_INST_R_XOR          `DEC_INST_R_SLTU+1
`define DEC_INST_R_SRL          `DEC_INST_R_XOR+1
`define DEC_INST_R_SRA          `DEC_INST_R_SRL+1
`define DEC_INST_R_OR           `DEC_INST_R_SRA+1
`define DEC_INST_R_AND          `DEC_INST_R_OR+1     

`define DEC_R_INFO_BUS_WIDTH    `DEC_INST_R_AND+1           //R型指令译码信息宽度
`define DEC_R_INFO_BUS          `DEC_R_INFO_BUS_WIDTH-1:0   //R型指令译码信息

//I instruction decode bus
`define DEC_INST_I              `DEC_INST_OP_WIDTH'd2      //I型指令
`define DEC_INST_I_ADDI         `DEC_INST_OP_WIDTH         //ADDI指令
`define DEC_INST_I_SLTI         `DEC_INST_I_ADDI+1 
`define DEC_INST_I_SLTIU        `DEC_INST_I_SLTI+1 
`define DEC_INST_I_XORI         `DEC_INST_I_SLTIU+1
`define DEC_INST_I_ORI          `DEC_INST_I_XORI+1
`define DEC_INST_I_ANDI         `DEC_INST_I_ORI+1 
`define DEC_INST_I_SLLI         `DEC_INST_I_ANDI+1  
`define DEC_INST_I_SRLI         `DEC_INST_I_SLLI+1
`define DEC_INST_I_SRAI         `DEC_INST_I_SRLI+1

`define DEC_I_INFO_BUS_WIDTH    `DEC_INST_I_SRAI+1          //I型指令译码信息宽度
`define DEC_I_INFO_BUS          `DEC_I_INFO_BUS_WIDTH-1:0   //I型指令译码信息

//U instruction decode bus
`define DEC_INST_U              `DEC_INST_OP_WIDTH'd3      //U型指令
`define DEC_INST_U_LUI          `DEC_INST_OP_WIDTH         //LUI指令
`define DEC_INST_U_AUIPC        `DEC_INST_U_LUI+1 

`define DEC_U_INFO_BUS_WIDTH    `DEC_INST_U_AUIPC+1         //U型指令译码信息宽度
`define DEC_U_INFO_BUS          `DEC_U_INFO_BUS_WIDTH-1:0   //U型指令译码信息

//L(OAD) instruction decode bus
`define DEC_INST_L              `DEC_INST_OP_WIDTH'd4      //L型指令
`define DEC_INST_L_LB           `DEC_INST_OP_WIDTH         //LB指令
`define DEC_INST_L_LH           `DEC_INST_L_LB+1 
`define DEC_INST_L_LW           `DEC_INST_L_LH+1
`define DEC_INST_L_LBU          `DEC_INST_L_LW+1 
`define DEC_INST_L_LHU          `DEC_INST_L_LBU+1 

`define DEC_L_INFO_BUS_WIDTH    `DEC_INST_L_LHU+1           //L型指令译码信息宽度
`define DEC_L_INFO_BUS          `DEC_L_INFO_BUS_WIDTH-1:0   //L型指令译码信息

//S(TORE) instruction decode bus
`define DEC_INST_S              `DEC_INST_OP_WIDTH'd5      //S型指令
`define DEC_INST_S_SB           `DEC_INST_OP_WIDTH         //SB指令
`define DEC_INST_S_SH           `DEC_INST_S_SB+1 
`define DEC_INST_S_SW           `DEC_INST_S_SH+1

`define DEC_S_INFO_BUS_WIDTH    `DEC_INST_S_SW+1           //S型指令译码信息宽度
`define DEC_S_INFO_BUS          `DEC_S_INFO_BUS_WIDTH-1:0  //S型指令译码信息

//J(UMP) instruction decode bus
`define DEC_INST_J              `DEC_INST_OP_WIDTH'd6      //J型指令
`define DEC_INST_J_JAL          `DEC_INST_OP_WIDTH         //JAL指令
`define DEC_INST_J_JALR         `DEC_INST_J_JAL+1 

`define DEC_J_INFO_BUS_WIDTH    `DEC_INST_J_JALR+1         //J型指令译码信息宽度
`define DEC_J_INFO_BUS          `DEC_J_INFO_BUS_WIDTH-1:0  //J型指令译码信息

//CONTROL STATE REGISTER instruction decode bus
`define DEC_INST_CSR            `DEC_INST_OP_WIDTH'd7       //CSR型指令
`define DEC_INST_CSR_CSRRW      `DEC_INST_OP_WIDTH
`define DEC_INST_CSR_CSRRS      `DEC_INST_CSR_CSRRW+1    
`define DEC_INST_CSR_CSRRC      `DEC_INST_CSR_CSRRS+1
`define DEC_INST_CSR_CSRRWI     `DEC_INST_CSR_CSRRC+1
`define DEC_INST_CSR_CSRRSI     `DEC_INST_CSR_CSRRWI+1
`define DEC_INST_CSR_CSRRCI     `DEC_INST_CSR_CSRRSI+1

`define DEC_CSR_INFO_BUS_WIDTH  `DEC_INST_CSR_CSRRCI+1      //CSR型指令译码信息宽度
`define DEC_CSR_INFO_BUS        `DEC_CSR_INFO_BUS_WIDTH-1:0 //CSR型指令译码信息

//MUL and DIV instruction
`define DEC_INST_MD             `DEC_INST_OP_WIDTH'd8       //MD型指令
`define DEC_INST_MD_MUL         `DEC_INST_OP_WIDTH
`define DEC_INST_MD_MULH        `DEC_INST_MD_MUL+1
`define DEC_INST_MD_MULHSU      `DEC_INST_MD_MULH+1
`define DEC_INST_MD_MULHU       `DEC_INST_MD_MULHSU+1
`define DEC_INST_MD_DIV         `DEC_INST_MD_MULHU+1
`define DEC_INST_MD_DIVU        `DEC_INST_MD_DIV+1
`define DEC_INST_MD_REM         `DEC_INST_MD_DIVU+1
`define DEC_INST_MD_REMU        `DEC_INST_MD_REM+1

`define DEC_MD_INFO_BUS_WIDTH   `DEC_INST_MD_REMU+1        //MD型指令译码信息宽度
`define DEC_MD_INFO_BUS         `DEC_MD_INFO_BUS_WIDTH-1:0 //MD型指令译码信息

//dec info bus
`define DEC_INFO_BUS_WIDTH      `DEC_R_INFO_BUS_WIDTH       //选取最长宽度为DEC信息总线宽度
`define DEC_INFO_BUS            `DEC_INFO_BUS_WIDTH-1:0     //DEC信息总线

//SYSTEM instruction info bus
`define DEC_SYS_BUS_WIDTH       3                           //特权(系统)指令信息总线宽度
`define DEC_SYS_BUS             `DEC_SYS_BUS_WIDTH-1:0      //特权(系统)指令信息总线

`define DEC_SYS_INST_ECALL      0                           //ecall指令
`define DEC_SYS_INST_EBREAK     `DEC_SYS_INST_ECALL+1
`define DEC_SYS_INST_MRET       `DEC_SYS_INST_EBREAK+1

//***********************
//EXE信息总线宏定义
//***********************
`define EXE_INST_OP_WIDTH       2                           //EXE指令类型信息宽度
`define EXE_INST_OP             `EXE_INST_OP_WIDTH-1:0      //EXE指令类型信息

`define EXE_INST_L              `EXE_INST_OP_WIDTH'd1       //L型指令
`define EXE_INST_L_LB           `EXE_INST_OP_WIDTH          //LB指令
`define EXE_INST_L_LH           `EXE_INST_L_LB+1 
`define EXE_INST_L_LW           `EXE_INST_L_LH+1
`define EXE_INST_L_LBU          `EXE_INST_L_LW+1 
`define EXE_INST_L_LHU          `EXE_INST_L_LBU+1 

`define EXE_L_INFO_BUS_WIDTH    `EXE_INST_L_LHU+1           //S型指令信息宽度
`define EXE_L_INFO_BUS          `EXE_L_INFO_BUS_WIDTH-1:0   //S型指令信息

`define EXE_INST_S              `EXE_INST_OP_WIDTH'd2       //S型指令
`define EXE_INST_S_SB           `EXE_INST_OP_WIDTH          //SB指令
`define EXE_INST_S_SH           `EXE_INST_S_SB+1 
`define EXE_INST_S_SW           `EXE_INST_S_SH+1

`define EXE_S_INFO_BUS_WIDTH    `EXE_INST_S_SW+1           //S型指令信息宽度
`define EXE_S_INFO_BUS          `EXE_S_INFO_BUS_WIDTH-1:0   //S型指令信息

`define EXE_INFO_BUS_WIDTH      `EXE_L_INFO_BUS_WIDTH       //选取最长宽度为EXE信息总线宽度
`define EXE_INFO_BUS            `EXE_INFO_BUS_WIDTH-1:0     //EXE信息总线
//***********************
//具体指令的宏定义
//***********************

//***********************
//指令存储器ROM宏定义
//***********************
`define ROM_DEPTH           8192            //指令存储器的深度，单位为word(4字节)
//***********************
//数据存储器ROM宏定义
//***********************
`define MEM_DATA_BUS_WIDTH  `REG_BUS_WIDTH          //数据存储器数据总线宽度
`define MEM_DATA_BUS        `REG_BUS                //数据存储器数据总线
`define MEM_ADDR_BUS_WIDTH  `REG_BUS_WIDTH          //数据存储器地址总线宽度
`define MEM_ADDR_BUS        `MEM_ADDR_BUS_WIDTH-1:0 //数据存储器地址总线
`define RAM_DEPTH           4096                    //数据存储器的深度，单位为word(4字节)

//***********************
//通用寄存器宏定义
//***********************
`define REG_BUS_WIDTH        32                      //regfile数据总线宽度
`define REG_BUS              `REG_BUS_WIDTH-1:0      //regfile数据总线
`define REG_ADDR_BUS_WIDTH   5                       //regfile地址总线宽度
`define REG_ADDR_BUS         `REG_ADDR_BUS_WIDTH-1:0 //regfile地址总线
`define REG_NUM              32                      //regfile数目
`define DOUBLE_REG_BUS_WIDTH 2*`REG_BUS_WIDTH
`define DOUBLE_REG_BUS       `DOUBLE_REG_BUS_WIDTH-1:0   
//***********************
//控制状态寄存器宏定义
//***********************
`define CSR_ADDR_BUS_WIDTH  12                      //csr地址总线宽度
`define CSR_ADDR_BUS        `CSR_ADDR_BUS_WIDTH-1:0 //csr地址总线
// CSR 地址
`define CSR_CYCLE   12'hc00
`define CSR_CYCLEH  12'hc80
`define CSR_MTVEC   12'h305
`define CSR_MCAUSE  12'h342
`define CSR_MEPC    12'h341
`define CSR_MIE     12'h304
`define CSR_MIP     12'h344
`define CSR_MSTATUS 12'h300
`define CSR_MSCRATCH 12'h340

//***********************
//ahb bus 宏定义
//***********************
`define HADDR_BUS_WIDTH `REG_BUS_WIDTH
`define HADDR_BUS       `HADDR_BUS_WIDTH-1:0
`define HDATA_BUS_WIDTH `REG_BUS_WIDTH
`define HDATA_BUS       `HDATA_BUS_WIDTH-1:0