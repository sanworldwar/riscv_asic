`include "defines.v"

module regfile_tb ();
    reg                    clk         ;

    reg    [`REG_ADDR_BUS] id_rs1_addr_o   ;
    reg                    id_rs1_re_o     ;
    wire    [`REG_BUS]      id_rs1_data_i   ;
    reg    [`REG_ADDR_BUS] id_rs2_addr_o   ;
    reg                    id_rs2_re_o     ;
    wire    [`REG_BUS]      id_rs2_data_i   ;
    reg                    wb_rd_we_i      ;
    reg    [`REG_BUS]      wb_rd_data_i    ;
    reg    [`REG_ADDR_BUS] wb_rd_addr_i    ; 

    always #10 clk = ~clk;

    initial begin
        clk = 1'b0;
        #2000 $finish;
    end

    initial begin
        wb_rd_we_i = 1'b0;
    end

    initial begin
        wb_rd_addr_i = `REG_ADDR_BUS_WIDTH'd0;
    end

    reg [`REG_ADDR_BUS_WIDTH:0] ram;

    initial begin
        #20
        ram = {1'b1, `REG_ADDR_BUS_WIDTH'd2};
        #40
        ram = {1'b0, `REG_ADDR_BUS_WIDTH'd3};
        #40
        ram = {1'b1, `REG_ADDR_BUS_WIDTH'd4};
        #40
        ram = {1'b0, `REG_ADDR_BUS_WIDTH'd0};
    end


    always @(*) begin
        id_rs1_re_o = ram[`REG_ADDR_BUS_WIDTH];
    end

    always @(*) begin
        id_rs1_addr_o = ram[`REG_ADDR_BUS_WIDTH-1:0];
    end

    initial begin
        $readmemh("../sim/regs.data", u_regfile.gpr_regs);
    end

    regfile u_regfile(
        .clk(clk),

        .raddr1_i(id_rs1_addr_o),
        .re1_i(id_rs1_re_o),
        .rdata1_o(id_rs1_data_i),
        .raddr2_i(id_rs2_addr_o),
        .re2_i(id_rs2_re_o),
        .rdata2_o(id_rs2_data_i),

        .waddr_i(wb_rd_addr_i),
        .we_i(wb_rd_we_i),
        .wdata_i(wb_rd_data_i)
    );
    
    initial begin
        $dumpfile("regfile_tb.vcd");
        $dumpvars(0,regfile_tb.u_regfile);
    end


endmodule  //data_ram_tb