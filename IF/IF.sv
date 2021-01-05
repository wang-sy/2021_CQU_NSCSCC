`include "defines.vh"
/**
* IF阶段的封装代码
*/
module IF (
    input logic         clk_i,
    input logic         rst_i,
    input logic         stall_i,

    input logic         flush_i, //qf
    input logic [31:0]  new_pc_i, //qf

    input logic         branch_flag_i,
    input logic [31:0]  branch_to_addr_i,

    output logic [31:0] pc_o,
    output logic        ce_o
);

    logic [31:0]pc_next;

    // PC寄存器
    pc_reg if_pc(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(stall_i),
        .pc_i(pc_next),

        .flush_i(flush_i),//qf
        .new_pc_i(new_pc_i),//qf

        .pc_o(pc_o),
        .ce_o(ce_o)
    );

    // 对下一时序的 pc 进行选择
    pc_next_sel if_pc_next_sel(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .pc_i(pc_o),
        .branch_flag_i(branch_flag_i),
        .branch_to_addr_i(branch_to_addr_i),
        .pc_o(pc_next)
    );
    
    
endmodule