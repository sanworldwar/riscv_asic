`include "defines.v"

module openrisc_sopc (
    input   wire            clk         ,
    input   wire            rst_n          
);

    //连接openriscv与inst_rom的信号
    wire    [31:0]  rom_inst    ;
    wire    [31:0]  rom_pc      ;

    openriscv u_openriscv(
        .clk(clk),
        .rst_n(rst_n),
        .rom_inst_i(rom_inst),
        .rom_pc_o(rom_pc)
    );

    inst_rom u_inst_rom(
        .pc_i(rom_pc),
        .inst_o(rom_inst)
    );
    
endmodule