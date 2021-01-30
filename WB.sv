`timescale 1ns / 1ps

`include "defines.h"

module WB(
    input  logic        clk_i,
    input  logic        rst_i,

    // hilo
    input  logic [1:0]  wb_hilo_we,

	input  logic [31:0] wb_hi_alu_out,
	input  logic [31:0] wb_lo_alu_out,

	output logic [31:0] id_hi,
	output logic [31:0] id_lo

);
    // wb stage
	hilo_reg hilo(
		clk_i,
		rst_i,
		wb_hilo_we,
		wb_hi_alu_out,
		wb_lo_alu_out,
		id_hi,
		id_lo
	);

endmodule