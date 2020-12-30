`include "defines.vh"

/**
* 负责在IF与ID两级之间传递信号，实质上是一个触发器
*/ 
module IF2ID (
    input logic         clk_i,
    input logic         rst_i,
    input logic         stall_i,

    input logic [31:0]  if_pc_i,
    input logic [31:0]  if_inst_i,

    input logic         flush_i,  //qf

    output logic [31:0] id_pc_o,
    output logic [31:0] id_inst_o
);

    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            id_pc_o <= `ZeroWord;
            id_inst_o <= `ZeroWord;
        end
        else if(flush_i==1'b1) begin  //qf
            id_pc_o <= `ZeroWord;//qf
            id_inst_o <= `ZeroWord;//qf
        end //qf
        else if (stall_i == 1'b1) begin
            id_pc_o <= id_pc_o;
            id_inst_o <= id_inst_o;
        end
        else begin
            id_pc_o <= if_pc_i;
            id_inst_o <= if_inst_i;
        end
    end

endmodule