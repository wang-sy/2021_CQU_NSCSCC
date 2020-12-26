`include "defines.vh"
// 执行阶段
module EX (
    input logic clk_i,
    input logic rst_i,
    input logic [`AluOpBus] aluop_i,
    input logic [`AluSelBus]alusel_i,
    input logic [`DataBus] reg1_i,
    input logic [`DataBus] reg2_i,
    input logic [`RegAddrBus] wd_i,
    input logic wreg_i,

    output logic [`RegBus]wdata_o
);

    // alu运算单元: 通过前面传来的信号进行运算，将结果赋值给wdata_o
    alu ex_alu(
        .rst_i(rst_i),
        .aluop_i(aluop_i),
        .alusel_i(alusel_i),
        .reg1_i(reg1_i),
        .reg2_i(reg2_i),
        .wdata_o(wdata_o)
    );

endmodule