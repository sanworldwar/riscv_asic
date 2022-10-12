module async_long_to_short (
    input   wire    clk         ,
    input   wire    rst_n       ,

    input   wire    async_i     ,
    output  wire    sync_o    
);
    reg sync_meta;
    reg sync_r;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sync_meta <= 1'b0;
            sync_r <= 1'b0;
        end else begin
            {sync_r, sync_meta} <= {sync_meta, async_i};
        end
    end

    assign sync_o = sync_r;
    
endmodule //async_long_to_short
