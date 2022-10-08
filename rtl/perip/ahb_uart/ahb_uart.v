module ahb_uart #(
    parameter  AWIDTH = 32,   
    parameter  DWIDTH = 32,
    parameter  DEPTH = 32      
)(
    input   wire                    hclk        ,
    input   wire                    uart_clk    ,
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

    reg                 hwrite_r    ;
    reg [2:0]           hsize_r     ;
    reg [2:0]           hburst_r    ;
    reg [1:0]           htrans_r    ;
    reg [AWIDTH-1:0] 	haddr_r     ;

    always @(posedge hclk or negedge hresetn) begin
        if(!hresetn) begin
            hwrite_r <= 1'b0;
            hsize_r <= 3'b000;
            hburst_r <= 3'b000;
            htrans_r <= 2'b00;
            haddr_r <= {AWIDTH{1'b0}};
        end else if (hsel_i && hready_i) begin
            hwrite_r <= hwrite_i;
            hsize_r <= hsize_i;
            hburst_r <= hburst_i; //一直为single
            htrans_r <= htrans_i;
            haddr_r <= haddr_i;
        end else begin
            hwrite_r <= 1'b0;
            hsize_r <= 3'b000;
            hburst_r <= 3'b000;
            htrans_r <= 2'b00;
            haddr_r <= {AWIDTH{1'b0}};
        end
    end

    reg [7:0]   uart_ctrl;
    reg [1:0]   clk_cnt;
    reg         clk_tx;

    //rfifo
    wire [7:0]  rf_data_i;
    wire [7:0]  rf_data_o;
    wire        rf_we;
    wire        rf_re;
    wire        rf_full;
    wire        rf_empty;
    wire        rf_valid;

    //wfifo
    reg [7:0]   wf_data_i;
    wire [7:0]  wf_data_o;
    wire        wf_we;
    wire        wf_re;
    wire        wf_full;
    wire        wf_empty;
    wire        wf_valid;

    always @(posedge uart_clk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            clk_cnt <= 2'b0;
        end else if (clk_cnt == 2'b11) begin
            clk_cnt <= 2'b0;
        end else begin
            clk_cnt <= clk_cnt + 2'b1;
        end
    end

    always @(posedge uart_clk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            clk_tx <= 1'b1;
        end else if (clk_cnt == 2'b11) begin
            clk_tx <= ~clk_tx;
        end
    end

    wire uart_cs = hsel_i && (hburst_r == HBURSTS_SINGLE) && (htrans_r == HTRANS_NONSEQ);
    wire uart_read = uart_cs && !hwrite_r && !(|haddr_r[3:0]);
    wire uart_write = uart_cs && hwrite_r && !(|haddr_r[3:0]);

    //uart_ctrl 波特率
    always @(posedge uart_clk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            uart_ctrl <= 8'd0;
            wf_data_i <= 8'd0;
        end else if (uart_write) begin
            wf_data_i <= hwdata_i[7:0];
        end else begin
            case (haddr_r[3:0])
                4'd1: begin
                    uart_ctrl <= hwdata_i[7:0];
                end
                //.....
                default: begin
                end
            endcase
            wf_data_i <= 8'd0;
        end
    end    

    assign wf_we = uart_write;
    assign rf_re = uart_read && !rf_empty;

    reg                    vaild;
    reg    [DWIDTH-1:0]    hrdata_r;

    always @(posedge uart_clk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            hrdata_r <= {DWIDTH{1'b0}};
            vaild <= 1'b0;
        end else if (rf_re) begin
            hrdata_r <= {{DWIDTH-8{1'b0}},rf_data_o};
            vaild <= 1'b1;
        end else begin
            hrdata_r <= {DWIDTH{1'b0}};
            vaild <= 1'b0;
        end
    end

    assign hrdata_o = hrdata_r;
    assign hreadyout_o = !uart_cs || 
                        (uart_write && !wf_full) || 
                        vaild;
    assign hresp_o = 1'b0; //ok

   

    uart_rx u_uart_rx (
        .clk (uart_clk),
        .rst_n (hresetn),
        .data_o (rf_data_i),
        .full_i(rf_full),
        .we_o (rf_we),
        .rx (rx)
    );

    sync_r_fifo #(
        .DEPTH(DEPTH),
        .DWIDTH(8)        
    )
    _sync_r_fifo (
        .clk(uart_clk),
        .rst_n(hresetn),
        .ren_i(rf_re),
        .rdata_o(rf_data_o),
        .wen_i(rf_we),
        .wdata_i(rf_data_i),
        .full_o(rf_full),
        .empty_o(rf_empty)
    );

    uart_tx u_uart_tx (
        .clk (clk_tx),
        .rst_n (hresetn),
        .data_i (wf_data_o),
        .empty_i (wf_empty),
        .valid_i(wf_valid),
        .re_o (wf_re),
        .tx (tx)
    ); 

    async_w_fifo #(
        .DEPTH(DEPTH),
        .DWIDTH(8)        
    )
    u_async_w_fifo (
        .rst_n(hresetn),
        .rclk(clk_tx),
        .renc_i(wf_re),
        .rdata_o(wf_data_o),
        .wclk(uart_clk),
        .wenc_i(wf_we),
        .wdata_i(wf_data_i),
        .full_o(wf_full),
        .empty_o(wf_empty),
        .valid_o(wf_valid)
    ); 

endmodule