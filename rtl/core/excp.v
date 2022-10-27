`include "defines.v"

module excp(
    input   wire    clk,
    input   wire    rst_n,

    // from clint
    input   wire                    timer_irq_i     ,

    //from idu
    input   wire    [`DEC_SYS_BUS]  dec_sys_bus_i   ,
    input   wire    [`REG_BUS]      pc_i            ,
    input   wire                    id_jump_req_i   ,

    //from csr_regs
    input   wire    [`REG_BUS]      csr_mtvec_i     ,
    input   wire    [`REG_BUS]      csr_mepc_i      ,
    input   wire    [`REG_BUS]      csr_mstatus_i   ,            

    //to csr_regs
    output  wire                    csr_we_o        ,
    output  wire    [`REG_BUS]      csr_wdata_o     ,
    output  wire    [`CSR_ADDR_BUS] csr_waddr_o     ,

    //to ctrl
    output  wire                    stallreq_o      ,
    output  wire    [1:0]           flushreq_o      ,

    //to ifu(excp_jump_req_o also to ctrl)
    output  wire                    jump_req_o      ,
    output  wire    [`REG_BUS]      jump_pc_o       ,

    //from exu
    input   wire                    ex_stallreq_i   ,
    output  wire                    mul_div_cancel_o,

    //from ls_ahb_interface
    input   wire                    ls_ahb_stallreq_i 
);

    localparam M_TIMER = `REG_BUS_WIDTH'h80000007;
    localparam M_ECALL = `REG_BUS_WIDTH'h0000000B;
    localparam BREAK = `REG_BUS_WIDTH'h00000003;

    localparam IDLE = 3'b000;
    localparam MEPC = 3'b001;
    localparam MEPC_EXCP = 3'b010;
    localparam MSTATUS = 3'b011;
    localparam MRET = 3'b100;

    wire inst_sys_ecall = dec_sys_bus_i[`DEC_SYS_INST_ECALL];
    wire inst_sys_ebreak = dec_sys_bus_i[`DEC_SYS_INST_EBREAK];
    wire inst_sys_mret = dec_sys_bus_i[`DEC_SYS_INST_MRET];

    wire pc_zero = pc_i == {`REG_BUS_WIDTH{1'b0}}; //跳转时id_pc为零

    reg [`REG_BUS]  pc_tmp;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_tmp <= {`REG_BUS_WIDTH{1'b0}};
        end else if (id_jump_req_i) begin
            pc_tmp <= pc_i;
        end
    end   

    reg [2:0]  sys_state, sys_nxstate;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
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
                    if (ex_stallreq_i | ls_ahb_stallreq_i) begin
                        sys_nxstate = MEPC;
                    end else begin
                        sys_nxstate = MEPC_EXCP;                        
                    end
                end else if ((inst_sys_ecall | inst_sys_ebreak) & !ex_stallreq_i) begin
                    sys_nxstate = MEPC;
                end else if ((inst_sys_mret) & !ex_stallreq_i) begin
                    sys_nxstate = MRET;
                end
            end
            MEPC: begin
                sys_nxstate = MSTATUS;
            end
            MEPC_EXCP: begin
                sys_nxstate = MEPC;
            end
            MSTATUS: begin
                sys_nxstate = IDLE;
            end
            MRET:begin
                sys_nxstate = IDLE;
            end
        endcase
    end

    reg     [`REG_BUS]  cause;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cause <= `REG_BUS_WIDTH'h0;
        end else begin
            if (timer_irq_en) begin
                cause <= M_TIMER;
            end else if (inst_sys_ecall) begin
                cause <= M_ECALL;
            end else if (inst_sys_ebreak) begin
                cause <= BREAK;                   
            end
        end
    end

    reg                     csr_we_r        ;
    reg     [`REG_BUS]      csr_wdata_r     ;
    reg     [`CSR_ADDR_BUS] csr_waddr_r     ;


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            csr_we_r <= 1'b0;
            csr_waddr_r <= `CSR_ADDR_BUS_WIDTH'h0;
            csr_wdata_r <= `REG_BUS_WIDTH'h0;
        end else begin
            csr_we_r <= 1'b0;
            csr_waddr_r <= `CSR_ADDR_BUS_WIDTH'h0;
            csr_wdata_r <= `REG_BUS_WIDTH'h0;
            case (sys_state)
                IDLE: begin
                    if (timer_irq_en) begin   
                        csr_we_r <= 1'b1;
                        csr_waddr_r <= `CSR_MEPC;
                        if (pc_zero) begin
                            if (ls_ahb_stallreq_i) begin
                                csr_wdata_r <= pc_tmp - `REG_BUS_WIDTH'h8;
                            end else if (ex_stallreq_i) begin                          
                                csr_wdata_r <= pc_tmp - `REG_BUS_WIDTH'h4;
                            end else begin
                                csr_wdata_r <= pc_tmp;
                            end                             
                        end else begin
                            if (ls_ahb_stallreq_i) begin
                                csr_wdata_r <= pc_i - `REG_BUS_WIDTH'h8;
                            end else if (ex_stallreq_i) begin                           
                                csr_wdata_r <= pc_i - `REG_BUS_WIDTH'h4;
                            end else begin
                                csr_wdata_r <= pc_i;
                            end                             
                        end                                     
                    end else if ((inst_sys_ecall | inst_sys_ebreak) & !ex_stallreq_i) begin
                        csr_we_r <= 1'b1;
                        csr_waddr_r <= `CSR_MEPC; 
                        csr_wdata_r <= pc_i+`REG_BUS_WIDTH'h4;                   
                    end else if (inst_sys_mret & !ex_stallreq_i) begin
                        csr_we_r <= 1'b1;
                        csr_waddr_r <= `CSR_MSTATUS;
                        csr_wdata_r <= {csr_mstatus_i[31:8], 1'b1, csr_mstatus_i[6:4], csr_mstatus_i[3], csr_mstatus_i[2:0]};
                    end else begin
                        csr_we_r <= 1'b0;
                        csr_waddr_r <= `CSR_ADDR_BUS_WIDTH'h0;
                        csr_wdata_r <= `REG_BUS_WIDTH'h0;
                    end
                end
                MEPC: begin
                    csr_we_r <= 1'b1;
                    csr_waddr_r <= `CSR_MSTATUS;
                    csr_wdata_r <= {csr_mstatus_i[31:8], csr_mstatus_i[3], csr_mstatus_i[6:4], 1'b0, csr_mstatus_i[2:0]};
                end
                MEPC_EXCP: begin
                    csr_we_r <= 1'b1;
                    csr_waddr_r <= `CSR_MEPC;                    
                    if (ls_ahb_stallreq_i) begin  //ex = inst_s or inst_l
                        if (pc_zero) begin        //id = inst_bj
                            csr_wdata_r <= pc_tmp - `REG_BUS_WIDTH'h4;
                        end else begin
                            csr_wdata_r <= pc_i - `REG_BUS_WIDTH'h4;
                        end
                    end else begin
                        csr_wdata_r <= csr_wdata_r;
                    end
                end
                MSTATUS: begin
                    csr_we_r <= 1'b1;
                    csr_waddr_r <= `CSR_MCAUSE;
                    csr_wdata_r <= cause;             
                end
            endcase
        end
    end

    assign csr_we_o = csr_we_r;
    assign csr_waddr_o = csr_waddr_r;
    assign csr_wdata_o = csr_wdata_r;

    reg     [1:0]           excp_type;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            excp_type <= 2'b00; 
        end else if (sys_state == IDLE) begin
            if (timer_irq_en) begin                     
                excp_type <= `EXCP_ASYNC_ASSERT;                                               
            end else if ((inst_sys_ecall | inst_sys_ebreak | inst_sys_mret) & !ex_stallreq_i) begin
                excp_type <= `EXCP_SYNC_ASSERT;
            end else begin
                excp_type <= 2'b00;
            end 
        end else begin
            excp_type <= 2'b00; 
        end               
    end

    reg                    jump_req_r;
    reg    [`REG_BUS]      jump_pc_r;      

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            jump_req_r <= 1'b0;
            jump_pc_r <= `REG_BUS_WIDTH'h0;
        end else if (sys_state == IDLE) begin
            if (timer_irq_en | ((inst_sys_ecall | inst_sys_ebreak) & !ex_stallreq_i)) begin
                jump_req_r <= 1'b1;
                jump_pc_r <= csr_mtvec_i;                        
            end else if (((inst_sys_mret) & !ex_stallreq_i)) begin
                jump_req_r <= 1'b1;
                jump_pc_r <= csr_mepc_i;
            end else begin
                jump_req_r <= 1'b0;
                jump_pc_r <= `REG_BUS_WIDTH'h0;
            end
        end else begin
            jump_req_r <= 1'b0;
            jump_pc_r <= `REG_BUS_WIDTH'h0;
        end
    end

    assign jump_req_o = jump_req_r;
    assign jump_pc_o = jump_pc_r;

    assign stallreq_o = (sys_nxstate != IDLE);
    assign flushreq_o[0] = (excp_type == `EXCP_SYNC_ASSERT);
    assign flushreq_o[1] = (excp_type == `EXCP_ASYNC_ASSERT);

    assign mul_div_cancel_o = flushreq_o[1];

endmodule
