`include "defines.v"

module ex_ls (
    input   wire    clk     ,
    input   wire    rst_n   ,

    //from ex
    input   wire                    rd_we_i         ,
    input   wire    [`REG_BUS]      rd_mem_data_i   ,
    input   wire    [`REG_ADDR_BUS] rd_addr_i       ,
    input   wire                    csr_we_i        ,
    input   wire    [`REG_BUS]      csr_wdata_i     ,
    input   wire    [`CSR_ADDR_BUS] csr_waddr_i     ,

    input  wire    [`MEM_ADDR_BUS]  mem_addr_i      ,
    input  wire    [`EXE_INFO_BUS]  exe_info_bus_i  ,

    //to lsu    
    output  wire                    rd_we_o         ,
    output  wire    [`REG_BUS]      rd_mem_data_o   ,
    output  wire    [`REG_ADDR_BUS] rd_addr_o       ,

    output  wire    [`MEM_ADDR_BUS] mem_addr_o      ,
    output  wire    [`EXE_INFO_BUS] exe_info_bus_o  ,

    //to ctrl
    input   wire    [5:0]           stall_i         ,

    //csr_regfile
    output  wire                    csr_we_o        ,
    output  wire    [`REG_BUS]      csr_wdata_o     ,
    output  wire    [`CSR_ADDR_BUS] csr_waddr_o     
);
    
    wire    clr = stall_i[3] & !stall_i[4]; //执行暂停，而访存继续
    wire    load = !stall_i[3];

    wire    rd_we_r;
    dff_lrc #(1) dff_rd_we(clk, rst_n, clr, load, rd_we_i, rd_we_r);
    assign rd_we_o = rd_we_r;

    wire    [`REG_BUS]  rd_mem_data_r;
    dff_lrc #(`REG_BUS_WIDTH) dff_rd_mem_data(clk, rst_n, clr, load, rd_mem_data_i, rd_mem_data_r);
    assign rd_mem_data_o = rd_mem_data_r;

    wire    [`REG_ADDR_BUS] rd_addr_r;
    dff_lrc #(`REG_ADDR_BUS_WIDTH) dff_rd_addr(clk, rst_n, clr, load, rd_addr_i,rd_addr_r);
    assign rd_addr_o = rd_addr_r;

    wire    [`MEM_ADDR_BUS] mem_addr_r;
    dff_lrc #(`MEM_ADDR_BUS_WIDTH) dff_mem_addr(clk, rst_n, clr, load, mem_addr_i,mem_addr_r);
    assign mem_addr_o = mem_addr_r;

    wire    [`EXE_INFO_BUS] exe_info_bus_r;
    dff_lrc #(`EXE_INFO_BUS_WIDTH) dff_exe_info_bus(clk, rst_n, clr, load, exe_info_bus_i,exe_info_bus_r);
    assign exe_info_bus_o = exe_info_bus_r;

    wire    csr_we_r;
    dff_lrc #(1) dff_csr_we(clk, rst_n, clr, load, csr_we_i, csr_we_r);
    assign csr_we_o = csr_we_r; 

    wire    [`REG_BUS]  csr_wdata_r;
    dff_lrc #(`REG_BUS_WIDTH) dff_csr_wdata(clk, rst_n, clr, load, csr_wdata_i, csr_wdata_r);
    assign csr_wdata_o = csr_wdata_r; 

    wire    [`CSR_ADDR_BUS] csr_waddr_r;
    dff_lrc #(`CSR_ADDR_BUS_WIDTH) dff_csr_waddr(clk, rst_n, clr, load, csr_waddr_i, csr_waddr_r);
    assign csr_waddr_o = csr_waddr_r; 



endmodule