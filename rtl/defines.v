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

`define DEC_INST_OP_WIDTH       3                           //指令类型信息宽度
`define DEC_INST_OP             `DEC_INST_OP_WIDTH-1:0      //指令类型信息

`define DEC_INST_R              `DEC_INST_OP_WIDTH'd0      //R型指令
`define DEC_INST_R_ADD          `DEC_INST_OP_WIDTH         //ADD指令
`define DEC_INST_R_SUB          `DEC_INST_R_ADD+1          //SUB指令
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

`define DEC_INST_I              `DEC_INST_OP_WIDTH'd1      //I型指令
`define DEC_INST_I_ADDI         `DEC_INST_OP_WIDTH         //ADDI指令
`define DEC_INST_I_SLTI         `DEC_INST_I_ADDI+1 
`define DEC_INST_I_SLTIU        `DEC_INST_I_SLTI+1 
`define DEC_INST_I_XORI         `DEC_INST_I_SLTIU+1
`define DEC_INST_I_ORI          `DEC_INST_I_XORI+1
`define DEC_INST_I_ANDI         `DEC_INST_I_ORI+1 
`define DEC_INST_I_SLLI         `DEC_INST_I_ANDI+1  
`define DEC_INST_I_SRLI         `DEC_INST_I_SLLI+1
`define DEC_INST_I_SRAI         `DEC_INST_I_SRLI+1

`define DEC_I_INFO_BUS_WIDTH    `DEC_INST_I_SRAI+1           //R型指令译码信息宽度
`define DEC_I_INFO_BUS          `DEC_I_INFO_BUS_WIDTH-1:0   //R型指令译码信息

`define DEC_INFO_BUS_WIDTH      `DEC_R_INFO_BUS_WIDTH       //译码信息总线宽度
`define DEC_INFO_BUS            `DEC_INFO_BUS_WIDTH-1:0     //译码信息总线

//***********************
//具体指令的宏定义
//***********************

//***********************
//指令存储器ROM宏定义
//***********************
`define DATA_BUS            31:0            //数据总线宽度
`define ROM_DEPTH           8192            //指令存储器的深度，单位为word(4字节)
`define RAM_DEPTH           4096            //数据存储器的深度，单位为word(4字节)

//***********************
//通用寄存器宏定义
//***********************
`define REG_BUS_WIDTH       32                      //regfile数据总线宽度
`define REG_BUS             `REG_BUS_WIDTH-1:0      //regfile数据总线
`define REG_ADDR_BUS_WIDTH  5                       //regfile地址总线宽度
`define REG_ADDR_BUS        `REG_ADDR_BUS_WIDTH-1:0 //regfile地址总线
`define REG_NUM             32                      //regfile数目