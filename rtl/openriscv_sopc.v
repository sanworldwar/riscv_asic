`include "defines.v"

module openrisc_sopc (
    input   wire            clk         ,
    input   wire            rst_n          
);

    //连接openriscv与inst_rom的信号
    wire    [31:0]  rom_inst    ;
    wire    [31:0]  rom_pc      ;

    wire    [`MEM_DATA_BUS] ram_data_i  ;
    wire                    ram_re_o    ;
    wire    [`MEM_ADDR_BUS] ram_raddr_o ;
    wire    [`MEM_DATA_BUS] ram_data_o  ;
    wire                    ram_we_o    ;
    wire    [`MEM_ADDR_BUS] ram_waddr_o ;

    openriscv u_openriscv(
        .clk(clk),
        .rst_n(rst_n),

        .rom_inst_i(rom_inst),
        .rom_pc_o(rom_pc),

        .ram_data_i(ram_data_i),
        .ram_re_o(ram_re_o),
        .ram_raddr_o(ram_raddr_o),
        .ram_data_o(ram_data_o),
        .ram_we_o(ram_we_o),
        .ram_waddr_o(ram_waddr_o)
    );

    inst_rom u_inst_rom(
        .pc_i(rom_pc),
        .inst_o(rom_inst)
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
    
endmodule