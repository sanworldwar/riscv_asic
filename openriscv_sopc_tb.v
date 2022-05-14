`include "defines.v"

module openriscv_sopc_tb ();
    
    reg clk     ;
    reg rst_n   ;

    always #10 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        #100 rst_n = 1'b1;
        #2000 $stop;
    end

    openrisc_sopc u_openrisc_sopc(
        .clk(clk),
        .rst_n(rst_n)
    );

endmodule