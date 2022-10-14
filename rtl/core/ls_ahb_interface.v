`include "defines.v"

module ls_ahb_interface (
    input   wire    clk     ,
    input   wire    rst_n   ,

    //from lsu
    output  wire    [`MEM_DATA_BUS] rdata_o     ,
    input   wire                    re_i        ,
    input   wire    [`MEM_DATA_BUS] wdata_i     ,
    input   wire                    we_i        ,
    input   wire    [`MEM_ADDR_BUS] addr_i      ,

    //from ctrl
    input   wire    [5:0]       stall_i     ,
    output  wire                stallreq_o  ,

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
    output  wire                    mst_priority_o  ,

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
    localparam PREPARE = 3'b001;    
    localparam READ = 3'b010;
    localparam WRITE = 3'b011;
    localparam WAIT_READ = 3'b100;
    localparam WAIT_WRITE = 3'b101;


    reg [2:0]   state, next_state;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    //读(暂停)：IDLE->PREPARE->READ->(WAIT_READ)->IDLE
    //写(暂停)：IDLE->PREPARE->WRITE->(WAIT_WRITE)->IDLE
    //读后写(暂停)：IDLE->PREPARE->READ->(WAIT_READ)->WRITE->(WAIT_WRITE)->IDLE
    //因为rd_we_o和rd_addr_o不能被修改，无法使用流水线地址形式
    always @(*) begin
        next_state = IDLE;
        case (state)       
            IDLE: begin
                if ((re_i || we_i) && mst_hready_i) begin
                    next_state = PREPARE;
                end else begin
                    next_state = IDLE;
                end
            end 
            PREPARE: begin
                if (re_i && mst_hready_i) begin
                    next_state = READ;
                end else if (we_i && mst_hready_i) begin
                    next_state = WRITE;
                end else begin
                    next_state = PREPARE;
                end
            end
            READ: begin
                if (mst_hready_i) begin
                    if (we_i) begin
                        next_state = WRITE;                            
                    end else begin
                        next_state = IDLE;
                    end                       
                end else begin
                    next_state = WAIT_READ;
                end
            end
            WRITE: begin
                if (mst_hready_i) begin
                    next_state = IDLE;
                end else begin
                    next_state = WAIT_WRITE;
                end
            end
            WAIT_READ: begin
                if (mst_hready_i) begin
                    next_state = IDLE;
                end else begin
                    next_state = WAIT_READ;
                end                
            end
            WAIT_WRITE: begin
                if (mst_hready_i) begin
                    next_state = IDLE;
                end else begin
                    next_state = WAIT_WRITE;
                end                
            end
        endcase
    end

    reg                 mst_hsel_r;
    reg [1:0]           mst_htrans_r;
    reg [`HADDR_BUS]    mst_haddr_r;
    reg [`HDATA_BUS]    mst_hwdata_r;
    reg                 mst_hwrite_r;
    reg [2:0]           mst_hsize_r;
    reg [1:0]           mst_hburst_r;
    reg [3:0]           mst_hprot_r;
    reg                 mst_hmastlock_r;
    reg                 mst_priority_r;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mst_hsel_r <= 1'b0;
            mst_htrans_r <= HTRANS_IDLE;
            mst_haddr_r <= `HADDR_BUS_WIDTH'H0;
            mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
            mst_hwrite_r <= 1'b0;
            mst_hsize_r <= 3'b000;
            mst_hburst_r <= HBURSTS_SINGLE;
            mst_hprot_r <= 4'b0000;
            mst_hmastlock_r <= 1'b0;
            mst_priority_r <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (re_i && mst_hready_i) begin
                        mst_hsel_r <= 1'b1;
                        mst_htrans_r <= HTRANS_NONSEQ;
                        mst_haddr_r <= addr_i;
                        mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                        mst_hwrite_r <= 1'b0;
                        mst_hsize_r <= 3'b010;
                        mst_hburst_r <= HBURSTS_SINGLE;
                        mst_hprot_r <= {3'b000, HPORT_OPCODE_FETCH};
                        mst_hmastlock_r <= 1'b1;
                        mst_priority_r <= 1'b1;
                    end else if (we_i && mst_hready_i) begin
                        mst_hsel_r <= 1'b1;
                        mst_htrans_r <= HTRANS_NONSEQ;
                        mst_haddr_r <= addr_i;
                        mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                        mst_hwrite_r <= 1'b1;
                        mst_hsize_r <= 3'b010;
                        mst_hburst_r <= HBURSTS_SINGLE;
                        mst_hprot_r <= {3'b000, HPORT_OPCODE_FETCH};
                        mst_hmastlock_r <= 1'b1;
                        mst_priority_r <= 1'b1;                        
                    end else begin
                        mst_hsel_r <= 1'b0;
                        mst_htrans_r <= HTRANS_IDLE;
                        mst_haddr_r <= `HADDR_BUS_WIDTH'H0;
                        mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                        mst_hwrite_r <= 1'b0;
                        mst_hsize_r <= 3'b000;
                        mst_hburst_r <= HBURSTS_SINGLE;
                        mst_hprot_r <= 4'b0000;
                        mst_hmastlock_r <= 1'b0;
                        mst_priority_r <= 1'b1;
                    end
                end
                PREPARE: begin
                    if (mst_hready_i) begin
                        if (re_i) begin
                            if (we_i) begin
                                mst_hsel_r <= 1'b1;
                                mst_htrans_r <= HTRANS_NONSEQ;
                                mst_haddr_r <= addr_i;
                                mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                                mst_hwrite_r <= 1'b1;
                                mst_hsize_r <= 3'b010;
                                mst_hburst_r <= HBURSTS_SINGLE;
                                mst_hprot_r <= {3'b000, HPORT_OPCODE_FETCH};
                                mst_hmastlock_r <= 1'b1;
                                mst_priority_r <= 1'b1;                                 
                            end else begin
                                mst_hsel_r <= 1'b1;
                                mst_htrans_r <= HTRANS_NONSEQ;
                                mst_haddr_r <= addr_i;
                                mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                                mst_hwrite_r <= 1'b0;
                                mst_hsize_r <= 3'b010;
                                mst_hburst_r <= HBURSTS_SINGLE;
                                mst_hprot_r <= {3'b000, HPORT_OPCODE_FETCH};
                                mst_hmastlock_r <= 1'b1;
                                mst_priority_r <= 1'b1; ;                               
                            end
                        end else if (we_i) begin
                            mst_hsel_r <= 1'b1;
                            mst_htrans_r <= HTRANS_NONSEQ;
                            mst_haddr_r <= addr_i;
                            mst_hwdata_r <= wdata_i;
                            mst_hwrite_r <= 1'b0;
                            mst_hsize_r <= 3'b010;
                            mst_hburst_r <= HBURSTS_SINGLE;
                            mst_hprot_r <= {3'b000, HPORT_OPCODE_FETCH};
                            mst_hmastlock_r <= 1'b1;
                            mst_priority_r <= 1'b1;
                        end else begin
                            mst_hsel_r <= 1'b1;
                            mst_htrans_r <= HTRANS_IDLE;
                            mst_haddr_r <= addr_i;
                            mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                            mst_hwrite_r <= 1'b0;
                            mst_hsize_r <= 3'b000;
                            mst_hburst_r <= HBURSTS_SINGLE;
                            mst_hprot_r <= 4'b0000;
                            mst_hmastlock_r <= 1'b0;
                            mst_priority_r <= 1'b1;                            
                        end
                    end else begin
                            mst_hsel_r <= 1'b1;
                            mst_htrans_r <= HTRANS_IDLE;
                            mst_haddr_r <= addr_i;
                            mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                            mst_hwrite_r <= 1'b0;
                            mst_hsize_r <= 3'b000;
                            mst_hburst_r <= HBURSTS_SINGLE;
                            mst_hprot_r <= 4'b0000;
                            mst_hmastlock_r <= 1'b0;
                            mst_priority_r <= 1'b1;                         
                    end
                end
                READ: begin
                    if (mst_hready_i) begin
                        if (we_i) begin
                            mst_hsel_r <= 1'b1;
                            mst_htrans_r <= HTRANS_NONSEQ;
                            mst_haddr_r <= addr_i;
                            mst_hwdata_r <= wdata_i;
                            mst_hwrite_r <= 1'b0;
                            mst_hsize_r <= 3'b010;
                            mst_hburst_r <= HBURSTS_SINGLE;
                            mst_hprot_r <= {3'b000, HPORT_OPCODE_FETCH};
                            mst_hmastlock_r <= 1'b1;
                            mst_priority_r <= 1'b1; 
                        end else begin
                            mst_hsel_r <= 1'b0;
                            mst_htrans_r <= HTRANS_IDLE;
                            mst_haddr_r <= `HADDR_BUS_WIDTH'H0;
                            mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                            mst_hwrite_r <= 1'b0;
                            mst_hsize_r <= 3'b000;
                            mst_hburst_r <= HBURSTS_SINGLE;
                            mst_hprot_r <= 4'b0000;
                            mst_hmastlock_r <= 1'b0;
                            mst_priority_r <= 1'b1;                             
                        end
                    end                    
                end
                WRITE: begin
                    if (mst_hready_i) begin
                        mst_hsel_r <= 1'b0;
                        mst_htrans_r <= HTRANS_IDLE;
                        mst_haddr_r <= `HADDR_BUS_WIDTH'H0;
                        mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                        mst_hwrite_r <= 1'b0;
                        mst_hsize_r <= 3'b000;
                        mst_hburst_r <= HBURSTS_SINGLE;
                        mst_hprot_r <= 4'b0000;
                        mst_hmastlock_r <= 1'b0;
                        mst_priority_r <= 1'b1;  
                    end                    
                end
                WAIT_READ: begin
                    if (mst_hready_i) begin
                        mst_hsel_r <= 1'b0;
                        mst_htrans_r <= HTRANS_IDLE;
                        mst_haddr_r <= `HADDR_BUS_WIDTH'H0;
                        mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                        mst_hwrite_r <= 1'b0;
                        mst_hsize_r <= 3'b000;
                        mst_hburst_r <= HBURSTS_SINGLE;
                        mst_hprot_r <= 4'b0000;
                        mst_hmastlock_r <= 1'b0;
                        mst_priority_r <= 1'b1;  
                    end
                end
                WAIT_WRITE: begin
                    if (mst_hready_i) begin
                        mst_hsel_r <= 1'b0;
                        mst_htrans_r <= HTRANS_IDLE;
                        mst_haddr_r <= `HADDR_BUS_WIDTH'H0;
                        mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                        mst_hwrite_r <= 1'b0;
                        mst_hsize_r <= 3'b000;
                        mst_hburst_r <= HBURSTS_SINGLE;
                        mst_hprot_r <= 4'b0000;
                        mst_hmastlock_r <= 1'b0;
                        mst_priority_r <= 1'b1;  
                    end
                end
                default: begin
                    mst_hsel_r <= 1'b0;
                    mst_htrans_r <= HTRANS_IDLE;
                    mst_haddr_r <= `HADDR_BUS_WIDTH'H0;
                    mst_hwdata_r <= `HDATA_BUS_WIDTH'h0;
                    mst_hwrite_r <= 1'b0;
                    mst_hsize_r <= 3'b000;
                    mst_hburst_r <= HBURSTS_SINGLE;
                    mst_hprot_r <= 4'b0000;
                    mst_hmastlock_r <= 1'b0;
                    mst_priority_r <= 1'b1;                     
                end
            endcase                            
        end
    end

    assign mst_hsel_o = mst_hsel_r;
    assign mst_htrans_o = mst_htrans_r;
    assign mst_haddr_o = mst_haddr_r;
    assign mst_hwdata_o = mst_hwdata_r;
    assign mst_hwrite_o = mst_hwrite_r;
    assign mst_hsize_o = mst_hsize_r;
    assign mst_hburst_o = mst_hburst_r;
    assign mst_hprot_o = mst_hprot_r;
    assign mst_hmastlock_o = mst_hmastlock_r;
    assign mst_priority_o = mst_priority_r;

    reg    [`MEM_DATA_BUS] rdata_r;

    always @(*) begin
        if (mst_hready_i && (state == READ) || (state == WAIT_READ)) begin
            rdata_r = mst_hrdata_i;
        end else begin
            rdata_r <= `MEM_DATA_BUS_WIDTH'h0;            
        end        
    end

    assign rdata_o = rdata_r;

    assign stallreq_o = !(next_state == IDLE);
    
endmodule