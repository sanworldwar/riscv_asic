`include "defines.v"

module exu (
    //from id
    input   wire    [31:0]          pc_i            ,
    input   wire    [`REG_BUS]      rs1_data_i      ,
    input   wire    [`REG_BUS]      rs2_data_i      ,
    input   wire    [`REG_ADDR_BUS] rd_addr_i       ,
    input   wire                    rd_we_i         ,
    input   wire    [`DEC_INFO_BUS] dec_info_bus_i  ,

    //to mem
    output  wire                    rd_we_o         ,
    output  wire    [`REG_BUS]      rd_data_o       ,
    output  wire    [`REG_ADDR_BUS] rd_addr_o       

);

reg [`REG_BUS]  reg_rd_data;

always @(*) begin
    case (dec_info_bus_i)
        1'b1: begin
            reg_rd_data = rs1_data_i | rs2_data_i;
        end 
        default: begin
            reg_rd_data = `REG_BUS_WIDTH'h0;
        end
    endcase
end

    
endmodule