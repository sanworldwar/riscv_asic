`include "defines.v"

module idu (
    //  from ifu
    input   wire    [31:0]  pc_i    ,
    input   wire    [31:0]  inst_i  ,

    //  to regfile
    input   wire    [`REG_BUS]      rs1_data_i      ,
    output  wire    [`REG_ADDR_BUS] rs1_addr_o      ,
    input   wire    [`REG_BUS]      rs2_data_i      ,
    output  wire    [`REG_ADDR_BUS] rs2_addr_o      ,
    
    //  to exu  
    output  wire    [31:0]          pc_o            ,
    output  wire    [`REG_BUS]      rs1_data_o      ,
    output  wire    [`REG_BUS]      rs2_data_o      ,
    output  wire    [`REG_ADDR_BUS] rd_addr_o       ,
    output  wire                    rd_we_o         ,
    output  wire    [`DEC_INFO_BUS] dec_info_bus_o   

);

    wire    [`REG_ADDR_BUS] rs1_addr = inst_i[19:15];
    wire    [`REG_ADDR_BUS] rs2_addr = inst_i[24:20];
    wire    [`REG_ADDR_BUS] rd_addr = inst_i[11:7];

    wire    [4:0]   opcode_6_2 = inst_i[6:2];
    wire    [2:0]   funct3 = inst_i[14:12];
    wire    [6:0]   funct7 = inst_i[31:25];

    wire    opcode_6_2_01100 = opcode_6_2 == 5'b01100;

    wire    funct3_110 = funct3 == 3'b110;

    wire    funct7_0000000 = funct7 == 7'b0000000;

    wire    inst_or = opcode_6_2_01100 & funct3_110 & funct7_0000000;

    assign pc_o = pc_i;
    assign rs1_addr_o = rs1_addr;
    assign rs1_data_o = rs1_data_i;
    assign rs2_addr_o = rs2_addr;
    assign rs2_data_o = rs2_data_i;
    assign rd_addr_o = rd_addr;
    assign rd_we_o = inst_or;


    assign dec_info_bus_o[0] = inst_or;


    
endmodule