`include "defines.vh"
module stall_flush_controller (
    input   logic           rst_i, //qf
    input   logic           ex_ok_i,
    input   logic[31:0]     cp0_epc_i, //qf
    input   logic[31:0]     exception_type_i,  //qf

    input   logic[31:0]     exception_type_encode_i,

    // 用于判断第二种，load类型需要停掉的冒险
    input   logic           inst_stall_i,
    input   logic           data_stall_i,
    input   logic [4:0]     mem_wd_i,
    input   logic           mem_rmem_i,
    input   logic [4:0]     id2exe_reg1_addr_i,
    input   logic [4:0]     id2exe_reg2_addr_i,
    input   logic           id2exe_reg1_read_ena_i,
    input   logic           id2exe_reg2_read_ena_i,

    input   logic [`AluOpBus] id_alu_op_i,
    // id 阶段需要读取的信号
    input   logic [4:0]     id_reg1_addr_i,
    input   logic [4:0]     id_reg2_addr_i,
    input   logic           id_reg1_read_ena_i,
    input   logic           id_reg2_read_ena_i,
    // ex 阶段正在运算的信号
    input   logic           ex_wreg_i,
    input   logic [4:0]     ex_wd_i,

    output  logic           if_stall_o,
    output  logic           if2id_stall_o,
    output  logic           id2ex_stall_o,
    output  logic           ex2mem_stall_o,
    output  logic           mem2wb_stall_o,
    output  logic           stall_all_o,

    output  logic           ex2mem_flush_o,
    output  logic           id2ex_flush_o,

    output  logic           flush,  //qf
    output  logic[31:0]     new_pc  //qf
);

    assign flush = rst_i == 1'b1 ? 1'b0 : (|exception_type_encode_i);

    assign new_pc = rst_i==1'b1 ? 32'b0 : 
                    (exception_type_encode_i == 32'h0000001) ? 32'hBFC00380 :
                    (exception_type_encode_i == 32'h0000004) ? 32'hBFC00380 :
                    (exception_type_encode_i == 32'h0000005) ? 32'hBFC00380 :
                    (exception_type_encode_i == 32'h0000008) ? 32'hBFC00380 :
                    (exception_type_encode_i == 32'h0000009) ? 32'hBFC00380:
                    (exception_type_encode_i == 32'h0000010) ? 32'hBFC00200:
                    (exception_type_encode_i == 32'h0000012) ? 32'hBFC00200 :
                    (exception_type_encode_i == 32'h000000a) ? 32'hBFC00380 :
                    (exception_type_encode_i == 32'h000000d) ? 32'hBFC00380 :
                    (exception_type_encode_i == 32'h000000c) ? 32'hBFC00380 :
                    (exception_type_encode_i == 32'h000000e) ? cp0_epc_i    : 32'h0;

    assign stall_all_o = inst_stall_i | data_stall_i | ~ex_ok_i;

    // 如果当前的EX想要读取的寄存器是LW阶段想要写入的寄存器，那么就需要STALL
    wire read_after_load = (
        mem_rmem_i & (
            (id2exe_reg1_read_ena_i & (id2exe_reg1_addr_i == mem_wd_i)) |
            (id2exe_reg2_read_ena_i & (id2exe_reg2_addr_i == mem_wd_i))
        )
    );
    // 判断是否为需要值的B类型指令
    wire is_branch_inst = (id_alu_op_i == `EXE_BEQ_OP)      ? 1'b1 :
                          (id_alu_op_i == `EXE_BGTZ_OP)     ? 1'b1 :
                          (id_alu_op_i == `EXE_BLEZ_OP)     ? 1'b1 :
                          (id_alu_op_i == `EXE_BNE_OP)      ? 1'b1 :
                          (id_alu_op_i == `EXE_BGEZ_OP)     ? 1'b1 :
                          (id_alu_op_i == `EXE_BGEZAL_OP)   ? 1'b1 :
                          (id_alu_op_i == `EXE_BLTZ_OP)     ? 1'b1 :
                          (id_alu_op_i == `EXE_BLTZAL_OP)   ? 1'b1 : 1'b0;

    // 判断是否为MEM指令
    wire is_mem_inst =  (id_alu_op_i == `EXE_LB_OP)      ? 1'b1 :
                        (id_alu_op_i == `EXE_LBU_OP)     ? 1'b1 :
                        (id_alu_op_i == `EXE_LH_OP)     ? 1'b1 :
                        (id_alu_op_i == `EXE_LHU_OP)      ? 1'b1 :
                        (id_alu_op_i == `EXE_LW_OP)     ? 1'b1 :
                        (id_alu_op_i == `EXE_SB_OP)   ? 1'b1 :
                        (id_alu_op_i == `EXE_SH_OP)     ? 1'b1 :
                        (id_alu_op_i == `EXE_SW_OP)   ? 1'b1 : 1'b0;

    // 如果当前ID阶段在执行需要判断的B指令或者是MEM指令，并且指令的结果：
    // 1、在被ALU运算(判断E阶段的目标寄存器以及写reg)
    // 2、在被MEM读取(判断MEM阶段的目标寄存器以及访存)
    // 那么就需要停止下来，进行等待
    wire  branch_stall = (
        (is_branch_inst | is_mem_inst)  & (
            // 被ALU运算（包含了mem在alu阶段）
            ex_wreg_i & (
                (ex_wd_i == id_reg1_addr_i) & id_reg1_read_ena_i |
                (ex_wd_i == id_reg2_addr_i) & id_reg2_read_ena_i
            )
        )
    );

    // 当前判断了两种冒险：
    // 第一种：进行除法时，会将所有流水线全部停掉
    // 第二种：当load类型指令在EX阶段，并且ID阶段需要该指令的结果时，需要将if、if2id、id2ex停掉
    assign  if2id_stall_o = stall_all_o | read_after_load | branch_stall;
    assign  if_stall_o  = stall_all_o | read_after_load | branch_stall; // 当运算没有结束时stall
    assign  id2ex_stall_o  = stall_all_o | read_after_load; // 当运算没有结束时stall
    assign  ex2mem_stall_o  = stall_all_o; // 当运算没有结束时stall
    assign  mem2wb_stall_o = stall_all_o; // 当运算没有结束时stall

    assign  id2ex_flush_o = branch_stall & ~stall_all_o;
    assign  ex2mem_flush_o = read_after_load & ~stall_all_o;
    
endmodule