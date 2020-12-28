module stall_controller (
    input   logic           ex_ok_i,

    output  logic           if_stall_o,
    output  logic           if2id_stall_o,
    output  logic           id2ex_stall_o,
    output  logic           ex2mem_stall_o,
    output  logic           mem2wb_stall_o
);
    assign  if2id_stall_o = ~ex_ok_i;
    assign  if_stall_o  = ~ex_ok_i; // 当运算没有结束时stall
    assign  id2ex_stall_o  = ~ex_ok_i; // 当运算没有结束时stall
    assign  ex2mem_stall_o  = ~ex_ok_i; // 当运算没有结束时stall
    assign  mem2wb_stall_o = ~ex_ok_i; // 当运算没有结束时stall
    
endmodule