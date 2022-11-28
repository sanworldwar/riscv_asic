module ahb_uart_tb ();
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

    wire                    tx;
    reg                     rx;

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

    initial begin
        $dumpfile("ahb_uart_tb.vcd");
        $dumpvars(0, ahb_uart_tb.u_ahb_uart);
    end

    initial begin     //“=”如果在时钟有效沿处，数据变化，则会检测到变化后的值
        #50           //“<=”如果在时钟有效沿处，数据变化，则会检测到变化前的值  
        hsel_i <= 1'b1;  
        hwrite_i <= 1'b1;
        hsize_i <= 3'b010;
        hburst_i <= 3'b000; //SINGLE
        htrans_i <= 2'b10; //NONSEQ 
        haddr_i <= 32'h4;
        hwdata_i <= {24'd0,8'b00000011};
        #20
        haddr_i <= 32'h0;
        hwdata_i <= {24'd0,8'b00100111}; //流水线，.v IDLE -> PREPARE
        #20
        hwdata_i <= {24'd0,8'b01101011};
        #20
        hwdata_i <= {24'd0,8'b10100011};
        hwrite_i <= 1'b0;
        #20
        hsel_i <= 1'b0;
        #3500
        hsel_i <= 1'b1; 
        hwrite_i <= 1'b0;
        #80
        hsel_i <= 1'b0;      
    end

    initial begin  //波特率分频比为8
        rx = 1'b1;
        #80 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b1;
        
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b1;
        
     /*   #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b1;
        #160 rx <= 1'b1;
        #160 rx <= 1'b1;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b1;      */  
        
    end

    ahb_uart u_ahb_uart(
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

        .tx(tx),
        .rx(rx)
    );


endmodule //ahb_sram_tb
