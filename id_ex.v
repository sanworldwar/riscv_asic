`include "defines.v"

module id_ex (
    input   wire    clk     ,
    input   wire    rst_n   ,

    //from id
    input   wire    [31:0]          pc_i            ,
    input   wire    [`REG_BUS]      rs1_data_i      ,
    input   wire    [`REG_BUS]      rs2_data_i      ,
    input   wire    [`REG_ADDR_BUS] rd_addr_i       ,
    input   wire                    rd_we_i         ,
    input   wire    [`DEC_INFO_BUS] dec_info_bus_i  ,

    //to ex
    output  wire    [31:0]          pc_o            ,
    output  wire    [`REG_BUS]      rs1_data_o      ,
    output  wire    [`REG_BUS]      rs2_data_o      ,
    output  wire    [`REG_ADDR_BUS] rd_addr_o       ,
    output  wire                    rd_we_o         ,
    output  wire    [`DEC_INFO_BUS] dec_info_bus_o     

);

    wire    load = |dec_info_bus_i;

    wire    [31:0]  pc_r;
    dff_lr #(32) dff_pc(clk, rst_n, load, pc_i, pc_r);
    assign pc_o = pc_r;

    wire    [`REG_BUS]  rs1_data_r;
    dff_lr #(`REG_BUS_WIDTH) dff_rs1_data(clk, rst_n, load, rs1_data_i, rs1_data_r);
    assign rs1_data_o = rs1_data_r;

    wire    [`REG_BUS]  rs2_data_r;
    dff_lr #(`REG_BUS_WIDTH) dff_rs2_data(clk, rst_n, load, rs2_data_i, rs2_data_r);
    assign rs2_data_o = rs2_data_r;

    wire    [`REG_ADDR_BUS]  rd_addr_r;
    dff_lr #(`REG_ADDR_BUS_WIDTH) dff_rd_addr(clk, rst_n, load, rd_addr_i, rd_addr_r);
    assign rd_addr_o = rd_addr_r;

    wire    rd_we_r;
    dff_lr #(1) dff_rd_we(clk, rst_n, load, rd_we_i, rd_we_r);
    assign rd_we_o = rd_we_r;     

    wire    [`DEC_INFO_BUS] dec_info_bus_r;
    dff_lr #(`DEC_INFO_BUS_WIDTH) dff_dec_info_bus(clk, rst_n, load, dec_info_bus_i, dec_info_bus_r);
    assign dec_info_bus_o = dec_info_bus_r;   

endmodule