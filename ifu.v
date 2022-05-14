
`include "defines.v"

module ifu (
    input   wire            clk         ,
    input   wire            rst_n       ,

    output  wire    [31:0]  pc_o        ,
    output  wire    [31:0]  inst_o      ,

    input   wire    [31:0]  inst_i

);

    reg [31:0]  pc_r        ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_r <= `CPU_RESET_ADDR;
        end else begin
            pc_r <= pc_r + 32'h4;
        end
    end

    assign  pc_o = pc_r;

    assign  inst_o = inst_i;
    
endmodule