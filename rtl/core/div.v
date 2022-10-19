`include "defines.v"

module div (
    input   wire      clk   ,
    input   wire      rst_n ,

    input   wire                  div_start_i       ,
    input   wire                  div_cancel_i      ,
    input   wire                  div_op1_signed_i  , //被除数符号位信号
    input   wire                  div_op2_signed_i  , //除数符号位信号     
    input   wire    [`REG_BUS]    div_op1_i         , //被除数
    input   wire    [`REG_BUS]    div_op2_i         , //除数

    output  wire                  div_stop_o        ,
    output  wire    [`REG_BUS]    div_res_o         ,
    output  wire    [`REG_BUS]    div_rem_o
);

    reg div_shl;  //右移信号
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            div_shl <= 1'b0;
        end else if (div_stop_o || div_cancel_i) begin
            div_shl <= 1'b0;
        end else if (div_start_i) begin
            div_shl <= 1'b1;
        end
    end

    reg [`REG_BUS]  div_op2_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            div_op2_r <= `REG_BUS_WIDTH'h0;
        end else if (div_start_i) begin
            div_op2_r <= div_op2_i;
        end
    end

    reg div_op1_signed_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            div_op1_signed_r <= 1'b0;
        end else if (div_start_i) begin
            div_op1_signed_r <= div_op1_signed_i;
        end
    end

    reg div_op2_signed_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            div_op2_signed_r <= 1'b0;
        end else if (div_start_i) begin
            div_op2_signed_r <= div_op2_signed_i;
        end
    end

    reg [5:0]   count;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            count <= 6'b000000;
        end else if (div_shl && !div_stop_o && !div_cancel_i) begin
            count <= count + 1'b1;
        end else if (div_start_i) begin
            if ((|div_op2_i) == 1'b0) begin
                count <= 6'b100000;
            end else begin
                count <= 6'b000000;
            end
        end else begin
            count <= 6'b000000;
        end
    end    

    reg [`DOUBLE_REG_BUS]   div_res_rem;

    wire    [`REG_BUS]  sub_op1 = div_res_rem[`DOUBLE_REG_BUS_WIDTH-2:`REG_BUS_WIDTH-1];
    wire    [`REG_BUS]  sub_op2 = div_op2_r;    
    wire    [`REG_BUS]  sub_res = sub_op1 - sub_op2;
    wire    [`REG_BUS]  sub_nxt = sub_res[`REG_BUS_WIDTH-1] ? sub_op1 : sub_res;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            div_res_rem <= `DOUBLE_REG_BUS_WIDTH'h0;
        end else if (div_shl && !div_stop_o && !div_cancel_i) begin
            div_res_rem <= {sub_nxt, div_res_rem[`REG_BUS_WIDTH-2:0], !sub_res[`REG_BUS_WIDTH-1]};
        end else if (div_cancel_i) begin
            div_res_rem <= `DOUBLE_REG_BUS_WIDTH'h0;
        end else if (div_start_i) begin
            if (|div_op2_i == 1'b0) begin
                div_res_rem <= `DOUBLE_REG_BUS_WIDTH'h0;
            end else begin
                div_res_rem <= {`REG_BUS_WIDTH'h0, div_op1_i};
            end
        end
    end

    assign div_res_o = ((div_op1_signed_r ^ div_op2_signed_r) && (!(|div_op2_i == 1'b0))) ? 
        ~div_res_rem[`REG_BUS_WIDTH-1:0] + 1'b1 : div_res_rem[`REG_BUS_WIDTH-1:0];
    assign div_rem_o = (div_op1_signed_r && (!(|div_op2_i == 1'b0))) ? 
        ~div_res_rem[`DOUBLE_REG_BUS_WIDTH-1:`REG_BUS_WIDTH] + 1'b1 : div_res_rem[`DOUBLE_REG_BUS_WIDTH-1:`REG_BUS_WIDTH];

    assign div_stop_o = (count[5] == 1'b1) && div_shl;    

endmodule //div