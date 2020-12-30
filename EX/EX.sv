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

    input logic [`DataBus]      exception_type_i,//qf
    input logic [`DataBus]      current_instr_addr_i,//qf
    input logic                 is_in_delayslot_i,//qf

    output logic                ok_o,
    output logic [`DoubleRegBus]wdata_o,

    output logic [`DataBus]     exception_type_o,//qf
    output logic [`DataBus]     current_instr_addr_o,//qf
    output logic                is_in_delayslot_o//qf

);
    assign current_instr_addr_o = current_instr_addr_o;  //qf
    assign is_in_delayslot_o    = is_in_delayslot_i;  //qf

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
    // 在当前阶段div指令执行时需要多个周期，因此会输出一个ok信号，在ok为0时，需要其他流水级stall
    alu ex_alu(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .aluop_i(aluop_i),
        .alusel_i(alusel_i),
        .reg1_i(alu_data1),
        .reg2_i(alu_data2),
        .hi_i(hi_i),
        .lo_i(lo_i),
        .exception_type_i(exception_type_i),//qf
        .ok_o(ok_o),
        .wdata_o(wdata_o),
        .exception_type_o(exception_type_o),//qf

    );

endmodule