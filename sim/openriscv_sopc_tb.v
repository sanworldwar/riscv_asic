`timescale 1ns/1ps

`include "../rtl/defines.v"

module openriscv_sopc_tb ();
    
    reg clk     ;
    reg rst_n   ;

    always #10 clk = ~clk;

    initial begin
        $readmemh("inst_rom.data", u_openrisc_sopc.u_inst_rom.inst_mem);
    end

    initial begin
        $readmemh("regs.data", u_openrisc_sopc.u_openriscv.u_regfile.gpr_regs);
    end


    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        #100 rst_n = 1'b1;
        #2000 $finish;
    end

    openrisc_sopc u_openrisc_sopc(
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        $dumpfile("openriscv_sopc_tb.vcd");
        $dumpvars(0,openriscv_sopc_tb.u_openrisc_sopc);
    end

endmodule