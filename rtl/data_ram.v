`include "defines.v"

module data_ram (
    input   wire    clk,

    output  wire    [`MEM_DATA_BUS] rdata_o     ,
    input   wire                    re_i        ,
    input   wire    [`MEM_ADDR_BUS] raddr_i     ,
    input   wire    [`MEM_DATA_BUS] wdata_i     ,
    input   wire                    we_i        ,
    input   wire    [`MEM_ADDR_BUS] waddr_i   
);
    reg [`MEM_DATA_BUS] data_mem[0:`RAM_DEPTH-1];

    always @(posedge clk) begin
        if (we_i) begin
            data_mem[waddr_i] <= wdata_i;
        end
    end

    assign rdata_o = re_i ? data_mem[raddr_i] : rdata_o;
    
endmodule