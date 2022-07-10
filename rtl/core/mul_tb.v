`include "defines.v"

module mul_tb ();

    reg clk;
    reg rst_n;

    reg                 mul_start_i;
    reg                 mul_cancel_i;
    reg                 mul_signed_i;
    reg     [`REG_BUS]  mul_op1_i;
    reg     [`REG_BUS]  mul_op2_i;    

    wire                mul_stop_o; 
    wire    [`REG_BUS]  mul_res_l_o;
    wire    [`REG_BUS]  mul_res_h_o;         

    mul u_mul(
        .clk(clk),
        .rst_n(rst_n),
        .mul_start_i(mul_start_i),
        .mul_cancel_i(mul_cancel_i),
        .mul_signed_i(mul_signed_i),
        .mul_op1_i(mul_op1_i),
        .mul_op2_i(mul_op2_i),
        .mul_stop_o(mul_stop_o),
        .mul_res_l_o(mul_res_l_o),
        .mul_res_h_o(mul_res_h_o)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        mul_start_i = 1'b0;
        mul_cancel_i = 1'b0;
        mul_signed_i = 1'b0;
        mul_op1_i = 32'd0;
        mul_op2_i = 32'd0;
        #100 rst_n = 1'b1;
        #400 mul_cancel_i = 1'b1;
        #20 mul_cancel_i = 1'b0;
        #3000 $finish;
    end

    integer i;
    initial begin
        i = 1;
        repeat (3) begin
            #200
            mul_start_i <= 1'b1;
            mul_signed_i = ~mul_signed_i;
            mul_op1_i <= mul_op1_i + i*32'd5;
            mul_op2_i <= mul_op2_i + i*32'd10;
            @ (posedge mul_stop_o or posedge mul_cancel_i);
            mul_start_i <= 1'b0;
            i <= i+1;
        end
    end

    initial begin
        $dumpfile("mul_tb.vcd");
        $dumpvars(0, mul_tb.u_mul);
    end

endmodule //mul_tb
