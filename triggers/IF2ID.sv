`include "defines.vh"

/**
* 负责在IF与ID两级之间传递信号，实质上是一个触发器
*/ 
module IF2ID (
    input logic         clk_i,
    input logic         rst_i,

    input logic [31:0]  if_pc_i,
    input logic [31:0]  if_inst_i,

    output logic [31:0] id_pc_o,
    output logic [31:0] id_inst_o
);

    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            id_pc_o <= `ZeroWord;
            id_inst_o <= `ZeroWord;
        end
        else begin
            id_pc_o <= if_pc_i;
            id_inst_o <= if_inst_i;
        end
    end

endmodule