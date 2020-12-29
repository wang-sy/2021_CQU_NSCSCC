`include "defines.vh"
module stall_controller (
    input   logic           ex_ok_i,

    // 用于判断第二种，load类型需要停掉的冒险
    input   logic           ex_rmem_i,
    input   logic [4:0]     ex_wd_i,
    input   logic           ex_wreg_i,
    input   logic [4:0]     id_rs_i,
    input   logic [4:0]     id_rt_i,
    input   logic           id_reg1_read_i,
    input   logic           id_reg2_read_i,


    output  logic           if_stall_o,
    output  logic           if2id_stall_o,
    output  logic           id2ex_stall_o,
    output  logic           id2ex_flush_o,
    output  logic           ex2mem_stall_o,
    output  logic           mem2wb_stall_o
);

    // 如果有任何一个端口在读，并且EX阶段是load，并且目标寄存器相同，那么就停掉
    wire read_after_load = (ex_wreg_i & ex_rmem_i) & ((ex_wd_i == id_rs_i && id_reg1_read_i) | (ex_wd_i == id_rt_i && id_reg2_read_i));
    // 当前判断了两种冒险：
    // 第一种：进行除法时，会将所有流水线全部停掉
    // 第二种：当load类型指令在EX阶段，并且ID阶段需要该指令的结果时，需要将if、if2id、id2ex停掉
    assign  if2id_stall_o = ~ex_ok_i | read_after_load;
    assign  if_stall_o  = ~ex_ok_i | read_after_load; // 当运算没有结束时stall
    assign  id2ex_stall_o  = ~ex_ok_i | read_after_load; // 当运算没有结束时stall
    assign  id2ex_flush_o = read_after_load;
    assign  ex2mem_stall_o  = ~ex_ok_i; // 当运算没有结束时stall
    assign  mem2wb_stall_o = ~ex_ok_i; // 当运算没有结束时stall
    
endmodule