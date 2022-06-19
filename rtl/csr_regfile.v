`include "defines.v"

module csr_regfile (
    input   clk     ,
    input   rst_n   ,

    output  wire    [`REG_BUS]      rdata_o     ,
    input   wire    [`CSR_ADDR_BUS] raddr_i     ,
    input   wire                    re_i        ,

    input   wire    [`REG_BUS]      wdata_i     ,
    input   wire    [`CSR_ADDR_BUS] waddr_i     ,
    input   wire                    we_i        ,

    //from excp
    input   wire    [`REG_BUS]      excp_wdata_i    ,
    input   wire    [`CSR_ADDR_BUS] excp_waddr_i    ,
    input   wire                    excp_we_i       ,

    output  wire    [`REG_BUS]      mtvec_o         ,
    output  wire    [`REG_BUS]      mepc_o          ,
    output  wire    [`REG_BUS]      mstatus_o       
);

    reg [`DOUBLE_REG_BUS]   cycle;
    reg [`REG_BUS]          mtvec;
    reg [`REG_BUS]          mcause;
    reg [`REG_BUS]          mepc;
    reg [`REG_BUS]          mie;
    reg [`REG_BUS]          mip;
    reg [`REG_BUS]          mstatus;
    reg [`REG_BUS]          mscratch;

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle <= `DOUBLE_REG_BUS_WIDTH'h0;
        end else begin
            cycle <= cycle + 1'b1;
        end
    end    


    //异常发生时写入和正常写回不会冲突 ecall-csr
    always @ (posedge clk) begin
        if (excp_we_i) begin
            case (excp_waddr_i)
                `CSR_MTVEC: begin
                    mtvec <= excp_wdata_i;
                end
                `CSR_MCAUSE: begin
                    mcause <= excp_wdata_i;
                end
                `CSR_MEPC: begin
                    mepc <= excp_wdata_i;
                end
                `CSR_MIE: begin
                    mie <= excp_wdata_i;
                end
                `CSR_MIP: begin
                    mip <= excp_wdata_i;
                end
                `CSR_MSTATUS: begin
                    mstatus <= excp_wdata_i;
                end
                `CSR_MSCRATCH: begin
                    mscratch <= excp_wdata_i;
                end
                default: begin

                end
            endcase
        end else if (we_i) begin
            case (waddr_i)
                `CSR_MTVEC: begin
                    mtvec <= wdata_i;
                end
                `CSR_MCAUSE: begin
                    mcause <= wdata_i;
                end
                `CSR_MEPC: begin
                    mepc <= wdata_i;
                end
                `CSR_MIE: begin
                    mie <= wdata_i;
                end
                `CSR_MIP: begin
                    mip <= wdata_i;
                end
                `CSR_MSTATUS: begin
                    mstatus <= wdata_i;
                end
                `CSR_MSCRATCH: begin
                    mscratch <= wdata_i;
                end
                default: begin

                end
            endcase
        end
    end


    reg [`REG_BUS]  rdata_r;
    always @ (*) begin
        if (re_i) begin
            if ((waddr_i == raddr_i) && we_i) begin
                rdata_r = wdata_i;
            end else begin
                case (raddr_i)
                    `CSR_CYCLE: begin
                        rdata_r = cycle[31:0];
                    end
                    `CSR_CYCLEH: begin
                        rdata_r = cycle[63:32];
                    end
                    `CSR_MTVEC: begin
                        rdata_r = mtvec;
                    end
                    `CSR_MCAUSE: begin
                        rdata_r = mcause;
                    end
                    `CSR_MEPC: begin
                        rdata_r = mepc;
                    end
                    `CSR_MIE: begin
                        rdata_r = mie;
                    end
                    `CSR_MIP: begin
                        rdata_r = mip;
                    end
                    `CSR_MSTATUS: begin
                        rdata_r = mstatus;
                    end
                    `CSR_MSCRATCH: begin
                        rdata_r = mscratch;
                    end
                    default: begin
                        rdata_r = `REG_BUS_WIDTH'h0;
                    end
                endcase
            end
        end else begin
            rdata_r = `REG_BUS_WIDTH'h0;
        end
    end

    assign rdata_o = rdata_r;
    
    assign mtvec_o = mtvec;
    assign mepc_o = mepc;
    assign mstatus_o = mstatus;    


endmodule  //csr_regs