`timescale 1ns / 1ps

`include "defines.h"

module IF(
    input logic         clk_i,
    input logic         rst_i,

    input logic         if_flush_i,
    input logic         if_stall_i,

    input logic [31:0]  id_branch_addr_i,
    input logic         id_branch_i,
    input logic         id_do_branch_i,
    input logic [31:0]  id_reg1_data_i,
    input logic         id_jr_i,
    input logic         id_jalr_i,
    input logic [31:0]  id_pc4_i,
    input logic [31:0]  id_instr_i,
    input logic         id_jump_i,
    input logic         id_jal_i,
    
    input logic [31:0]  mem_newpc_i,

    output logic [31:0] if_pc4_o,
    output logic [31:0] if_pc_o,
    output logic [7:0]  if_except_o,
    output logic        if_is_in_delayslot_o
);
    logic [31:0] pc_next;

    assign if_pc4_o = if_pc_o + 32'b100;

    assign pc_next   =  (id_jump_i| id_jal_i)     ?  {id_pc4_i[31:28],id_instr_i[25:0],2'b00} : 
                        ((id_jr_i | id_jalr_i)    ?  id_reg1_data_i                              :
                        (id_do_branch_i==1'b1   ?  id_branch_addr_i                         : if_pc4_o));

	pc_reg if_pc_reg(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(~if_stall_i),
        .flush_i(if_flush_i),
        .pc_i(pc_next),
        .new_pc_i(mem_newpc_i),
        .pc_o(if_pc_o)
    );

	assign if_except_o = (if_pc_o[1:0] == 2'b00) ? 8'b00000000 : 8'b10000000;
	assign if_is_in_delayslot_o = (id_jump_i|id_jalr_i|id_jr_i|id_jal_i|id_branch_i);
    
endmodule