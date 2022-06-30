`include "defines.v"

module openrisc_sopc (
    input   wire            clk         ,
    input   wire            rst_n       ,

    input   wire            timer_irq_i       
);

    //连接openriscv与inst_rom的信号
 //   wire    [31:0]  rom_inst    ;
 //   wire    [31:0]  rom_pc      ;

    wire    [`MEM_DATA_BUS] ram_data_i  ;
    wire                    ram_re_o    ;
    wire    [`MEM_ADDR_BUS] ram_raddr_o ;
    wire    [`MEM_DATA_BUS] ram_data_o  ;
    wire                    ram_we_o    ;
    wire    [`MEM_ADDR_BUS] ram_waddr_o ;

    wire                    mst_hsel_o      ;
    wire    [1:0]           mst_htrans_o    ;
    wire    [`HADDR_BUS]    mst_haddr_o     ;
    wire    [`HDATA_BUS]    mst_hwdata_o    ;
    wire    [`HDATA_BUS]    mst_hrdata_i    ;
    wire                    mst_hwrite_o    ;
    wire    [2:0]           mst_hsize_o     ;
    wire    [2:0]           mst_hburst_o    ;
    wire    [3:0]           mst_hprot_o     ;
    wire                    mst_hmastlock_o ;
    wire                    mst_hready_i    ;
    wire                    mst_hresp_o     ;

    openriscv u_openriscv(
        .clk(clk),
        .rst_n(rst_n),

//        .rom_inst_i(rom_inst),
//        .rom_pc_o(rom_pc),

        .ram_data_i(ram_data_i),
        .ram_re_o(ram_re_o),
        .ram_raddr_o(ram_raddr_o),
        .ram_data_o(ram_data_o),
        .ram_we_o(ram_we_o),
        .ram_waddr_o(ram_waddr_o),

        .timer_irq_i(timer_irq_i),

        .mst_hsel_o(mst_hsel_o),
        .mst_htrans_o(mst_htrans_o),
        .mst_haddr_o(mst_haddr_o),
        .mst_hwdata_o(mst_hwdata_o),
        .mst_hrdata_i(mst_hrdata_i),
        .mst_hwrite_o(),
        .mst_hsize_o(mst_hsize_o),
        .mst_hburst_o(mst_hburst_o),
        .mst_hprot_o(mst_hprot_o),
        .mst_hmastlock_o(mst_hmastlock_o),
        .mst_hready_i(mst_hready_i),
        .mst_hresp_o(mst_hresp_o)
    );

    wire    [`HDATA_BUS]    mst_hrdata; 
    inst_rom u_inst_rom(
        .pc_i(mst_haddr_o),
        .inst_o(mst_hrdata)
    );

    data_ram u_data_ram(
        .clk(clk),

        .rdata_o(ram_data_i),
        .re_i(ram_re_o),
        .raddr_i(ram_raddr_o),
        .wdata_i(ram_data_o),
        .we_i(ram_we_o),
        .waddr_i(ram_waddr_o)
    );
    
    reg [`HDATA_BUS]    mst_hrdata_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mst_hrdata_r <= 0;
        end else begin
            mst_hrdata_r <= mst_hrdata;
        end
    end
    assign mst_hrdata_i = mst_hrdata_r;

    assign mst_hready_i = 1'b1;

endmodule