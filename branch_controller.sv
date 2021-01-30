`timescale 1ns / 1ps

`include "defines.h"
module branch_controller(
	input  wire [31:0] rdata1_i,
	input  wire [31:0] rdata2_i,
	input  wire [5:0]  id_op_i,
	input  wire [4:0]  id_rt_i,
	output reg         id_equal_o
    );
	always@(*) begin
		case(id_op_i)
			`BEQ: id_equal_o  <=  (rdata1_i == rdata2_i) ? 1 : 0;
			`BNE: id_equal_o  <=  (rdata1_i == rdata2_i) ? 0 : 1;
			`BGTZ:id_equal_o  <=  (rdata1_i[31] == 0 && rdata1_i != 32'b0) ? 1: 0;
			`BLEZ:id_equal_o  <=  (rdata1_i[31] == 1 || rdata1_i == 32'b0) ? 1: 0;
			`REGIMM_INST:case(id_rt_i)
							`BLTZ:id_equal_o   <= (rdata1_i[31] == 1) ? 1: 0;
							`BLTZAL:id_equal_o <= (rdata1_i[31] == 1) ? 1: 0;
							`BGEZ:id_equal_o   <= (rdata1_i[31] == 0) ? 1: 0;
							`BGEZAL:id_equal_o <= (rdata1_i[31] == 0) ? 1: 0;
							default:id_equal_o <= 0;
						 endcase
			default:id_equal_o<=0;
		endcase
	end
endmodule
