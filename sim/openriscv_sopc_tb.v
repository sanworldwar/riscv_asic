//时序逻辑中的值，在另一个逻辑中通过“=”或“<=”被赋值（仅tb文件中 #10 a<=b）
//“=”如果在时钟有效沿处，数据变化，则会检测到变化后的值
//“<=”如果在时钟有效沿处，数据变化，则会检测到变化前的值

//组合逻辑中的值，always块或assign里包括如if块、?：
//当条件与值一同变化时，值先变，条件后考虑
`timescale 1ns/1ps

`include "../rtl/core/defines.v"

module openriscv_sopc_tb ();
    
    reg                     clk         ;
    reg                     rst_n       ;

    reg                     sram_clk    ;

    reg                     timer_irq_i ;

    reg                     rx          ;
    wire                    tx          ;

    wire                    spi_clk     ;
    reg                     spi_miso    ;
    wire                    spi_mosi    ;
    wire    [4:3]           spi_nss     ;    

    always #10 clk = ~clk;
    always #10 sram_clk = ~sram_clk;

    initial begin
        $readmemh("./data/inst_rom1.data", u_openrisc_sopc.u1_ahb_sram.bank0[0].u_sram_8kx8.mem);
        $readmemh("./data/inst_rom2.data", u_openrisc_sopc.u1_ahb_sram.bank0[1].u_sram_8kx8.mem);
        $readmemh("./data/inst_rom3.data", u_openrisc_sopc.u1_ahb_sram.bank0[2].u_sram_8kx8.mem);
        $readmemh("./data/inst_rom4.data", u_openrisc_sopc.u1_ahb_sram.bank0[3].u_sram_8kx8.mem);
    end


    initial begin
        $readmemh("./data/regs.data", u_openrisc_sopc.u_openriscv.u_regfile.gpr_regs);
    end

    initial begin
        $readmemh("./data/data_ram1.data", u_openrisc_sopc.u2_ahb_sram.bank0[0].u_sram_8kx8.mem);
        $readmemh("./data/data_ram2.data", u_openrisc_sopc.u2_ahb_sram.bank0[1].u_sram_8kx8.mem);
        $readmemh("./data/data_ram3.data", u_openrisc_sopc.u2_ahb_sram.bank0[2].u_sram_8kx8.mem);
        $readmemh("./data/data_ram4.data", u_openrisc_sopc.u2_ahb_sram.bank0[3].u_sram_8kx8.mem);
    end

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        sram_clk = 1'b1;
        timer_irq_i = 1'b0;
        #100 rst_n = 1'b1;
        #5500 $finish;
    end

    openrisc_sopc #(
        .MASTERS(2),
        .SLAVES(4)
    )
    u_openrisc_sopc(
        .clk(clk),
        .rst_n(rst_n),

        .sram_clk(sram_clk),

        .timer_irq_i(timer_irq_i),

        .rx(rx),
        .tx(tx),

        .spi_clk(spi_clk),
        .spi_miso(spi_miso),
        .spi_mosi(spi_mosi),
        .spi_nss(spi_nss)        
    );

    /*initial begin
        $dumpfile("openriscv_sopc_tb.vcd");
        $dumpvars(0,openriscv_sopc_tb.u_openrisc_sopc);
    end*/

    initial begin
        $dumpfile("openriscv_sopc_tb.fsdb");
        $dumpvars(0,openriscv_sopc_tb.u_openrisc_sopc);
    end


    initial begin
        rx = 1'b1;
        #80 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b1;
        
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b1;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
        #160 rx <= 1'b0;
        #160 rx <= 1'b0;
        #160 rx <= 1'b1;
    end

    initial begin
        spi_miso <= 1'b0;
        #1910 
            repeat (8) begin
                spi_miso <= ~spi_miso;
                #40;
            end
    end

endmodule