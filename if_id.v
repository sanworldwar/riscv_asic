`include "defines.v"

module if_id (
    input   wire            clk      ,
    input   wire            rst_n    ,

    input   wire    [31:0]  pc_i     ,
    input   wire    [31:0]  inst_i   ,

    output  wire    [31:0]  pc_o     ,
    output  wire    [31:0]  inst_o   
);

    reg [31:0]  pc_r     ;
    reg [31:0]  inst_r   ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_r <= `CPU_RESET_ADDR;
        end else begin
            pc_r <= pc_i;
        end
    end

    assign  pc_o = pc_r;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            inst_r <= `ZERO_WORD;
        end else begin
            inst_r <= inst_i;
        end
    end

    assign  inst_o = inst_r;

endmodule