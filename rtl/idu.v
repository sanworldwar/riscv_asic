`include "defines.v"

module idu (
    //  from ifu
    input   wire    [31:0]  pc_i    ,
    input   wire    [31:0]  inst_i  ,

    //  to regfile
    input   wire    [`REG_BUS]      rs1_data_i      ,
    output  wire    [`REG_ADDR_BUS] rs1_addr_o      ,
    output  wire                    rs1_re_o        ,
    input   wire    [`REG_BUS]      rs2_data_i      ,
    output  wire    [`REG_ADDR_BUS] rs2_addr_o      ,
    output  wire                    rs2_re_o        ,    
    
    //  to exu  
    output  wire    [31:0]          pc_o            ,
    output  wire    [`REG_BUS]      op1_data_o      ,
    output  wire    [`REG_BUS]      op2_data_o      ,
    output  wire    [`REG_ADDR_BUS] rd_addr_o       ,
    output  wire                    rd_we_o         ,
    output  wire    [`DEC_INFO_BUS] dec_info_bus_o  ,

    //from exu
    input   wire                    ex_rd_we_i   ,
    input   wire    [`REG_BUS]      ex_rd_data_i ,
    input   wire    [`REG_ADDR_BUS] ex_rd_addr_i ,

    //from lsu
    input   wire                    ls_rd_we_i      ,
    input   wire    [`REG_BUS]      ls_rd_data_i    ,
    input   wire    [`REG_ADDR_BUS] ls_rd_addr_i   

);

    wire    [`REG_ADDR_BUS] rs1_addr = inst_i[19:15];
    wire    [`REG_ADDR_BUS] rs2_addr = inst_i[24:20];
    wire    [`REG_ADDR_BUS] rd_addr = inst_i[11:7];

    wire    [1:0]   opcode_1_0 = inst_i[1:0];
    wire    [4:0]   opcode_6_2 = inst_i[6:2];
    wire    [2:0]   funct3 = inst_i[14:12];
    wire    [6:0]   funct7 = inst_i[31:25];

    //opcode_1_0
    wire    opcode_1_0_11 = opcode_1_0 == 2'b11; //32位指令
    //opcode_6_2
    wire    opcode_6_2_01100 = opcode_6_2 == 5'b01100;  //R型算术指令
    wire    opcode_6_2_00100 = opcode_6_2 == 5'b00100;  //i型算术指令

    //funct3
    wire    funct3_000 = funct3 == 3'b000;
    wire    funct3_001 = funct3 == 3'b001;
    wire    funct3_010 = funct3 == 3'b010;
    wire    funct3_011 = funct3 == 3'b011;
    wire    funct3_100 = funct3 == 3'b100;
    wire    funct3_101 = funct3 == 3'b101;
    wire    funct3_110 = funct3 == 3'b110;
    wire    funct3_111 = funct3 == 3'b111;

    //funct7
    wire    funct7_0000000 = funct7 == 7'b0000000;
    wire    funct7_0100000 = funct7 == 7'b0100000; 
    
    //R instruction
    wire    inst_add = funct7_0000000 & funct3_000 & opcode_6_2_01100;
    wire    inst_sub = funct7_0100000 & funct3_000 & opcode_6_2_01100;
    wire    inst_sll = funct7_0000000 & funct3_001 & opcode_6_2_01100;
    wire    inst_slt = funct7_0000000 & funct3_010 & opcode_6_2_01100;
    wire    inst_sltu = funct7_0000000 & funct3_011 & opcode_6_2_01100;
    wire    inst_xor = funct7_0000000 & funct3_100 & opcode_6_2_01100;
    wire    inst_srl = funct7_0000000 & funct3_101 & opcode_6_2_01100;
    wire    inst_sra = funct7_0100000 & funct3_101 & opcode_6_2_01100;
    wire    inst_or = funct7_0000000 & funct3_110 & opcode_6_2_01100;
    wire    inst_and = funct7_0000000 & funct3_111 & opcode_6_2_01100;

    wire    inst_r_op = inst_add | inst_sub | inst_sll | inst_slt | inst_sltu | 
                        inst_xor | inst_srl | inst_sra | inst_or  | inst_and; //R类指令有效

    wire    [`DEC_R_INFO_BUS]  dec_r_info_bus; 
    assign dec_r_info_bus[`DEC_INST_OP] = `DEC_INST_R;
    assign dec_r_info_bus[`DEC_INST_R_ADD] = inst_add;
    assign dec_r_info_bus[`DEC_INST_R_SUB] = inst_sub;
    assign dec_r_info_bus[`DEC_INST_R_SLL] = inst_sll;
    assign dec_r_info_bus[`DEC_INST_R_SLT] = inst_slt;
    assign dec_r_info_bus[`DEC_INST_R_SLTU] = inst_sltu;
    assign dec_r_info_bus[`DEC_INST_R_XOR] = inst_xor;
    assign dec_r_info_bus[`DEC_INST_R_SRL] = inst_srl;
    assign dec_r_info_bus[`DEC_INST_R_SRA] = inst_sra;
    assign dec_r_info_bus[`DEC_INST_R_OR] = inst_or;
    assign dec_r_info_bus[`DEC_INST_R_AND] = inst_and;

    //I instruction
    wire    inst_addi = funct3_000 & opcode_6_2_00100;
    wire    inst_slti = funct3_010 & opcode_6_2_00100;
    wire    inst_sltiu = funct3_011 & opcode_6_2_00100;
    wire    inst_xori = funct3_100 & opcode_6_2_00100;
    wire    inst_ori = funct3_110 & opcode_6_2_00100;
    wire    inst_andi = funct3_111 & opcode_6_2_00100;
    wire    inst_slli = funct7_0000000 & funct3_001 & opcode_6_2_00100;
    wire    inst_srli = funct7_0000000 & funct3_101 & opcode_6_2_00100;
    wire    inst_srai = funct7_0100000 & funct3_101 & opcode_6_2_00100;

    wire    inst_i_op = inst_addi | inst_slti | inst_sltiu | inst_xori | inst_ori | 
                        inst_andi | inst_srli | inst_srai  | inst_slli; //I类指令有效

    wire    [`DEC_I_INFO_BUS]  dec_i_info_bus; 
    assign dec_i_info_bus[`DEC_INST_OP] = `DEC_INST_I;
    assign dec_i_info_bus[`DEC_INST_I_ADDI] = inst_addi;
    assign dec_i_info_bus[`DEC_INST_I_SLTI] = inst_slti;
    assign dec_i_info_bus[`DEC_INST_I_SLTIU] = inst_sltiu;
    assign dec_i_info_bus[`DEC_INST_I_XORI] = inst_xori;
    assign dec_i_info_bus[`DEC_INST_I_ORI] = inst_ori;
    assign dec_i_info_bus[`DEC_INST_I_ANDI] = inst_andi;
    assign dec_i_info_bus[`DEC_INST_I_SLLI] = inst_slli;
    assign dec_i_info_bus[`DEC_INST_I_SRLI] = inst_srli;
    assign dec_i_info_bus[`DEC_INST_I_SRAI] = inst_srai;

    wire    [`REG_BUS]  imm = {`REG_BUS_WIDTH{inst_i_op}} & {{`REG_BUS_WIDTH-12{inst_i[31]}}, inst_i[31:20]}; //立即数

    assign pc_o = pc_i;
    
    wire    [`REG_BUS]  rs1_data = (rs1_addr == `REG_ADDR_BUS_WIDTH'h0) ? rs1_data_i   : //数据前移
                        ((rs1_addr == ex_rd_addr_i) && ex_rd_we_i)      ? ex_rd_data_i :
                        ((rs1_addr == ls_rd_addr_i) && ls_rd_we_i)      ? ls_rd_data_i : 
                        rs1_data_i;
    wire    [`REG_BUS]  rs2_data = (rs2_addr == `REG_ADDR_BUS_WIDTH'h0) ? rs2_data_i   : //数据前移
                        ((rs2_addr == ex_rd_addr_i) && ex_rd_we_i)      ? ex_rd_data_i :
                        ((rs2_addr == ls_rd_addr_i) && ls_rd_we_i)      ? ls_rd_data_i : 
                        rs2_data_i;        
                 
    assign rs1_addr_o = rs1_addr;
    assign rs1_re_o = inst_r_op | inst_i_op;

    assign rs2_addr_o = rs2_addr;
    assign rs2_re_o = inst_r_op;

    assign rd_addr_o = rd_addr;
    assign rd_we_o = inst_r_op | inst_i_op;

    assign op1_data_o = {`REG_BUS_WIDTH{(inst_r_op | inst_i_op)}} & rs1_data;
    assign op2_data_o = {`REG_BUS_WIDTH{inst_r_op}} & rs2_data |
                        {`REG_BUS_WIDTH{inst_i_op}} & imm;

    assign dec_info_bus_o = 
    ({{`DEC_INFO_BUS_WIDTH{inst_r_op}} & {{`DEC_INFO_BUS_WIDTH-`DEC_R_INFO_BUS_WIDTH{1'b0}}, dec_r_info_bus}}) |
    ({{`DEC_INFO_BUS_WIDTH{inst_i_op}} & {{`DEC_INFO_BUS_WIDTH-`DEC_I_INFO_BUS_WIDTH{1'b0}}, dec_i_info_bus}});
   
endmodule