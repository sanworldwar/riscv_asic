`include "defines.v"

module excp(
    input   wire    clk,
    input   wire    rst_n,

    // from clint
    input   wire                    timer_irq_i     ,

    //from idu
    input   wire    [`DEC_SYS_BUS]  dec_sys_bus_i   ,
    input   wire    [`REG_BUS]      pc_i            ,

    //from csr_regs
    input   wire    [`REG_BUS]      csr_mtvec_i      ,
    input   wire    [`REG_BUS]      csr_mepc_i       ,
    input   wire    [`REG_BUS]      csr_mstatus_i    ,            

    //to csr_regs
    output  wire                    csr_we_o        ,
    output  wire    [`REG_BUS]      csr_wdata_o     ,
    output  wire    [`CSR_ADDR_BUS] csr_waddr_o     ,

    //to ctrl
    output  wire                    stallreq_o      ,
    output  wire    [2:0]           flushreq_o      ,

    //to ifu(excp_jump_req_o also to ctrl)
    output  wire                    jump_req_o      ,
    output  wire    [`REG_BUS]      jump_pc_o       ,

    //from exu
    input   wire                    mul_start_i     ,
    input   wire                    div_start_i     ,
    output  wire                    mul_div_cancel_o 
);

    localparam IDLE = 3'd0;
    localparam MEPC = 3'd1;
    localparam MSTATUS = 3'd2;
    localparam MCAUSE = 3'd3;
    localparam MRET_MSTATUS = 3'd4;

    wire inst_sys_ecall = dec_sys_bus_i[`DEC_SYS_INST_ECALL];
    wire inst_sys_ebreak = dec_sys_bus_i[`DEC_SYS_INST_EBREAK];
    wire inst_sys_mret = dec_sys_bus_i[`DEC_SYS_INST_MRET];

    reg [2:0]  sys_state, sys_nxstate;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sys_state <= IDLE;
        end else begin
            sys_state <= sys_nxstate;
        end
    end

    wire    timer_irq_en = timer_irq_i & csr_mstatus_i[3];

    always @(*) begin
        sys_nxstate = IDLE;
        case (sys_state)
            IDLE: begin
                if (timer_irq_en) begin
                    sys_nxstate = MEPC;
                end else if ((inst_sys_ecall | inst_sys_ebreak) & !(mul_start_i | div_start_i)) begin
                    sys_nxstate = MEPC;
                end else if (inst_sys_mret & !(mul_start_i | div_start_i)) begin
                    sys_nxstate = MRET_MSTATUS;
                end
            end
            MEPC: begin
                sys_nxstate = MSTATUS;
            end
            MSTATUS: begin
                sys_nxstate = MCAUSE;
            end 
            MCAUSE: begin
                
            end
            MRET_MSTATUS: begin

            end 
        endcase
    end

    reg     [`REG_BUS]  cause;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cause <= `CSR_ADDR_BUS_WIDTH'd0;
        end else begin
            if (timer_irq_en) begin
                cause <= `CSR_ADDR_BUS_WIDTH'b1000_0000_0111;
            end else if (inst_sys_ecall) begin
                cause <= `CSR_ADDR_BUS_WIDTH'b0000_0000_1011;
            end else if (inst_sys_ebreak) begin
                cause <= `CSR_ADDR_BUS_WIDTH'b0000_0000_0011;                   
            end
        end
    end

    reg                     csr_we_r        ;
    reg     [`REG_BUS]      csr_wdata_r     ;
    reg     [`CSR_ADDR_BUS] csr_waddr_r     ;
    reg     [`REG_BUS]      csr_wdata_tmp   ;
    reg     [1:0]   excp_type;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            csr_we_r <= 1'b0;
            csr_waddr_r <= `CSR_ADDR_BUS_WIDTH'h0;
            csr_wdata_r <= `REG_BUS_WIDTH'h0;
            csr_wdata_tmp <= `REG_BUS_WIDTH'h0;
            excp_type <= 2'b00;
        end else begin
            case (sys_state)
                IDLE: begin
                    csr_we_r <= 1'b0;
                    csr_waddr_r <= `CSR_ADDR_BUS_WIDTH'h0;
                    csr_wdata_r <= `REG_BUS_WIDTH'h0;
                    if (timer_irq_en) begin                     
                        if (mul_start_i | div_start_i) begin
                            csr_wdata_tmp <= pc_i - `REG_BUS_WIDTH'd4;
                            excp_type <= `EXCP_ASYNC_ASSERT_1;
                        end else begin
                            csr_wdata_tmp <= pc_i;
                            excp_type <= `EXCP_ASYNC_ASSERT_2;
                        end
                                                
                    end else if ((inst_sys_ecall | inst_sys_ebreak) & !(mul_start_i | div_start_i)) begin
                        csr_wdata_tmp <= pc_i+`REG_BUS_WIDTH'h4;  
                        excp_type <= `EXCP_SYNC_ASSERT;                  
                    end else if ((inst_sys_mret) & !(mul_start_i | div_start_i)) begin
                        csr_wdata_tmp <= {csr_mstatus_i[31:8], 1'b1, csr_mstatus_i[6:4], csr_mstatus_i[3], csr_mstatus_i[2:0]};
                        excp_type <= `EXCP_SYNC_ASSERT; 
                    end else begin
                        csr_wdata_tmp <= `REG_BUS_WIDTH'h0;
                        excp_type <= 2'b00;
                    end
                end
                MEPC: begin
                    csr_we_r <= 1'b1;
                    csr_waddr_r <= `CSR_MEPC;
                    csr_wdata_r <= csr_wdata_tmp;
                    csr_wdata_tmp <= {csr_mstatus_i[31:8], csr_mstatus_i[3], csr_mstatus_i[6:4], 1'b0, csr_mstatus_i[2:0]};
                    excp_type <= 2'b00;
                end
                MSTATUS: begin
                    csr_we_r <= 1'b1;
                    csr_waddr_r <= `CSR_MSTATUS;
                    csr_wdata_r <= csr_wdata_tmp;
                    csr_wdata_tmp <= `REG_BUS_WIDTH'h0;   
                    excp_type <= 2'b00;              
                end
                MCAUSE: begin
                    csr_we_r <= 1'b1;
                    csr_waddr_r <= `CSR_MCAUSE;
                    csr_wdata_r <= cause;
                    csr_wdata_tmp <= `REG_BUS_WIDTH'h0;
                    excp_type <= 2'b00;
                end
                MRET_MSTATUS: begin
                    csr_we_r <= 1'b1;
                    csr_waddr_r <= `CSR_MSTATUS;
                    csr_wdata_r <= csr_wdata_tmp;
                    csr_wdata_tmp <= `REG_BUS_WIDTH'h0; 
                    excp_type <= 2'b00;
                end
                default: begin
                    csr_we_r <= 1'b0;
                    csr_waddr_r <= `CSR_ADDR_BUS_WIDTH'h0;
                    csr_wdata_r <= `REG_BUS_WIDTH'h0;
                    csr_wdata_tmp <= `REG_BUS_WIDTH'h0;
                    excp_type <= 2'b00;                    
                end
            endcase
        end
    end

    assign csr_we_o = csr_we_r;
    assign csr_waddr_o = csr_waddr_r;
    assign csr_wdata_o = csr_wdata_r;

    reg                    jump_req_r;
    reg    [`REG_BUS]      jump_pc_r;      

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            jump_req_r <= 1'b0;
            jump_pc_r <= `REG_BUS_WIDTH'h0;
        end else begin
            case (sys_state)
                MCAUSE: begin
                    jump_req_r <= 1'b1;
                    jump_pc_r <= csr_mtvec_i;
                end
                MRET_MSTATUS: begin
                    jump_req_r <= 1'b1;
                    jump_pc_r <= csr_mepc_i;
                end
                default: begin
                    jump_req_r <= 1'b0;
                    jump_pc_r <= `REG_BUS_WIDTH'h0;
                end
            endcase
        end
    end

    assign jump_req_o = jump_req_r;
    assign jump_pc_o = jump_pc_r;

    assign stallreq_o = (sys_state != IDLE) | (sys_nxstate != IDLE);
    assign flushreq_o[0] = (excp_type == `EXCP_SYNC_ASSERT);
    assign flushreq_o[1] = (excp_type == `EXCP_ASYNC_ASSERT_1);
    assign flushreq_o[2] = (excp_type == `EXCP_ASYNC_ASSERT_2);

    assign mul_div_cancel_o = flushreq_o[1];

endmodule