module ahb_uart #(
    parameter  AWIDTH = 32,   
    parameter  DWIDTH = 32,
    parameter  DEPTH = 32      
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

    output  wire                    tx          ,
    input   wire                    rx
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

    localparam IDLE = 2'b00;
    localparam PREPARE = 2'b01;
    localparam WAIT_READ = 2'b10;
    localparam WAIT_WRITE = 2'b11;

    // 50MHz时钟，波特率115200bps(bit/s)对应的分频系数 8 1 1 1
    localparam BAUD_115200 = 32'h1B2;

    localparam UART_DATA = 4'h0;
    localparam UART_CTRL = 4'h4;
    localparam UART_BAUD = 4'h8;    

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

    // addr: 0x04
    // rw. bit[0]: rx enable, 1 = enable, 0 = disable
    // rw. bit[1]: tx enable, 1 = enable, 0 = disable
    reg [7:0]   uart_ctrl;
    // addr: 0x08
    // rw. clk div
    reg [31:0]  uart_baud;

    //rfifo
    wire [7:0]  rf_wdata;
    wire [7:0]  rf_rdata;
    wire        rf_we;
    wire        rf_re;
    wire        rf_full;
    wire        rf_empty;

    //wfifo
    reg [7:0]   wf_wdata;
    wire [7:0]  wf_rdata;
    wire        wf_we;
    wire        wf_re;
    wire        wf_full;
    wire        wf_empty;


    reg [1:0]   state, next_state;

    wire uart_cs = hsel_i && (hburst_r == HBURSTS_SINGLE) && (htrans_r == HTRANS_NONSEQ);
    wire uart_read = uart_cs && !hwrite_r && (haddr_r[3:0] == UART_DATA); //!(|haddr_r[3:0])
    wire uart_write = uart_cs && hwrite_r && (haddr_r[3:0] == UART_DATA);
    wire uart_reg_read = uart_cs && !hwrite_r && !(haddr_r[3:0] == UART_DATA);
    wire uart_reg_write = uart_cs && hwrite_r && !(haddr_r[3:0] == UART_DATA);

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
                if (uart_read) begin
                    if (!rf_empty) begin
                        next_state = PREPARE; //PREPARE   hready_i=1时会无效读，lsu此时地址未备好，hsel_i至少拉低一周期，下同
                    end else begin
                        next_state = WAIT_READ;
                    end
                end else if (uart_write) begin
                    if (!wf_full) begin
                        next_state = PREPARE;
                    end else begin
                        next_state = WAIT_WRITE;
                    end
                end else if (uart_reg_read) begin
                    next_state = PREPARE;  //PREPARE 
                end else if (uart_reg_write) begin
                    next_state = PREPARE; //PREPARE
                end else begin
                    next_state = IDLE;
                end 
            end          
            WAIT_READ : begin   
                if (uart_read) begin
                    if (!rf_empty) begin
                        next_state = PREPARE; //PREPARE 
                    end else begin
                        next_state = WAIT_READ;
                    end                
                end           
            end
            WAIT_WRITE : begin   
                if (uart_write) begin
                    if (!wf_full) begin
                        next_state = PREPARE;
                    end else begin
                        next_state = WAIT_WRITE;
                    end                
                end           
            end
        endcase
    end

    //uart_ctrl 波特率
    always @(posedge hclk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            wf_wdata <= 8'h0;
        end else if (wf_we) begin
            wf_wdata <= hwdata_i[7:0];
        end else begin
            wf_wdata <= 8'h0;
        end
    end    

    assign wf_we = uart_write && !wf_full && ((state == PREPARE) || (state == WAIT_WRITE));

    reg    [DWIDTH-1:0]    hrdata_r;

    assign rf_re = uart_read && !rf_empty && ((state == PREPARE) || (state == WAIT_READ));;

    always @(*) begin
        if (rf_re) begin
            hrdata_r = {{DWIDTH-8{1'b0}},rf_rdata};
        end else if (uart_reg_read && (state == PREPARE)) begin
            case (haddr_r[3:0])
                UART_CTRL: begin
                    hrdata_r = {{DWIDTH-8{1'b0}},uart_ctrl};
                end
                UART_BAUD: begin
                    hrdata_r = uart_baud;
                end
                default: begin
                    hrdata_r = {DWIDTH{1'b0}};
                end
            endcase            
        end else begin
            hrdata_r = {DWIDTH{1'b0}};
        end
    end

    assign hrdata_o = hrdata_r;
    assign hreadyout_o = ((next_state == IDLE) || (next_state == PREPARE));
    assign hresp_o = 1'b0; //ok

    always @(posedge hclk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            uart_ctrl <= 8'h0;
            uart_baud <= BAUD_115200;
        end else if (uart_reg_write) begin
            case (haddr_r[3:0])
                UART_CTRL: begin
                    uart_ctrl <= hwdata_i[7:0];
                end
                UART_BAUD: begin
                    uart_baud <= hwdata_i;
                end
                default: begin

                end
            endcase
        end
    end    

    wire rx_en = uart_ctrl[0];
    wire tx_en = uart_ctrl[1];

    wire    [31:0]  baud = uart_baud;

    wire            clk_tx;


    uart_rx u_uart_rx (
        .clk (hclk),
        .rst_n (hresetn),
        .rx_en(rx_en),
        .data_o (rf_wdata),
        .full_i(rf_full),
        .we_o (rf_we),
        .baud(baud),
        .rx (rx)
    );

    sync_fifo #(
        .DEPTH(DEPTH),
        .DWIDTH(8)        
    )
    u_sync_r_fifo (
        .clk(hclk),
        .rst_n(hresetn),
        .ren_i(rf_re),
        .rdata_o(rf_rdata),
        .wen_i(rf_we),
        .wdata_i(rf_wdata),
        .full_o(rf_full),
        .empty_o(rf_empty)
    );

    uart_tx u_uart_tx (
        .clk (hclk),
        .clk_tx(clk_tx),
        .rst_n (hresetn),
        .tx_en(tx_en),
        .data_i (wf_rdata),
        .empty_i (wf_empty),
        .re_o (wf_re),
        .baud(baud),
        .tx (tx)
    ); 

    async_fifo #(
        .DEPTH(DEPTH),
        .DWIDTH(8)        
    )
    u_async_w_fifo (
        .rst_n(hresetn),
        .rclk(clk_tx),
        .renc_i(wf_re),
        .rdata_o(wf_rdata),
        .wclk(hclk),
        .wenc_i(wf_we),
        .wdata_i(wf_wdata),
        .full_o(wf_full),
        .empty_o(wf_empty)
    ); 

endmodule