`include "defines.vh"
module alu (
    input logic rst_i,
    input logic [`AluOpBus] aluop_i,
    input logic [`AluSelBus]alusel_i,
    input logic [`DataBus] reg1_i,
    input logic [`DataBus] reg2_i,

    output logic [`DataBus] wdata_o
);

    assign wdata_o = (rst_i == 1'b1) ? `ZeroWord : 
        (alusel_i == `EXE_RES_LOGIC) ? 
            (aluop_i == `EXE_ORI_OP) ? (reg1_i | reg2_i) : 32'd0 :
        32'd0;
    
endmodule