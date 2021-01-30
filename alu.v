// `timescale 1ns / 1ps

// `include "defines.h"

// module alu(
// 	input wire [31:0] reg1_i,
// 	input wire [31:0] reg2_i,

// 	input wire [4:0]  sa,
// 	input wire [4:0]  alucontrol,

// 	input wire [31:0] hi_in,lo_in,
// 	input wire [31:0] cp0_reg_data_i,

// 	output wire [31:0] wdata_o,
// 	output wire        ov,
// 	output wire [31:0] hi_alu_out,
// 	output wire [31:0] lo_alu_out
//     );
	

// 	assign wdata_o = 	alucontrol== `AND_CONTROL   ? (reg1_i & reg2_i)   : 
// 	                 	alucontrol== `OR_CONTROL    ? (reg1_i | reg2_i)   :
// 						alucontrol== `XOR_CONTROL   ? (reg1_i ^ reg2_i)   :
// 						alucontrol== `NOR_CONTROL   ? (~(reg1_i | reg2_i)):

// 						alucontrol== `ADD_CONTROL   ? (reg1_i + reg2_i) :
// 						alucontrol== `ADDU_CONTROL  ? (reg1_i + reg2_i) :
// 						alucontrol== `SUB_CONTROL   ? (reg1_i - reg2_i)  :
// 						alucontrol== `SUBU_CONTROL  ? (reg1_i - reg2_i)  :

// 						alucontrol== `SLT_CONTROL   ? (($signed(reg1_i)<$signed(reg2_i))? 1 : 0) :
// 						alucontrol== `SLTU_CONTROL  ? (reg1_i<reg2_i)                            :
// 						alucontrol== `LUI_CONTROL   ? ({reg2_i[15:0], 16'b0})                    :
// 						alucontrol== `MULT_CONTROL  ? ($signed(reg1_i)*$signed(reg2_i))          :
// 						alucontrol== `MULTU_CONTROL ? (reg1_i * reg2_i)                          :

// 						alucontrol== `SLL_CONTROL   ? (reg2_i << sa)                                                             :
// 						alucontrol== `SRL_CONTROL   ? (reg2_i >> sa)                                                             :
// 						alucontrol== `SRA_CONTROL   ? (({32{reg2_i[31]}} << (6'd32-{1'b0,sa})) | reg2_i >> sa)                   :
// 						alucontrol== `SLLV_CONTROL  ? (reg2_i << reg1_i[4:0])                                                    :
// 						alucontrol== `SRLV_CONTROL  ? (reg2_i >> reg1_i[4:0])                                                    :
// 						alucontrol== `SRAV_CONTROL  ? (({32{reg2_i[31]}} << (6'd32-{1'b0,reg1_i[4:0]})) | reg2_i >> reg1_i[4:0]) :

// 						alucontrol== `MFHI_CONTROL  ? (hi_in[31:0])    :
// 						alucontrol== `MFLO_CONTROL  ? (lo_in[31:0])    :
// 						alucontrol== `MTHI_CONTROL  ? (reg1_i)         :
// 						alucontrol== `MTLO_CONTROL  ? (reg1_i)         :
// 						alucontrol== `MFC0_CONTROL  ? (cp0_reg_data_i) :
// 						alucontrol== `MTC0_CONTROL  ? (reg2_i)         :   32'b0 ;

// 	assign ov = alucontrol==`ADD_CONTROL ? (reg1_i[31] & reg2_i[31] & ~wdata_o[31] | ~reg1_i[31] & ~reg2_i[31] & wdata_o[31])    : 
// 	            alucontrol==`SUB_CONTROL ? (((reg1_i[31]&&!reg2_i[31])&&!wdata_o[31])||((!reg1_i[31]&&reg2_i[31])&&wdata_o[31])) : 1'b0 ;

// endmodule

`timescale 1ns / 1ps

`include "defines.h"

module alu(
	input wire[31:0] a,b,
	input wire[4:0] sa,
	input wire[4:0] alucontrol,
	input wire [31:0] hi_in,lo_in,
	input wire [31:0] cp0data,
	output reg[31:0] y,
	output reg overflow,
	output  reg[31:0] hi_alu_out,lo_alu_out
    );
	
	always @(*) begin
		case (alucontrol)
			// logic and algor inst
			`AND_CONTROL:  y <= a & b;
			`OR_CONTROL:   y <= a | b;
			`XOR_CONTROL:  y <= a ^ b;
			`NOR_CONTROL:  y <= ~(a | b);

			`ADD_CONTROL, `ADDU_CONTROL: y <= a + b;
			`SUB_CONTROL, `SUBU_CONTROL: y <= a - b;
			`SLT_CONTROL:  y <= ($signed(a)<$signed(b))? 1 : 0;
			`SLTU_CONTROL: y <= (a<b);
			`LUI_CONTROL:  y <= {b[15:0], 16'b0};
			`MULT_CONTROL: {hi_alu_out,lo_alu_out} = $signed(a)*$signed(b);
			`MULTU_CONTROL:{hi_alu_out,lo_alu_out} = a * b;
			//shift inst
			`SLL_CONTROL:  y <= b << sa;
			`SRL_CONTROL:  y <= b >> sa;
			`SRA_CONTROL:  y <= ({32{b[31]}} << (6'd32-{1'b0,sa})) | b >> sa;
			`SLLV_CONTROL: y <= b << a[4:0];
			`SRLV_CONTROL: y <= b >> a[4:0];
			`SRAV_CONTROL: y <= ({32{b[31]}} << (6'd32-{1'b0,a[4:0]})) | b >> a[4:0];
			//data_move inst
			`MFHI_CONTROL:y <= hi_in[31:0];
			`MFLO_CONTROL:y <= lo_in[31:0];
			`MTHI_CONTROL:hi_alu_out <= a;
			`MTLO_CONTROL:lo_alu_out <= a;
			`MFC0_CONTROL: y <= cp0data;
			`MTC0_CONTROL: y <= b;
			default : y <= 32'b0;
		endcase	
	end

	always @(*) begin
		case (alucontrol)
			`ADD_CONTROL: overflow <= a[31] & b[31] & ~y[31] | ~a[31] & ~b[31] & y[31];
			`SUB_CONTROL: overflow <= ((a[31]&&!b[31])&&!y[31])||((!a[31]&&b[31])&&y[31]);
			`ADDU_CONTROL:overflow <= 0;
			`SUBU_CONTROL:overflow <= 0;
			default: overflow <= 0;
        endcase
	end
endmodule
