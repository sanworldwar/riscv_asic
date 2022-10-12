module async_short_to_long (
    input   wire    clk         ,
    input   wire    rst_n       ,

    input   wire    async_i     ,
    output  wire    sync_o  
);
    reg q1, q2;
    reg sync_r;
    wire    clr_q1_q2 = !rst_n || (!async_i && sync_r);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sync_r <= 1'b0;
        end else begin
            sync_r <= q2;
        end
    end

    assign sync_o = sync_r;

    always @(posedge clk or posedge clr_q1_q2) begin
        if(clr_q1_q2) begin
            q2 <= 1'b0;
        end else begin
            q2 <= q1;
        end
    end

    always @(posedge async_i or posedge clr_q1_q2) begin
        if(clr_q1_q2) begin
            q1 <= 1'b0;
        end else begin
            q1 <= 1'b1;
        end
    end
    
endmodule //async_short_to_long
