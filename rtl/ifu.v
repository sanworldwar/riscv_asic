
`include "defines.v"

module ifu (
    input   wire    clk         ,
    input   wire    rst_n       ,

    //to idu
    output  wire                ce_o        ,    
    output  wire    [`REG_BUS]  pc_o        ,

    //from ctrl
    input   wire    [5:0]       stall_i     ,

    //from idu
    input   wire                jump_req_i  ,
    input   wire    [`REG_BUS]  jump_pc_i   ,

    //from excp
    input   wire                excp_jump_req_i  ,
    input   wire    [`REG_BUS]  excp_jump_pc_i   
);

    reg ce_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ce_r <= 1'b0;
        end else begin
            ce_r <= 1'b1;
        end
    end

    assign ce_o = ce_r;

    reg [`REG_BUS]  pc_r    ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_r <= `CPU_RESET_ADDR;
        end else if (excp_jump_req_i) begin
            pc_r <= excp_jump_pc_i + `REG_BUS_WIDTH'h4;       
        end else if (jump_req_i) begin
            pc_r <= jump_pc_i + `REG_BUS_WIDTH'h4;
        end else if (!stall_i[0]) begin
            pc_r <= pc_r + `REG_BUS_WIDTH'h4;
        end 
    end

    assign  pc_o = excp_jump_req_i ? excp_jump_pc_i : 
                   jump_req_i      ? jump_pc_i      : pc_r;  //branch译码时发生中断，中断优先


endmodule