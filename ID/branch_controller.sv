`include "defines.vh"
// branch控制器，读取两个寄存器的读取值
// 通过aluop对branch指令的类型进行选择
// 根据不同branch指令，选择是否进行跳转
module branch_controller (
    input   logic [7:0]     aluop_i,
    input   logic [31:0]    reg1_i,
    input   logic [31:0]    reg2_i,
    
    output  logic           do_branch_o
);

    // 判断数字与 0之间的关系，就只需要判断数字的首位即可(符号位)
    assign do_branch_o =    ( aluop_i == `EXE_BEQ_OP    ) ? ((reg1_i == reg2_i)     ? 1'b1 : 1'b0)  : 
                            ( aluop_i == `EXE_BGTZ_OP   ) ? ((reg1_i[31] != 1'b1 && reg1_i != `ZeroWord)   ? 1'b1 : 1'b0)  : 
                            ( aluop_i == `EXE_BLEZ_OP   ) ? ((reg1_i[31] != 1'b1 && reg1_i != `ZeroWord)   ? 1'b0 : 1'b1)  :  // 这里是小于等于0，就是对大于0取反
                            ( aluop_i == `EXE_BNE_OP    ) ? ((reg1_i != reg2_i)     ? 1'b1 : 1'b0)  : 
                            ( aluop_i == `EXE_BGEZ_OP   ) ? ((reg1_i[31] == 1'b1)   ? 1'b0 : 1'b1)  : 
                            ( aluop_i == `EXE_BGEZAL_OP ) ? ((reg1_i[31] == 1'b1)   ? 1'b0 : 1'b1)  : 
                            ( aluop_i == `EXE_BLTZ_OP   ) ? ((reg1_i[31] == 1'b1)   ? 1'b1 : 1'b0)  : 
                            ( aluop_i == `EXE_BLTZAL_OP ) ? ((reg1_i[31] == 1'b1)   ? 1'b1 : 1'b0)  : 1'b0;

    
endmodule