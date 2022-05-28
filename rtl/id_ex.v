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

    //to ex
    output  wire    [`REG_BUS]      pc_o            ,
    output  wire    [`REG_BUS]      op1_data_o      ,
    output  wire    [`REG_BUS]      op2_data_o      ,
    output  wire    [`REG_BUS]      imm_data_o      ,
    output  wire    [`REG_ADDR_BUS] rd_addr_o       ,
    output  wire                    rd_we_o         ,
    output  wire    [`DEC_INFO_BUS] dec_info_bus_o  ,

    //to ctrl
    input   wire    [5:0]           stall_i              
);

    wire    clr = stall_i[2] & !stall_i[3]; //译码暂停，而执行继续
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

endmodule