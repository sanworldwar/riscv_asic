module sync_fifo #(
    parameter DEPTH = 32,
    parameter DWIDTH = 8
)(
    input   wire                    clk     ,
    input   wire                    rst_n   ,

    input   wire                    ren_i  ,
    output  wire    [DWIDTH-1:0]    rdata_o ,
   
    input   wire                    wen_i  ,
    input   wire    [DWIDTH-1:0]    wdata_i ,

    output  wire                    full_o  ,
    output  wire                    empty_o     
);

    wire [$clog2(DEPTH)-1:0] waddr;
    wire [$clog2(DEPTH)-1:0] raddr;

    reg [$clog2(DEPTH):0] wcntr;
    reg [$clog2(DEPTH):0] rcntr;

    reg [DWIDTH-1:0] mem [DEPTH-1:0];

    assign waddr = wcntr[$clog2(DEPTH)-1:0];
    assign raddr = rcntr[$clog2(DEPTH)-1:0];

    always @(posedge clk) begin
        if (wen_i) begin
            mem[waddr] <= wdata_i;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wcntr <= {$clog2(DEPTH)+1{1'b0}};
        end else if (wen_i) begin
            wcntr <=  wcntr + 1'b1;
        end
    end

    assign rdata_o = mem [raddr];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rcntr <= {$clog2(DEPTH)+1{1'b0}};
        end else if (ren_i) begin
            rcntr <= rcntr + 1'b1;
        end
    end

    assign empty_o = (rcntr == wcntr);
    assign full_o = ((rcntr - wcntr) == DEPTH);

endmodule