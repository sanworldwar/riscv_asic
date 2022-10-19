`include "defines.v"

module id_ex (
    input   wire    clk     ,
    input   wire    rst_n   ,

    //from id
    input   wire    [`REG_BUS]      pc_i            ,
    input   wire    [`REG_BUS]      op1_data_i      ,
    input   wire    [`REG_BUS]      op2_data_i      ,
    input   wire    [`REG_BUS]      imm_data_i      ,
    input   wire    [`REG_ADDR_BUS] rd_addr_i       ,
    input   wire                    rd_we_i         ,
    input   wire    [`DEC_INFO_BUS] dec_info_bus_i  ,
    input   wire    [`CSR_ADDR_BUS] csr_waddr_i     ,
    input   wire                    csr_we_i        ,

    //to ex
    output  wire    [`REG_BUS]      pc_o            ,
    output  wire    [`REG_BUS]      op1_data_o      ,
    output  wire    [`REG_BUS]      op2_data_o      ,
    output  wire    [`REG_BUS]      imm_data_o      ,
    output  wire    [`REG_ADDR_BUS] rd_addr_o       ,
    output  wire                    rd_we_o         ,
    output  wire    [`DEC_INFO_BUS] dec_info_bus_o  ,
    output  wire    [`CSR_ADDR_BUS] csr_waddr_o     ,
    output  wire                    csr_we_o        ,

    //from ctrl
    input   wire    [5:0]           stall_i         ,
    input   wire    [5:0]           flush_i              
);

    wire    clr = (stall_i[2] && !stall_i[3]) || flush_i[2]; //译码暂停，而执行继续/冲刷译码
    wire    load = !stall_i[2];


    wire    [`REG_BUS]  pc_r;
    dff_lrc #(`REG_BUS_WIDTH) dff_pc(clk, rst_n, clr, load, pc_i, pc_r);
    assign pc_o = pc_r;

    wire    [`REG_BUS]  op1_data_r;
    dff_lrc #(`REG_BUS_WIDTH) dff_op1_data(clk, rst_n, clr, load, op1_data_i, op1_data_r);
    assign op1_data_o = op1_data_r;

    wire    [`REG_BUS]  op2_data_r;
    dff_lrc #(`REG_BUS_WIDTH) dff_op2_data(clk, rst_n, clr, load, op2_data_i, op2_data_r);
    assign op2_data_o = op2_data_r;

    wire    [`REG_BUS]  imm_data_r;
    dff_lrc #(`REG_BUS_WIDTH) dff_imm_data(clk, rst_n, clr, load, imm_data_i, imm_data_r);
    assign imm_data_o = imm_data_r;

    wire    [`REG_ADDR_BUS]  rd_addr_r;
    dff_lrc #(`REG_ADDR_BUS_WIDTH) dff_rd_addr(clk, rst_n, clr, load, rd_addr_i, rd_addr_r);
    assign rd_addr_o = rd_addr_r;

    wire    rd_we_r;
    dff_lrc #(1) dff_rd_we(clk, rst_n, clr, load, rd_we_i, rd_we_r);
    assign rd_we_o = rd_we_r;     

    wire    [`DEC_INFO_BUS] dec_info_bus_r;
    dff_lrc #(`DEC_INFO_BUS_WIDTH) dff_dec_info_bus(clk, rst_n, clr, load, dec_info_bus_i, dec_info_bus_r);
    assign dec_info_bus_o = dec_info_bus_r;   

    wire    [`CSR_ADDR_BUS] csr_waddr_r;
    dff_lrc #(`CSR_ADDR_BUS_WIDTH) dff_csr_waddr(clk, rst_n, clr, load, csr_waddr_i, csr_waddr_r);
    assign csr_waddr_o = csr_waddr_r; 

    wire    csr_we_r;
    dff_lrc #(1) dff_csr_we(clk, rst_n, clr, load, csr_we_i, csr_we_r);
    assign csr_we_o = csr_we_r; 

endmodule