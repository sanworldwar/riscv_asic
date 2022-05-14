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
//
//***********************
`define DEC_INFO_BUS_WIDTH  1                       //译码信息总线宽度
`define DEC_INFO_BUS        `DEC_INFO_BUS_WIDTH-1:0 //译码信息总线

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