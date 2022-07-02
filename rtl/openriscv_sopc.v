`include "defines.v"

module openrisc_sopc (
    input   wire            clk         ,
    input   wire            rst_n       ,

    input   wire            timer_irq_i       
);
    //if_ahb_interface信号与inst_rom的信号
    wire                    if_mst_hsel_o      ;
    wire    [1:0]           if_mst_htrans_o    ;
    wire    [`HADDR_BUS]    if_mst_haddr_o     ;
    wire    [`HDATA_BUS]    if_mst_hwdata_o    ;
    wire    [`HDATA_BUS]    if_mst_hrdata_i    ;
    wire                    if_mst_hwrite_o    ;
    wire    [2:0]           if_mst_hsize_o     ;
    wire    [2:0]           if_mst_hburst_o    ;
    wire    [3:0]           if_mst_hprot_o     ;
    wire                    if_mst_hmastlock_o ;
    wire                    if_mst_hready_i    ;
    wire                    if_mst_hresp_o     ;

    //ls_ahb_interface信号与inst_rom的信号
    wire                    ls_mst_hsel_o      ;
    wire    [1:0]           ls_mst_htrans_o    ;
    wire    [`HADDR_BUS]    ls_mst_haddr_o     ;
    wire    [`HDATA_BUS]    ls_mst_hwdata_o    ;
    wire    [`HDATA_BUS]    ls_mst_hrdata_i    ;
    wire                    ls_mst_hwrite_o    ;
    wire    [2:0]           ls_mst_hsize_o     ;
    wire    [2:0]           ls_mst_hburst_o    ;
    wire    [3:0]           ls_mst_hprot_o     ;
    wire                    ls_mst_hmastlock_o ;
    wire                    ls_mst_hready_i    ;
    wire                    ls_mst_hresp_o     ;


    openriscv u_openriscv(
        .clk(clk),
        .rst_n(rst_n),

        .timer_irq_i(timer_irq_i),

        .if_mst_hsel_o(if_mst_hsel_o),
        .if_mst_htrans_o(if_mst_htrans_o),
        .if_mst_haddr_o(if_mst_haddr_o),
        .if_mst_hwdata_o(if_mst_hwdata_o),
        .if_mst_hrdata_i(if_mst_hrdata_i),
        .if_mst_hwrite_o(if_mst_hwrite_o),
        .if_mst_hsize_o(if_mst_hsize_o),
        .if_mst_hburst_o(if_mst_hburst_o),
        .if_mst_hprot_o(if_mst_hprot_o),
        .if_mst_hmastlock_o(if_mst_hmastlock_o),
        .if_mst_hready_i(if_mst_hready_i),
        .if_mst_hresp_o(if_mst_hresp_o),

        .ls_mst_hsel_o(ls_mst_hsel_o),
        .ls_mst_htrans_o(ls_mst_htrans_o),
        .ls_mst_haddr_o(ls_mst_haddr_o),
        .ls_mst_hwdata_o(ls_mst_hwdata_o),
        .ls_mst_hrdata_i(ls_mst_hrdata_i),
        .ls_mst_hwrite_o(ls_mst_hwrite_o),
        .ls_mst_hsize_o(ls_mst_hsize_o),
        .ls_mst_hburst_o(ls_mst_hburst_o),
        .ls_mst_hprot_o(ls_mst_hprot_o),
        .ls_mst_hmastlock_o(ls_mst_hmastlock_o),
        .ls_mst_hready_i(ls_mst_hready_i),
        .ls_mst_hresp_o(ls_mst_hresp_o)
    );

    wire    [`HDATA_BUS]    if_mst_hrdata; 
    inst_rom u_inst_rom(
        .pc_i(if_mst_haddr_o),
        .inst_o(if_mst_hrdata)
    );

    reg [`HDATA_BUS]    if_mst_hrdata_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            if_mst_hrdata_r <= `HDATA_BUS_WIDTH'h0;
        end else begin
            if_mst_hrdata_r <= if_mst_hrdata;
        end
    end
    assign if_mst_hrdata_i = if_mst_hrdata_r;

    assign if_mst_hready_i = 1'b1;

    wire    [`HDATA_BUS]    ls_mst_hrdata;
    reg                     ls_mst_hwrite_r;
    reg     [`HADDR_BUS]    ls_mst_haddr_r;        
    data_ram u_data_ram(
        .clk(clk),

        .rdata_o(ls_mst_hrdata),
        .re_i(!ls_mst_hwrite_o),
        .raddr_i(ls_mst_haddr_o),
        .wdata_i(ls_mst_hwdata_o),
        .we_i(ls_mst_hwrite_r),
        .waddr_i(ls_mst_haddr_r)
    );

    reg [`HDATA_BUS]    ls_mst_hrdata_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ls_mst_hrdata_r <= `HDATA_BUS_WIDTH'h0;
        end else begin
            ls_mst_hrdata_r <= ls_mst_hrdata;
        end
    end
    assign ls_mst_hrdata_i = ls_mst_hrdata_r;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ls_mst_hwrite_r <= 1'b0;
        end else begin
            ls_mst_hwrite_r <= ls_mst_hwrite_o;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ls_mst_haddr_r <= `HADDR_BUS_WIDTH'h0;
        end else begin
            ls_mst_haddr_r <= ls_mst_haddr_o;
        end
    end
    
    assign ls_mst_hready_i = 1'b1;

endmodule