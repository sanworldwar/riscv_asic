`timescale 1ns/1ps

`include "../rtl/core/defines.v"

module openriscv_sopc_tb ();
    
    reg clk     ;
    reg rst_n   ;

    reg sram_clk    ;

    reg timer_irq_i ;

    always #10 clk = ~clk;
    always #10 sram_clk = ~sram_clk;

    initial begin
        $readmemh("inst_rom1.data", u_openrisc_sopc.u1_ahb_sram.bank0[0].u_sram_8kx8.mem);
        $readmemh("inst_rom2.data", u_openrisc_sopc.u1_ahb_sram.bank0[1].u_sram_8kx8.mem);
        $readmemh("inst_rom3.data", u_openrisc_sopc.u1_ahb_sram.bank0[2].u_sram_8kx8.mem);
        $readmemh("inst_rom4.data", u_openrisc_sopc.u1_ahb_sram.bank0[3].u_sram_8kx8.mem);
    end


    initial begin
        $readmemh("regs.data", u_openrisc_sopc.u_openriscv.u_regfile.gpr_regs);
    end

    initial begin
        $readmemh("data_ram1.data", u_openrisc_sopc.u2_ahb_sram.bank0[0].u_sram_8kx8.mem);
        $readmemh("data_ram2.data", u_openrisc_sopc.u2_ahb_sram.bank0[1].u_sram_8kx8.mem);
        $readmemh("data_ram3.data", u_openrisc_sopc.u2_ahb_sram.bank0[2].u_sram_8kx8.mem);
        $readmemh("data_ram4.data", u_openrisc_sopc.u2_ahb_sram.bank0[3].u_sram_8kx8.mem);
    end

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        sram_clk = 1'b1;
        timer_irq_i = 1'b0;
        #100 rst_n = 1'b1;
        #2000 $finish;
    end

    openrisc_sopc u_openrisc_sopc(
        .clk(clk),
        .rst_n(rst_n),

        .sram_clk(sram_clk),

        .timer_irq_i(timer_irq_i)
    );

    initial begin
        $dumpfile("openriscv_sopc_tb.vcd");
        $dumpvars(0,openriscv_sopc_tb.u_openrisc_sopc);
    end

endmodule