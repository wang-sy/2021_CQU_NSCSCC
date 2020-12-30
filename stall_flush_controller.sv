module stall_flush_controller (
    input   logic           rst_i,
    input   logic           ex_ok_i,

    input   logic[31:0]     cp0_epc_i, //qf
    input   logic[31:0]     exception_type_i,  //qf

    output  logic           if_stall_o,
    output  logic           if2id_stall_o,
    output  logic           id2ex_stall_o,
    output  logic           ex2mem_stall_o,
    output  logic           mem2wb_stall_o,

    output  logic           flush,
    output  logic[31:0]     new_pc
);
    assign flush = rst_i == 1'b1 ? 1'b0 : (exception_type_i != 32'b0);

    assign new_pc = rst_i==1'b1 ? 32'b0 : 
                    (exception_type_i == 32'h0000001) ? 32'h00000020 :
                    (exception_type_i == 32'h0000008) ? 32'h00000040 :
                    (exception_type_i == 32'h000000a) ? 32'h00000040 :
                    (exception_type_i == 32'h000000d) ? 32'h00000040 :
                    (exception_type_i == 32'h000000c) ? 32'h00000040 :
                    (exception_type_i == 32'h000000e) ? cp0_epc_i    : 32'h0;

    assign  if2id_stall_o = ~ex_ok_i;
    assign  if_stall_o  = ~ex_ok_i; // 当运算没有结束时stall
    assign  id2ex_stall_o  = ~ex_ok_i; // 当运算没有结束时stall
    assign  ex2mem_stall_o  = ~ex_ok_i; // 当运算没有结束时stall
    assign  mem2wb_stall_o = ~ex_ok_i; // 当运算没有结束时stall
    
endmodule