module ctrl (
    input   wire            id_stallreq_i,
    input   wire            ex_stallreq_i,
    output  wire    [5:0]   stall_o
);
    //stall[0]暂停pc，stall[1]暂停取指，stall[2]暂停译码
    //stall[3]暂停执行，stall[4]暂停访存，stall[5]暂停写回
    assign stall_o = ex_stallreq_i ? 6'b001111 :
                     id_stallreq_i ? 6'b000111 : 6'b000000;
    
endmodule  //crtl