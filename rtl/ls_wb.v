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
    output  wire    [`REG_ADDR_BUS] rd_addr_o   ,

    //from ctrl
    input   wire    [5:0]           stall_i     ,
    input   wire    [3:0]           flush_i     
);
    
    wire    clr = (stall_i[4] & !stall_i[5]) | flush_i[3]; //访存暂停，而写回继续
    wire    load = !stall_i[4];

    wire    rd_we_r;
    dff_lrc #(1) dff_rd_we(clk, rst_n, clr, load, rd_we_i, rd_we_r);
    assign rd_we_o = rd_we_r;

    wire    [`REG_BUS]  rd_data_r;
    dff_lrc #(`REG_BUS_WIDTH) dff_rd_data(clk, rst_n, clr, load, rd_data_i, rd_data_r);
    assign rd_data_o = rd_data_r;

    wire    [`REG_ADDR_BUS] rd_addr_r;
    dff_lrc #(`REG_ADDR_BUS_WIDTH) dff_rd_addr(clk, rst_n, clr, load, rd_addr_i,rd_addr_r);
    assign rd_addr_o = rd_addr_r;

endmodule

