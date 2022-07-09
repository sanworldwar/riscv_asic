module ctrl (
    //from idu
    input   wire            id_stallreq_i   ,
    input   wire            id_jump_req_i   ,

    //from exu
    input   wire            ex_stallreq_i   ,

    //to if_ahb_interface ifu, if_id, id_ex, ex_ls, ls_wb
    output  wire    [5:0]   stall_o         ,

    //from excp
    input   wire            excp_stallreq_i ,
    input   wire    [2:0]   excp_flushreq_i ,
    input   wire            excp_jump_req_i ,    

    //to if_ahb_interface if_id, id_ex, ex_ls, ls_ahb_interface, ls_wb
    output  wire    [4:0]   flush_o,

    //from if_ahb_interface
    input   wire            if_ahb_stallreq_i   ,

    //from ls_ahb_interface
    input   wire            ls_ahb_stallreq_i   
);
    //stall[0]暂停pc，stall[1]暂停取指，stall[2]暂停译码
    //stall[3]暂停执行，stall[4]暂停访存，stall[5]暂停写回
    assign stall_o = ls_ahb_stallreq_i ? 6'b011111 :
                     ex_stallreq_i     ? 6'b001111 :
                     id_stallreq_i     ? 6'b000111 : 
                     excp_stallreq_i   ? 6'b000111 : 
                     if_ahb_stallreq_i ? 6'b000011 : 6'b000000;

    assign flush_o = ({5{excp_flushreq_i[1]}} & 5'b00110) | 
                     ({5{excp_flushreq_i[2]}} & 5'b00010) |
                     ({5{excp_flushreq_i[0]}} & 5'b00010) |
                     ({5{excp_jump_req_i | (id_jump_req_i & (!ex_stallreq_i | !excp_stallreq_i))}} & 5'b00011); //跳转时清除if_id输出,
                     //div-beq成立且div-jal成立，irq和jar同时发生成立

endmodule  //ctrl