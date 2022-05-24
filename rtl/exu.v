`include "defines.v"

module exu (
    //from idu
    input   wire    [31:0]          pc_i            ,
    input   wire    [`REG_BUS]      op1_data_i      ,
    input   wire    [`REG_BUS]      op2_data_i      ,
    input   wire    [`REG_ADDR_BUS] rd_addr_i       ,
    input   wire                    rd_we_i         ,
    input   wire    [`DEC_INFO_BUS] dec_info_bus_i  ,

    //to lsu, to idu
    output  wire                    rd_we_o         ,
    output  wire    [`REG_BUS]      rd_data_o       ,
    output  wire    [`REG_ADDR_BUS] rd_addr_o       

);

    wire    [`REG_BUS]  shift_mask = {`REG_BUS_WIDTH{op1_data_i[`REG_BUS_WIDTH-1]}} & ~(32'hffffffff >> op2_data_i[4:0]);

    reg [`REG_BUS]  reg_rd_data;

    always @(*) begin
        case (dec_info_bus_i[`DEC_INST_OP])
            `DEC_INST_R, `DEC_INST_I: begin
                reg_rd_data = 
                    ((op1_data_i + op2_data_i) 
                    & {`REG_BUS_WIDTH{dec_info_bus_i[`DEC_INST_R_ADD] | dec_info_bus_i[`DEC_INST_I_ADDI]}})
                |
                    ((op1_data_i - op2_data_i) 
                    & {`REG_BUS_WIDTH{dec_info_bus_i[`DEC_INST_R_SUB]}})  
                |   
                    ({`REG_BUS_WIDTH{($signed(op1_data_i) <= $signed(op2_data_i))}} 
                    & {`REG_BUS_WIDTH{dec_info_bus_i[`DEC_INST_R_SLT] | dec_info_bus_i[`DEC_INST_I_SLTI]}})

                |   
                    ({`REG_BUS_WIDTH{(op1_data_i <= op2_data_i)}} 
                    & {`REG_BUS_WIDTH{dec_info_bus_i[`DEC_INST_R_SLTU] | dec_info_bus_i[`DEC_INST_I_SLTIU]}})                    
                | 
                    ((op1_data_i ^ op2_data_i) 
                    & {`REG_BUS_WIDTH{dec_info_bus_i[`DEC_INST_R_XOR] | dec_info_bus_i[`DEC_INST_I_XORI]}})
                |
                    ((op1_data_i | op2_data_i) 
                    & {`REG_BUS_WIDTH{dec_info_bus_i[`DEC_INST_R_OR] | dec_info_bus_i[`DEC_INST_I_ORI]}}) 
                | 
                    ((op1_data_i & op2_data_i) 
                    & {`REG_BUS_WIDTH{dec_info_bus_i[`DEC_INST_R_AND] | dec_info_bus_i[`DEC_INST_I_ANDI]}})                 
                | 
                    ((op1_data_i << op2_data_i[4:0]) 
                    & {`REG_BUS_WIDTH{dec_info_bus_i[`DEC_INST_R_SLL] | dec_info_bus_i[`DEC_INST_I_SLLI]}})
                | 
                    ((op1_data_i >> op2_data_i[4:0]) 
                    & {`REG_BUS_WIDTH{dec_info_bus_i[`DEC_INST_R_SRL] | dec_info_bus_i[`DEC_INST_I_SRLI]}})
                | 
                    (((op1_data_i >> op2_data_i[4:0]) | shift_mask) 
                    & {`REG_BUS_WIDTH{dec_info_bus_i[`DEC_INST_R_SRA] | dec_info_bus_i[`DEC_INST_I_SRAI]}});
            end
        endcase
    end   

    assign rd_data_o = reg_rd_data;
    assign rd_we_o = rd_we_i;
    assign rd_addr_o = rd_addr_i;

    
endmodule