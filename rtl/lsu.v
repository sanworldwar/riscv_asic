`include "defines.v"

module lsu (
    //from exu
    input   wire                    rd_we_i     ,
    input   wire    [`REG_BUS]      rd_data_i   ,
    input   wire    [`REG_ADDR_BUS] rd_addr_i   ,

    //to wb, to idu
    output  wire                    rd_we_o     ,
    output  wire    [`REG_BUS]      rd_data_o   ,
    output  wire    [`REG_ADDR_BUS] rd_addr_o  
);
    
    assign rd_we_o = rd_we_i;
    assign rd_data_o = rd_data_i;
    assign rd_addr_o = rd_addr_i;

endmodule