`include "defines.v"

module data_ram_tb ();
    reg                    clk         ;

    wire    [`MEM_DATA_BUS] ram_data_i  ;
    reg                     ram_re_o    ;
    reg     [`MEM_ADDR_BUS] ram_raddr_o ;
    reg     [`MEM_DATA_BUS] ram_data_o  ;
    reg                     ram_we_o    ;
    reg     [`MEM_ADDR_BUS] ram_waddr_o ;

    always #10 clk = ~clk;

    initial begin
        clk = 1'b0;
        #2000 $finish;
    end

    reg [`MEM_DATA_BUS_WIDTH:0] ram;

    initial begin
        #20
        ram = {1'b1, `MEM_DATA_BUS_WIDTH'd2};
        #40
        ram = {1'b0, `MEM_DATA_BUS_WIDTH'd3};
        #40
        ram = {1'b1, `MEM_DATA_BUS_WIDTH'd4};
        #40
        ram = {1'b0, `MEM_DATA_BUS_WIDTH'd0};
    end


    always @(*) begin
        ram_re_o = ram[`MEM_DATA_BUS_WIDTH];
    end

    always @(*) begin
        ram_raddr_o = ram[`MEM_DATA_BUS_WIDTH-1:0];
    end

    initial begin
        $readmemh("../sim/data_ram.data", u_data_ram.data_mem);
    end

    data_ram u_data_ram(
        .clk(clk),

        .rdata_o(ram_data_i),
        .re_i(ram_re_o),
        .raddr_i(ram_raddr_o),
        .wdata_i(ram_data_o),
        .we_i(ram_we_o),
        .waddr_i(ram_waddr_o)
    );
    
    initial begin
        $dumpfile("data_ram_tb.vcd");
        $dumpvars(0,data_ram_tb.u_data_ram);
    end


endmodule  //data_ram_tb