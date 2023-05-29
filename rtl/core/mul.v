`include "defines.v"

module mul (
    input      clk      ,
    input      rst_n    ,

    input   wire                mul_start_i     ,
    input   wire                mul_cancel_i    ,
    input   wire                mul_signed_i    , //符号位信号
    input   wire    [`REG_BUS]  mul_op1_i       , //被乘数
    input   wire    [`REG_BUS]  mul_op2_i       , //乘数

    output  wire                mul_stop_o      ,
    output  wire    [`REG_BUS]  mul_res_l_o     ,
    output  wire    [`REG_BUS]  mul_res_h_o                  
);

    reg mul_shr;  //右移信号
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mul_shr <= 1'b0;
        end else if (mul_stop_o || mul_cancel_i) begin
            mul_shr <= 1'b0;
        end else if (mul_start_i) begin
            mul_shr <= 1'b1;
        end
    end

    reg [`REG_BUS]  mul_op1_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mul_op1_r <= `REG_BUS_WIDTH'h0;
        end else if (mul_start_i) begin
            mul_op1_r <= mul_op1_i;
        end
    end

    reg mul_signed_r;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mul_signed_r <= 1'b0;
        end else if (mul_start_i) begin
            mul_signed_r <= mul_signed_i;
        end
    end

    reg [5:0]   count;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            count <= 6'b000000;
        end else if (mul_shr && !mul_stop_o && !mul_cancel_i) begin
            count <= count + 1'b1;
        end else if (mul_start_i) begin
            if (((|mul_op1_i) == 1'b0) || ((|mul_op2_i) == 1'b0)) begin
                count <= 6'b100000;     
            end else begin
                count <= 6'b000000; 
            end
        end else begin
            count <= 6'b000000;    
        end
    end  

    reg [`DOUBLE_REG_BUS]   mul_res_r;

    wire    [`REG_BUS]  add_op1 = mul_res_r[`DOUBLE_REG_BUS_WIDTH-1:`REG_BUS_WIDTH];
    wire    [`REG_BUS]  add_op2 = mul_res_r[0] ? mul_op1_r : `REG_BUS_WIDTH'h0;    
    wire    [`REG_BUS_WIDTH:0]  add_res = add_op1 + add_op2;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mul_res_r <= `DOUBLE_REG_BUS_WIDTH'h0;
        end else if (mul_shr && !mul_stop_o && !mul_cancel_i) begin
            mul_res_r <= {add_res, mul_res_r[`REG_BUS_WIDTH-1:1]};
        end else if (mul_cancel_i) begin
            mul_res_r <= `DOUBLE_REG_BUS_WIDTH'h0;
        end else if (mul_start_i) begin
            if (((|mul_op1_i) == 1'b0) || ((|mul_op2_i) == 1'b0)) begin
                mul_res_r <= `DOUBLE_REG_BUS_WIDTH'h0;
            end else begin
                mul_res_r <= {`REG_BUS_WIDTH'h0, mul_op2_i};
            end  
        end        
    end

    wire    [`DOUBLE_REG_BUS]  mul_res_tmp = (mul_signed_r && (!(((|mul_op1_i) == 1'b0) || ((|mul_op2_i) == 1'b0)))) ?
                                            ~mul_res_r + 1'b1 : mul_res_r;
    
    assign mul_res_l_o = mul_res_tmp[`REG_BUS_WIDTH-1:0];
    assign mul_res_h_o = mul_res_tmp[`DOUBLE_REG_BUS_WIDTH-1:`REG_BUS_WIDTH];   
    assign mul_stop_o = (count[5] == 1'b1) && mul_shr;


endmodule //mul
