`timescale 1ns / 1ps

`include "defines.h"

module if2id(
    input  logic        clk_i,
    input  logic        rst_i,
    input  logic        flush_i,
    input  logic        stall_i,

    input  logic [31:0] pcplus4_i,
    input  logic [31:0] instr_i,
    input  logic [31:0] pc_i,
    input  logic [7:0]  except_i,
    input               is_in_delayslot_i,

    output logic [31:0] pcplus4_o,
    output logic [31:0] instr_o,
    output logic [31:0] pc_o,
    output logic [7:0]  except_o,
    output logic        is_in_delayslot_o
);

    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            pcplus4_o         <= 32'b0;
            instr_o           <= 32'b0;
            pc_o              <= 32'b0;
            except_o          <= 8'b0;
            is_in_delayslot_o <= 1'b0;
        end
        else if (flush_i == 1'b1) begin
            pcplus4_o         <= 32'b0;
            instr_o           <= 32'b0;
            pc_o              <= 32'b0;
            except_o          <= 8'b0;
            is_in_delayslot_o <= 1'b0;
        end
        else if (stall_i == 1'b1) begin
            pcplus4_o         <= pcplus4_o;
            instr_o           <= instr_o;
            pc_o              <= pc_o;
            except_o          <= except_o;
            is_in_delayslot_o <= is_in_delayslot_o;
        end
        else begin
            pcplus4_o         <= pcplus4_i;
            instr_o           <= instr_i;
            pc_o              <= pc_i;
            except_o          <= except_i;
            is_in_delayslot_o <= is_in_delayslot_i;
        end
    end

endmodule