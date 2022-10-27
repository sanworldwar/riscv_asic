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

    reg                     rx          ;
    wire                    tx          ;

    wire                    spi_clk     ;
    reg                     spi_miso    ;
    wire                    spi_mosi    ;
    wire    [4:3]           spi_nss     ;

    wire    [1:0]           pin_io      ;

    always #10 clk = ~clk;
    
    //c_sim
    initial begin
        $readmemh("./c_sim/inst1.data", u_openrisc_sopc.u1_ahb_sram.bank0[0].u_sram_8kx8.mem);
        $readmemh("./c_sim/inst2.data", u_openrisc_sopc.u1_ahb_sram.bank0[1].u_sram_8kx8.mem);
        $readmemh("./c_sim/inst3.data", u_openrisc_sopc.u1_ahb_sram.bank0[2].u_sram_8kx8.mem);
        $readmemh("./c_sim/inst4.data", u_openrisc_sopc.u1_ahb_sram.bank0[3].u_sram_8kx8.mem);
    end

    //asm_sim
    /*initial begin
        $readmemh("./asm_sim/inst1.data", u_openrisc_sopc.u1_ahb_sram.bank0[0].u_sram_8kx8.mem);
        $readmemh("./asm_sim/inst2.data", u_openrisc_sopc.u1_ahb_sram.bank0[1].u_sram_8kx8.mem);
        $readmemh("./asm_sim/inst3.data", u_openrisc_sopc.u1_ahb_sram.bank0[2].u_sram_8kx8.mem);
        $readmemh("./asm_sim/inst4.data", u_openrisc_sopc.u1_ahb_sram.bank0[3].u_sram_8kx8.mem);
    end


    initial begin
        $readmemh("./asm_sim/regs.data", u_openrisc_sopc.u_openriscv.u_regfile.gpr_regs);
    end

    initial begin
        $readmemh("./asm_sim/data_ram1.data", u_openrisc_sopc.u2_ahb_sram.bank0[0].u_sram_8kx8.mem);
        $readmemh("./asm_sim/data_ram2.data", u_openrisc_sopc.u2_ahb_sram.bank0[1].u_sram_8kx8.mem);
        $readmemh("./asm_sim/data_ram3.data", u_openrisc_sopc.u2_ahb_sram.bank0[2].u_sram_8kx8.mem);
        $readmemh("./asm_sim/data_ram4.data", u_openrisc_sopc.u2_ahb_sram.bank0[3].u_sram_8kx8.mem);
    end*/

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        #100 rst_n = 1'b1;
    end

    openrisc_sopc #(
        .MASTERS(2),
        .SLAVES(6)
    )
    u_openrisc_sopc(
        .clk(clk),
        .rst_n(rst_n),

        .rx(rx),
        .tx(tx),

        .spi_clk(spi_clk),
        .spi_miso(spi_miso),
        .spi_mosi(spi_mosi),
        .spi_nss(spi_nss),

        .pin_io(pin_io)
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
        #2250 rx <= 1'b0;
        #8680 rx <= 1'b1;
        #8680 rx <= 1'b0;
        #8680 rx <= 1'b1;
        #8680 rx <= 1'b0;
        #8680 rx <= 1'b1;
        #8680 rx <= 1'b0;
        #8680 rx <= 1'b1;
        #8680 rx <= 1'b0;
        #8680 rx <= 1'b1;
        #8680 rx <= 1'b1;
        
        #8680 rx <= 1'b0;
        #8680 rx <= 1'b1;
        #8680 rx <= 1'b1;
        #8680 rx <= 1'b1;
        #8680 rx <= 1'b0;
        #8680 rx <= 1'b1;
        #8680 rx <= 1'b0;
        #8680 rx <= 1'b1;
        #8680 rx <= 1'b0;
        #8680 rx <= 1'b0;
        #8680 rx <= 1'b1;
    end

    initial begin
        spi_miso <= 1'b0;
        #930 
            repeat (8) begin
                spi_miso <= ~spi_miso;
                #40;
            end
    end

    reg pin_1;
    initial begin
        pin_1 <= 1'b0;
        #5000
            repeat (8) begin
                pin_1 <= ~pin_1;
                #2000;
            end        
    end

    assign pin_io[1] = pin_1;
    
    // sim timeout
    initial begin
        #1000000
        $display("Time Out.");
        $finish;
    end

    wire    [`REG_BUS]  x26 = u_openrisc_sopc.u_openriscv.u_regfile.gpr_regs[26];
    wire    [`REG_BUS]  x27 = u_openrisc_sopc.u_openriscv.u_regfile.gpr_regs[27];

    initial begin
        `ifdef SIMULATION
            wait(x26 == 32'h1);   // wait sim end, when x26 == 1
            #100
            if (x27 == 32'h1) begin
                $display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~");
                $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~");
                $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~");
                $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~");
                $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~");
                $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~");
                $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~");
                $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            end else begin
                $display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
                $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
                $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
                $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
                $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
                $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
                $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
                $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
                $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            end
        `endif
    end
endmodule
