module g2b_core #(
    parameter DEPTH = 32
)(
    input   wire    [$clog2(DEPTH):0]   gray_i      ,
    output  wire    [$clog2(DEPTH):0]   binary_o          
);
    
    reg [$clog2(DEPTH):0]   binary_r;

    always @(*) begin
        for (integer k=0; k<=$clog2(DEPTH); k=k+1) begin
            binary_r[k] = ^(gray_i >> k);
        end
    end

    assign binary_o = binary_r;

endmodule //g2b_core
