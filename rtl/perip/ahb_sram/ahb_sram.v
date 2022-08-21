module ahb_sram #(
    parameter  AWIDTH = 32,   
    parameter  DWIDTH = 32    
)(
    input   wire                    hclk        ,
    input   wire                    sram_clk    ,
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
    output  wire    [DWIDTH-1:0]    hrdata_o    
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

    assign hreadyout_o = 1'b1; //sram一直有效
    assign hresp_o = 1'b0; //ok

    wire    sram_cs = (hburst_r == HBURSTS_SINGLE) || (htrans_r == HTRANS_NONSEQ);
    wire    sram_read = sram_cs && !hwrite_r;
    wire    sram_write = sram_cs && hwrite_r;
    wire    sram_wen = !sram_write;

    wire    sram_bank_sel = haddr_r[15] ? 1'b1 : 1'b0; //sram_bank_sel = 1'b1 select bank1
    wire    [DWIDTH-1:0]    sram_wdata = hwdata_i;

    wire    [DWIDTH-1:0]    sram_bank0_rdata;
    wire    [DWIDTH-1:0]    sram_bank1_rdata;
    wire    [DWIDTH-1:0]    sram_rdata = sram_bank_sel ? sram_bank1_rdata : sram_bank0_rdata;

    assign hrdata_o = sram_rdata;

    wire    [12:0]  sram_addr = haddr_r[AWIDTH-1:2]; //sram_addr=haddr/4

    reg [3:0]   bank_csn;
    always @(*) begin
        bank_csn = 4'b1111;
        case (hsize_r)
            3'b010: begin //32bit
                bank_csn = 4'b0000;
            end
            3'b001: begin //16bit
                if (haddr_r[1]) begin
                    bank_csn = 4'b0011;                    
                end else begin
                    bank_csn = 4'b1100;
                end
            end
            3'b000: begin //8bit
                case(haddr_r[1:0])
                    2'b00: begin
                        bank_csn = 4'b0001;
                    end
                    2'b01: begin
                        bank_csn = 4'b0010;
                    end
                    2'b10: begin
                        bank_csn = 4'b0100;
                    end
                    2'b11: begin
                        bank_csn = 4'b1000;
                    end
                endcase
            end
        endcase
    end

    wire    [3:0]   bank0_csn = (sram_cs && !sram_bank_sel) ? bank_csn : 4'b1111;
    wire    [3:0]   bank1_csn = (sram_cs && sram_bank_sel) ? bank_csn : 4'b1111;

    genvar i;
    for (i=0; i<4; i=i+1) begin: bank0 //DWIDTH/8
        sram_8kx8 u_sram_8kx8(
            .clk(sram_clk),
            .cen_i(bank0_csn[i]),
            .wen_i(sram_wen),
            .addr_i(sram_addr),
            .data_i(sram_wdata[i*8+:8]),
            .data_o(sram_bank0_rdata[i*8+:8])
        );
    end

    genvar j;
    for (j=0; j<4; j=j+1) begin: bank1
        sram_8kx8 u_sram_8kx8(
            .clk(sram_clk),
            .cen_i(bank1_csn[j]),
            .wen_i(sram_wen),
            .addr_i(sram_addr),
            .data_i(sram_wdata[j*8+:8]),
            .data_o(sram_bank1_rdata[j*8+:8])
        );
    end

endmodule //ahb_sram
