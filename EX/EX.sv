`include "defines.vh"
// 执行阶段
module EX (
    input logic                 clk_i,
    input logic                 rst_i,
    input logic [`AluOpBus]     aluop_i,
    input logic [`AluSelBus]    alusel_i,
    input logic [`DataBus]      reg1_i,
    input logic [`DataBus]      reg2_i,
    input logic [`RegAddrBus]   wd_i,
    input logic                 wreg_i,

    input logic                 mf_hi_i,
    input logic                 mf_lo_i,
    input logic [`DataBus]      hi_i,
    input logic [`DataBus]      lo_i,

    output logic [`DoubleRegBus]wdata_o
);

    logic [`DataBus] alu_data1;
    logic [`DataBus] alu_data2;

    // 对进入alu的数据进行选择
    // 当前阶段主要对：
    //  - 寄存器的值
    //  - hilo寄存器的值
    // 进行选择
    alu_data_sel ex_alu_data_sel(
        .rst_i(rst_i),
        .mf_hi_i(mf_hi_i),
        .mf_lo_i(mf_lo_i),
        .reg1_i(reg1_i),
        .reg2_i(reg2_i),
        .hi_i(hi_i),
        .lo_i(lo_i),
        .alu_data1_o(alu_data1),
        .alu_data2_o(alu_data2)
    );


    // alu运算单元: 通过前面传来的信号进行运算，将结果赋值给wdata_o
    alu ex_alu(
        .rst_i(rst_i),
        .aluop_i(aluop_i),
        .alusel_i(alusel_i),
        .reg1_i(alu_data1),
        .reg2_i(alu_data2),
        .hi_i(hi_i),
        .lo_i(lo_i),
        .wdata_o(wdata_o)
    );

endmodule