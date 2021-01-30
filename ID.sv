`timescale 1ns / 1ps

`include "defines.h"

module ID(
	input  logic            clk_i,
    input  logic            rst_i,

	input  logic            id_stall_i,

    input  logic  [31:0]    id_instr_i,

	input  logic  [31:0]    ex_wdata_i,
	input  logic  [31:0]    mem_wdata_i,
	input  logic  [31:0]    wb_wdata_i,

	input  logic  [31:0]    id_pc4_i,

	input  logic  [4:0]     ex_waddr_i,
	input  logic  [4:0]     mem_waddr_i,
	input  logic  [4:0]     wb_waddr_i,

	input  logic            ex_we_i,
	input  logic            mem_we_i,
	input  logic            wb_we_i,

    output logic  [31:0]    sign_imm_o,
	output logic  [31:0]    branch_addr_o,

	output logic  [5:0]     id_op_o, 
	output logic  [5:0]     id_func_o,
	output logic  [4:0]     id_rs_o, 
	output logic  [4:0]     id_rt_o, 
	output logic  [4:0]     id_rd_o, 
	output logic  [4:0]     id_sa_o, 

	output  logic           id_is_syscall_o,
	output  logic           id_is_break_o,
	output  logic           id_is_eret_o,

	output  logic           id_equal_o,

	output  logic [31:0]    rdata1_o,
	output  logic [31:0]    rdata2_o,
    
	// controller
	output  logic           do_branch_o,
	output  logic           branch_flag_o,
	output  logic           jump_flag_o,

	output  logic           jal_flag_o,
	output  logic           jr_flag_o,
	output  logic           bal_flag_o,
	output  logic           jalr_flag_o,

	output  logic [4:0]     id_alucontrol_o,

	output logic [1:0]      id_whilo_o,
	output logic            id_invalid_o,

	// controller
	output logic		    id_rmem_o,
	output logic		    id_wmem_o,
	output logic		    id_use_imm_o,
	output logic		    id_regdst_o,
	output logic		    id_wreg_o,
	output logic		    id_wcp0_o,
	output logic		    id_memen_o


);
	logic  [31:0]    reg_data1;
	logic  [31:0]    reg_data2;


	assign sign_imm_o = (id_instr_i[29:28] == 2'b11) ? ({{16{1'b0}},id_instr_i[15:0]}) : ({{16{id_instr_i[15]}},id_instr_i[15:0]});
  
    assign branch_addr_o = id_pc4_i + {sign_imm_o[29:0],2'b00};

	assign id_op_o   = id_instr_i[31:26];
	assign id_func_o = id_instr_i[5:0];
	assign id_rs_o   = id_instr_i[25:21];
	assign id_rt_o   = id_instr_i[20:16];
	assign id_rd_o   = id_instr_i[15:11];
	assign id_sa_o   = id_instr_i[10:6];

	assign id_is_syscall_o = (id_op_o == 6'b000000 && id_func_o == 6'b001100);
	assign id_is_break_o   = (id_op_o == 6'b000000 && id_func_o == 6'b001101);

	assign id_is_eret_o    = (id_instr_i == 32'b01000010000000000000000000011000);

	branch_controller id_branch_controller(
		.rdata1_i(rdata1_o),
		.rdata2_i(rdata2_o),
		.id_op_i(id_op_o),
		.id_rt_i(id_rt_o),
		.id_equal_o(id_equal_o)
	);

	assign do_branch_o = branch_flag_o & id_equal_o;

	id_reg_harzrd id_id_reg_harzrd (

    	.rst_i(rst_i),

    	.reg_addr1_i(id_rs_o),
    	.reg_addr2_i(id_rt_o),

    	.reg_data1_i(reg_data1),
    	.reg_data2_i(reg_data2),

    	.ex_we_i(ex_we_i),
    	.ex_waddr_i(ex_waddr_i),
    	.ex_wdata_i(ex_wdata_i),

    	.mem_we_i(mem_we_i),
    	.mem_waddr_i(mem_waddr_i),
    	.mem_wdata_i(mem_wdata_i),

    	.wb_we_i(wb_we_i),
    	.wb_waddr_i(wb_waddr_i),
    	.wb_wdata_i(wb_wdata_i),

    	.rdata1_o(rdata1_o),
    	.rdata2_o(rdata2_o)
	);

	instr_decode id_instr_decode(

		.id_stall_i(id_stall_i),
		.id_instr_i(id_instr_i),

		//decode stage
		.branch_flag_o(branch_flag_o), // 作为 hazard 和 IF 模块的输入
		.jump_flag_o(jump_flag_o),   // 作为 IF 模块的输入

		.jal_flag_o(jal_flag_o),    // 作为 id2exe 和IF 模块的输入
		.jr_flag_o(jr_flag_o),     // 作为 hazard 和 IF 模块的输入
		.bal_flag_o(bal_flag_o),    // 作为 id2exe 模块的输入
		.jalr_flag_o(jalr_flag_o),   // hazard if id2exe

		.alucontrol_o(id_alucontrol_o),  // id2exe
		.whilo_o(id_whilo_o),  // id2exe
		.invalid_o(id_invalid_o),  // id2exe hazard

		// controller的触发器
		.use_imm_o(id_use_imm_o),
		.regdst_o(id_regdst_o),
		.wreg_o(id_wreg_o),
		.wcp0_o(id_wcp0_o),

		.rmem_o(id_rmem_o),
		.wmem_o(id_wmem_o),
		.memen_o(id_memen_o)
	);

	    // wb stage
	regfile ID_regfile(
		clk_i,
		wb_we_i,
		id_rs_o,
		id_rt_o,
		wb_waddr_i,
		wb_wdata_i,
		reg_data1,
		reg_data2
	);

endmodule