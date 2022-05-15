`include "defines.v"

module regfile (
    input   wire                    clk         ,
    input   wire                    rst_n       ,

    input   wire    [`REG_ADDR_BUS] raddr1_i    ,
    output  wire    [`REG_BUS]      rdata1_o    ,
    input   wire    [`REG_ADDR_BUS] raddr2_i    ,
    output  wire    [`REG_BUS]      rdata2_o    ,

    input   wire    [`REG_ADDR_BUS] waddr_i     ,
    input   wire                    we_i        ,
    input   wire    [`REG_BUS]      wdata_i     
);

    reg [`REG_BUS_WIDTH-1:0]  gpr_regs [0:`REG_NUM-1]  ;

    always @(posedge clk) begin
        if (we_i) begin
            gpr_regs[waddr_i] <= wdata_i;
        end
    end
    
    assign rdata1_o = (raddr1_i == `REG_ADDR_BUS_WIDTH'h0) ? `ZERO_WORD : 
                    ((raddr1_i == waddr_i) ? wdata_i : gpr_regs[raddr1_i]);    
    assign rdata2_o = (raddr2_i == `REG_ADDR_BUS_WIDTH'h0) ? `ZERO_WORD : 
                    ((raddr2_i == waddr_i) ? wdata_i : gpr_regs[raddr2_i]);    
   
   

endmodule