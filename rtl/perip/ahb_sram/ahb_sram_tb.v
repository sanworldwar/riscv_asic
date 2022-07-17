`include "../../core/defines.v"

module ahb_sram_tb ();
    reg                     hclk        ;
    reg                     sram_clk    ;
    reg    		            hresetn     ;
    
    reg    		            hsel_i      ;
    reg   	 	            hwrite_i    ;
    reg			            hready_i    ;
    reg    [2:0]  	        hsize_i     ;
    reg    [2:0]  	        hburst_i    ;
    reg    [1:0]  	        htrans_i    ;
    reg    [`HDATA_BUS] 	hwdata_i    ;
    reg    [`HADDR_BUS] 	haddr_i     ;	
    
    wire                    hreadyout_o ;
    wire    [1:0]           hresp_o     ;
    wire    [`HDATA_BUS]    hrdata_o    ; 

    always #10 hclk = ~hclk;
    always @ (*) sram_clk = ~hclk;

    initial begin
        hclk <= 1'b0;
        hresetn <= 1'b0;
        hsel_i <= 1'b0;
        hwrite_i <= 1'b0;
        hready_i <= hreadyout_o;
        hsize_i <= 3'b000;
        hburst_i <= 3'b000;
        htrans_i <= 2'b00;
        hwdata_i <= `HDATA_BUS_WIDTH'h0;
        haddr_i <= `HADDR_BUS_WIDTH'h0;
        #10 hresetn <= 1'b1;
        #1000 $finish;
    end

    initial begin
        $dumpfile("ahb_sram_tb.vcd");
        $dumpvars(0, ahb_sram_tb.u_ahb_sram);
    end

    initial begin     //“=”如果在时钟有效沿处，数据变化，则会检测到变化后的值
        #50           //“<=”如果在时钟有效沿处，数据变化，则会检测到变化前的值  
        hsel_i <= 1'b1;  
        hwrite_i <= 1'b1;
        hsize_i <= 3'b010;
        hburst_i <= 3'b000; //SINGLE
        htrans_i <= 2'b10; //NONSEQ 
        haddr_i <= `HADDR_BUS_WIDTH'h0;       
        repeat (5) begin
            #20
            hwdata_i <= $random;
            haddr_i <= haddr_i + `HADDR_BUS_WIDTH'h4;
        end
        haddr_i <= `HADDR_BUS_WIDTH'h0;
        hwrite_i <= 1'b0;
        repeat (5) begin
            #20
            haddr_i <= haddr_i + `HADDR_BUS_WIDTH'h4;
        end        
    end

    ahb_sram u_ahb_sram(
        .hclk(hclk),
        .sram_clk(sram_clk),
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
        .hrdata_o(hrdata_o)
    );


endmodule //ahb_sram_tb
