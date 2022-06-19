`include "defines.v"

module idu (
    //  from ifu
    input   wire    [`REG_BUS]  pc_i    ,
    input   wire    [31:0]      inst_i  ,

    //  to regfile
    input   wire    [`REG_BUS]      rs1_data_i      ,
    output  wire    [`REG_ADDR_BUS] rs1_addr_o      ,
    output  wire                    rs1_re_o        ,
    input   wire    [`REG_BUS]      rs2_data_i      ,
    output  wire    [`REG_ADDR_BUS] rs2_addr_o      ,
    output  wire                    rs2_re_o        ,    
    
    //  to exu(pc_o also to excp)  
    output  wire    [`REG_BUS]      pc_o            ,
    output  wire    [`REG_BUS]      op1_data_o      ,
    output  wire    [`REG_BUS]      op2_data_o      ,
    output  wire    [`REG_BUS]      imm_data_o      ,    
    output  wire    [`REG_ADDR_BUS] rd_addr_o       ,
    output  wire                    rd_we_o         ,
    output  wire    [`DEC_INFO_BUS] dec_info_bus_o  ,
    output  wire    [`CSR_ADDR_BUS] csr_waddr_o     ,
    output  wire                    csr_we_o        ,

    //from exu
    input   wire                    ex_rd_we_i      ,
    input   wire    [`REG_BUS]      ex_rd_data_i    ,
    input   wire    [`REG_ADDR_BUS] ex_rd_addr_i    ,
    input   wire                    ex_csr_we_i     ,
    input   wire    [`REG_BUS]      ex_csr_wdata_i  ,
    input   wire    [`CSR_ADDR_BUS] ex_csr_waddr_i  ,

    //from lsu
    input   wire                    ls_rd_we_i      ,
    input   wire    [`REG_BUS]      ls_rd_data_i    ,
    input   wire    [`REG_ADDR_BUS] ls_rd_addr_i    ,

    //to ctrl
    output  wire                    stallreq_o      ,

    //to ifu
    output  wire                    jump_req_o      ,
    output  wire    [`REG_BUS]      jump_pc_o       ,

    //to csr
    input   wire    [`REG_BUS]      csr_rdata_i     ,
    output  wire    [`CSR_ADDR_BUS] csr_raddr_o     ,
    output  wire                    csr_re_o        ,

    //to excp
    output  wire    [`DEC_SYS_BUS]  dec_sys_bus_o   
);

    wire    [`REG_ADDR_BUS] rs1_addr = inst_i[19:15];
    wire    [`REG_ADDR_BUS] rs2_addr = inst_i[24:20];
    wire    [`REG_ADDR_BUS] rd_addr = inst_i[11:7];
    wire    [`CSR_ADDR_BUS] csr_addr = inst_i[31:20];

    wire    [1:0]   opcode_1_0 = inst_i[1:0];
    wire    [4:0]   opcode_6_2 = inst_i[6:2];
    wire    [2:0]   funct3 = inst_i[14:12];
    wire    [6:0]   funct7 = inst_i[31:25];

    //funct7
    wire    funct7_0000000 = funct7 == 7'b0000000;
    wire    funct7_0100000 = funct7 == 7'b0100000; 
    wire    funct7_0000001 = funct7 == 7'b0000001; 

    //funct3
    wire    funct3_000 = funct3 == 3'b000;
    wire    funct3_001 = funct3 == 3'b001;
    wire    funct3_010 = funct3 == 3'b010;
    wire    funct3_011 = funct3 == 3'b011;
    wire    funct3_100 = funct3 == 3'b100;
    wire    funct3_101 = funct3 == 3'b101;
    wire    funct3_110 = funct3 == 3'b110;
    wire    funct3_111 = funct3 == 3'b111;

    //opcode_1_0
    wire    opcode_1_0_11 = opcode_1_0 == 2'b11; //32位指令
    //opcode_6_2
    wire    opcode_6_2_01100 = opcode_6_2 == 5'b01100;  //R型算术指令
    wire    opcode_6_2_00100 = opcode_6_2 == 5'b00100;  //I型算术指令
    wire    opcode_6_2_01101 = opcode_6_2 == 5'b01101; //lui指令
    wire    opcode_6_2_00101 = opcode_6_2 == 5'b00101; //auipc指令
    wire    opcode_6_2_00000 = opcode_6_2 == 5'b00000; //l(oad)指令
    wire    opcode_6_2_01000 = opcode_6_2 == 5'b01000; //s(tore)指令
    wire    opcode_6_2_11011 = opcode_6_2 == 5'b11011; //jal指令
    wire    opcode_6_2_11001 = opcode_6_2 == 5'b11001; //jal指令
    wire    opcode_6_2_11000 = opcode_6_2 == 5'b11000; //b(ranch)指令
    wire    opcode_6_2_00011 = opcode_6_2 == 5'b00011; //fence指令
    wire    opcode_6_2_11100 = opcode_6_2 == 5'b11100; //system指令

    //R instruction
    wire    inst_r_add = funct7_0000000 & funct3_000 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_r_sub = funct7_0100000 & funct3_000 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_r_sll = funct7_0000000 & funct3_001 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_r_slt = funct7_0000000 & funct3_010 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_r_sltu = funct7_0000000 & funct3_011 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_r_xor = funct7_0000000 & funct3_100 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_r_srl = funct7_0000000 & funct3_101 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_r_sra = funct7_0100000 & funct3_101 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_r_or = funct7_0000000 & funct3_110 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_r_and = funct7_0000000 & funct3_111 & opcode_6_2_01100 & opcode_1_0_11;

    wire    inst_r_op = inst_r_add | inst_r_sub | inst_r_sll | inst_r_slt | inst_r_sltu | 
                        inst_r_xor | inst_r_srl | inst_r_sra | inst_r_or  | inst_r_and; //R类指令有效

    wire    [`DEC_R_INFO_BUS]   dec_r_info_bus; 
    assign dec_r_info_bus[`DEC_INST_OP] = `DEC_INST_R;
    assign dec_r_info_bus[`DEC_INST_R_ADD] = inst_r_add;
    assign dec_r_info_bus[`DEC_INST_R_SUB] = inst_r_sub;
    assign dec_r_info_bus[`DEC_INST_R_SLT] = inst_r_slt;
    assign dec_r_info_bus[`DEC_INST_R_SLTU] = inst_r_sltu;
    assign dec_r_info_bus[`DEC_INST_R_XOR] = inst_r_xor;
    assign dec_r_info_bus[`DEC_INST_R_OR] = inst_r_or;
    assign dec_r_info_bus[`DEC_INST_R_AND] = inst_r_and;
    assign dec_r_info_bus[`DEC_INST_R_SLL] = inst_r_sll;
    assign dec_r_info_bus[`DEC_INST_R_SRL] = inst_r_srl;
    assign dec_r_info_bus[`DEC_INST_R_SRA] = inst_r_sra;

    //I instruction
    wire    inst_i_addi = funct3_000 & opcode_6_2_00100 & opcode_1_0_11;
    wire    inst_i_slti = funct3_010 & opcode_6_2_00100 & opcode_1_0_11;
    wire    inst_i_sltiu = funct3_011 & opcode_6_2_00100 & opcode_1_0_11;
    wire    inst_i_xori = funct3_100 & opcode_6_2_00100 & opcode_1_0_11;
    wire    inst_i_ori = funct3_110 & opcode_6_2_00100 & opcode_1_0_11;
    wire    inst_i_andi = funct3_111 & opcode_6_2_00100 & opcode_1_0_11;
    wire    inst_i_slli = funct7_0000000 & funct3_001 & opcode_6_2_00100 & opcode_1_0_11;
    wire    inst_i_srli = funct7_0000000 & funct3_101 & opcode_6_2_00100 & opcode_1_0_11;
    wire    inst_i_srai = funct7_0100000 & funct3_101 & opcode_6_2_00100 & opcode_1_0_11;

    wire    inst_i_op = inst_i_addi | inst_i_slti | inst_i_sltiu | inst_i_xori | inst_i_ori | 
                        inst_i_andi | inst_i_srli | inst_i_srai  | inst_i_slli; //I类指令有效

    wire    [`DEC_I_INFO_BUS]   dec_i_info_bus; 
    assign dec_i_info_bus[`DEC_INST_OP] = `DEC_INST_I;
    assign dec_i_info_bus[`DEC_INST_I_ADDI] = inst_i_addi;
    assign dec_i_info_bus[`DEC_INST_I_SLTI] = inst_i_slti;
    assign dec_i_info_bus[`DEC_INST_I_SLTIU] = inst_i_sltiu;
    assign dec_i_info_bus[`DEC_INST_I_XORI] = inst_i_xori;
    assign dec_i_info_bus[`DEC_INST_I_ORI] = inst_i_ori;
    assign dec_i_info_bus[`DEC_INST_I_ANDI] = inst_i_andi;
    assign dec_i_info_bus[`DEC_INST_I_SLLI] = inst_i_slli;
    assign dec_i_info_bus[`DEC_INST_I_SRLI] = inst_i_srli;
    assign dec_i_info_bus[`DEC_INST_I_SRAI] = inst_i_srai;

    //U instruction
    wire    inst_u_lui = opcode_6_2_01101 & opcode_1_0_11;
    wire    inst_u_auipc = opcode_6_2_00101 & opcode_1_0_11;

    wire    inst_u_op = inst_u_lui | inst_u_auipc;

    wire    [`DEC_U_INFO_BUS]   dec_u_info_bus;
    assign dec_u_info_bus[`DEC_INST_OP] = `DEC_INST_U;
    assign dec_u_info_bus[`DEC_INST_U_LUI] = inst_u_lui;
    assign dec_u_info_bus[`DEC_INST_U_AUIPC] =  inst_u_auipc;

    //L(OAD) instruction
    wire    inst_l_lb = funct3_000 & opcode_6_2_00000 & opcode_1_0_11;
    wire    inst_l_lh = funct3_001 & opcode_6_2_00000 & opcode_1_0_11;
    wire    inst_l_lw = funct3_010 & opcode_6_2_00000 & opcode_1_0_11;
    wire    inst_l_lbu = funct3_100 & opcode_6_2_00000 & opcode_1_0_11;
    wire    inst_l_lhu = funct3_101 & opcode_6_2_00000 & opcode_1_0_11;

    wire    inst_l_op = inst_l_lb | inst_l_lh | inst_l_lw | inst_l_lbu | inst_l_lhu;

    wire    [`DEC_L_INFO_BUS]   dec_l_info_bus;
    assign dec_l_info_bus[`DEC_INST_OP] = `DEC_INST_L;
    assign dec_l_info_bus[`DEC_INST_L_LB] = inst_l_lb;
    assign dec_l_info_bus[`DEC_INST_L_LH] = inst_l_lh;
    assign dec_l_info_bus[`DEC_INST_L_LW] = inst_l_lw;
    assign dec_l_info_bus[`DEC_INST_L_LBU] =  inst_l_lbu;
    assign dec_l_info_bus[`DEC_INST_L_LHU] =  inst_l_lhu;    

    //S(TORE) instruction
    wire    inst_s_sb = funct3_000 & opcode_6_2_01000 & opcode_1_0_11;
    wire    inst_s_sh = funct3_001 & opcode_6_2_01000 & opcode_1_0_11;
    wire    inst_s_sw = funct3_010 & opcode_6_2_01000 & opcode_1_0_11;

    wire    inst_s_op = inst_s_sb | inst_s_sh | inst_s_sw;

    wire    [`DEC_S_INFO_BUS]   dec_s_info_bus;
    assign dec_s_info_bus[`DEC_INST_OP] = `DEC_INST_S;
    assign dec_s_info_bus[`DEC_INST_S_SB] = inst_s_sb;
    assign dec_s_info_bus[`DEC_INST_S_SH] = inst_s_sh;
    assign dec_s_info_bus[`DEC_INST_S_SW] = inst_s_sw;

    //J(UMP) instruction
    wire    inst_j_jal = opcode_6_2_11011 & opcode_1_0_11;
    wire    inst_j_jalr = opcode_6_2_11001 & opcode_1_0_11;

    wire    inst_j_op = inst_j_jal | inst_j_jalr;

    wire    [`DEC_J_INFO_BUS]   dec_j_info_bus;
    assign dec_j_info_bus[`DEC_INST_OP] = `DEC_INST_J;
    assign dec_j_info_bus[`DEC_INST_J_JAL] = inst_j_jal;
    assign dec_j_info_bus[`DEC_INST_J_JALR] = inst_j_jalr; 

    //B(RANCH) instruction
    wire    inst_b_beq = funct3_000 & opcode_6_2_11000 & opcode_1_0_11;
    wire    inst_b_bne = funct3_001 & opcode_6_2_11000 & opcode_1_0_11;
    wire    inst_b_blt = funct3_100 & opcode_6_2_11000 & opcode_1_0_11;
    wire    inst_b_bge = funct3_101 & opcode_6_2_11000 & opcode_1_0_11;
    wire    inst_b_bltu = funct3_110 & opcode_6_2_11000 & opcode_1_0_11;
    wire    inst_b_bgeu = funct3_111 & opcode_6_2_11000 & opcode_1_0_11;

    wire    inst_b_op = inst_b_beq | inst_b_bne  | inst_b_blt | 
                        inst_b_bge | inst_b_bltu | inst_b_bgeu;

    //fence: nop
    wire    inst_fence = funct3_000 & opcode_6_2_00011 & opcode_1_0_11;

    //SYSTEM instruction no use
    wire    inst_sys_ecall = inst_i[31:20] == 12'b0000_0000_0000 & funct3_000 & opcode_6_2_11100 & opcode_1_0_11;
    wire    inst_sys_ebreak = inst_i[31:20] == 12'b0000_0000_0001 & funct3_000 & opcode_6_2_11100 & opcode_1_0_11;
    wire    inst_sys_mret = inst_i[31:20] == 12'b0011_0000_0010 & funct3_000 & opcode_6_2_11100 & opcode_1_0_11;

    assign dec_sys_bus_o[`DEC_SYS_INST_ECALL] = inst_sys_ecall;
    assign dec_sys_bus_o[`DEC_SYS_INST_EBREAK] = inst_sys_ebreak;
    assign dec_sys_bus_o[`DEC_SYS_INST_MRET] = inst_sys_mret;

    //CONTROL STATE REGISTER instruction
    wire    inst_csr_csrrw = funct3_001 & opcode_6_2_11100 & opcode_1_0_11;
    wire    inst_csr_csrrs = funct3_010 & opcode_6_2_11100 & opcode_1_0_11;
    wire    inst_csr_csrrc = funct3_011 & opcode_6_2_11100 & opcode_1_0_11;
    wire    inst_csr_csrrwi = funct3_101 & opcode_6_2_11100 & opcode_1_0_11;
    wire    inst_csr_csrrsi = funct3_110 & opcode_6_2_11100 & opcode_1_0_11;
    wire    inst_csr_csrrci = funct3_111 & opcode_6_2_11100 & opcode_1_0_11;

    wire    inst_csr_r_op = inst_csr_csrrw  | inst_csr_csrrs  | inst_csr_csrrc;
    wire    inst_csr_i_op = inst_csr_csrrwi | inst_csr_csrrsi | inst_csr_csrrci;
    wire    inst_csr_op = inst_csr_r_op | inst_csr_i_op;

    wire    [`DEC_CSR_INFO_BUS]   dec_csr_info_bus;
    assign dec_csr_info_bus[`DEC_INST_OP] = `DEC_INST_CSR;
    assign dec_csr_info_bus[`DEC_INST_CSR_CSRRW] = inst_csr_csrrw;
    assign dec_csr_info_bus[`DEC_INST_CSR_CSRRS] = inst_csr_csrrs;
    assign dec_csr_info_bus[`DEC_INST_CSR_CSRRC] = inst_csr_csrrc;
    assign dec_csr_info_bus[`DEC_INST_CSR_CSRRWI] = inst_csr_csrrwi;
    assign dec_csr_info_bus[`DEC_INST_CSR_CSRRSI] = inst_csr_csrrsi;
    assign dec_csr_info_bus[`DEC_INST_CSR_CSRRCI] = inst_csr_csrrci;

    //MUL and DIV instruction
    wire    inst_md_mul = funct7_0000001 & funct3_000 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_md_mulh = funct7_0000001 & funct3_001 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_md_mulhsu = funct7_0000001 & funct3_010 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_md_mulhu = funct7_0000001 & funct3_011 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_md_div = funct7_0000001 & funct3_100 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_md_divu = funct7_0000001 & funct3_101 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_md_rem = funct7_0000001 & funct3_110 & opcode_6_2_01100 & opcode_1_0_11;
    wire    inst_md_remu =funct7_0000001 & funct3_111 & opcode_6_2_01100 & opcode_1_0_11;

    wire    inst_md_op = inst_md_mul | inst_md_mulh | inst_md_mulhsu | inst_md_mulhu |
                         inst_md_div | inst_md_divu | inst_md_rem    | inst_md_remu;

    wire    [`DEC_MD_INFO_BUS]  dec_md_info_bus;
    assign dec_md_info_bus[`DEC_INST_OP] = `DEC_INST_MD;
    assign dec_md_info_bus[`DEC_INST_MD_MUL] = inst_md_mul;
    assign dec_md_info_bus[`DEC_INST_MD_MULH] = inst_md_mulh;
    assign dec_md_info_bus[`DEC_INST_MD_MULHSU] = inst_md_mulhsu;
    assign dec_md_info_bus[`DEC_INST_MD_MULHU] = inst_md_mulhu;
    assign dec_md_info_bus[`DEC_INST_MD_DIV] = inst_md_div;
    assign dec_md_info_bus[`DEC_INST_MD_DIVU] = inst_md_divu;
    assign dec_md_info_bus[`DEC_INST_MD_REM] = inst_md_rem;
    assign dec_md_info_bus[`DEC_INST_MD_REMU] = inst_md_remu;

    wire    [`REG_BUS]  imm =  //立即数
        ({`REG_BUS_WIDTH{inst_j_jal}} & {{`REG_BUS_WIDTH-20-1{inst_i[31]}}, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0}) |
        ({`REG_BUS_WIDTH{inst_j_jalr}} & {{`REG_BUS_WIDTH-12{inst_i[31]}}, inst_i[31:20]}) |
        ({`REG_BUS_WIDTH{inst_b_op}} & {{`REG_BUS_WIDTH-12-1{inst_i[31]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0});

    assign pc_o = pc_i;
    
    wire    [`REG_BUS]  rs1_data = (rs1_addr == `REG_ADDR_BUS_WIDTH'h0) ? rs1_data_i   : //数据前移
                        ((rs1_addr == ex_rd_addr_i) & ex_rd_we_i)       ? ex_rd_data_i :
                        ((rs1_addr == ls_rd_addr_i) & ls_rd_we_i)       ? ls_rd_data_i : 
                        rs1_data_i;
    wire    [`REG_BUS]  rs2_data = (rs2_addr == `REG_ADDR_BUS_WIDTH'h0) ? rs2_data_i   : //数据前移
                        ((rs2_addr == ex_rd_addr_i) & ex_rd_we_i)       ? ex_rd_data_i :
                        ((rs2_addr == ls_rd_addr_i) & ls_rd_we_i)       ? ls_rd_data_i : 
                        rs2_data_i;        
                 
    assign rs1_addr_o = rs1_addr;
    assign rs1_re_o = inst_r_op | inst_i_op | inst_l_op | inst_s_op | inst_j_jalr |  inst_b_op | inst_csr_r_op | inst_md_op;

    assign rs2_addr_o = rs2_addr;
    assign rs2_re_o = inst_r_op | inst_s_op | inst_b_op | inst_md_op;

    assign rd_addr_o = {`REG_BUS_WIDTH{~(inst_s_op | inst_b_op)}} & rd_addr;
    assign rd_we_o = inst_r_op | inst_i_op | inst_u_op | inst_j_op | inst_csr_op | inst_md_op;

    wire    [`REG_BUS]  csr_rdata = (csr_addr == ex_csr_waddr_i) ? ex_csr_wdata_i : csr_rdata_i;//数据前移

    assign csr_raddr_o = csr_addr;
    assign csr_re_o = inst_csr_op; 

    assign csr_waddr_o = csr_addr;
    assign csr_we_o = inst_csr_op; 

    assign op1_data_o = {`REG_BUS_WIDTH{(inst_r_op | inst_i_op | inst_l_op | inst_s_op | inst_csr_r_op | inst_md_op)}} & rs1_data;
    assign op2_data_o = ({`REG_BUS_WIDTH{inst_r_op | inst_s_op | inst_md_op}} & rs2_data) |
                        ({`REG_BUS_WIDTH{inst_csr_op}} & csr_rdata);
    assign imm_data_o = 
        ({`REG_BUS_WIDTH{inst_i_op}} & {{`REG_BUS_WIDTH-12{inst_i[31]}}, inst_i[31:20]}) | 
        ({`REG_BUS_WIDTH{inst_u_op}} & {inst_i[31:12], {`REG_BUS_WIDTH-20{inst_i[31]}}}) |
        ({`REG_BUS_WIDTH{inst_l_op}} & {{`REG_BUS_WIDTH-12{inst_i[31]}}, inst_i[31:20]}) |
        ({`REG_BUS_WIDTH{inst_s_op}} & {{`REG_BUS_WIDTH-12{inst_i[31]}}, inst_i[31:25], inst_i[11:7]}) |
        ({`REG_BUS_WIDTH{inst_csr_i_op}} & {{`REG_BUS_WIDTH-5{1'b0}}, inst_i[19:15]});

    assign dec_info_bus_o = 
        ({`DEC_INFO_BUS_WIDTH{inst_r_op}} & {{`DEC_INFO_BUS_WIDTH-`DEC_R_INFO_BUS_WIDTH{1'b0}}, dec_r_info_bus}) |
        ({`DEC_INFO_BUS_WIDTH{inst_i_op}} & {{`DEC_INFO_BUS_WIDTH-`DEC_I_INFO_BUS_WIDTH{1'b0}}, dec_i_info_bus}) |
        ({`DEC_INFO_BUS_WIDTH{inst_u_op}} & {{`DEC_INFO_BUS_WIDTH-`DEC_U_INFO_BUS_WIDTH{1'b0}}, dec_u_info_bus}) |
        ({`DEC_INFO_BUS_WIDTH{inst_l_op}} & {{`DEC_INFO_BUS_WIDTH-`DEC_L_INFO_BUS_WIDTH{1'b0}}, dec_l_info_bus}) |
        ({`DEC_INFO_BUS_WIDTH{inst_s_op}} & {{`DEC_INFO_BUS_WIDTH-`DEC_S_INFO_BUS_WIDTH{1'b0}}, dec_s_info_bus}) |
        ({`DEC_INFO_BUS_WIDTH{inst_j_op}} & {{`DEC_INFO_BUS_WIDTH-`DEC_J_INFO_BUS_WIDTH{1'b0}}, dec_j_info_bus}) |
        ({`DEC_INFO_BUS_WIDTH{inst_csr_op}} & {{`DEC_INFO_BUS_WIDTH-`DEC_CSR_INFO_BUS_WIDTH{1'b0}}, dec_csr_info_bus}) |
        ({`DEC_INFO_BUS_WIDTH{inst_md_op}} & {{`DEC_INFO_BUS_WIDTH-`DEC_MD_INFO_BUS_WIDTH{1'b0}}, dec_md_info_bus});
   
    //停顿流水线 //load-store, load-use, load-branch 
    assign  stallreq_o = (rs1_addr != `REG_ADDR_BUS_WIDTH'h0) & (rs1_addr == ex_rd_addr_i) & rs1_re_o & !ex_rd_we_i |
                         (rs2_addr != `REG_ADDR_BUS_WIDTH'h0) & (rs2_addr == ex_rd_addr_i) & rs2_re_o & !ex_rd_we_i;

    //B(RANCH) and J(UMP) instruction result
    wire                inst_b_jump = ((rs1_data == rs2_data) & inst_b_beq)                  |
                                      ((rs1_data != rs2_data) & inst_b_bne)                  |
                                      (($signed(rs1_data) < $signed(rs2_data)) & inst_b_blt) |
                                      (($signed(rs1_data) >= $signed(rs2_data)) & inst_b_bge)|
                                      ((rs1_data < rs2_data) & inst_b_bltu)                  |
                                      ((rs1_data >= rs2_data) & inst_b_bgeu);
    wire    [`REG_BUS]  inst_bj_pc = ((imm + pc_i) & {`REG_BUS_WIDTH{inst_j_jal}})       |
                                     ((rs1_data + pc_i) & {`REG_BUS_WIDTH{inst_j_jalr}}) |
                                     ((imm + pc_i) & {`REG_BUS_WIDTH{(inst_b_jump)}});

    assign jump_req_o = (inst_b_jump | inst_j_op);
    assign jump_pc_o = inst_bj_pc;

endmodule