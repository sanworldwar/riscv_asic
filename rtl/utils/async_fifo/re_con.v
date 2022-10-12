module re_con #(
    parameter DEPTH = 32
)(
    input   wire                        rst_n           ,

    input   wire                        rclk            ,
    input   wire                        renc_i          ,
    input   wire                        empty_i         ,

    output  wire                        ren_o           ,     
    output  wire    [$clog2(DEPTH):0]   rcntr_o         ,
    output  wire    [$clog2(DEPTH)-1:0] raddr_o         
);

    reg                     ren_r; 
    reg [$clog2(DEPTH):0]   rcntr_r; 
    reg [$clog2(DEPTH):0]   next_rcntr_r;
    reg [$clog2(DEPTH)-1:0] raddr_r;

    always @(posedge rclk or negedge rst_n) begin
        if(!rst_n) begin
            ren_r <= 1'b0;
        end else if (renc_i && !empty_i) begin
            ren_r <= 1'b1;
        end else begin
            ren_r <= 1'b0;
        end
    end

    always @(posedge rclk or negedge rst_n) begin
        if(!rst_n) begin
            rcntr_r <= {$clog2(DEPTH)+1{1'b0}};
        end else if (renc_i && !empty_i) begin
            rcntr_r <= next_rcntr_r;
        end
    end    

    always @(posedge rclk or negedge rst_n) begin
        if(!rst_n) begin
            raddr_r <= {$clog2(DEPTH){1'b0}};
        end else if (ren_r) begin
            raddr_r <= rcntr_r[$clog2(DEPTH)-1:0];
        end
    end  

    assign ren_o = ren_r;
    assign rcntr_o = rcntr_r;
    assign raddr_o = raddr_r;

    always @(*) begin
        next_rcntr_r = rcntr_r + 1'b1;
    end

endmodule //re_con