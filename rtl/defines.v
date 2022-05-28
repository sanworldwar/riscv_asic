//***********************
//全局宏定义
//***********************
`define CPU_CLOCK_HZ        10000000        //cpu时钟10MHz
`define CPU_RESET_ADDR      32'h00000000    //cpu复位地址
`define RST_ENABLE          1'b0            //复位有效
`define RST_DISABLE         1'b1            //复位无效
`define ZERO_WORD           32'h00000000    //32位的数值0
`define WRITE_ENABLE        1'b1            //写使能
`define WRITE_DISABLE       1'b0            //写禁止
`define READ_ENABLE         1'b1            //读使能
`define READ_DISABLE        1'b0            //读禁止



//***********************
//IDU信息总线宏定义
//***********************

`define DEC_INST_OP_WIDTH       3                           //DEC指令类型信息宽度
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

//B(RANCH) and J(UMP) instruction decode bus
`define DEC_INST_J             `DEC_INST_OP_WIDTH'd6      //J型指令
`define DEC_INST_J_JAL         `DEC_INST_OP_WIDTH         //JAL指令
`define DEC_INST_J_JALR        `DEC_INST_J_JAL+1 

`define DEC_J_INFO_BUS_WIDTH   `DEC_INST_J_JALR+1         //J型指令译码信息宽度
`define DEC_J_INFO_BUS         `DEC_J_INFO_BUS_WIDTH-1:0  //J型指令译码信息

//dec info bus
`define DEC_INFO_BUS_WIDTH      `DEC_R_INFO_BUS_WIDTH       //选取最长宽度为DEC信息总线宽度
`define DEC_INFO_BUS            `DEC_INFO_BUS_WIDTH-1:0     //DEC信息总线

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
`define REG_BUS_WIDTH       32                      //regfile数据总线宽度
`define REG_BUS             `REG_BUS_WIDTH-1:0      //regfile数据总线
`define REG_ADDR_BUS_WIDTH  5                       //regfile地址总线宽度
`define REG_ADDR_BUS        `REG_ADDR_BUS_WIDTH-1:0 //regfile地址总线
`define REG_NUM             32                      //regfile数目