module dual_port_ram #(
    parameter DEPTH = 32,
    parameter DWIDTH = 8
)(
    input   wire    rclk                            ,
    input   wire    ren_i                           ,
    input   wire    [$clog2(DEPTH)-1:0]     raddr_i ,
    output  wire    [DWIDTH-1:0]            rdata_o ,

    input   wire    wclk                            ,
    input   wire    wen_i                           ,
    input   wire    [$clog2(DEPTH)-1:0]     waddr_i ,
    input   wire    [DWIDTH-1:0]            wdata_i       
);

    reg [DWIDTH-1:0]    mem [0:DEPTH-1];

    always @(posedge wclk) begin
        if (wen_i) begin
            mem[waddr_i] <= wdata_i;
        end;
    end

    reg [DWIDTH-1:0]    rdata_r;    

    always @(posedge rclk) begin
        if (ren_i) begin
            rdata_r <= mem[raddr_i];
        end;
    end

    assign rdata_o = rdata_r;
    
endmodule //moduleName
