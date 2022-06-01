`include "defines.v"

module openriscv (
    input   wire    clk                 ,
    input   wire    rst_n               ,

    input   wire    [31:0]  rom_inst_i  ,
    output  wire    [31:0]  rom_pc_o    ,

    input   wire    [`MEM_DATA_BUS] ram_data_i      ,
    output  wire                    ram_re_o        ,
    output  wire    [`MEM_ADDR_BUS] ram_raddr_o     ,
    output  wire    [`MEM_DATA_BUS] ram_data_o      ,
    output  wire                    ram_we_o        ,
    output  wire    [`MEM_ADDR_BUS] ram_waddr_o   
);

    //连接ifu和if_id的信号
    wire    [`REG_BUS]  if_pc_o             ;
    wire    [31:0]      if_inst_o           ;
 
    //连接ifu和rom的信号
    wire    [31:0]  if_inst_i = rom_inst_i  ;
    assign rom_pc_o = if_pc_o               ;

    //连接if_id和idu的信号
    wire    [`REG_BUS]  id_pc_i         ;
    wire    [31:0]      id_inst_i       ;
    
    //连接idu和id_ex的信号
    wire    [`REG_BUS]      id_pc_o             ;
    wire    [`REG_BUS]      id_op1_data_o       ;
    wire    [`REG_BUS]      id_op2_data_o       ;
    wire    [`REG_BUS]      id_imm_data_o       ;
    wire    [`REG_ADDR_BUS] id_rd_addr_o        ;
    wire                    id_rd_we_o          ;
    wire    [`DEC_INFO_BUS] id_dec_info_bus_o   ;
    wire    [`CSR_ADDR_BUS] id_csr_waddr_o      ;
    wire                    id_csr_we_o         ;

    //连接idu和regfile的信号
    wire    [`REG_ADDR_BUS] id_rs1_addr_o   ;
    wire                    id_rs1_re_o     ;
    wire    [`REG_BUS]      id_rs1_data_i   ;
    wire    [`REG_ADDR_BUS] id_rs2_addr_o   ;
    wire                    id_rs2_re_o     ;
    wire    [`REG_BUS]      id_rs2_data_i   ;

    //连接idu和ctrl的信号
    wire                    id_stallreq_o   ;

    //连接idu和ifu的地址跳转信号
    wire                    id_jump_req_o   ;
    wire    [`REG_BUS]      id_jump_pc_o    ;

   //连接idu和csr_regfile的信号
    wire    [`REG_BUS]      id_csr_rdata_i  ;
    wire    [`CSR_ADDR_BUS] id_csr_raddr_o  ;
    wire                    id_csr_re_o     ;

    //连接id_ex和exu的信号
    wire    [`REG_BUS]      ex_pc_i             ;
    wire    [`REG_BUS]      ex_op1_data_i       ;
    wire    [`REG_BUS]      ex_op2_data_i       ;
    wire    [`REG_BUS]      ex_imm_data_i       ;
    wire    [`REG_ADDR_BUS] ex_rd_addr_i        ;
    wire                    ex_rd_we_i          ;
    wire    [`DEC_INFO_BUS] ex_dec_info_bus_i   ;
    wire    [`CSR_ADDR_BUS] ex_csr_waddr_i      ;
    wire                    ex_csr_we_i         ;

    //连接exu和ex_ls和idu的信号
    wire                    ex_rd_we_o          ;
    wire    [`REG_BUS]      ex_rd_mem_data_o    ;
    wire    [`REG_ADDR_BUS] ex_rd_addr_o        ;
    wire                    ex_csr_we_o         ;
    wire    [`REG_BUS]      ex_csr_wdata_o      ;    
    wire    [`CSR_ADDR_BUS] ex_csr_waddr_o      ;
    
    //连接exu和ex_ls的信号
    wire    [`MEM_ADDR_BUS] ex_mem_addr_o       ;
    wire    [`EXE_INFO_BUS] ex_exe_info_bus_o   ;

    //连接exu和ctrl的信号
    wire                    ex_stallreq_o       ;

    //连接ex_ls和lsu的信号
    wire                    ls_rd_we_i          ;
    wire    [`REG_BUS]      ls_rd_mem_data_i    ;
    wire    [`REG_ADDR_BUS] ls_rd_addr_i        ;
    wire    [`MEM_ADDR_BUS] ls_mem_addr_i       ;
    wire    [`EXE_INFO_BUS] ls_exe_info_bus_i   ;

    //连接ex_ls和csr_regfile的信号
    wire                    wb_csr_we_i         ;
    wire    [`REG_BUS]      wb_csr_wdata_i      ;    
    wire    [`CSR_ADDR_BUS] wb_csr_waddr_i      ;

    //连接lsu和ls_wb和idu的信号
    wire                    ls_rd_we_o     ;
    wire    [`REG_BUS]      ls_rd_data_o   ;
    wire    [`REG_ADDR_BUS] ls_rd_addr_o   ;  

    //连接lsu和data ram的信号
    wire    [`MEM_DATA_BUS] ls_mem_rdata_i = ram_data_i ;
    wire                    ls_mem_re_o                 ;
    wire    [`MEM_ADDR_BUS] ls_mem_raddr_o              ;
    wire    [`MEM_DATA_BUS] ls_mem_wdata_o              ;
    wire                    ls_mem_we_o                 ;
    wire    [`MEM_ADDR_BUS] ls_mem_waddr_o              ;  

    assign ram_re_o = ls_mem_re_o       ;
    assign ram_raddr_o = ls_mem_raddr_o ;
    assign ram_data_o = ls_mem_wdata_o  ;
    assign ram_we_o = ls_mem_we_o       ;
    assign ram_waddr_o = ls_mem_waddr_o ;

    //连接ls_wb和wb的信号
    wire                    wb_rd_we_i      ;
    wire    [`REG_BUS]      wb_rd_data_i    ;
    wire    [`REG_ADDR_BUS] wb_rd_addr_i    ; 

    //连接ctrl和ifu, if_id, id_ex, ex_ls, ls_wb的信号
    wire    [5:0]           ctrl_stall_o    ;

    ifu u_ifu(
        .clk(clk),
        .rst_n(rst_n),

        .pc_o(if_pc_o),
        .inst_o(if_inst_o),

        .inst_i(if_inst_i),

        .stall_i(ctrl_stall_o),

        .jump_pc_i(id_jump_pc_o),
        .jump_req_i(id_jump_req_o)
    );

    if_id u_if_id(
        .clk(clk),
        .rst_n(rst_n),

        .pc_i(if_pc_o),
        .inst_i(if_inst_o),

        .pc_o(id_pc_i),
        .inst_o(id_inst_i),

        .stall_i(ctrl_stall_o)
    );

    idu u_idu(
        .pc_i(id_pc_i),
        .inst_i(id_inst_i),

        .rs1_data_i(id_rs1_data_i),
        .rs1_addr_o(id_rs1_addr_o),
        .rs1_re_o(id_rs1_re_o),
        .rs2_data_i(id_rs2_data_i),
        .rs2_addr_o(id_rs2_addr_o),
        .rs2_re_o(id_rs2_re_o),

        .pc_o(id_pc_o),
        .op1_data_o(id_op1_data_o),
        .op2_data_o(id_op2_data_o),
        .imm_data_o(id_imm_data_o),
        .rd_addr_o(id_rd_addr_o),
        .rd_we_o(id_rd_we_o),
        .dec_info_bus_o(id_dec_info_bus_o),
        .csr_waddr_o(id_csr_waddr_o),
        .csr_we_o(id_csr_we_o),

        .ex_rd_we_i(ex_rd_we_o),
        .ex_rd_addr_i(ex_rd_addr_o),
        .ex_rd_data_i(ex_rd_mem_data_o),
        .ex_csr_we_i(ex_csr_we_o),
        .ex_csr_wdata_i(ex_csr_wdata_o),
        .ex_csr_waddr_i(ex_csr_waddr_o),

        .ls_rd_we_i(ls_rd_we_o),
        .ls_rd_addr_i(ls_rd_addr_o),
        .ls_rd_data_i(ls_rd_data_o),

        .stallreq_o(id_stallreq_o),

        .jump_pc_o(id_jump_pc_o),
        .jump_req_o(id_jump_req_o),

        .csr_rdata_i(id_csr_rdata_i),
        .csr_raddr_o(id_csr_raddr_o),
        .csr_re_o(id_csr_re_o)
    );

    id_ex u_id_ex(
        .clk(clk),
        .rst_n(rst_n),

        .pc_i(id_pc_o),
        .op1_data_i(id_op1_data_o),
        .op2_data_i(id_op2_data_o),
        .imm_data_i(id_imm_data_o),
        .rd_addr_i(id_rd_addr_o),
        .rd_we_i(id_rd_we_o),
        .dec_info_bus_i(id_dec_info_bus_o),
        .csr_waddr_i(id_csr_waddr_o),
        .csr_we_i(id_csr_we_o),

        .pc_o(ex_pc_i),
        .op1_data_o(ex_op1_data_i),
        .op2_data_o(ex_op2_data_i),
        .imm_data_o(ex_imm_data_i),
        .rd_addr_o(ex_rd_addr_i),
        .rd_we_o(ex_rd_we_i),
        .dec_info_bus_o(ex_dec_info_bus_i),
        .csr_waddr_o(ex_csr_waddr_i),
        .csr_we_o(ex_csr_we_i),        

        .stall_i(ctrl_stall_o)
    );

    exu u_exu(
        .pc_i(ex_pc_i),
        .op1_data_i(ex_op1_data_i),
        .op2_data_i(ex_op2_data_i),
        .imm_data_i(ex_imm_data_i),
        .rd_addr_i(ex_rd_addr_i),
        .rd_we_i(ex_rd_we_i),
        .dec_info_bus_i(ex_dec_info_bus_i),
        .csr_waddr_i(ex_csr_waddr_i),
        .csr_we_i(ex_csr_we_i),

        .rd_we_o(ex_rd_we_o),
        .rd_mem_data_o(ex_rd_mem_data_o),
        .rd_addr_o(ex_rd_addr_o),
        .csr_we_o(ex_csr_we_o),
        .csr_wdata_o(ex_csr_wdata_o),
        .csr_waddr_o(ex_csr_waddr_o),

        .mem_addr_o(ex_mem_addr_o),
        .exe_info_bus_o(ex_exe_info_bus_o),

        .stallreq_o(ex_stallreq_o)
    );

    ex_ls u_ex_ls(
        .clk(clk),
        .rst_n(rst_n),

        .rd_we_i(ex_rd_we_o),
        .rd_mem_data_i(ex_rd_mem_data_o),
        .rd_addr_i(ex_rd_addr_o),
        .csr_we_i(ex_csr_we_o),
        .csr_wdata_i(ex_csr_wdata_o),
        .csr_waddr_i(ex_csr_waddr_o),

        .mem_addr_i(ex_mem_addr_o),
        .exe_info_bus_i(ex_exe_info_bus_o),

        .rd_we_o(ls_rd_we_i),
        .rd_mem_data_o(ls_rd_mem_data_i),
        .rd_addr_o(ls_rd_addr_i),

        .mem_addr_o(ls_mem_addr_i),
        .exe_info_bus_o(ls_exe_info_bus_i),

        .stall_i(ctrl_stall_o),

        .csr_we_o(wb_csr_we_i),
        .csr_wdata_o(wb_csr_wdata_i),
        .csr_waddr_o(wb_csr_waddr_i)
    );

    lsu u_lsu(
        .rd_we_i(ls_rd_we_i),
        .rd_mem_data_i(ls_rd_mem_data_i),
        .rd_addr_i(ls_rd_addr_i),

        .mem_addr_i(ls_mem_addr_i),
        .exe_info_bus_i(ls_exe_info_bus_i),

        .rd_we_o(ls_rd_we_o),
        .rd_data_o(ls_rd_data_o),
        .rd_addr_o(ls_rd_addr_o),

        .mem_rdata_i(ls_mem_rdata_i),
        .mem_re_o(ls_mem_re_o),
        .mem_raddr_o(ls_mem_raddr_o),
        .mem_wdata_o(ls_mem_wdata_o),
        .mem_we_o(ls_mem_we_o),
        .mem_waddr_o(ls_mem_waddr_o)
    );

    ls_wb u_ls_wb(
        .clk(clk),
        .rst_n(rst_n),

        .rd_we_i(ls_rd_we_o),
        .rd_data_i(ls_rd_data_o),
        .rd_addr_i(ls_rd_addr_o),

        .rd_we_o(wb_rd_we_i),
        .rd_data_o(wb_rd_data_i),
        .rd_addr_o(wb_rd_addr_i),

        .stall_i(ctrl_stall_o)
    );

    regfile u_regfile(
        .clk(clk),

        .raddr1_i(id_rs1_addr_o),
        .re1_i(id_rs1_re_o),
        .rdata1_o(id_rs1_data_i),
        .raddr2_i(id_rs2_addr_o),
        .re2_i(id_rs2_re_o),
        .rdata2_o(id_rs2_data_i),

        .waddr_i(wb_rd_addr_i),
        .we_i(wb_rd_we_i),
        .wdata_i(wb_rd_data_i)
    );

    ctrl u_ctrl(
        .id_stallreq_i(id_stallreq_o),
        .ex_stallreq_i(ex_stallreq_o),
        .stall_o(ctrl_stall_o)
    );

    csr_regfile u_csr_regfile(
        .clk(clk),
        .rst_n(rst_n),

        .rdata_o(id_csr_rdata_i),
        .raddr_i(id_csr_raddr_o),
        .re_i(id_csr_re_o),

        .wdata_i(wb_csr_wdata_i),
        .waddr_i(wb_csr_waddr_i),
        .we_i(wb_csr_we_i)
    );    

endmodule