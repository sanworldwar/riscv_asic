`include "defines.v"

module if_id (
    input   wire            clk      ,
    input   wire            rst_n    ,
    
    input   wire    [`REG_BUS]  pc_i     ,
    input   wire    [31:0]      inst_i   ,

    output  wire    [`REG_BUS]  pc_o     ,
    output  wire    [31:0]      inst_o   ,

    //from ctrl
    input   wire    [5:0]       stall_i  ,
    input   wire    [3:0]       flush_i  
);

    wire    clr = (stall_i[1] & !stall_i[2]) | flush_i[0]; //取指暂停，而译码继续/冲刷取指
    wire    load = !stall_i[1];

    wire    [`REG_BUS]  pc_r;
    dff_lrc #(`REG_BUS_WIDTH) dff_pc(clk, rst_n, clr, load, pc_i, pc_r);
    assign pc_o = pc_r;
    
    wire    [31:0]  inst_r;
    dff_lrc #(32) dff_inst(clk, rst_n, clr, load, inst_i, inst_r);
    assign inst_o = inst_r;

endmodule