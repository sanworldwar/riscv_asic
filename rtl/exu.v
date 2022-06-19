`include "defines.v" 

module exu (
    //from idu
    input   wire    [`REG_BUS]      pc_i            ,
    input   wire    [`REG_BUS]      op1_data_i      ,
    input   wire    [`REG_BUS]      op2_data_i      ,
    input   wire    [`REG_BUS]      imm_data_i      ,
    input   wire    [`REG_ADDR_BUS] rd_addr_i       ,
    input   wire                    rd_we_i         ,
    input   wire    [`DEC_INFO_BUS] dec_info_bus_i  ,
    input   wire    [`CSR_ADDR_BUS] csr_waddr_i     ,
    input   wire                    csr_we_i        ,



    //to lsu, to idu
    output  wire                    rd_we_o         ,
    output  wire    [`REG_BUS]      rd_mem_data_o   ,
    output  wire    [`REG_ADDR_BUS] rd_addr_o       ,
    output  wire                    csr_we_o        ,
    output  wire    [`REG_BUS]      csr_wdata_o     ,
    output  wire    [`CSR_ADDR_BUS] csr_waddr_o     ,


    //to lsu
    output  wire    [`MEM_ADDR_BUS] mem_addr_o      ,
    output  wire    [`EXE_INFO_BUS] exe_info_bus_o  ,

    //to ctrl
    output  wire                stallreq_o          ,

    //from excp
    input   wire                mul_div_cancel_i    ,              

    //to mul(mul_start_o also to excp)
    output  wire                mul_start_o         ,
    output  wire                mul_cancel_o        ,
    output  wire                mul_signed_o        ,
    output  wire    [`REG_BUS]  mul_op1_o           , //被乘数
    output  wire    [`REG_BUS]  mul_op2_o           , //乘数
    input   wire                mul_stop_i          ,
    input   wire    [`REG_BUS]  mul_res_l_i         ,
    input   wire    [`REG_BUS]  mul_res_h_i         ,

    //to div(div_start_o also to excp)
    output  wire                div_start_o         ,
    output  wire                div_cancel_o        ,
    output  wire                div_op1_signed_o    , //被除数符号位信号
    output  wire                div_op2_signed_o    , //除数符号位信号     
    output  wire    [`REG_BUS]  div_op1_o           , //被除数
    output  wire    [`REG_BUS]  div_op2_o           , //除数
    input   wire                div_stop_i          ,
    input   wire    [`REG_BUS]  div_res_i           ,
    input   wire    [`REG_BUS]  div_rem_i    
);
    //R instruction
    wire    inst_r_op = dec_info_bus_i[`DEC_INST_OP] == `DEC_INST_R;
    wire    inst_r_add = dec_info_bus_i[`DEC_INST_R_ADD];
    wire    inst_r_sub = dec_info_bus_i[`DEC_INST_R_SUB];
    wire    inst_r_sll = dec_info_bus_i[`DEC_INST_R_SLL];
    wire    inst_r_slt = dec_info_bus_i[`DEC_INST_R_SLT];
    wire    inst_r_sltu = dec_info_bus_i[`DEC_INST_R_SLTU];
    wire    inst_r_xor = dec_info_bus_i[`DEC_INST_R_XOR];
    wire    inst_r_srl = dec_info_bus_i[`DEC_INST_R_SRL];
    wire    inst_r_sra = dec_info_bus_i[`DEC_INST_R_SRA];
    wire    inst_r_or = dec_info_bus_i[`DEC_INST_R_OR];
    wire    inst_r_and = dec_info_bus_i[`DEC_INST_R_AND];
    //I instruction
    wire    inst_i_op = dec_info_bus_i[`DEC_INST_OP] == `DEC_INST_I;
    wire    inst_i_addi = dec_info_bus_i[`DEC_INST_I_ADDI];
    wire    inst_i_slti = dec_info_bus_i[`DEC_INST_I_SLTI];
    wire    inst_i_sltiu = dec_info_bus_i[`DEC_INST_I_SLTIU];
    wire    inst_i_xori = dec_info_bus_i[`DEC_INST_I_XORI];
    wire    inst_i_ori = dec_info_bus_i[`DEC_INST_I_ORI];
    wire    inst_i_andi = dec_info_bus_i[`DEC_INST_I_ANDI];
    wire    inst_i_slli = dec_info_bus_i[`DEC_INST_I_SLLI];
    wire    inst_i_srli = dec_info_bus_i[`DEC_INST_I_SRLI];
    wire    inst_i_srai = dec_info_bus_i[`DEC_INST_I_SRAI];
    //U instruction
    wire    inst_u_op = dec_info_bus_i[`DEC_INST_OP] == `DEC_INST_U;
    wire    inst_u_lui = dec_info_bus_i[`DEC_INST_U_LUI];
    wire    inst_u_auipc = dec_info_bus_i[`DEC_INST_U_AUIPC];
    //L(OAD) instruction
    wire    inst_l_op = dec_info_bus_i[`DEC_INST_OP] == `DEC_INST_L;
    wire    inst_l_lb = dec_info_bus_i[`DEC_INST_L_LB];
    wire    inst_l_lh = dec_info_bus_i[`DEC_INST_L_LH];
    wire    inst_l_lw = dec_info_bus_i[`DEC_INST_L_LW];
    wire    inst_l_lbu = dec_info_bus_i[`DEC_INST_L_LBU];
    wire    inst_l_lhu = dec_info_bus_i[`DEC_INST_L_LHU];
    //S(TORE) instruction
    wire    inst_s_op = dec_info_bus_i[`DEC_INST_OP] == `DEC_INST_S;
    wire    inst_s_sb = dec_info_bus_i[`DEC_INST_S_SB];
    wire    inst_s_sh = dec_info_bus_i[`DEC_INST_S_SH];
    wire    inst_s_sw = dec_info_bus_i[`DEC_INST_S_SW];
    //J(UMP) instruction
    wire    inst_j_op = dec_info_bus_i[`DEC_INST_OP] == `DEC_INST_J;
    wire    inst_j_jal = dec_info_bus_i[`DEC_INST_J_JAL];
    wire    inst_j_jalr = dec_info_bus_i[`DEC_INST_J_JALR];
    //CONTROL STATE REGISTER instruction 
    wire    inst_csr_op = dec_info_bus_i[`DEC_INST_OP] == `DEC_INST_CSR;
    wire    inst_csr_csrrw = dec_info_bus_i[`DEC_INST_CSR_CSRRW];
    wire    inst_csr_csrrs = dec_info_bus_i[`DEC_INST_CSR_CSRRS];
    wire    inst_csr_csrrc = dec_info_bus_i[`DEC_INST_CSR_CSRRC];
    wire    inst_csr_csrrwi = dec_info_bus_i[`DEC_INST_CSR_CSRRWI];
    wire    inst_csr_csrrsi = dec_info_bus_i[`DEC_INST_CSR_CSRRSI];
    wire    inst_csr_csrrci = dec_info_bus_i[`DEC_INST_CSR_CSRRCI];  
    //MUL and DIV instruction
    wire    inst_md_op = dec_info_bus_i[`DEC_INST_OP] == `DEC_INST_MD;
    wire    inst_md_mul = dec_info_bus_i[`DEC_INST_MD_MUL];
    wire    inst_md_mulh = dec_info_bus_i[`DEC_INST_MD_MULH];
    wire    inst_md_mulhsu = dec_info_bus_i[`DEC_INST_MD_MULHSU];
    wire    inst_md_mulhu = dec_info_bus_i[`DEC_INST_MD_MULHU];
    wire    inst_md_div = dec_info_bus_i[`DEC_INST_MD_DIV];
    wire    inst_md_divu = dec_info_bus_i[`DEC_INST_MD_DIVU];
    wire    inst_md_rem = dec_info_bus_i[`DEC_INST_MD_REM];
    wire    inst_md_remu = dec_info_bus_i[`DEC_INST_MD_REMU];

    wire    [`REG_BUS]  op1_data_comp = ~op1_data_i + 1'b1;
    wire    [`REG_BUS]  op2_data_comp = ~op2_data_i + 1'b1;

    //R and I instruction result
    wire    [`REG_BUS]  inst_r_i_data = op2_data_i & {`REG_BUS_WIDTH{inst_r_op}} | 
                                        imm_data_i & {`REG_BUS_WIDTH{inst_i_op}};

    //SRA掩码
    wire    [`REG_BUS]  shift_mask = {`REG_BUS_WIDTH{op1_data_i[`REG_BUS_WIDTH-1]}} & 
                                     (~(32'hffffffff >> inst_r_i_data[4:0]));

    wire    [`REG_BUS]  inst_r_i_res = 
                    ((op1_data_i + inst_r_i_data) & 
                    {`REG_BUS_WIDTH{(inst_r_add & inst_r_op) | (inst_i_addi & inst_i_op)}})
                |
                    ((op1_data_i - inst_r_i_data) & 
                    {`REG_BUS_WIDTH{(inst_r_sub & inst_r_op)}})
                |   
                    ({`REG_BUS_WIDTH{($signed(op1_data_i) <= $signed(inst_r_i_data))}} & 
                    {`REG_BUS_WIDTH{(inst_r_slt & inst_r_op) | (inst_i_slti & inst_i_op)}})
                |   
                    ({`REG_BUS_WIDTH{(op1_data_i <= inst_r_i_data)}} & 
                    {`REG_BUS_WIDTH{(inst_r_sltu & inst_r_op) | (inst_i_sltiu & inst_i_op)}})
                | 
                    ((op1_data_i ^ inst_r_i_data) & 
                    {`REG_BUS_WIDTH{(inst_r_xor & inst_r_op) | (inst_i_xori & inst_i_op)}})
                |
                    ((op1_data_i | inst_r_i_data) & 
                    {`REG_BUS_WIDTH{(inst_r_or & inst_r_op) | (inst_i_ori & inst_i_op)}}) 
                | 
                    ((op1_data_i & inst_r_i_data) & 
                    {`REG_BUS_WIDTH{(inst_r_and & inst_r_op) | (inst_i_andi & inst_i_op)}})
                | 
                    ((op1_data_i << inst_r_i_data[4:0]) & 
                    {`REG_BUS_WIDTH{(inst_r_sll & inst_r_op) | (inst_i_slli & inst_i_op)}})
                | 
                    ((op1_data_i >> inst_r_i_data[4:0]) & 
                    {`REG_BUS_WIDTH{(inst_r_srl & inst_r_op) | (inst_i_srli & inst_i_op)}})
                | 
                    (((op1_data_i >> inst_r_i_data[4:0]) | shift_mask) & 
                    {`REG_BUS_WIDTH{(inst_r_sra & inst_r_op) | (inst_i_srai & inst_i_op)}});

    //U instruction result
    wire    [`REG_BUS]  inst_u_res = (imm_data_i & {`REG_BUS_WIDTH{(inst_u_lui & inst_u_op)}}) |
                                     ((imm_data_i + pc_i) & {`REG_BUS_WIDTH{(inst_u_auipc & inst_u_op)}});   

    //L(OAD) and S(TORE) instruction result
    wire    [`REG_BUS]  inst_l_s_addr = ((op1_data_i + imm_data_i) & {`REG_BUS_WIDTH{inst_l_op | inst_s_op}});
    wire    [`REG_BUS]  inst_s_res = op2_data_i & {`REG_BUS_WIDTH{inst_s_op}};

    //J(UMP) instruction result
    wire    [`REG_BUS]  inst_j_res = (pc_i + `REG_BUS_WIDTH'd4) & {`REG_BUS_WIDTH{(inst_j_jal | inst_j_jalr) & inst_j_op}};

    //CONTROL STATE REGISTER instruction result
    wire    [`REG_BUS]  inst_csr_res = op2_data_i & {`REG_BUS_WIDTH{inst_csr_op}};

    //MUL and DIV instruction result
    assign mul_start_o = inst_md_op & (inst_md_mul | inst_md_mulh | inst_md_mulhsu | inst_md_mulhu) & !mul_stop_i;
    assign mul_cancel_o = mul_div_cancel_i;
    assign mul_signed_o = inst_md_op & 
        ((inst_md_mulh & (op1_data_i[`REG_BUS_WIDTH-1] ^ op2_data_i[`REG_BUS_WIDTH-1])) | (inst_md_mulhsu & op1_data_i[`REG_BUS_WIDTH-1]));
    assign mul_op1_o = inst_md_op & (inst_md_mulh | inst_md_mulhsu) & op1_data_i[`REG_BUS_WIDTH-1] ? op1_data_comp : op1_data_i;
    assign mul_op2_o = inst_md_op & inst_md_mulh & op2_data_i[`REG_BUS_WIDTH-1] ? op2_data_comp : op2_data_i;

    assign div_start_o = inst_md_op & (inst_md_div | inst_md_divu | inst_md_rem | inst_md_remu) & !div_stop_i;
    assign div_cancel_o = mul_div_cancel_i;
    assign div_op1_signed_o = inst_md_op & (inst_md_div | inst_md_rem) & op1_data_i[`REG_BUS_WIDTH-1];
    assign div_op2_signed_o = inst_md_op & (inst_md_div | inst_md_rem) & op2_data_i[`REG_BUS_WIDTH-1];
    assign div_op1_o = inst_md_op & (inst_md_div | inst_md_rem) & op1_data_i[`REG_BUS_WIDTH-1] ? op1_data_comp : op1_data_i;
    assign div_op2_o = inst_md_op & (inst_md_div | inst_md_rem) & op2_data_i[`REG_BUS_WIDTH-1] ? op2_data_comp : op2_data_i;

    wire    [`REG_BUS]  inst_md_res = 
        (mul_res_l_i & {`REG_BUS_WIDTH{inst_md_mul & inst_md_op}}) |
        (mul_res_h_i & {`REG_BUS_WIDTH{(inst_md_mulh | inst_md_mulhsu | inst_md_mulhu) & inst_md_op}}) |
        (div_res_i & {`REG_BUS_WIDTH{(inst_md_div | inst_md_divu) & inst_md_op}}) |
        (div_rem_i & {`REG_BUS_WIDTH{(inst_md_rem | inst_md_remu) & inst_md_op}});

    assign csr_wdata_o = (op1_data_i & {`REG_BUS_WIDTH{(inst_csr_csrrw & inst_csr_op)}}) |
                         ((op2_data_i | op1_data_i) & {`REG_BUS_WIDTH{inst_csr_csrrs & inst_csr_op}}) |
                         ((op2_data_i & ~op1_data_i) & {`REG_BUS_WIDTH{(inst_csr_csrrc & inst_csr_op)}}) |
                         (imm_data_i & {`REG_BUS_WIDTH{(inst_csr_csrrwi & inst_csr_op)}}) |
                         ((op2_data_i | imm_data_i) & {`REG_BUS_WIDTH{(inst_csr_csrrsi & inst_csr_op)}}) |
                         ((op2_data_i & ~imm_data_i) & {`REG_BUS_WIDTH{(inst_csr_csrrci & inst_csr_op)}}); 

    assign csr_we_o = csr_we_i;    
    assign csr_waddr_o = csr_waddr_i;
 

    assign rd_mem_data_o = inst_r_i_res | inst_u_res | inst_s_res | inst_j_res | inst_csr_res | inst_md_res;
    assign rd_we_o = rd_we_i;
    assign rd_addr_o = rd_addr_i;

    assign mem_addr_o = inst_l_s_addr;

    wire    [`EXE_L_INFO_BUS]   exe_l_info_bus;
    assign exe_l_info_bus[`EXE_INST_OP] = `EXE_INST_L;
    assign exe_l_info_bus[`EXE_INST_L_LB] = inst_l_lb;
    assign exe_l_info_bus[`EXE_INST_L_LH] = inst_l_lh;
    assign exe_l_info_bus[`EXE_INST_L_LW] = inst_l_lw;
    assign exe_l_info_bus[`EXE_INST_L_LBU] = inst_l_lbu;
    assign exe_l_info_bus[`EXE_INST_L_LHU] = inst_l_lhu;

    wire    [`EXE_S_INFO_BUS]   exe_s_info_bus;
    assign exe_s_info_bus[`EXE_INST_OP] = `EXE_INST_S;
    assign exe_s_info_bus[`EXE_INST_S_SB] = inst_s_sb;
    assign exe_s_info_bus[`EXE_INST_S_SH] = inst_s_sh;
    assign exe_s_info_bus[`EXE_INST_S_SW] = inst_s_sw;

    assign exe_info_bus_o = 
        {`EXE_INFO_BUS_WIDTH{inst_l_op}} & {{`EXE_INFO_BUS_WIDTH-`EXE_L_INFO_BUS_WIDTH{1'b0}}, exe_l_info_bus} |
        {`EXE_INFO_BUS_WIDTH{inst_s_op}} & {{`EXE_INFO_BUS_WIDTH-`EXE_S_INFO_BUS_WIDTH{1'b0}}, exe_s_info_bus};
    
    assign  stallreq_o = (mul_start_o & !mul_stop_i)  | (div_start_o & !div_stop_i);



endmodule