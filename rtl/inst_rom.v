`include "defines.v"

module inst_rom (
    input   wire    [31:0]  pc_i        ,
    output  wire    [31:0]  inst_o          
);

    reg [31:0]  inst_mem    [0:`ROM_DEPTH-1];

    assign  inst_o = inst_mem[pc_i[31:2]];
    
endmodule