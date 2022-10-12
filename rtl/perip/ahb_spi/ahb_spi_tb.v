module ahb_spi_tb ();
    reg                     hclk        ;
    reg    		            hresetn     ;
    
    reg    		            hsel_i      ;
    reg   	 	            hwrite_i    ;
    reg			            hready_i    ;
    reg    [2:0]  	        hsize_i     ;
    reg    [2:0]  	        hburst_i    ;
    reg    [1:0]  	        htrans_i    ;
    reg    [31:0] 	        hwdata_i    ;
    reg    [31:0] 	        haddr_i     ;	
    
    wire                    hreadyout_o ;
    wire                    hresp_o     ;
    wire    [31:0]          hrdata_o    ; 

    wire                    spi_clk     ;
    reg                     spi_miso    ;
    wire                    spi_mosi    ;
    wire    [4:3]           spi_nss     ;

    always #10 hclk = ~hclk;

    always @ (*) begin
        hready_i = hreadyout_o;
    end

    initial begin
        hclk <= 1'b0;
        hresetn <= 1'b0;
        hsel_i <= 1'b0;
        hwrite_i <= 1'b0;
        hsize_i <= 3'b000;
        hburst_i <= 3'b000;
        htrans_i <= 2'b00;
        hwdata_i <= 32'h0;
        haddr_i <= 32'h0;
        #10 hresetn <= 1'b1;
        #5000 $finish;
    end


    initial begin     //“=”如果在时钟有效沿处，数据变化，则会检测到变化后的值
        #50           //“<=”如果在时钟有效沿处，数据变化，则会检测到变化前的值  
        hsel_i <= 1'b1;  
        hwrite_i <= 1'b1;
        hsize_i <= 3'b010;
        hburst_i <= 3'b000; //SINGLE
        htrans_i <= 2'b10; //NONSEQ 
        haddr_i <= 32'h1;       

        #20
        hwdata_i <= {24'd0,8'b00100111};
        haddr_i <= 32'h0;
        #20
        hwdata_i <= {24'd0,8'b01101011};
        #40
        hwdata_i <= {24'd0,8'b10100011};
        #40
        hsel_i <= 1'b0;
        #3500
        hsel_i <= 1'b1; 
        hwrite_i <= 1'b0;
        #80
        hsel_i <= 1'b0;      
    end

    initial begin
        spi_miso <= 1'b0;
        #190 
            repeat (8) begin
                spi_miso <= ~spi_miso;
                #40;
            end
    end

    initial begin
        $dumpfile("ahb_spi_tb.vcd");
        $dumpvars(0,ahb_spi_tb.u_ahb_spi);
    end


    ahb_spi u_ahb_spi(
        .hclk(hclk),
        .hresetn(hresetn),

        .hsel_i(hsel_i),
        .hwrite_i(hwrite_i),
        .hready_i(hready_i),
        .hsize_i(hsize_i),
        .hburst_i(hburst_i),
        .htrans_i(htrans_i),
        .hwdata_i(hwdata_i),
        .haddr_i(haddr_i),

        .hreadyout_o(hreadyout_o),
        .hresp_o(hresp_o),
        .hrdata_o(hrdata_o),

        .spi_clk(spi_clk),
        .spi_miso(spi_miso),
        .spi_mosi(spi_mosi),
        .spi_nss(spi_nss)
    );

endmodule