`timescale 1ns / 1ps

`include "defines.vh"
`include "id_defines.vh"

module instr_decode(

	input wire        id_stall_i,
	input wire [31:0] id_instr_i,

	output wire       branch_flag_o,
	output wire       jump_flag_o,

	output wire       jal_flag_o,
	output wire       jr_flag_o,
	output wire       bal_flag_o,
	output wire       jalr_flag_o,

	output wire[4:0]  alucontrol_o,
	output wire[1:0]  whilo_o,
	output reg        invalid_o,

	output wire       use_imm_o,
	output wire       regdst_o,
	output wire       wreg_o,
	output wire       wcp0_o,

	output wire       rmem_o,
	output wire       wmem_o,
	output wire       memen_o

    );

    wire[3:0] aluop;

	wire [4:0]  rt,rs,rd;
	wire [5:0]  op,func;
	reg  [18:0] controls;

	assign op   =   id_instr_i[31:26];
	assign rs   =   id_instr_i[25:21];
	assign rt   =   id_instr_i[20:16];
	assign rd   =   id_instr_i[15:11];
	assign func =   id_instr_i[5:0];

	assign wcp0_o=((op==`COP0_INST)&(rs==`MTC0))?1:0;

	assign {wreg_o,regdst_o,use_imm_o,branch_flag_o,wmem_o,rmem_o,jump_flag_o,jal_flag_o,jr_flag_o,bal_flag_o,jalr_flag_o,alucontrol_o,memen_o,whilo_o} = controls;

	always @(*) begin
		invalid_o = 0;
		controls <= {11'b0_0_0_0_0_0_0_0_0_0_0,4'b0000, 3'b000};
		if (~id_stall_i) begin
			case (op)
				`R_TYPE:
					case (func)
						//JR and JALR instrs
						`JR:  controls<=    `JR_DECODE;
						`JALR:controls<=    `JALR_DECODE;

						// data_move instrs
						`MFHI:controls <=   `MFHI_DECODE;
						`MFLO:controls <=   `MFLO_DECODE;
						`MTHI:controls <=   `MTHI_DECODE;
						`MTLO:controls <=   `MTLO_DECODE;	

						// mul and div instrs
						`MULTU:controls <=  `MULTU_DECODE;
						`MULT:controls <=   `MULT_DECODE;
						`DIVU:controls <=   `DIVU_DECODE;
						`DIV:controls <=    `DIV_DECODE;

						// R_TYPE Logic operation instrs
						`AND: controls <= `AND_DECODE;
						`OR: controls <=  `OR_DECODE;
						`XOR: controls <= `XOR_DECODE;
						`NOR: controls <= `NOR_DECODE;
						`ADD: controls <= `ADD_DECODE;
						`ADDU: controls <=`ADDU_DECODE;
						`SUB: controls <= `SUB_DECODE;
						`SUBU: controls <=`SUBU_DECODE;
						`SLT: controls <= `SLT_DECODE;
						`SLTU: controls <=`SLTU_DECODE;
						`SLL: controls <= `SLL_DECODE;
						`SRL: controls <= `SRL_DECODE;
						`SRA: controls <= `SRA_DECODE;
						`SLLV: controls <=`SLLV_DECODE;
						`SRLV: controls <=`SRLV_DECODE;
						`SRAV: controls <=`SRAV_DECODE;

						// Privileged instrs
						`BREAK:controls <=`BREAK_DECODE;
						`SYSCALL:controls <=`SYSCALL_DECODE;

						default:invalid_o = 1;
					endcase

				`J:controls <= `J_DECODE;
				`JAL:controls<=`JAL_DECODE;
				`BEQ:controls<= `BEQ_DECODE;
				`BNE:controls<= `BNE_DECODE;
				`BGTZ:controls<=`BGTZ_DECODE;
				`BLEZ:controls<=`BLEZ_DECODE;			
				`REGIMM_INST:
					case(rt)
						`BLTZ:controls<=  `BLTZ_DECODE;
						`BLTZAL:controls<=`BLTZAL_DECODE;
						`BGEZ:controls<=  `BGEZ_DECODE;
						`BGEZAL:controls<=`BGEZAL_DECODE;
						default:invalid_o = 1;//illegal op
					endcase

				`ANDI: controls <= `ANDI_DECODE;
				`XORI: controls <= `XORI_DECODE;
				`LUI:  controls <= `LUI_DECODE;
				`ORI:  controls <= `ORI_DECODE;
				`ADDI: controls <= `ADDI_DECODE;
				`ADDIU:controls <= `ADDIU_DECODE;
				`SLTI: controls <= `SLTI_DECODE;
				`SLTIU:controls <= `SLTIU_DECODE;

				`LW: controls <=`LW_DECODE;
				`SW: controls <=`SW_DECODE;
				`LB:controls <= `LB_DECODE;
				`LBU:controls <=`LBU_DECODE;
				`LH:controls <= `LH_DECODE;
				`LHU:controls <=`LHU_DECODE;
				`SH:controls <= `SH_DECODE;
				`SB:controls <= `SB_DECODE;
				
				//mfc0 and mtc0
				`COP0_INST:
					case(rs)
						`MTC0:controls <= `MTC0_DECODE;
						`MFC0:controls <= `MFC0_DECODE;
						`CO1_INST: 
							case (func)
								`ERET: controls <= `ERET_DECODE;
								/*
								TODO:
								`TLBP:
								`TLBR:
								`TLBWI:
								`TLBWR:
								*/
								default: invalid_o=1;//illegal instrs
							endcase
							controls <= `ERET_DECODE;
						default: invalid_o=1;//illegal instrs
					endcase
			endcase
		end
	end

endmodule