module b2g #(
    parameter DEPTH = 32
)(
    input   wire    clk     ,
    input   wire    rst_n   ,

    input   wire    en_i    ,
    input   wire    fu_em_i ,

    input   wire    [$clog2(DEPTH):0]   binary_i    ,
    output  wire    [$clog2(DEPTH):0]   gray_o      
);
    
    reg [$clog2(DEPTH):0]   gray_r;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            gray_r <= {$clog2(DEPTH)+1{1'b0}};
        end
        else if (en_i && !fu_em_i) begin
            gray_r <= (binary_i >> 1) ^ binary_i;
        end
    end

    assign gray_o = gray_r;

endmodule //b2g