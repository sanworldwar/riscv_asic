module async_w_fifo #(
    parameter DEPTH = 32,
    parameter DWIDTH = 8
)(
    input   wire                    rst_n   ,

    input   wire                    rclk    ,
    input   wire                    renc_i  ,
    output  wire    [DWIDTH-1:0]    rdata_o ,

    input   wire                    wclk    ,    
    input   wire                    wenc_i  ,
    input   wire    [DWIDTH-1:0]    wdata_i ,

    output  wire                    full_o  ,
    output  wire                    empty_o ,

    output  wire                    valid_o
);

    wire    ren, wen;
    wire    [$clog2(DEPTH)-1:0] raddr, waddr;

    wire    [$clog2(DEPTH):0]   rcntr, next_rcntr;
    wire    [$clog2(DEPTH):0]   wcntr;

    wire    [$clog2(DEPTH):0]   next_rcntr_g;
    wire    [$clog2(DEPTH):0]   wcntr_g;

    wire    [$clog2(DEPTH):0]   sync_next_rcntr_g;
    wire    [$clog2(DEPTH):0]   sync_wcntr_g;

    wire    [$clog2(DEPTH):0]   sync_next_rcntr_b;
    wire    [$clog2(DEPTH):0]   sync_wcntr_b;

    assign full_o = ((wcntr-sync_next_rcntr_b)== DEPTH) || !rst_n; //sync_next_wcntr_g
    assign empty_o = (rcntr==sync_wcntr_b) || !rst_n;

    dual_port_ram #(
        .DEPTH(DEPTH),
        .DWIDTH(DWIDTH)
    )
    u_dual_port_ram (
        .rclk(rclk),
        .ren_i(ren),
        .raddr_i(raddr),
        .rdata_o(rdata_o),
        .wclk(wclk),
        .wen_i(wen),
        .waddr_i(waddr),
        .wdata_i(wdata_i)
    );

    re_con #(
        .DEPTH(DEPTH)
    )
    u_re_con (
        .rst_n(rst_n),
        .rclk(rclk),
        .renc_i(renc_i),
        .empty_i(empty_o),
        .ren_o(ren),
        .rcntr_o(rcntr),
        .next_rcntr_o(next_rcntr),
        .raddr_o(raddr),
        .valid_o(valid_o)
    );

    wr_con #(
        .DEPTH(DEPTH)
    )
    u_wr_con (
        .rst_n(rst_n),
        .wclk(wclk),
        .wenc_i(wenc_i),
        .full_i(full_o),
        .wen_o(wen),
        .wcntr_o(wcntr),
        .waddr_o(waddr)
    );

    b2g #(
        .DEPTH(DEPTH)
    )
    u_r_b2g (
        .clk(rclk),
        .rst_n(rst_n),
        .en_i(ren),
        .fu_em_i(empty_o),
        .binary_i(next_rcntr),
        .gray_o(next_rcntr_g)
    );

    b2g #(
        .DEPTH(DEPTH)
    )
    u_w_b2g (
        .clk(wclk),
        .rst_n(rst_n),
        .en_i(wen),
        .fu_em_i(full_o),
        .binary_i(wcntr),
        .gray_o(wcntr_g)
    );

    generate
        genvar i;
        for (i=0; i<=$clog2(DEPTH); i=i+1) begin
            async_long_to_short u_async_long_to_short(
                .clk(wclk),
                .rst_n(rst_n),
                .async_i(next_rcntr_g[i]),
                .sync_o(sync_next_rcntr_g[i])
            );           
        end
    endgenerate

    generate
        genvar j;
        for (j=0; j<=$clog2(DEPTH); j=j+1) begin
            async_short_to_long u_async_short_to_long(
                .clk(rclk),
                .rst_n(rst_n),
                .async_i(wcntr_g[j]),
                .sync_o(sync_wcntr_g[j])
            );           
        end
    endgenerate

    g2b_core #(
        .DEPTH(DEPTH)
    )
    u_r_g2b_core(
        .gray_i(sync_next_rcntr_g),
        .binary_o(sync_next_rcntr_b)
    );

    g2b_core #(
        .DEPTH(DEPTH)
    )
    u_w_g2b_core(
        .gray_i(sync_wcntr_g),
        .binary_o(sync_wcntr_b)
    );
    

endmodule  //name
