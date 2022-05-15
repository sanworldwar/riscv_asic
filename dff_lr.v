`include "defines.v"

module dff_lr #(
    parameter DATA_WIDTH = 1
) (
    input   wire                        clk     ,
    input   wire                        rst_n   ,

    input   wire                        load    ,
    input   wire    [DATA_WIDTH-1:0]    data_in ,
    output  wire    [DATA_WIDTH-1:0]    data_out
);

    reg    [DATA_WIDTH-1:0]    data_out_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_r <= {DATA_WIDTH{1'b0}};
        end else if (load) begin
            data_out_r <= data_in;
        end
    end
    assign data_out = data_out_r;
    
endmodule