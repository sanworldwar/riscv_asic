`include "defines.v"

module div_tb ();

    reg clk;
    reg rst_n;

    reg                         div_start_i;
    reg                         div_cancel_i;
    reg                         div_op1_signed_i;
    reg                         div_op2_signed_i;        
    reg     [`REG_BUS]          div_op1_i;
    reg     [`REG_BUS]          div_op2_i;    

    wire                        div_stop_o;
    wire    [`REG_BUS]          div_res_o;          
    wire    [`REG_BUS]          div_rem_o;

    div u_div(
        .clk(clk),
        .rst_n(rst_n),
        .div_start_i(div_start_i),
        .div_cancel_i(div_cancel_i),
        .div_op1_signed_i(div_op1_signed_i),
        .div_op2_signed_i(div_op2_signed_i),
        .div_op1_i(div_op1_i),
        .div_op2_i(div_op2_i),
        .div_stop_o(div_stop_o),
        .div_res_o(div_res_o),
        .div_rem_o(div_rem_o)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        div_start_i = 1'b0;
        div_cancel_i = 1'b0;
        div_op1_signed_i = 1'b0;
        div_op2_signed_i = 1'b0;
        div_op1_i = 32'd0;
        div_op2_i = 32'd0;
        #100 rst_n = 1'b1;
        #3000 $finish;
    end

    integer i;
    initial begin
        i = 0;
        repeat (3) begin
            #200
            div_start_i <= 1'b1;
            div_op1_signed_i <= ~div_op1_signed_i;
            div_op2_signed_i <= div_op2_signed_i;
            div_op1_i <= div_op1_i + i*32'd10;
            div_op2_i <= div_op2_i + i*32'd3;
            @ (posedge div_stop_o);
            div_start_i <= 1'b0;
            i <= i+1;
        end
    end

    initial begin
        $dumpfile("div_tb.vcd");
        $dumpvars(0, div_tb.u_div);
    end

endmodule //div_tb