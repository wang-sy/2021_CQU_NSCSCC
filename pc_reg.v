`timescale 1ns / 1ps


module pc_reg(
	input  wire         clk_i,
	input  wire         rst_i,
	input  wire         stall_i,
	input  wire         flush_i,

	input  wire [31:0]  pc_i,
	input  wire [31:0]  new_pc_i,
	
	output reg  [31:0]  pc_o
    );
	always @(posedge clk_i,posedge rst_i) begin
		if(rst_i) begin
			pc_o <= 32'hbfc00000;
		end else if(flush_i) begin
            pc_o <= new_pc_i;
        end else if(stall_i) begin
			pc_o <= pc_i;
		end
	end
endmodule