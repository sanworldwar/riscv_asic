`include "defines.v"

module ls_wb (
    input   wire    clk     ,
    input   wire    rst_n   ,

    //from lsu
    input   wire                    rd_we_i     ,
    input   wire    [`REG_BUS]      rd_data_i   ,
    input   wire    [`REG_ADDR_BUS] rd_addr_i   ,

    //to regfile
    output  wire                    rd_we_o     ,
    output  wire    [`REG_BUS]      rd_data_o   ,
    output  wire    [`REG_ADDR_BUS] rd_addr_o       
       
);
    
    wire    load = rd_we_i;

    wire    rd_we_r;
    dff_lr #(1) dff_rd_we(clk, rst_n, load, rd_we_i, rd_we_r);
    assign rd_we_o = rd_we_r;

    wire    [`REG_BUS]  rd_data_r;
    dff_lr #(`REG_BUS_WIDTH) dff_rd_data(clk, rst_n, load, rd_data_i, rd_data_r);
    assign rd_data_o = rd_data_r;

    wire    [`REG_ADDR_BUS] rd_addr_r;
    dff_lr #(`REG_ADDR_BUS_WIDTH) dff_rd_addr(clk, rst_n, load, rd_addr_i,rd_addr_r);
    assign rd_addr_o = rd_addr_r;

endmodule

