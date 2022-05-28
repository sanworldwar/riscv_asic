
`include "defines.v"

module ifu (
    input   wire    clk         ,
    input   wire    rst_n       ,

    //to id
    output  wire    [`REG_BUS]  pc_o        ,
    output  wire    [31:0]      inst_o      ,

    //from inst_rom
    input   wire    [31:0]      inst_i      ,

    //from ctrl
    input   wire    [5:0]       stall_i     ,

    //from idu
    input   wire                jump_req_i  ,
    input   wire    [`REG_BUS]  jump_pc_i
);

    reg [`REG_BUS]  pc_r    ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_r <= `CPU_RESET_ADDR;
        end else if (jump_req_i) begin
            pc_r <= jump_pc_i + `REG_BUS_WIDTH'h4;
        end else if (!stall_i[0]) begin
            pc_r <= pc_r + `REG_BUS_WIDTH'h4;
        end 
    end

    assign  pc_o = jump_req_i ? jump_pc_i : pc_r;

    assign  inst_o = inst_i;
    
endmodule