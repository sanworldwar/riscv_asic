module ahb_timer #(
    parameter  AWIDTH = 32,   
    parameter  DWIDTH = 32     
)(
    input   wire                    hclk        ,
    input   wire    		        hresetn     ,

    input   wire    		        hsel_i      ,
    input   wire   	 	            hwrite_i    ,
    input   wire			        hready_i    ,
    input   wire    [2:0]  	        hsize_i     ,
    input   wire    [2:0]  	        hburst_i    ,
    input   wire    [1:0]  	        htrans_i    ,
    input   wire    [DWIDTH-1:0] 	hwdata_i    ,
    input   wire    [AWIDTH-1:0] 	haddr_i     ,	
    
    output  wire                    hreadyout_o ,
    output  wire                    hresp_o     ,
    output  wire    [DWIDTH-1:0]    hrdata_o    ,

    output  wire                    timer_irq_o    
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

    localparam IDLE = 1'b0;
    localparam PREPARE = 1'b1;

    localparam TIMER_CTRL = 4'h0;
    localparam TIMER_COUNT = 4'h4;
    localparam TIMER_VALUE = 4'h8;

    reg                 hwrite_r    ;
    reg [2:0]           hsize_r     ;
    reg [2:0]           hburst_r    ;
    reg [1:0]           htrans_r    ;
    reg [AWIDTH-1:0] 	haddr_r     ;

    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            hwrite_r <= 1'b0;
            hsize_r <= 3'b000;
            hburst_r <= 3'b000;
            htrans_r <= 2'b00;
            haddr_r <= {AWIDTH{1'b0}};
        end else if (hsel_i) begin
            if (hready_i) begin
                hwrite_r <= hwrite_i;
                hsize_r <= hsize_i;
                hburst_r <= hburst_i; //一直为single
                htrans_r <= htrans_i;
                haddr_r <= haddr_i;
            end
        end else begin
            hwrite_r <= 1'b0;
            hsize_r <= 3'b000;
            hburst_r <= 3'b000;
            htrans_r <= 2'b00;
            haddr_r <= {AWIDTH{1'b0}};
        end
    end

    // [0]: timer enable
    // [1]: timer int enable
    // [2]: timer int pending, write 1 to clear it
    // addr offset: 0x00
    reg [DWIDTH-1:0]    timer_ctrl;

    // timer current count, read only
    // addr offset: 0x04
    reg [DWIDTH-1:0]    timer_count;

    // timer expired value
    // addr offset: 0x08
    reg [DWIDTH-1:0]    timer_value;

    reg                 state, next_state;

    wire timer_cs = hsel_i && (hburst_r == HBURSTS_SINGLE) && (htrans_r == HTRANS_NONSEQ);
    wire timer_read = timer_cs && !hwrite_r;
    wire timer_write = timer_cs && hwrite_r;

    assign timer_irq_o = ((timer_ctrl[2] == 1'b1) && (timer_ctrl[1] == 1'b1)) ? 1'b1 : 1'b0;

    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = IDLE;
        case (state)
            IDLE : begin
                if (hsel_i) begin
                    next_state = PREPARE;
                end else begin
                    next_state = IDLE;
                end
            end
           PREPARE : begin
                if (timer_read) begin
                    next_state = PREPARE; //PREPARE   hready_i=1时会无效读，lsu此时地址未备好，hsel_i至少拉低一周期，下同
                end else if (timer_write) begin 
                    next_state = PREPARE; //PREPARE 
                end else begin
                    next_state = IDLE;
                end 
            end          
        endcase
    end

    // counter
    always @ (posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            timer_count <= {DWIDTH{1'b0}};
        end else begin
            if (timer_ctrl[0] == 1'b1) begin
                timer_count <= timer_count + 1'b1;
                if (timer_count >= timer_value) begin
                    timer_count <= {DWIDTH{1'b0}};
                end
            end else begin
                timer_count <= {DWIDTH{1'b0}};
            end
        end
    end

    // write regs
    always @ (posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            timer_ctrl <= {DWIDTH{1'b0}};
            timer_value <= {DWIDTH{1'b0}};
        end else if (timer_write && (state == PREPARE)) begin           
            case (haddr_r[3:0])
                TIMER_CTRL: begin
                    timer_ctrl <= {hwdata_i[31:3], (timer_ctrl[2] & (~hwdata_i[2])), hwdata_i[1:0]};
                end
                TIMER_VALUE: begin
                    timer_value <= hwdata_i;
                end
                default: begin
                    
                end
            endcase
        end else if ((timer_ctrl[0] == 1'b1) && (timer_count >= timer_value)) begin
            timer_ctrl[0] <= 1'b0;
            timer_ctrl[2] <= 1'b1;
        end
    end

    reg [DWIDTH-1:0]    hrdata_r;

    // read regs
    always @ (*) begin
        if (timer_read && (state == PREPARE)) begin
            case (haddr_r[3:0])
                TIMER_VALUE: begin
                    hrdata_r <= timer_value;
                end
                TIMER_CTRL: begin
                    hrdata_r <= timer_ctrl;
                end
                TIMER_COUNT: begin
                    hrdata_r <= timer_count;
                end
                default: begin
                    hrdata_r <= {DWIDTH{1'b0}};
                end
            endcase
        end else begin
            hrdata_r <= {DWIDTH{1'b0}};
        end
    end

    assign hrdata_o = hrdata_r;
    assign hreadyout_o = ((next_state == IDLE) || (next_state == PREPARE));
    assign hresp_o = 1'b0; //ok


endmodule
