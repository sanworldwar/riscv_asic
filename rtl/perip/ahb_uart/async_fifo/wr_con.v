module wr_con #(
    parameter DEPTH = 32
)(
    input   wire                        rst_n           ,

    input   wire                        wclk            ,
    input   wire                        wenc_i          ,
    input   wire                        full_i          ,

    output  wire                        wen_o           , 
    output  wire    [$clog2(DEPTH):0]   wcntr_o         ,
    output  wire    [$clog2(DEPTH)-1:0] waddr_o       
);

    reg                     wen_r; 
    reg [$clog2(DEPTH):0]   wcntr_r; 
    reg [$clog2(DEPTH):0]   next_wcntr_r;
    reg [$clog2(DEPTH)-1:0] waddr_r;

    always @(posedge wclk or negedge rst_n) begin
        if(!rst_n) begin
            wen_r <= 1'b0;
        end else if (wenc_i && !full_i) begin
            wen_r <= 1'b1;
        end else begin
            wen_r <= 1'b0;
        end
    end  

    always @(posedge wclk or negedge rst_n) begin
        if(!rst_n) begin
            wcntr_r <= {$clog2(DEPTH)+1{1'b0}};
        end else if (wenc_i && !full_i) begin
            wcntr_r <= next_wcntr_r;
        end
    end 

    always @(posedge wclk or negedge rst_n) begin
        if(!rst_n) begin
            waddr_r <= {$clog2(DEPTH){1'b0}};
        end else if (wen_r) begin
            waddr_r <= wcntr_r[$clog2(DEPTH)-1:0];
        end
    end  

    assign wen_o = wen_r;
    assign wcntr_o = wcntr_r;
    assign waddr_o = waddr_r;

    always @(*) begin
        next_wcntr_r = wcntr_r + 1'b1;
    end

endmodule //wr_con
