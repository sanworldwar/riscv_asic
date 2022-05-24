`include "defines.v"

module openriscv (
    input   wire    clk                 ,
    input   wire    rst_n               ,

    input   wire    [31:0]  rom_inst_i  ,
    output  wire    [31:0]  rom_pc_o    
);

    //连接ifu和if_id的信号
    wire    [31:0]  if_pc_o     ;
    wire    [31:0]  if_inst_o   ;

    //连接ifu和rom的信号
    assign rom_pc_o = if_pc_o;

    //连接if_id和idu的信号
    wire    [31:0]  id_pc_i     ;
    wire    [31:0]  id_inst_i   ;
    
    //连接idu和id_ex的信号
    wire    [31:0]          id_pc_o             ;
    wire    [`REG_BUS]      id_op1_data_o       ;
    wire    [`REG_BUS]      id_op2_data_o       ;
    wire    [`REG_ADDR_BUS] id_rd_addr_o        ;
    wire                    id_rd_we_o          ;
    wire    [`DEC_INFO_BUS] id_dec_info_bus_o   ;

    //连接idu和regfile的信号
    wire    [`REG_ADDR_BUS] id_rs1_addr_o   ;
    wire                    id_rs1_re_o     ;
    wire    [`REG_BUS]      id_rs1_data_i   ;
    wire    [`REG_ADDR_BUS] id_rs2_addr_o   ;
    wire                    id_rs2_re_o     ;
    wire    [`REG_BUS]      id_rs2_data_i   ;

    //连接id_ex和exu的信号
    wire    [31:0]          ex_pc_i             ;
    wire    [`REG_BUS]      ex_op1_data_i       ;
    wire    [`REG_BUS]      ex_op2_data_i       ;
    wire    [`REG_ADDR_BUS] ex_rd_addr_i        ;
    wire                    ex_rd_we_i          ;
    wire    [`DEC_INFO_BUS] ex_dec_info_bus_i   ;

    //连接exu和ex_ls和idu的信号
    wire                    ex_rd_we_o      ;
    wire    [`REG_BUS]      ex_rd_data_o    ;
    wire    [`REG_ADDR_BUS] ex_rd_addr_o    ;

    //连接ex_ls和lsu的信号
    wire                    ls_rd_we_i     ;
    wire    [`REG_BUS]      ls_rd_data_i   ;
    wire    [`REG_ADDR_BUS] ls_rd_addr_i   ;

    //连接lsu和ls_wb和idu的信号
    wire                    ls_rd_we_o     ;
    wire    [`REG_BUS]      ls_rd_data_o   ;
    wire    [`REG_ADDR_BUS] ls_rd_addr_o   ;    

    //连接ls_wb和wb的信号
    wire                    wb_rd_we_i      ;
    wire    [`REG_BUS]      wb_rd_data_i    ;
    wire    [`REG_ADDR_BUS] wb_rd_addr_i    ;  

    //ifu例化
    ifu u_ifu(
        .clk(clk),
        .rst_n(rst_n),

        .pc_o(if_pc_o),
        .inst_o(if_inst_o),

        .inst_i(rom_inst_i)
    );

    //if_id
    if_id u_if_id(
        .clk(clk),
        .rst_n(rst_n),

        .pc_i(if_pc_o),
        .inst_i(if_inst_o),

        .pc_o(id_pc_i),
        .inst_o(id_inst_i)
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
        .rd_addr_o(id_rd_addr_o),
        .rd_we_o(id_rd_we_o),
        .dec_info_bus_o(id_dec_info_bus_o),


        .ex_rd_we_i(ex_rd_we_o),
        .ex_rd_addr_i(ex_rd_addr_o),
        .ex_rd_data_i(ex_rd_data_o),

        .ls_rd_we_i(ls_rd_we_o),
        .ls_rd_addr_i(ls_rd_addr_o),
        .ls_rd_data_i(ls_rd_data_o)
    );

    id_ex u_id_ex(
        .clk(clk),
        .rst_n(rst_n),

        .pc_i(id_pc_o),
        .op1_data_i(id_op1_data_o),
        .op2_data_i(id_op2_data_o),
        .rd_addr_i(id_rd_addr_o),
        .rd_we_i(id_rd_we_o),
        .dec_info_bus_i(id_dec_info_bus_o),

        .pc_o(ex_pc_i),
        .op1_data_o(ex_op1_data_i),
        .op2_data_o(ex_op2_data_i),
        .rd_addr_o(ex_rd_addr_i),
        .rd_we_o(ex_rd_we_i),
        .dec_info_bus_o(ex_dec_info_bus_i)
    );

    exu u_exu(
        .pc_i(ex_pc_i),
        .op1_data_i(ex_op1_data_i),
        .op2_data_i(ex_op2_data_i),
        .rd_addr_i(ex_rd_addr_i),
        .rd_we_i(ex_rd_we_i),
        .dec_info_bus_i(ex_dec_info_bus_i),

        .rd_we_o(ex_rd_we_o),
        .rd_data_o(ex_rd_data_o),
        .rd_addr_o(ex_rd_addr_o)
    );

    ex_ls u_ex_ls(
        .clk(clk),
        .rst_n(rst_n),

        .rd_we_i(ex_rd_we_o),
        .rd_data_i(ex_rd_data_o),
        .rd_addr_i(ex_rd_addr_o),

        .rd_we_o(ls_rd_we_i),
        .rd_data_o(ls_rd_data_i),
        .rd_addr_o(ls_rd_addr_i)                        
    );

    lsu u_lsu(
        .rd_we_i(ls_rd_we_i),
        .rd_data_i(ls_rd_data_i),
        .rd_addr_i(ls_rd_addr_i),

        .rd_we_o(ls_rd_we_o),
        .rd_data_o(ls_rd_data_o),
        .rd_addr_o(ls_rd_addr_o)          
    );

    ls_wb u_ls_wb(
        .clk(clk),
        .rst_n(rst_n),

        .rd_we_i(ls_rd_we_o),
        .rd_data_i(ls_rd_data_o),
        .rd_addr_i(ls_rd_addr_o),

        .rd_we_o(wb_rd_we_i),
        .rd_data_o(wb_rd_data_i),
        .rd_addr_o(wb_rd_addr_i)                   
    );

    //regfile
    regfile u_regfile(
        .clk(clk),
        .rst_n(rst_n),

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



endmodule