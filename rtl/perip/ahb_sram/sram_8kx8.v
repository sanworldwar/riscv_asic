/*
cen_i   wen_i   data_o      mode
 h       x      last_data   standby
 l       l      data_in     write
 l       h      sram_data   read
*/
module sram_8kx8 #(
   parameter		   DWIDTH = 8   ,
   parameter		   DEPTH = 8192 ,
   parameter		   AWIDTH = 13
) (
    input   wire                    clk     ,
    input   wire                    cen_i   ,
    input   wire                    wen_i   ,
    input   wire    [AWIDTH-1:0]    addr_i  ,
    input   wire    [DWIDTH-1:0]    data_i  ,
    output  wire    [DWIDTH-1:0]    data_o  
);

    reg [DWIDTH-1:0]    mem [0:DEPTH-1];


    always @(posedge clk) begin
        if (!cen_i) begin
            if (!wen_i) begin
                mem[addr_i] <= data_i;   
            end
        end
    end

    reg [DWIDTH-1:0]    data_r;
    always @(*) begin
        if (!cen_i) begin
            if (!wen_i) begin
                data_r = data_i;   
            end else begin
                data_r = mem[addr_i];
            end
        end
    end
    assign data_o = data_r;

//  assign data_o = !cen_i ? (!wen_i ? data_i : mem[addr_i]) : data_o;
//  若addr_i先到，cen_i后到，则会输出新数据，而不是保持原有数据。

endmodule  //sram_8kx8
