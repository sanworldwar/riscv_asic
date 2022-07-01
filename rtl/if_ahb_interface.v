`include "defines.v"

module if_ahb_interface (
    input   wire    clk     ,
    input   wire    rst_n   ,

    //from ifu
    input   wire                ce_i        ,    
    input   wire    [`REG_BUS]  pc_i        ,

    //to idu
    output  wire    [`REG_BUS]  pc_o        ,
    output  wire    [31:0]      inst_o      ,

    //from ctrl
    input   wire    [5:0]       stall_i     ,
    input   wire    [4:0]       flush_i     ,
    output  wire                stallreq_o  ,

    //to ahb bus
    output  wire                    mst_hsel_o      ,
    output  wire    [1:0]           mst_htrans_o    ,
    output  wire    [`HADDR_BUS]    mst_haddr_o     ,
    output  wire    [`HDATA_BUS]    mst_hwdata_o    ,
    input   wire    [`HDATA_BUS]    mst_hrdata_i    ,
    output  wire                    mst_hwrite_o    ,
    output  wire    [2:0]           mst_hsize_o     ,
    output  wire    [2:0]           mst_hburst_o    ,
    output  wire    [3:0]           mst_hprot_o     ,
    output  wire                    mst_hmastlock_o ,
    input   wire                    mst_hready_i    ,
    output  wire                    mst_hresp_o       
  //output  wire                    mst_priority
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
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam RUN = 2'b10;
    localparam WAIT = 2'b11;

    reg [1:0]   state, next_state;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    //复位开始，正常情况，普通停顿，jal， excp， div-jal， div-excp，irq-jal
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
                if (stall_i[0] & mst_hready_i) begin
                    next_state = WAIT;
                end else if (flush_i[0]) begin
                    next_state = START;
                end else begin
                    next_state = RUN;
                end
            end
            WAIT: begin
                if (flush_i[0]) begin //针对excp，跳转优先，div-irq div优先(irq在结束时发生)，
                    next_state = START;
                end else if (!stall_i[0]) begin
                    next_state = RUN;
                end else begin
                    next_state = WAIT;
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
            mst_hprot_r <= {3'b000, HPORT_OPCODE_FETCH};
            mst_hmastlock_r <= 1'b0;
            pc_r <= `REG_BUS_WIDTH'h0;
            inst_r <= 32'h0;
        end
        else begin
            mst_hsel_r <= ce_i;
            mst_htrans_r <= HTRANS_NONSEQ;
            mst_hwrite_r <= 1'b0;
            mst_hsize_r <= 3'b010;
            mst_hburst_r <= HBURSTS_SINGLE;
            mst_hprot_r <= {3'b000, HPORT_OPCODE_FETCH};
            mst_hmastlock_r <= 1'b1;
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
                    if (stall_i[0] & mst_hready_i) begin   //irq-jal优先响应irq
                        inst_r <= mst_hrdata_i;
                    end else if (flush_i[0]) begin //跳转比hready优先级高
                        mst_haddr_r <= pc_i;
                        pc_r <= `REG_BUS_WIDTH'h0;
                    end else if (mst_hready_i) begin
                        mst_haddr_r <= pc_i;
                        pc_r <= mst_haddr_r;
                    end
                end
                WAIT: begin
                    if (flush_i[0]) begin //跳转时清零
                        mst_haddr_r <= pc_i;
                        pc_r <= `REG_BUS_WIDTH'h0;
                        inst_r <= 32'h0;
                    end else if (!stall_i[0]) begin
                        mst_haddr_r <= pc_i;
                        pc_r <= mst_haddr_r;
                        inst_r <= 32'h0;
                    end
                end    
            endcase                            
        end
    end

    assign mst_hsel_o = mst_hsel_r;
    assign mst_htrans_o = mst_htrans_r;
    assign mst_haddr_o = mst_haddr_r;
    assign mst_hwdata_o = `HDATA_BUS_WIDTH'h0;
    assign mst_hwrite_o = mst_hwrite_r;
    assign mst_hsize_o = mst_hsize_r;
    assign mst_hburst_o = mst_hburst_r;
    assign mst_hprot_o = mst_hprot_r;
    assign mst_hmastlock_o = mst_hmastlock_r;


    assign pc_o = pc_r;
    assign inst_o = ({`HDATA_BUS_WIDTH{(state == RUN) & mst_hready_i}} & mst_hrdata_i) |
                    ({`HDATA_BUS_WIDTH{(state == WAIT) & mst_hready_i}} & inst_r);

    assign stallreq_o = !mst_hready_i;

endmodule //if_ahb_interface
