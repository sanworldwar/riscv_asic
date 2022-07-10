`include "defines.v"

module lsu (
    //from exu
    input   wire                    rd_we_i         ,
    input   wire    [`REG_BUS]      rd_mem_data_i   ,
    input   wire    [`REG_ADDR_BUS] rd_addr_i       ,

    input  wire    [`MEM_ADDR_BUS]  mem_addr_i      ,
    input  wire    [`EXE_INFO_BUS]  exe_info_bus_i  ,

    //to wb, to idu
    output  wire                    rd_we_o         ,
    output  wire    [`REG_BUS]      rd_data_o       ,
    output  wire    [`REG_ADDR_BUS] rd_addr_o       ,

    //to ls_ahb_interface
    input   wire    [`MEM_DATA_BUS] mem_rdata_i     ,
    output  wire                    mem_re_o        ,
    output  wire    [`MEM_DATA_BUS] mem_wdata_o     ,
    output  wire                    mem_we_o        ,
    output  wire    [`MEM_ADDR_BUS] mem_addr_o     
);
    //L(OAD) instruction
    wire inst_l_op = exe_info_bus_i[`EXE_INST_OP] == `EXE_INST_L;
    wire inst_l_lb = exe_info_bus_i[`EXE_INST_L_LB];
    wire inst_l_lh = exe_info_bus_i[`EXE_INST_L_LH];
    wire inst_l_lw = exe_info_bus_i[`EXE_INST_L_LW];
    wire inst_l_lbu = exe_info_bus_i[`EXE_INST_L_LBU];
    wire inst_l_lhu = exe_info_bus_i[`EXE_INST_L_LHU];
    //S(TORE) instruction
    wire inst_s_op = exe_info_bus_i[`EXE_INST_OP] == `EXE_INST_S;
    wire inst_s_sb = exe_info_bus_i[`EXE_INST_S_SB];
    wire inst_s_sh = exe_info_bus_i[`EXE_INST_S_SH];
    wire inst_s_sw = exe_info_bus_i[`EXE_INST_S_SW];

    wire    [`MEM_DATA_BUS] inst_l_rdata = 
                ({{`MEM_DATA_BUS_WIDTH-8{mem_rdata_i[7]}},mem_rdata_i[7:0]} & {`MEM_DATA_BUS_WIDTH{inst_l_lb & inst_l_op}})    |
                ({{`MEM_DATA_BUS_WIDTH-16{mem_rdata_i[15]}},mem_rdata_i[15:0]} & {`MEM_DATA_BUS_WIDTH{inst_l_lh & inst_l_op}}) |
                (mem_rdata_i & {`MEM_DATA_BUS_WIDTH{inst_l_lw & inst_l_op}})                                                   |
                {{`MEM_DATA_BUS_WIDTH-8{1'b0}},mem_rdata_i[7:0]} & {`MEM_DATA_BUS_WIDTH{inst_l_lbu & inst_l_op}}               |
                {{`MEM_DATA_BUS_WIDTH-16{1'b0}},mem_rdata_i[15:0]} & {`MEM_DATA_BUS_WIDTH{inst_l_lhu & inst_l_op}};

    wire    [`MEM_DATA_BUS] inst_s_wdata = 
                ({mem_rdata_i[`MEM_DATA_BUS_WIDTH-1:8],rd_mem_data_i[7:0]} & {`MEM_DATA_BUS_WIDTH{inst_s_sb & inst_s_op}})    |
                ({mem_rdata_i[`MEM_DATA_BUS_WIDTH-1:16],rd_mem_data_i[15:0]} & {`MEM_DATA_BUS_WIDTH{inst_s_sh & inst_s_op}})  |
                (rd_mem_data_i & {`MEM_DATA_BUS_WIDTH{inst_s_sw & inst_s_op}});

    assign mem_re_o = inst_l_op | ((inst_s_sb | inst_s_sh) & inst_s_op);
    assign mem_we_o = inst_s_op;
    assign mem_wdata_o = inst_s_wdata;
    assign mem_addr_o = mem_addr_i;    

    assign rd_we_o = rd_we_i | inst_l_op;
    assign rd_data_o = inst_l_op ? inst_l_rdata : rd_mem_data_i;
    assign rd_addr_o = rd_addr_i;

endmodule