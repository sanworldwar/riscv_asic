`include "defines.v"

module openriscv (
    input   wire    clk                 ,
    input   wire    rst_n               ,

    //外部计时器中断
    input   wire                    timer_irq_i     ,

    //if_ahb_interface信号
    output  wire                    if_mst_hsel_o       ,
    output  wire    [1:0]           if_mst_htrans_o     ,
    output  wire    [`HADDR_BUS]    if_mst_haddr_o      ,
    output  wire    [`HDATA_BUS]    if_mst_hwdata_o     ,
    output  wire                    if_mst_hwrite_o     ,
    output  wire    [2:0]           if_mst_hsize_o      ,
    output  wire    [2:0]           if_mst_hburst_o     ,
    output  wire    [3:0]           if_mst_hprot_o      ,
    output  wire                    if_mst_hmastlock_o  ,
    output  wire                    if_mst_priority_o   ,   
    input   wire                    if_mst_hready_i     ,
    input   wire                    if_mst_hresp_i      ,
    input   wire    [`HDATA_BUS]    if_mst_hrdata_i     ,    

    //ls_ahb_interface信号
    output  wire                    ls_mst_hsel_o       ,
    output  wire    [1:0]           ls_mst_htrans_o     ,
    output  wire    [`HADDR_BUS]    ls_mst_haddr_o      ,
    output  wire    [`HDATA_BUS]    ls_mst_hwdata_o     ,
    output  wire                    ls_mst_hwrite_o     ,
    output  wire    [2:0]           ls_mst_hsize_o      ,
    output  wire    [2:0]           ls_mst_hburst_o     ,
    output  wire    [3:0]           ls_mst_hprot_o      ,
    output  wire                    ls_mst_hmastlock_o  ,
    output  wire                    ls_mst_priority_o   ,     
    input   wire                    ls_mst_hready_i     ,
    input   wire                    ls_mst_hresp_i      ,
    input   wire    [`HDATA_BUS]    ls_mst_hrdata_i       
);

    //连接ifu和if_ahb_interface
    wire                if_ce_o         ;
    wire    [`REG_BUS]  if_pc_o         ;

    //连接if_id和idu的信号
    wire    [`REG_BUS]  id_pc_i         ;
    wire    [31:0]      id_inst_i       ;
    
    //连接idu和id_ex的信号(pc_o also to excp)
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

    //连接idu和ifu的地址跳转信号(id_jump_req_o also to ctrl)
    wire                    id_jump_req_o   ;
    wire    [`REG_BUS]      id_jump_pc_o    ;

   //连接idu和csr_regfile的信号
    wire    [`REG_BUS]      id_csr_rdata_i  ;
    wire    [`CSR_ADDR_BUS] id_csr_raddr_o  ;
    wire                    id_csr_re_o     ;

    //连接idu和excp的信号
    wire    [`DEC_SYS_BUS]  id_dec_sys_bus_o    ;

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
    wire                ex_stallreq_o       ;

    //连接exu和excp的信号    
    wire                ex_mul_div_cancel_i ;

    //连接exu和mul的信号(mul_start_o also to excp)
    wire                ex_mul_start_o  ;
    wire                ex_mul_cancel_o ;
    wire                ex_mul_signed_o ;
    wire    [`REG_BUS]  ex_mul_op1_o    ;
    wire    [`REG_BUS]  ex_mul_op2_o    ;    
    wire                ex_mul_stop_i   ; 
    wire    [`REG_BUS]  ex_mul_res_l_i  ;
    wire    [`REG_BUS]  ex_mul_res_h_i  ;       

    //连接exu和div的信号(div_start_o also to excp)    
    wire                ex_div_start_o      ;
    wire                ex_div_cancel_o     ;
    wire                ex_div_op1_signed_o ;
    wire                ex_div_op2_signed_o ;        
    wire    [`REG_BUS]  ex_div_op1_o        ;
    wire    [`REG_BUS]  ex_div_op2_o        ;    
    wire                ex_div_stop_i       ;
    wire    [`REG_BUS]  ex_div_res_i        ;          
    wire    [`REG_BUS]  ex_div_rem_i        ;

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

    //连接lsu和ls_ahb_interface的信号
    wire    [`MEM_DATA_BUS] ls_mem_rdata_i  ;
    wire                    ls_mem_re_o     ;             ;
    wire    [`MEM_DATA_BUS] ls_mem_wdata_o  ;
    wire                    ls_mem_we_o     ;
    wire    [`MEM_ADDR_BUS] ls_mem_addr_o   ;  

    //连接ls_wb和wb的信号
    wire                    wb_rd_we_i      ;
    wire    [`REG_BUS]      wb_rd_data_i    ;
    wire    [`REG_ADDR_BUS] wb_rd_addr_i    ; 

    //连接ctrl和if_ahb_interface, ifu, if_id, id_ex, ex_ls, ls_wb的停顿信号
    wire    [5:0]           ctrl_stall_o    ;

    //连接ctrl和if_ahb_interface, if_id, id_ex, ex_ls, ls_ahb_interface, ls_wb的冲刷信号
    wire    [4:0]           ctrl_flush_o    ;

    //连接excp和csr_regs信号
    wire    [`REG_BUS]      excp_csr_mtvec_i    ;
    wire    [`REG_BUS]      excp_csr_mepc_i     ;
    wire    [`REG_BUS]      excp_csr_mstatus_i  ;            

    wire                    excp_csr_we_o       ;
    wire    [`REG_BUS]      excp_csr_wdata_o    ; 
    wire    [`CSR_ADDR_BUS] excp_csr_waddr_o    ;

    //连接excp和ctrl信号
    wire                    excp_stallreq_o     ;
    wire    [2:0]           excp_flushreq_o     ;

    //连接excp和ifu地址跳转信号(excp_jump_req_o also to ctrl)
    wire                    excp_jump_req_o   ;
    wire    [`REG_BUS]      excp_jump_pc_o    ;

    //连接if_ahb_interface和if_id的信号
    wire    [`REG_BUS]  if_ahb_pc_o         ;
    wire    [31:0]      if_ahb_inst_o       ;

    //连接if_ahb_interface和ctrl的信号
    wire                if_ahb_stallreq_o   ;

    //连接ls_ahb_interface和ctrl的信号
    wire                ls_ahb_stallreq_o   ;

    ifu u_ifu(
        .clk(clk),
        .rst_n(rst_n),

        .ce_o(if_ce_o),
        .pc_o(if_pc_o),

        .stall_i(ctrl_stall_o),

        .jump_pc_i(id_jump_pc_o),
        .jump_req_i(id_jump_req_o),

        .excp_jump_pc_i(excp_jump_pc_o),
        .excp_jump_req_i(excp_jump_req_o)
    );

    if_id u_if_id(
        .clk(clk),
        .rst_n(rst_n),

        .pc_i(if_ahb_pc_o),
        .inst_i(if_ahb_inst_o),

        .pc_o(id_pc_i),
        .inst_o(id_inst_i),

        .stall_i(ctrl_stall_o),
        .flush_i(ctrl_flush_o)
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
        .csr_re_o(id_csr_re_o),

        .dec_sys_bus_o(id_dec_sys_bus_o)
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

        .stall_i(ctrl_stall_o),
        .flush_i(ctrl_flush_o)
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

        .stallreq_o(ex_stallreq_o),
        
        .mul_div_cancel_i(ex_mul_div_cancel_i),

        .mul_start_o(ex_mul_start_o),
        .mul_cancel_o(ex_mul_cancel_o),
        .mul_signed_o(ex_mul_signed_o),
        .mul_op1_o(ex_mul_op1_o),
        .mul_op2_o(ex_mul_op2_o),
        .mul_stop_i(ex_mul_stop_i),
        .mul_res_l_i(ex_mul_res_l_i),
        .mul_res_h_i(ex_mul_res_h_i),

        .div_start_o(ex_div_start_o),
        .div_cancel_o(ex_div_cancel_o),
        .div_op1_signed_o(ex_div_op1_signed_o),
        .div_op2_signed_o(ex_div_op2_signed_o),
        .div_op1_o(ex_div_op1_o),
        .div_op2_o(ex_div_op2_o),
        .div_stop_i(ex_div_stop_i),
        .div_res_i(ex_div_res_i),
        .div_rem_i(ex_div_rem_i)
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
        .flush_i(ctrl_flush_o),

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
        .mem_wdata_o(ls_mem_wdata_o),
        .mem_we_o(ls_mem_we_o),
        .mem_addr_o(ls_mem_addr_o)
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

        .stall_i(ctrl_stall_o),
        .flush_i(ctrl_flush_o)
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
        .id_jump_req_i(id_jump_req_o),

        .ex_stallreq_i(ex_stallreq_o),
        .stall_o(ctrl_stall_o),

        .excp_stallreq_i(excp_stallreq_o),
        .excp_flushreq_i(excp_flushreq_o),
        .excp_jump_req_i(excp_jump_req_o),

        .flush_o(ctrl_flush_o),

        .if_ahb_stallreq_i(if_ahb_stallreq_o),

        .ls_ahb_stallreq_i(ls_ahb_stallreq_o)//ls_ahb_stallreq_o        
    );

    csr_regfile u_csr_regfile(
        .clk(clk),
        .rst_n(rst_n),

        .rdata_o(id_csr_rdata_i),
        .raddr_i(id_csr_raddr_o),
        .re_i(id_csr_re_o),

        .wdata_i(wb_csr_wdata_i),
        .waddr_i(wb_csr_waddr_i),
        .we_i(wb_csr_we_i),

        .excp_wdata_i(excp_csr_wdata_o),
        .excp_waddr_i(excp_csr_waddr_o),
        .excp_we_i(excp_csr_we_o),

        .mtvec_o(excp_csr_mtvec_i),
        .mepc_o(excp_csr_mepc_i),
        .mstatus_o(excp_csr_mstatus_i)
    );

    excp u_excp(
        .clk(clk),
        .rst_n(rst_n),

        .timer_irq_i(timer_irq_i),

        .dec_sys_bus_i(id_dec_sys_bus_o),
        .pc_i(id_pc_o),

        .csr_mtvec_i(excp_csr_mtvec_i),
        .csr_mepc_i(excp_csr_mepc_i),
        .csr_mstatus_i(excp_csr_mstatus_i),

        .csr_we_o(excp_csr_we_o),
        .csr_wdata_o(excp_csr_wdata_o),
        .csr_waddr_o(excp_csr_waddr_o),

        .stallreq_o(excp_stallreq_o),
        .flushreq_o(excp_flushreq_o),

        .jump_req_o(excp_jump_req_o),
        .jump_pc_o(excp_jump_pc_o),

        .mul_start_i(ex_mul_start_o),
        .div_start_i(ex_div_start_o),
        .mul_div_cancel_o(ex_mul_div_cancel_i)
    );

    mul u_mul(
        .clk(clk),
        .rst_n(rst_n),
        .mul_start_i(ex_mul_start_o),
        .mul_cancel_i(ex_mul_cancel_o),
        .mul_signed_i(ex_mul_signed_o),
        .mul_op1_i(ex_mul_op1_o),
        .mul_op2_i(ex_mul_op2_o),
        .mul_stop_o(ex_mul_stop_i),
        .mul_res_l_o(ex_mul_res_l_i),
        .mul_res_h_o(ex_mul_res_h_i)
    );

    div u_div(
        .clk(clk),
        .rst_n(rst_n),
        .div_start_i(ex_div_start_o),
        .div_cancel_i(ex_div_cancel_o),
        .div_op1_signed_i(ex_div_op1_signed_o),
        .div_op2_signed_i(ex_div_op2_signed_o),
        .div_op1_i(ex_div_op1_o),
        .div_op2_i(ex_div_op2_o),
        .div_stop_o(ex_div_stop_i),
        .div_res_o(ex_div_res_i),
        .div_rem_o(ex_div_rem_i)
    );

    if_ahb_interface u_if_ahb_interface(
        .clk(clk),
        .rst_n(rst_n),

        .ce_i(if_ce_o),
        .pc_i(if_pc_o),

        .pc_o(if_ahb_pc_o),
        .inst_o(if_ahb_inst_o),

        .stall_i(ctrl_stall_o),
        .flush_i(ctrl_flush_o),
        .stallreq_o(if_ahb_stallreq_o),

        .mst_hsel_o(if_mst_hsel_o),
        .mst_htrans_o(if_mst_htrans_o),
        .mst_haddr_o(if_mst_haddr_o),
        .mst_hwdata_o(if_mst_hwdata_o),
        .mst_hwrite_o(if_mst_hwrite_o),
        .mst_hsize_o(if_mst_hsize_o),
        .mst_hburst_o(if_mst_hburst_o),
        .mst_hprot_o(if_mst_hprot_o),
        .mst_hmastlock_o(if_mst_hmastlock_o),
        .mst_priority_o(if_mst_priority_o),

        .mst_hready_i(if_mst_hready_i),
        .mst_hresp_i(if_mst_hresp_i),
        .mst_hrdata_i(if_mst_hrdata_i)
    );

    ls_ahb_interface u_ls_ahb_interface(
        .clk(clk),
        .rst_n(rst_n),

        .rdata_o(ls_mem_rdata_i),
        .re_i(ls_mem_re_o),
        .wdata_i(ls_mem_wdata_o),
        .we_i(ls_mem_we_o),
        .addr_i(ls_mem_addr_o),

        .stall_i(ctrl_stall_o),
        .stallreq_o(ls_ahb_stallreq_o),

        .mst_hsel_o(ls_mst_hsel_o),
        .mst_htrans_o(ls_mst_htrans_o),
        .mst_haddr_o(ls_mst_haddr_o),
        .mst_hwdata_o(ls_mst_hwdata_o),
        .mst_hwrite_o(ls_mst_hwrite_o),
        .mst_hsize_o(ls_mst_hsize_o),
        .mst_hburst_o(ls_mst_hburst_o),
        .mst_hprot_o(ls_mst_hprot_o),
        .mst_hmastlock_o(ls_mst_hmastlock_o),
        .mst_priority_o(ls_mst_priority_o),

        .mst_hready_i(ls_mst_hready_i),
        .mst_hresp_i(ls_mst_hresp_i),
        .mst_hrdata_i(ls_mst_hrdata_i)        
    );

endmodule