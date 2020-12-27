`include "defines.vh"
module alu (
    input logic                 rst_i,
    input logic [`AluOpBus]     aluop_i,
    input logic [`AluSelBus]    alusel_i,
    input logic [`DataBus]      reg1_i,
    input logic [`DataBus]      reg2_i,

    output logic [`DataBus]     wdata_o
);
//                              条件                            结果
    wire [31:0]logic_res = ( aluop_i == `EXE_ORI_OP  || aluop_i == `EXE_OR_OP )   ? (reg1_i | reg2_i   )  :
                           ( aluop_i == `EXE_ANDI_OP || aluop_i == `EXE_AND_OP)   ? (reg1_i & reg2_i   )  :
                           ( aluop_i == `EXE_XORI_OP || aluop_i == `EXE_XOR_OP)   ? (reg1_i ^ reg2_i   )  :
                           ( aluop_i == `EXE_LUI_OP ) ? (reg2_i            )  :
                           ( aluop_i == `EXE_NOR_OP ) ? (~(reg1_i | reg2_i))  : `ZeroWord;
 
    wire [31:0]shift_res =  ( aluop_i == `EXE_SLL_OP || aluop_i == `EXE_SLLV_OP)  ? ( reg2_i << reg1_i[4:0] )  : 
                            ( aluop_i == `EXE_SRL_OP || aluop_i == `EXE_SRLV_OP)  ? ( reg2_i >> reg1_i[4:0] )  : 
                            ( aluop_i == `EXE_SRA_OP || aluop_i == `EXE_SRAV_OP)  ? ( ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0] )  : `ZeroWord;
    
    assign wdata_o =    (rst_i == 1'b1) ? `ZeroWord : 
                        (alusel_i == `EXE_RES_LOGIC) ? logic_res : 
                        (alusel_i == `EXE_RES_SHIFT) ? shift_res : `ZeroWord;
    
endmodule