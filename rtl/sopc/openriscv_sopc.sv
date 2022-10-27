`include "../core/defines.v"

module openrisc_sopc #(
    parameter MASTERS = 2,
    parameter SLAVES = 2
)(
    input   wire            clk         ,
    input   wire            rst_n       ,

    input   wire            rx          ,   
    output  wire            tx          ,

    output  wire            spi_clk     ,
    input   wire            spi_miso    ,
    output  wire            spi_mosi    ,
    output  wire    [1:0]   spi_nss     ,

    inout   wire    [1:0]   pin_io 
);
    //if_ahb_interface信号与AHB的信号
    wire                    if_mst_hsel_o       ;
    wire    [1:0]           if_mst_htrans_o     ;
    wire    [`HADDR_BUS]    if_mst_haddr_o      ;
    wire    [`HDATA_BUS]    if_mst_hwdata_o     ;
    wire                    if_mst_hwrite_o     ;
    wire    [2:0]           if_mst_hsize_o      ;
    wire    [2:0]           if_mst_hburst_o     ;
    wire    [3:0]           if_mst_hprot_o      ;
    wire                    if_mst_hmastlock_o  ;
    wire                    if_mst_priority_o   ;   
    wire                    if_mst_hready_i     ;
    wire                    if_mst_hresp_i      ;
    wire    [`HDATA_BUS]    if_mst_hrdata_i     ;

    //ls_ahb_interface信号与AHB的信号
    wire                    ls_mst_hsel_o       ;
    wire    [1:0]           ls_mst_htrans_o     ;
    wire    [`HADDR_BUS]    ls_mst_haddr_o      ;
    wire    [`HDATA_BUS]    ls_mst_hwdata_o     ;
    wire                    ls_mst_hwrite_o     ;
    wire    [2:0]           ls_mst_hsize_o      ;
    wire    [2:0]           ls_mst_hburst_o     ;
    wire    [3:0]           ls_mst_hprot_o      ;
    wire                    ls_mst_hmastlock_o  ;
    wire                    ls_mst_priority_o   ;
    wire                    ls_mst_hready_i     ;
    wire                    ls_mst_hresp_i      ;
    wire    [`HDATA_BUS]    ls_mst_hrdata_i     ;

    //ahb_sram_1的信号
    wire    		        sram_1_hsel_i       ;
    wire   	 	            sram_1_hwrite_i     ;
    wire			        sram_1_hready_i     ;
    wire    [2:0]  	        sram_1_hsize_i      ;
    wire    [2:0]  	        sram_1_hburst_i     ;
    wire    [1:0]  	        sram_1_htrans_i     ;
    wire    [`HDATA_BUS] 	sram_1_hwdata_i     ;
    wire    [`HADDR_BUS] 	sram_1_haddr_i      ;	
    
    wire                    sram_1_hreadyout_o  ;
    wire                    sram_1_hresp_o      ;
    wire    [`HDATA_BUS]    sram_1_hrdata_o     ;     

    //ahb_sram_2的信号
    wire    		        sram_2_hsel_i       ;
    wire   	 	            sram_2_hwrite_i     ;
    wire			        sram_2_hready_i     ;
    wire    [2:0]  	        sram_2_hsize_i      ;
    wire    [2:0]  	        sram_2_hburst_i     ;
    wire    [1:0]  	        sram_2_htrans_i     ;
    wire    [`HDATA_BUS] 	sram_2_hwdata_i     ;
    wire    [`HADDR_BUS] 	sram_2_haddr_i      ;	
    
    wire                    sram_2_hreadyout_o  ;
    wire                    sram_2_hresp_o      ;
    wire    [`HDATA_BUS]    sram_2_hrdata_o     ; 

    //uart的信号
    wire    		        uart_hsel_i         ;
    wire   	 	            uart_hwrite_i       ;
    wire			        uart_hready_i       ;
    wire    [2:0]  	        uart_hsize_i        ;
    wire    [2:0]  	        uart_hburst_i       ;
    wire    [1:0]  	        uart_htrans_i       ;
    wire    [`HDATA_BUS] 	uart_hwdata_i       ;
    wire    [`HADDR_BUS] 	uart_haddr_i        ;
    
    wire                    uart_hreadyout_o    ;
    wire                    uart_hresp_o        ;
    wire    [`HDATA_BUS]    uart_hrdata_o       ;

    //spi的信号
    wire    		        spi_hsel_i          ;
    wire   	 	            spi_hwrite_i        ;
    wire			        spi_hready_i        ;
    wire    [2:0]  	        spi_hsize_i         ;
    wire    [2:0]  	        spi_hburst_i        ;
    wire    [1:0]  	        spi_htrans_i        ;
    wire    [`HDATA_BUS] 	spi_hwdata_i        ;
    wire    [`HADDR_BUS] 	spi_haddr_i         ;
    
    wire                    spi_hreadyout_o     ;
    wire                    spi_hresp_o         ;
    wire    [`HDATA_BUS]    spi_hrdata_o        ;  

    //timer的信号
    wire    		        timer_hsel_i        ;
    wire   	 	            timer_hwrite_i      ;
    wire			        timer_hready_i      ;
    wire    [2:0]  	        timer_hsize_i       ;
    wire    [2:0]  	        timer_hburst_i      ;
    wire    [1:0]  	        timer_htrans_i      ;
    wire    [`HDATA_BUS] 	timer_hwdata_i      ;
    wire    [`HADDR_BUS] 	timer_haddr_i       ;
    
    wire                    timer_hreadyout_o   ;
    wire                    timer_hresp_o       ;
    wire    [`HDATA_BUS]    timer_hrdata_o      ;

    wire                    timer_irq           ;  

    //gpio的信号
    wire    		        gpio_hsel_i         ;
    wire   	 	            gpio_hwrite_i       ;
    wire			        gpio_hready_i       ;
    wire    [2:0]  	        gpio_hsize_i        ;
    wire    [2:0]  	        gpio_hburst_i       ;
    wire    [1:0]  	        gpio_htrans_i       ;
    wire    [`HDATA_BUS] 	gpio_hwdata_i       ;
    wire    [`HADDR_BUS] 	gpio_haddr_i        ;	
    
    wire                    gpio_hreadyout_o    ;
    wire                    gpio_hresp_o        ;
    wire    [`HDATA_BUS]    gpio_hrdata_o       ;  


    wire                    mst_hsel_o      [MASTERS];
    wire    [1:0]           mst_htrans_o    [MASTERS];
    wire    [`HADDR_BUS]    mst_haddr_o     [MASTERS]; 
    wire    [`HDATA_BUS]    mst_hwdata_o    [MASTERS]; 
    wire                    mst_hwrite_o    [MASTERS];
    wire    [2:0]           mst_hsize_o     [MASTERS];
    wire    [2:0]           mst_hburst_o    [MASTERS];
    wire    [3:0]           mst_hprot_o     [MASTERS];
    wire                    mst_hmastlock_o [MASTERS];
    wire                    mst_priority_o  [MASTERS];
    wire                    mst_hready_i    [MASTERS];
    wire                    mst_hresp_i     [MASTERS];
    wire    [`HDATA_BUS]    mst_hrdata_i    [MASTERS];


    assign mst_hsel_o[0] = if_mst_hsel_o;
    assign mst_htrans_o[0] = if_mst_htrans_o;
    assign mst_haddr_o[0] = if_mst_haddr_o;
    assign mst_hwdata_o[0] = if_mst_hwdata_o;
    assign mst_hwrite_o[0] = if_mst_hwrite_o;
    assign mst_hsize_o[0] = if_mst_hsize_o;
    assign mst_hburst_o[0] = if_mst_hburst_o;
    assign mst_hprot_o[0] = if_mst_hprot_o;
    assign mst_hmastlock_o[0] = if_mst_hmastlock_o;
    assign mst_priority_o[0] = if_mst_priority_o;
    assign if_mst_hready_i = mst_hready_i[0];
    assign if_mst_hresp_i = mst_hresp_i[0];
    assign if_mst_hrdata_i = mst_hrdata_i[0];


    assign mst_hsel_o[1] = ls_mst_hsel_o;
    assign mst_htrans_o[1] = ls_mst_htrans_o;
    assign mst_haddr_o[1] = ls_mst_haddr_o;
    assign mst_hwdata_o[1] = ls_mst_hwdata_o;
    assign mst_hwrite_o[1] = ls_mst_hwrite_o;
    assign mst_hsize_o[1] = ls_mst_hsize_o;
    assign mst_hburst_o[1] = ls_mst_hburst_o;
    assign mst_hprot_o[1] = ls_mst_hprot_o;
    assign mst_hmastlock_o[1] = ls_mst_hmastlock_o;
    assign mst_priority_o[1] = ls_mst_priority_o;
    assign ls_mst_hready_i = mst_hready_i[1];
    assign ls_mst_hresp_i = mst_hresp_i[1];
    assign ls_mst_hrdata_i = mst_hrdata_i[1];

    wire    [`HADDR_BUS]    slv_addr_mask   [SLAVES];
    wire    [`HADDR_BUS]    slv_addr_base   [SLAVES];
    wire    		        slv_hsel_i      [SLAVES];
    wire   	 	            slv_hwrite_i    [SLAVES];
    wire			        slv_hready_i    [SLAVES];
    wire    [2:0]  	        slv_hsize_i     [SLAVES];
    wire    [2:0]  	        slv_hburst_i    [SLAVES];
    wire    [1:0]  	        slv_htrans_i    [SLAVES];
    wire    [`HDATA_BUS] 	slv_hwdata_i    [SLAVES];
    wire    [`HADDR_BUS] 	slv_haddr_i     [SLAVES];	
    wire                    slv_hreadyout_o [SLAVES];
    wire                    slv_hresp_o     [SLAVES];
    wire    [`HDATA_BUS]    slv_hrdata_o    [SLAVES];

    assign slv_addr_mask[0] = 32'hF0000000;
    assign slv_addr_base[0] = 32'h00000000;
    assign sram_1_hsel_i = slv_hsel_i[0];
    assign sram_1_hwrite_i = slv_hwrite_i[0];
    assign sram_1_hready_i = slv_hready_i[0];
    assign sram_1_hsize_i = slv_hsize_i[0];
    assign sram_1_hburst_i = slv_hburst_i[0];
    assign sram_1_htrans_i = slv_htrans_i[0];
    assign sram_1_hwdata_i = slv_hwdata_i[0];
    assign sram_1_haddr_i = slv_haddr_i[0];
    assign slv_hreadyout_o[0] = sram_1_hreadyout_o;
    assign slv_hresp_o[0] = sram_1_hresp_o;
    assign slv_hrdata_o[0] = sram_1_hrdata_o;

    assign slv_addr_mask[1] = 32'hF0000000;
    assign slv_addr_base[1] = 32'h10000000;
    assign sram_2_hsel_i = slv_hsel_i[1];
    assign sram_2_hwrite_i = slv_hwrite_i[1];
    assign sram_2_hready_i = slv_hready_i[1];
    assign sram_2_hsize_i = slv_hsize_i[1];
    assign sram_2_hburst_i = slv_hburst_i[1];
    assign sram_2_htrans_i = slv_htrans_i[1];
    assign sram_2_hwdata_i = slv_hwdata_i[1];
    assign sram_2_haddr_i = slv_haddr_i[1];
    assign slv_hreadyout_o[1] = sram_2_hreadyout_o;
    assign slv_hresp_o[1] = sram_2_hresp_o;
    assign slv_hrdata_o[1] = sram_2_hrdata_o;

    assign slv_addr_mask[2] = 32'hF0000000;
    assign slv_addr_base[2] = 32'h20000000;
    assign uart_hsel_i = slv_hsel_i[2];
    assign uart_hwrite_i = slv_hwrite_i[2];
    assign uart_hready_i = slv_hready_i[2];
    assign uart_hsize_i = slv_hsize_i[2];
    assign uart_hburst_i = slv_hburst_i[2];
    assign uart_htrans_i = slv_htrans_i[2];
    assign uart_hwdata_i = slv_hwdata_i[2];
    assign uart_haddr_i = slv_haddr_i[2];
    assign slv_hreadyout_o[2] = uart_hreadyout_o;
    assign slv_hresp_o[2] = uart_hresp_o;
    assign slv_hrdata_o[2] = uart_hrdata_o;

    assign slv_addr_mask[3] = 32'hF0000000;
    assign slv_addr_base[3] = 32'h30000000;
    assign spi_hsel_i = slv_hsel_i[3];
    assign spi_hwrite_i = slv_hwrite_i[3];
    assign spi_hready_i = slv_hready_i[3];
    assign spi_hsize_i = slv_hsize_i[3];
    assign spi_hburst_i = slv_hburst_i[3];
    assign spi_htrans_i = slv_htrans_i[3];
    assign spi_hwdata_i = slv_hwdata_i[3];
    assign spi_haddr_i = slv_haddr_i[3];
    assign slv_hreadyout_o[3] = spi_hreadyout_o;
    assign slv_hresp_o[3] = spi_hresp_o;
    assign slv_hrdata_o[3] = spi_hrdata_o;

    assign slv_addr_mask[4] = 32'hF0000000;
    assign slv_addr_base[4] = 32'h40000000;
    assign timer_hsel_i = slv_hsel_i[4];
    assign timer_hwrite_i = slv_hwrite_i[4];
    assign timer_hready_i = slv_hready_i[4];
    assign timer_hsize_i = slv_hsize_i[4];
    assign timer_hburst_i = slv_hburst_i[4];
    assign timer_htrans_i = slv_htrans_i[4];
    assign timer_hwdata_i = slv_hwdata_i[4];
    assign timer_haddr_i = slv_haddr_i[4];
    assign slv_hreadyout_o[4] = timer_hreadyout_o;
    assign slv_hresp_o[4] = timer_hresp_o;
    assign slv_hrdata_o[4] = timer_hrdata_o;

    assign slv_addr_mask[5] = 32'hF0000000;
    assign slv_addr_base[5] = 32'h50000000;
    assign gpio_hsel_i = slv_hsel_i[5];
    assign gpio_hwrite_i = slv_hwrite_i[5];
    assign gpio_hready_i = slv_hready_i[5];
    assign gpio_hsize_i = slv_hsize_i[5];
    assign gpio_hburst_i = slv_hburst_i[5];
    assign gpio_htrans_i = slv_htrans_i[5];
    assign gpio_hwdata_i = slv_hwdata_i[5];
    assign gpio_haddr_i = slv_haddr_i[5];
    assign slv_hreadyout_o[5] = gpio_hreadyout_o;
    assign slv_hresp_o[5] = gpio_hresp_o;
    assign slv_hrdata_o[5] = gpio_hrdata_o;

    openriscv u_openriscv(
        .clk(clk),
        .rst_n(rst_n),

        .timer_irq_i(timer_irq),

        .if_mst_hsel_o(if_mst_hsel_o),
        .if_mst_htrans_o(if_mst_htrans_o),
        .if_mst_haddr_o(if_mst_haddr_o),
        .if_mst_hwdata_o(if_mst_hwdata_o),
        .if_mst_hwrite_o(if_mst_hwrite_o),
        .if_mst_hsize_o(if_mst_hsize_o),
        .if_mst_hburst_o(if_mst_hburst_o),
        .if_mst_hprot_o(if_mst_hprot_o),
        .if_mst_hmastlock_o(if_mst_hmastlock_o),
        .if_mst_priority_o(if_mst_priority_o),
        .if_mst_hready_i(if_mst_hready_i),
        .if_mst_hresp_i(if_mst_hresp_i),
        .if_mst_hrdata_i(if_mst_hrdata_i),

        .ls_mst_hsel_o(ls_mst_hsel_o),
        .ls_mst_htrans_o(ls_mst_htrans_o),
        .ls_mst_haddr_o(ls_mst_haddr_o),
        .ls_mst_hwdata_o(ls_mst_hwdata_o),
        .ls_mst_hwrite_o(ls_mst_hwrite_o),
        .ls_mst_hsize_o(ls_mst_hsize_o),
        .ls_mst_hburst_o(ls_mst_hburst_o),
        .ls_mst_hprot_o(ls_mst_hprot_o),
        .ls_mst_hmastlock_o(ls_mst_hmastlock_o),
        .ls_mst_priority_o(ls_mst_priority_o),
        .ls_mst_hready_i(ls_mst_hready_i),
        .ls_mst_hresp_i(ls_mst_hresp_i),
        .ls_mst_hrdata_i(ls_mst_hrdata_i)        
    );

    ahb3lite_interconnect #(
        .HADDR_SIZE(32),
        .HDATA_SIZE(32),
        .MASTERS(MASTERS),
        .SLAVES(SLAVES),
        .SLAVE_MASK(),
        .ERROR_ON_SLAVE_MASK(),
        .ERROR_ON_NO_SLAVE()
    )
    u_ahb3lite_interconnect(
        .HRESETn(rst_n),
        .HCLK(clk),

        .mst_priority(mst_priority_o),

        .mst_HSEL(mst_hsel_o),
        .mst_HADDR(mst_haddr_o),
        .mst_HWDATA(mst_hwdata_o),
        .mst_HRDATA(mst_hrdata_i),
        .mst_HWRITE(mst_hwrite_o),
        .mst_HSIZE(mst_hsize_o),
        .mst_HBURST(mst_hburst_o),
        .mst_HPROT(mst_hprot_o),
        .mst_HTRANS(mst_htrans_o),
        .mst_HMASTLOCK(mst_hmastlock_o),
        .mst_HREADYOUT(mst_hready_i),
        .mst_HREADY(mst_hready_i),
        .mst_HRESP(mst_hresp_i),

        .slv_addr_mask(slv_addr_mask),
        .slv_addr_base(slv_addr_base),
        .slv_HSEL(slv_hsel_i),
        .slv_HADDR(slv_haddr_i),
        .slv_HWDATA(slv_hwdata_i),
        .slv_HRDATA(slv_hrdata_o),
        .slv_HWRITE(slv_hwrite_i),
        .slv_HSIZE(slv_hsize_i),
        .slv_HBURST(slv_hburst_i),
        .slv_HPROT(),
        .slv_HTRANS(slv_htrans_i),
        .slv_HMASTLOCK(),
        .slv_HREADYOUT(slv_hready_i),
        .slv_HREADY(slv_hreadyout_o),
        .slv_HRESP(slv_hresp_o)
    );

    ahb_sram #(
        .AWIDTH(),
        .DWIDTH()
    )
    u1_ahb_sram(
        .hclk(clk),
        .hresetn(rst_n),

        .hsel_i(sram_1_hsel_i),
        .hwrite_i(sram_1_hwrite_i),
        .hready_i(sram_1_hready_i),
        .hsize_i(sram_1_hsize_i),
        .hburst_i(sram_1_hburst_i),
        .htrans_i(sram_1_htrans_i),
        .hwdata_i(sram_1_hwdata_i),
        .haddr_i(sram_1_haddr_i),

        .hreadyout_o(sram_1_hreadyout_o),
        .hresp_o(sram_1_hresp_o),
        .hrdata_o(sram_1_hrdata_o)
    );

    ahb_sram #(
        .AWIDTH(),
        .DWIDTH()
    )
    u2_ahb_sram(
        .hclk(clk),
        .hresetn(rst_n),

        .hsel_i(sram_2_hsel_i),
        .hwrite_i(sram_2_hwrite_i),
        .hready_i(sram_2_hready_i),
        .hsize_i(sram_2_hsize_i),
        .hburst_i(sram_2_hburst_i),
        .htrans_i(sram_2_htrans_i),
        .hwdata_i(sram_2_hwdata_i),
        .haddr_i(sram_2_haddr_i),

        .hreadyout_o(sram_2_hreadyout_o),
        .hresp_o(sram_2_hresp_o),
        .hrdata_o(sram_2_hrdata_o)
    );

    ahb_uart #(
        .AWIDTH(),
        .DWIDTH(),
        .DEPTH()
    ) 
    u_ahb_uart(
        .hclk(clk),
        .hresetn(rst_n),

        .hsel_i(uart_hsel_i),
        .hwrite_i(uart_hwrite_i),
        .hready_i(uart_hready_i),
        .hsize_i(uart_hsize_i),
        .hburst_i(uart_hburst_i),
        .htrans_i(uart_htrans_i),
        .hwdata_i(uart_hwdata_i),
        .haddr_i(uart_haddr_i),

        .hreadyout_o(uart_hreadyout_o),
        .hresp_o(uart_hresp_o),
        .hrdata_o(uart_hrdata_o),

        .tx(tx),
        .rx(rx)
    );

    ahb_spi #(
        .AWIDTH(),
        .DWIDTH(),
        .DEPTH()
    )
    u_ahb_spi(
        .hclk(clk),
        .hresetn(rst_n),

        .hsel_i(spi_hsel_i),
        .hwrite_i(spi_hwrite_i),
        .hready_i(spi_hready_i),
        .hsize_i(spi_hsize_i),
        .hburst_i(spi_hburst_i),
        .htrans_i(spi_htrans_i),
        .hwdata_i(spi_hwdata_i),
        .haddr_i(spi_haddr_i),

        .hreadyout_o(spi_hreadyout_o),
        .hresp_o(spi_hresp_o),
        .hrdata_o(spi_hrdata_o),

        .spi_clk(spi_clk),
        .spi_miso(spi_miso),
        .spi_mosi(spi_mosi),
        .spi_nss(spi_nss)
    );

    ahb_timer #(
        .AWIDTH(),
        .DWIDTH()
    )
    u_ahb_timer(
        .hclk(clk),
        .hresetn(rst_n),

        .hsel_i(timer_hsel_i),
        .hwrite_i(timer_hwrite_i),
        .hready_i(timer_hready_i),
        .hsize_i(timer_hsize_i),
        .hburst_i(timer_hburst_i),
        .htrans_i(timer_htrans_i),
        .hwdata_i(timer_hwdata_i),
        .haddr_i(timer_haddr_i),

        .hreadyout_o(timer_hreadyout_o),
        .hresp_o(timer_hresp_o),
        .hrdata_o(timer_hrdata_o),

        .timer_irq_o(timer_irq)
    );

    ahb_gpio #(
        .AWIDTH(),
        .DWIDTH()
    )
    u_ahb_gpio(
        .hclk(clk),
        .hresetn(rst_n),

        .hsel_i(gpio_hsel_i),
        .hwrite_i(gpio_hwrite_i),
        .hready_i(gpio_hready_i),
        .hsize_i(gpio_hsize_i),
        .hburst_i(gpio_hburst_i),
        .htrans_i(gpio_htrans_i),
        .hwdata_i(gpio_hwdata_i),
        .haddr_i(gpio_haddr_i),

        .hreadyout_o(gpio_hreadyout_o),
        .hresp_o(gpio_hresp_o),
        .hrdata_o(gpio_hrdata_o),

        .pin_io(pin_io)
    );

endmodule
