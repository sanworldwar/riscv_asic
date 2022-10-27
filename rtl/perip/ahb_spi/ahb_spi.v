module ahb_spi #(
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


    output  reg                     spi_clk     ,
    input   wire                    spi_miso    ,
    output  wire                    spi_mosi    ,
    output  wire    [1:0]           spi_nss
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

    localparam SPI_DATA = 4'h0;
    localparam SPI_CTRL = 4'h4;

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

    //rfifo
    reg [7:0]   rf_wdata;
    reg         rf_we;
    wire        rf_re;

    wire [7:0]  rf_rdata;
    wire        rf_full;
    wire        rf_empty;
    //wfifo
    wire [7:0]  wf_wdata;
    reg         wf_we;
    reg         wf_re;

    wire [7:0]  wf_rdata;
    wire        wf_full;
    wire        wf_empty;

    reg [1:0]   state, next_state;

    wire spi_cs = hsel_i && (hburst_r == HBURSTS_SINGLE) && (htrans_r == HTRANS_NONSEQ);
    wire spi_read = spi_cs && !hwrite_r && (haddr_r[3:0] == SPI_DATA);  //!(|haddr_r[3:0])
    wire spi_write = spi_cs && hwrite_r && (haddr_r[3:0] == SPI_DATA);
    wire spi_reg_read = spi_cs && !hwrite_r && !(haddr_r[3:0] == SPI_DATA);
    wire spi_reg_write = spi_cs && hwrite_r && !(haddr_r[3:0] == SPI_DATA);

    reg [7:0]  spi_ctrl; //[0]:en [1]:CPOL, [2]:CPHA, [4:3]:NSS, [7:5]:div
    wire [3:0] spi_div = spi_ctrl[7:5];
    wire en = spi_ctrl[0];
    wire CPOL = spi_ctrl[1];
    wire CPHA = spi_ctrl[2];
    
    assign spi_nss = en ? spi_ctrl[4:3] : 2'b11;    
    
    //ahb端逻辑
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
                if (spi_read) begin
                    if (!rf_empty) begin
                        next_state = PREPARE; //PREPARE   hready_i=1时会无效读，lsu此时地址未备好，下同
                    end else begin
                        next_state = WAIT_READ;
                    end
                end else if (spi_write) begin
                    if (!wf_full) begin
                        next_state = PREPARE; //PREPARE
                    end else begin
                        next_state = WAIT_WRITE;
                    end
                end else if (spi_reg_read) begin
                    next_state = PREPARE; //PREPARE
                end else if (spi_reg_write) begin
                    next_state = PREPARE; //PREPARE
                end else begin
                    next_state = IDLE;
                end
            end     
            WAIT_READ : begin   
                if (spi_read) begin
                    if (!rf_empty) begin
                        next_state = PREPARE; //PREPARE
                    end else begin
                        next_state = WAIT_READ;
                    end                
                end           
            end
            WAIT_WRITE : begin   
                if (spi_write) begin
                    if (!wf_full) begin
                        next_state = PREPARE; //PREPARE
                    end else begin
                        next_state = WAIT_WRITE;
                    end                
                end           
            end
        endcase
    end


    assign wf_wdata = hwdata_i[7:0];

    assign wf_we = spi_write && !wf_full && ((state == PREPARE) || (state == WAIT_WRITE));

    reg    [DWIDTH-1:0]    hrdata_r;

    assign rf_re = spi_read && !rf_empty && ((state == PREPARE) || (state == WAIT_READ));

    always @(*) begin
        if (rf_re) begin
            hrdata_r = {{DWIDTH-8{1'b0}},rf_rdata};
        end else if (spi_reg_read && (state == PREPARE)) begin
            case (haddr_r[3:0])
                SPI_CTRL: begin
                    hrdata_r = spi_ctrl;
                end
                //.....
                default: begin
                    hrdata_r = {DWIDTH{1'b0}};
                end
            endcase            
        end else begin
            hrdata_r = {DWIDTH{1'b0}};
        end
    end 
 
    assign hrdata_o = hrdata_r; //
    assign hreadyout_o = ((next_state == IDLE) || (next_state == PREPARE));
    assign hresp_o = 1'b0; //ok

    always @(posedge hclk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            spi_ctrl <= 8'h0;
        end else if (spi_reg_write) begin
            case (haddr_r[3:0])
                SPI_CTRL: begin
                    spi_ctrl <= hwdata_i[7:0];
                end
                //.....
                default: begin

                end
            endcase
        end
    end 

    //spi端逻辑
    reg [7:0]  spi_rdata;
    reg [7:0]  spi_wdata;
    
    reg [3:0]  spi_cnt;
    reg [3:0]  spi_count;
    reg        done;
    reg        start;

    always @(posedge hclk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            wf_re <= 1'b0;
        end else if (en && !wf_empty && done) begin  
            wf_re <= 1'b1; 
        end else begin
            wf_re <= 1'b0;
        end
    end

    always @(posedge hclk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            start <= 1'b0;
        end else if (!done) begin  
            start <= 1'd1; 
        end else begin
            start <= 1'b0;
        end
    end

    always @(posedge hclk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            done <= 1'd1;
        end else if (en && !wf_empty && done) begin  
            done <= 1'b0; 
        end else if ((spi_count == spi_div-4'd1) && (spi_cnt == 'd15)) begin
            done <= 1'd1;
        end
    end

    always @(posedge hclk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            spi_count <= 4'h0;
        end else begin
            if (start && !done) begin
                if (spi_count == spi_div-4'd1) begin
                    spi_count <= 4'h0;
                end else begin
                    spi_count <= spi_count + 4'd1;
                end 
            end else begin
                spi_count <= 4'h0;
            end
        end
    end

    always @(posedge hclk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            spi_clk <= CPOL;
        end else begin
            if (start && !done) begin
                if (spi_count == spi_div-4'd1) begin
                    spi_clk <= ~spi_clk;
                end else begin
                    spi_clk <= spi_clk;
                end
            end else begin
                spi_clk = CPOL;
            end
        end
    end

    always @(posedge hclk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            spi_cnt <= 4'h0;
        end else begin
            if (start && !done) begin
                if (spi_count == spi_div-4'd1) begin
                    spi_cnt <= spi_cnt + 4'd1;
                end else if ((spi_cnt == 4'd15) && (spi_count == spi_div-4'd1)) begin
                    spi_cnt = 4'h0;
                end else begin
                    spi_cnt <= spi_cnt;
                end
            end else begin
                spi_cnt = 4'h0;
            end
        end
    end


    reg spi_mosi_CPHA;

    assign spi_mosi =  CPHA ? spi_mosi_CPHA : spi_wdata[7];

    always @(posedge hclk or negedge hresetn) begin
        if (hresetn == 1'b0) begin          
            spi_rdata <= 8'h0;
            spi_mosi_CPHA <= 1'b0;
            spi_wdata <= 8'h0;
        end else begin
            if (wf_re) begin  
                spi_wdata <= wf_rdata;
            end
            if (start && !done) begin
                if (spi_count == spi_div-4'd1) begin
                    case (spi_cnt)
                        'h0,'d2,'d4,'d6,'d8,'d10,'d12,'d14: begin                       
                            if (CPHA) begin
                                spi_wdata <= spi_wdata << 1'b1;
                                spi_mosi_CPHA <= spi_wdata[7];                           
                            end else begin                           
                                spi_rdata <= {spi_rdata[6:0], spi_miso};
                            end             
                        end
                        'd1,'d3,'d5,'d7,'d9,'d11,'d13,'d15: begin
                            if (CPHA) begin     
                                spi_rdata <= {spi_rdata[6:0], spi_miso};
                            end else begin
                                spi_wdata <= spi_wdata << 1'b1;
                            end
                        end
                        default: begin
                            
                        end
                    endcase
                end
            end 
        end
    end

    always @(posedge hclk or negedge hresetn) begin
        if (hresetn == 1'b0) begin
            rf_we <= 1'b0;
            rf_wdata <= 8'h0;
        end else if (done && start && !rf_full) begin  
            rf_we <= 1'b1; 
            rf_wdata <= spi_rdata;
        end else begin
            rf_we <= 1'b0;
            rf_wdata <= 8'h0;
        end
    end

    sync_fifo #(
        .DEPTH(DEPTH),
        .DWIDTH(8)        
    ) 
    w_fifo (
        .clk (hclk), 
        .rst_n (hresetn), 
        .ren_i (wf_re), 
        .rdata_o (wf_rdata), 
        .wen_i (wf_we), 
        .wdata_i (wf_wdata), 
        .full_o (wf_full), 
        .empty_o (wf_empty)
    );

    sync_fifo #(
        .DEPTH(DEPTH),
        .DWIDTH(8)        
    )
    r_fifo (
        .clk (hclk), 
        .rst_n (hresetn), 
        .ren_i (rf_re), 
        .rdata_o (rf_rdata), 
        .wen_i (rf_we), 
        .wdata_i (rf_wdata), 
        .full_o (rf_full), 
        .empty_o (rf_empty)
    );

endmodule