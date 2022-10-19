`include "defines.v"

module if_ahb_interface (
    input   wire    clk     ,
    input   wire    rst_n   ,

    //from ifu
    input   wire                    ce_i            ,    
    input   wire    [`REG_BUS]      pc_i            ,

    //to idu
    output  wire    [`REG_BUS]      pc_o            ,
    output  wire    [31:0]          inst_o          ,

    //from ctrl
    input   wire    [5:0]           stall_i         ,
    input   wire    [5:0]           flush_i         ,
    output  wire                    stallreq_o      ,

    //to ahb bus
    output  wire                    mst_hsel_o      ,
    output  wire    [1:0]           mst_htrans_o    ,
    output  wire    [`HADDR_BUS]    mst_haddr_o     ,
    output  wire    [`HDATA_BUS]    mst_hwdata_o    ,
    output  wire                    mst_hwrite_o    ,
    output  wire    [2:0]           mst_hsize_o     ,
    output  wire    [2:0]           mst_hburst_o    ,
    output  wire    [3:0]           mst_hprot_o     ,
    output  wire                    mst_hmastlock_o ,
    output  wire                    mst_priority_o    ,

    input   wire                    mst_hready_i    ,
    input   wire                    mst_hresp_i     ,
    input   wire    [`HDATA_BUS]    mst_hrdata_i    
);
    //HTRANS
    localparam HTRANS_IDLE = 2'b00;
  //localparam HTRANS_BUSY = 2'b00;
    localparam HTRANS_NONSEQ = 2'b10;
  //localparam HTRANS_SEQ = 2'b00;  

    //HBURSTS
    localparam HBURSTS_SINGLE = 3'b000;
  //localparam HBURSTS_INCR = 3'b001;
  //localparam HBURSTS_WRAP4 = 3'b010;
  //...... 

    //HPORT
    localparam HPORT_DATA_ACCESS = 1; //bit0
    localparam HPORT_OPCODE_FETCH = 0; //bit0
  //...... //bit1
  //...... //bit2  

    //STATUS MACHINE PARAM
    localparam IDLE = 3'b000;
    localparam START = 3'b001;
    localparam RUN = 3'b010;
    localparam WAIT = 3'b011;
    localparam JUMP = 3'b100;    

    reg [2:0]   state, next_state;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    //1、复位开始，IDLE->START->RUN
    //2、正常情况，RUN->RUN(包括mst_hready_i引起的内部停顿)
    //3、外部停顿，RUN->WAIT(mst_hready_i有效后再转移状态，无效则RUN->RUN)，数据暂存到inst_r
    //4、jal， RUN->JUMP->RUN
    //5、jal-外部停顿，RUN/WAIT->JUMP->WAIT->RUN
    //6、excp， RUN->WAIT->JUMP->RUN
    //7、div-jal = jal-外部停顿，div与jal有关时不会产生跳转请求
    //8、div-irq，RUN->WAIT->JUMP->WAIT->RUN
    //9、div-ecall/ebreak = 外部停顿, div时，ecall/ebreak不会进行
    //10、irq与jal同时，RUN->JUMP->JUMP->WAIT->RUN

    always @(*) begin
        next_state = IDLE;
        case (state)
            IDLE: begin
                next_state = START;
            end 
            START: begin
                next_state = RUN;
            end
            RUN: begin
                if (flush_i[0]) begin
                    next_state = JUMP;
                end else if (stall_i[0]) begin
                    if (mst_hready_i) begin
                        next_state = WAIT;                        
                    end else begin
                        next_state = RUN;
                    end
                end else begin
                    next_state = RUN;
                end
            end
            WAIT: begin
                if (flush_i[0]) begin
                    next_state = JUMP;
                end else begin
                    if (stall_i[0]) begin
                        next_state = WAIT;
                    end else begin
                        next_state = RUN;
                    end
                end
            end
            JUMP: begin
                if (flush_i[0]) begin
                    next_state = JUMP;
                end else if (stall_i[0]) begin
                    next_state = WAIT;
                end else begin
                    next_state = RUN;
                end              
            end
        endcase
    end

    reg                 mst_hsel_r;
    reg [1:0]           mst_htrans_r;
    reg [`HADDR_BUS]    mst_haddr_r;
    reg                 mst_hwrite_r;
    reg [2:0]           mst_hsize_r;
    reg [1:0]           mst_hburst_r;
    reg [3:0]           mst_hprot_r;
    reg                 mst_hmastlock_r;
    reg [`REG_BUS]      pc_r;
    reg [31:0]          inst_r;

   always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mst_hsel_r <= 1'b0;
            mst_htrans_r <= HTRANS_IDLE;
            mst_haddr_r <= `HADDR_BUS_WIDTH'h0;
            mst_hwrite_r <= 1'b0;
            mst_hsize_r <= 3'b000;
            mst_hburst_r <= HBURSTS_SINGLE;
            mst_hprot_r <= 4'b0000;
            mst_hmastlock_r <= 1'b0;
        end else begin
            mst_hsel_r <= ce_i;
            mst_htrans_r <= HTRANS_NONSEQ;
            mst_hwrite_r <= 1'b0;
            mst_hsize_r <= 3'b010;
            mst_hburst_r <= HBURSTS_SINGLE;
            mst_hprot_r <= {3'b000, HPORT_OPCODE_FETCH};
            mst_hmastlock_r <= 1'b0;
        end
   end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mst_haddr_r <= `HADDR_BUS_WIDTH'h0;
            pc_r <= `REG_BUS_WIDTH'h0;
            inst_r <= 32'h0;
        end else begin
            case (state)
                IDLE: begin
                    mst_haddr_r <= pc_i;
                    pc_r <= `REG_BUS_WIDTH'h0;
                    inst_r <= 32'h0;
                end
                START: begin
                    mst_haddr_r <= pc_i;
                    pc_r <= mst_haddr_r;
                    inst_r <= 32'h0;
                end
                RUN: begin
                    if (flush_i[0]) begin
                        mst_haddr_r <= pc_i;
                        pc_r <= `REG_BUS_WIDTH'h0;
                        inst_r <= 32'h0;
                    end else if (stall_i[0]) begin
                        mst_haddr_r <= mst_haddr_r;
                        pc_r <= pc_r;
                        if (mst_hready_i) begin
                            inst_r <= mst_hrdata_i;
                        end else begin
                            inst_r <= 32'h0;
                        end                       
                    end else begin
                        mst_haddr_r <= pc_i;
                        pc_r <= mst_haddr_r;
                        inst_r <= 32'h0;
                    end
                end
                WAIT: begin
                    if (flush_i[0]) begin
                        mst_haddr_r <= pc_i;
                        pc_r <= `REG_BUS_WIDTH'h0;
                        inst_r <= 32'h0;
                    end else begin
                        if (stall_i[0]) begin
                            mst_haddr_r <= mst_haddr_r;
                            pc_r <= pc_r;
                            inst_r <= inst_r;
                        end else begin
                            mst_haddr_r <= pc_i;
                            pc_r <= mst_haddr_r;
                            inst_r <= 32'h0;
                        end
                    end
                end
                JUMP: begin
                    if (flush_i[0]) begin
                        mst_haddr_r <= pc_i;
                        pc_r <= `REG_BUS_WIDTH'h0;
                        inst_r <= 32'h0;                        
                    end else if (stall_i[0]) begin
                        mst_haddr_r <= mst_haddr_r;
                        pc_r <= `REG_BUS_WIDTH'h0;
                        inst_r <= 32'h0; 
                    end else begin
                        mst_haddr_r <= pc_i;
                        pc_r <= mst_haddr_r;
                        inst_r <= 32'h0;
                    end
                end
                default: begin
                    mst_haddr_r <= `HADDR_BUS_WIDTH'h0;
                    pc_r <= `REG_BUS_WIDTH'h0;
                    inst_r <= 32'h0;                    
                end
            endcase                            
        end
    end

    assign mst_hsel_o = flush_i[0] ? 1'b0 : mst_hsel_r;
    assign mst_htrans_o = flush_i[0] ? HTRANS_IDLE : mst_htrans_r;
    assign mst_haddr_o = flush_i[0] ? `HADDR_BUS_WIDTH'h0 : mst_haddr_r;
    assign mst_hwdata_o = `HDATA_BUS_WIDTH'h0;
    assign mst_hwrite_o = flush_i[0] ? 1'b0 : mst_hwrite_r;
    assign mst_hsize_o = flush_i[0] ? 3'b000 : mst_hsize_r;
    assign mst_hburst_o = flush_i[0] ? HBURSTS_SINGLE : mst_hburst_r;
    assign mst_hprot_o = flush_i[0] ? 4'b0000 : mst_hprot_r;
    assign mst_hmastlock_o = flush_i[0] ? 1'b0 : mst_hmastlock_r;
    assign mst_priority_o = 1'b0;

    assign pc_o = pc_r;
    assign inst_o = ({`HDATA_BUS_WIDTH{(state == RUN) & mst_hready_i}} & mst_hrdata_i) |
                    ({`HDATA_BUS_WIDTH{(state == WAIT) & mst_hready_i}} & inst_r);

    assign stallreq_o = !mst_hready_i;

endmodule //if_ahb_interface
