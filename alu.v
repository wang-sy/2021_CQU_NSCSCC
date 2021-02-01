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
	input wire clk,
	input wire[31:0] a,b,
	input wire[4:0] sa,
	input wire[4:0] alucontrol,
	input wire [31:0] hi_in,lo_in,
	input wire [31:0] cp0data,
	output wire [31:0] y,
	output wire overflow,
	output wire [31:0] hi_alu_out,lo_alu_out
    );
	
	wire [31:0] result_and;
	assign result_and = a & b;

	wire [31:0] result_or;
	assign result_or = a | b;

	wire [31:0] result_xor;
	assign result_xor = a ^ b;

	wire [31:0] result_nor;
	assign result_nor = ~(a | b);

	wire [31:0] result_add;
	assign result_add = (a + b);

	wire [31:0] result_sub;
	assign result_sub = (a - b);

	wire [31:0] result_slt;
	assign result_slt = {{31{1'b0}},($signed(a)<$signed(b))?1:0};

	wire [31:0] result_sltu;
	assign result_sltu = {{31{1'b0}},(a<b)?1:0};

	wire [31:0] result_lui;
	assign result_lui = {b[15:0], 16'b0};

	wire [63:0] result_mult;
	assign result_mult = $signed(a)*$signed(b);

	wire [63:0] result_multu;
	assign result_multu = a * b;

	wire [31:0] result_sll;
	assign result_sll = b << sa;

	wire [31:0] result_srl;
	assign result_srl = b >> sa;

	wire [31:0] result_sra;
	assign result_sra = ({32{b[31]}} << (6'd32-{1'b0,sa})) | b >> sa;

	wire [31:0] result_sllv;
	assign result_sllv = b << a[4:0];

	wire [31:0] result_srlv;
	assign result_srlv = b >> a[4:0];

	wire [31:0] result_srav;
	assign result_srav = ({32{b[31]}} << (6'd32-{1'b0,a[4:0]})) | b >> a[4:0];

	wire [31:0] result_mfhi;
	assign result_mfhi = hi_in[31:0];

	wire [31:0] result_mflo;
	assign result_mflo = lo_in[31:0];

	wire [31:0] result_mfc0;
	assign result_mfc0 = cp0data;

	wire [31:0] result_mtc0;
	assign result_mtc0 = b;

	assign y = 
		({32{alucontrol == `AND_CONTROL}} & result_and) |
		({32{alucontrol == `OR_CONTROL}} & result_or) | 
		({32{alucontrol == `XOR_CONTROL}} & result_xor) |
		({32{alucontrol == `NOR_CONTROL}} & result_nor) |
		({32{alucontrol == `ADD_CONTROL}} & result_add) |
		({32{alucontrol == `ADDU_CONTROL}} & result_add) |
		({32{alucontrol == `SUB_CONTROL}} & result_sub) |
		({32{alucontrol == `SUBU_CONTROL}} & result_sub) |
		({32{alucontrol == `SLT_CONTROL}} & result_slt) |
		({32{alucontrol == `SLTU_CONTROL}} & result_sltu) |
		({32{alucontrol == `LUI_CONTROL}} & result_lui) |
		({32{alucontrol == `SLL_CONTROL}} & result_sll) |
		({32{alucontrol == `SRL_CONTROL}} & result_srl) |
		({32{alucontrol == `SRA_CONTROL}} & result_sra) |
		({32{alucontrol == `SLLV_CONTROL}} & result_sllv) |
		({32{alucontrol == `SRLV_CONTROL}} & result_srlv) |
		({32{alucontrol == `SRAV_CONTROL}} & result_srav) |

		({32{alucontrol == `MFHI_CONTROL}} & result_mfhi) |
		({32{alucontrol == `MFLO_CONTROL}} & result_mflo) |
		({32{alucontrol == `MFC0_CONTROL}} & result_mfc0) |
		({32{alucontrol == `MTC0_CONTROL}} & result_mtc0);

	assign hi_alu_out = 
		({32{alucontrol == `MULT_CONTROL}} & result_mult[63:32]) |
		({32{alucontrol == `MULTU_CONTROL}} & result_multu[63:32]) | 
		({32{alucontrol == `MTHI_CONTROL}} & a);
	
	assign lo_alu_out = 
		({32{alucontrol == `MULT_CONTROL}} & result_mult[31:0]) |
		({32{alucontrol == `MULTU_CONTROL}} & result_multu[31:0]) | 
		({32{alucontrol == `MTLO_CONTROL}} & a);

	/*
	always @(negedge clk) begin
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
	*/
	assign overflow = 
		( (alucontrol == `ADD_CONTROL) & a[31] & b[31] & ~y[31] | ~a[31] & ~b[31] & y[31])
		|
		( (alucontrol == `SUB_CONTROL) & ((a[31]&&!b[31])&&!y[31])||((!a[31]&&b[31])&&y[31]) );

endmodule
