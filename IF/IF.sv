`include "defines.vh"
/**
* IF阶段的封装代码
*/
module IF (
    input logic         clk_i,
    input logic         rst_i,
    input logic         stall_i,

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
        .pc_o(pc_o),
        .ce_o(ce_o)
    );

    // 对下一时序的 pc 进行选择
    pc_next_sel if_pc_next_sel(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .pc_i(pc_o),
        .pc_o(pc_next)
    );
    
    
endmodule