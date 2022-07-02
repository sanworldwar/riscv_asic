`include "defines.v"

module ls_ahb_interface (
    input   wire    clk     ,
    input   wire    rst_n   ,

    //from lsu
    output  wire    [`MEM_DATA_BUS] rdata_o     ,
    input   wire                    re_i        ,
    input   wire    [`MEM_DATA_BUS] wdata_i     ,
    input   wire                    we_i        ,
    input   wire    [`MEM_ADDR_BUS] addr_i     ,

    //from ctrl
    input   wire    [5:0]       stall_i     ,
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
    localparam READ = 2'b01;
    localparam WRITE = 2'b10;


    reg [1:0]   state, next_state;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = IDLE;
        case (state)       
            IDLE: begin
                if (re_i) begin
                    next_state = READ;
                end else if (we_i) begin
                    next_state = WRITE;
                end
            end 
            READ: begin
                if (mst_hready_i & !stall_i[4]) begin
                    if (we_i) begin
                        next_state = WRITE;
                    end else begin
                        next_state = IDLE;                       
                    end
                end else begin
                    next_state = READ;
                end
            end
            WRITE: begin
                if (mst_hready_i & !stall_i[4]) begin
                    next_state = IDLE;
                end else begin
                    next_state = WRITE;
                end
            end
        endcase
    end

    reg [1:0]           mst_htrans_r;
    reg [`HDATA_BUS]    mst_hwdata_r;
    reg [2:0]           mst_hsize_r;
    reg [1:0]           mst_hburst_r;
    reg [3:0]           mst_hprot_r;
    reg                 mst_hmastlock_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mst_htrans_r <= HTRANS_IDLE;
            mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
            mst_hsize_r <= 3'b000;
            mst_hburst_r <= HBURSTS_SINGLE;
            mst_hprot_r <= {3'b000, HPORT_OPCODE_FETCH};
            mst_hmastlock_r <= 1'b0;
        end
        else begin
            mst_htrans_r <= HTRANS_NONSEQ;
            mst_hsize_r <= 3'b010;
            mst_hburst_r <= HBURSTS_SINGLE;
            mst_hprot_r <= {3'b000, HPORT_OPCODE_FETCH};
            mst_hmastlock_r <= 1'b1;
            case (state)
                IDLE: begin
                    if (we_i & !re_i) begin
                        mst_hwdata_r <= wdata_i;
                    end else begin
                        mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                    end
                end
                READ: begin
                    if (mst_hready_i & !stall_i[4] & we_i) begin
                        mst_hwdata_r <= wdata_i;
                    end else begin
                        mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                    end                    
                end
                WRITE: begin
                    if (mst_hready_i & !stall_i[4]) begin
                        mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                    end                   
                end 
            endcase                            
        end
    end

    assign mst_hsel_o = re_i | we_i;
    assign mst_htrans_o = mst_htrans_r;
    assign mst_haddr_o = addr_i;
    assign mst_hwdata_o = mst_hwdata_r;
    assign mst_hwrite_o = (state != WRITE) & (next_state == WRITE);
    assign mst_hsize_o = mst_hsize_r;
    assign mst_hburst_o = mst_hburst_r;
    assign mst_hprot_o = mst_hprot_r;
    assign mst_hmastlock_o = mst_hmastlock_r;

    reg    [`MEM_DATA_BUS] rdata_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rdata_r <= `MEM_DATA_BUS_WIDTH'h0;
        end else if ((state == READ) & mst_hready_i) begin
            rdata_r <= mst_hrdata_i;
        end else begin
            rdata_r <= `MEM_DATA_BUS_WIDTH'h0;
        end
    end

    assign rdata_o = rdata_r;
    //assign rdata_o = mst_hready_i ? mst_hrdata_i : `MEM_DATA_BUS_WIDTH'h0; //== mst_hready_i&mst_hrdata_i

    assign stallreq_o = ((state == IDLE) & (next_state != IDLE)) | !mst_hready_i | 
                        ((state == READ) & (next_state != READ));
    
endmodule