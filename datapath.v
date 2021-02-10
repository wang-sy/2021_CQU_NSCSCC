`timescale 1ns / 1ps

`include "defines.vh"

module datapath(
	input wire         clk,
	input wire         rst,

	output wire[31:0]  if_pc,
	input wire[31:0]   if_instr,

	output wire        id_equal,
	output wire        id_stall,
	output wire [31:0] id_instr,

	output wire        ex_flush,
	output wire        ex_stall,

	output wire[31:0]  mem_wdata,
	output wire[31:0]  mem_wdata_last,
	output wire[1:0]   mem_size,
	input  wire[31:0]  mem_rdata,
	output wire [3:0]  sel,

	output wire        mem_stall,
	output wire        mem_flush,
	output wire [31:0] mem_excepttype,

	output wire [31:0] wb_pc ,    
	output wire [4:0]  wb_regdst, 
	output wire [31:0] wb_wdata,   
	output wire        wb_flush,

	input wire         stallreq_from_if,
	input wire         stallreq_from_mem,

    output wire        mem_we,// mips使用
	output wire        mem_en// mips使用

    );

	// IF
	wire       		if_stall;
	wire [31:0] 	if_pc4;
	wire       		if_flush;
	wire [7:0] 		if_except;
	wire       		if_is_in_delayslot;

	//decode stage
	wire [31:0] 	id_branch_addr;
	wire [31:0] 	id_pc4;
	wire [4:0] 		id_rs,id_rt,id_rd,id_sa;
	wire 			id_flush;

	wire [5:0] 		id_op;
	wire [31:0] 	id_sign_imm;
	wire [31:0] 	id_reg_data1,id_reg_data1_last,id_reg_data2,id_reg_data2_last;
	wire [31:0] 	id_pc;
	wire [31:0] 	id_hi,id_lo;

	wire			id_is_in_delayslot;
	wire [7:0]		id_except;
	wire			id_syscall,id_break,id_eret;

	//execute stage
	wire [4:0] 		ex_rs,ex_rt,ex_rd,ex_sa;
	wire [4:0]		ex_waddr;
	wire [31:0]		ex_sign_imm;
	wire [31:0] 	ex_regdata1,ex_regdata2,ex_regdata2_last;
	wire [31:0] 	ex_wdata;
	wire [31:0]	 	ex_pc;
	wire [5:0] 		ex_op;
	wire 			ex_bal,ex_jal,ex_jalr;
	wire 			ov;
	wire 			ex_ready,ex_start;
	wire [31:0] 	ex_hi_data,ex_lo_data;

	//hi-lo reg value propagate
	wire [31:0]		ex_hi,ex_lo;
	wire [4:0]      ex_alucontrol;
	wire [1:0]      ex_hilo_we;
	wire            ex_is_in_delayslot;	
	wire [7:0]      ex_except;
	wire [31:0]     ex_cp0data;

	//mem stage
	wire [4:0]      mem_rdst;
	wire [31:0]     mem_pc;
	wire [5:0]      mem_op;
	wire [31:0]     mem_rdata2,mem_finaldata,mem_result;
	wire [31:0]     mem_hi_alu_out,mem_lo_alu_out;
	wire [1:0]      mem_hilo_we;
	wire [4:0]      mem_rd;
	wire            mem_is_in_delayslot;
	wire [7:0]      mem_except;
	wire [31:0]		mem_newpc;

	//CP0 varibles
	wire[`RegBus]   data_o,epc_o;

	//writeback stage
	wire [31:0]     wb_rdata;

	//hi-lo reg
	wire [31:0]     wb_hi_alu_out,wb_lo_alu_out;
	wire [1:0]      wb_hilo_we;

	
//////////////////////////////////////////////////////////////////////////////////////////////////////
	// controller
	wire id_do_brach,id_brach_flag,id_jump_flag;
	wire id_jal,id_jr,id_bal,id_jalr;

	wire [4:0] id_alucontrol;
   
    wire [1:0] id_hilo_we; 
    wire       id_invalid;

    wire ex_rmem;
    wire ex_use_imm;
    wire ex_regdst;
    wire ex_wreg;

	wire mem_rmem;
	wire mem_memwe;
	wire mem_cp0we;

	wire wb_wreg;
    wire ex_wmem,ex_cp0we,ex_memen;

	wire wb_wmem;


	// controller的触发器
	wire		   id_rmem;
	wire		   id_wmem;
	wire		   id_use_imm;
	wire		   id_regdst;
	wire		   id_wreg;
	wire		   id_cp0we;
	wire		   id_memen;


	//hazard detection
	hazard h(
		.if_stall			(if_stall),
		.if_flush			(if_flush),

		.id_flush			(id_flush),
		.id_rs			    (id_rs),
		.id_rt			    (id_rt),
		.id_stall			(id_stall),

		.ex_alucontrol		(ex_alucontrol),
		.ex_rt			    (ex_rt),
		.mem_rmem			(ex_rmem),
		.ex_flush			(ex_flush),
		.ex_stall			(ex_stall),
		.div_start			(ex_start),
		.div_ready			(ex_ready),

		.mem_stall			(mem_stall),
		.mem_flush			(mem_flush),
		.mem_excepttype		(mem_excepttype),
		.mem_cp0_epc		(epc_o),
		.mem_newpc			(mem_newpc),

		.wb_flush			(wb_flush),
		.stallreq_from_if	(stallreq_from_if),
		.stallreq_from_mem	(stallreq_from_mem)
	);

	// IF stage
	IF datapath_IF(
		.clk_i(clk),
		.rst_i(rst),

	    .if_flush_i(if_flush),
		.if_stall_i(if_stall),

		.id_branch_addr_i(id_branch_addr),
		.id_branch_i(id_brach_flag),
		.id_do_branch_i(id_do_brach),
		.id_reg1_data_i(id_reg_data1_last),
		.id_jr_i(id_jr),
		.id_jalr_i(id_jalr),
		.id_pc4_i(id_pc4),
		.id_instr_i(id_instr),
		.id_jump_i(id_jump_flag),
		.id_jal_i(id_jal),
		
		.mem_newpc_i(mem_newpc),

		.if_pc4_o(if_pc4),
		.if_pc_o(if_pc),
		.if_except_o(if_except),
		.if_is_in_delayslot_o(if_is_in_delayslot)
	);

    // IF stage to ID stage triger
	if2id datapath_if2id(
        .clk_i(clk),
        .rst_i(rst),
        .flush_i(id_flush),
        .stall_i(id_stall),

        .pcplus4_i(if_pc4),
        .instr_i(if_instr),
        .pc_i(if_pc),
        .except_i(if_except),
        .is_in_delayslot_i(if_is_in_delayslot),

        .pcplus4_o(id_pc4),
        .instr_o(id_instr),
        .pc_o(id_pc),
        .except_o(id_except),
        .is_in_delayslot_o(id_is_in_delayslot)
    );


	// ID stage
	ID datapath_ID(
		.clk_i(clk),
    	.rst_i(rst),

	    .id_stall_i(id_stall),

    	.id_instr_i(id_instr),

		.ex_wdata_i(ex_wdata),
		.mem_wdata_i(mem_result),
		.wb_wdata_i(wb_wdata),

		.id_pc4_i(id_pc4),

		.ex_waddr_i(ex_waddr),
		.mem_waddr_i(mem_rdst),
        .wb_waddr_i(wb_regdst),

		.ex_we_i(ex_wreg),
		.mem_we_i(mem_memwe),
		.wb_we_i(wb_wreg),

    	.sign_imm_o(id_sign_imm),
		.branch_addr_o(id_branch_addr),

		.id_op_o(id_op), 
		.id_rs_o(id_rs), 
		.id_rt_o(id_rt), 
		.id_rd_o(id_rd), 
		.id_sa_o(id_sa), 

		.id_is_syscall_o(id_syscall),
		.id_is_break_o(id_break),
		.id_is_eret_o(id_eret),

		.id_equal_o(id_equal),

		.rdata1_o(id_reg_data1_last),
		.rdata2_o(id_reg_data2_last),
         
		.do_branch_o(id_do_brach),

		.branch_flag_o(id_brach_flag),
		.jump_flag_o(id_jump_flag),

		.jal_flag_o(id_jal),
		.jr_flag_o(id_jr),
		.bal_flag_o(id_bal),
		.jalr_flag_o(id_jalr),

		.id_alucontrol_o(id_alucontrol),

		.id_whilo_o(id_hilo_we),
		.id_invalid_o(id_invalid),

		.id_rmem_o(id_rmem),
		.id_wmem_o(id_wmem),
		.id_use_imm_o(id_use_imm),
		.id_regdst_o(id_regdst),
		.id_wreg_o(id_wreg),
		.id_wcp0_o(id_cp0we),
		.id_memen_o(id_memen)
    );
	
    // ID stage to EXE stage triger
	id2exe datapath_id2exe(
    	.clk_i(clk),
    	.rst_i(rst),
    	.flush_i(ex_flush),
    	.stall_i(ex_stall),

    	.rdata1_i(id_reg_data1_last),
    	.rdata2_i(id_reg_data2_last),
    	.sign_imm_i(id_sign_imm),

    	.rs_i(id_rs),
    	.rt_i(id_rt),
    	.rd_i(id_rd),
    	.sa_i(id_sa),
    	.alucontrol_i(id_alucontrol),
    	.pc_i(id_pc),

    	.bal_i(id_bal),
    	.jal_i(id_jal),
    	.jalr_i(id_jalr),
    	.is_in_delayslot_i(id_is_in_delayslot),

    	.op_i(id_op),
    	.hilo_we_i(id_hilo_we),

    	.hi_i(id_hi),
    	.lo_i(id_lo),
    	.except_i({id_except[7],id_syscall,id_break,id_eret,id_invalid,id_except[2:0]}),

	    // controller的触发器
		.rmem_i(id_rmem),
		.wmem_i(id_wmem),
		.use_imm_i(id_use_imm),

		.regdst_i(id_regdst),
		.wreg_i(id_wreg),
		.wcp0_i(id_cp0we),
		.memen_i(id_memen),
	    // controller的触发器
		.rmem_o(ex_rmem),
		.wmem_o(ex_wmem),
		.use_imm_o(ex_use_imm),
		.regdst_o(ex_regdst),
		.wreg_o(ex_wreg),
		.wcp0_o(ex_cp0we),
		.memen_o(ex_memen),


    	.rdata1_o(ex_regdata1),
    	.rdata2_o(ex_regdata2),
    	.sign_imm_o(ex_sign_imm),
    	.rs_o(ex_rs),
    	.rt_o(ex_rt),
    	.rd_o(ex_rd),
    	.sa_o(ex_sa),
    	.alucontrol_o(ex_alucontrol),
    	.pc_o(ex_pc),

    	.bal_o(ex_bal),
    	.jal_o(ex_jal),
    	.jalr_o(ex_jalr),
    	.is_in_delayslot_o(ex_is_in_delayslot),
    	.op_o(ex_op),
    	.whilo_o(ex_hilo_we),
    	.hi_o(ex_hi),
    	.lo_o(ex_lo),
    	.except_o(ex_except)
    );

    // EXE stage
    EXE datapath_EXE(
	    .clk(clk),
	    .rst(rst),
		
        .ex_rdata1_i(ex_regdata1),
        .ex_rdata2_i(ex_regdata2),

        .wb_wdata_i(wb_wdata),
        .mem_wdata_i(mem_wdata),

        .ex_hi_i(ex_hi),
        .ex_lo_i(ex_lo),

        .mem_hi_alu_out_i(mem_hi_alu_out),
        .wb_hi_alu_out_i(wb_hi_alu_out),
        .mem_lo_alu_out_i(mem_lo_alu_out),
        .wb_lo_alu_out_i(wb_lo_alu_out),

        .ex_sign_imm_i(ex_sign_imm),
        .use_imm_i(ex_use_imm),

        .ex_cp0_data_i(ex_cp0data),
        .ex_sa_i(ex_sa),
        .ex_alucontrol_i(ex_alucontrol),

        .ex_pc_i(ex_pc),
        .ex_jal_i(ex_jal),
        .ex_jalr_i(ex_jalr),
        .ex_bal_i(ex_bal),
        .ex_rd_i(ex_rd),
        .ex_regdst_i(ex_regdst),
        .ex_start_i(ex_start),

        .ex_rs_i(ex_rs),
        .ex_rt_i(ex_rt),

		.mem_waddr_i(mem_rdst),
		.mem_we_i(mem_memwe),
		.wb_waddr_i(wb_regdst),
		.wb_we_i(wb_wreg),

		.ex_hilo_we_i(ex_hilo_we),
		.mem_hilo_we_i(mem_hilo_we),
		.wb_hilo_we_i(wb_hilo_we),

		.mem_rd_i(mem_rd),
		.mem_wcp0_i(mem_cp0we),

	    .rdata2_o(ex_regdata2_last),
        .ov_o(ov),
        .exe_aluout_o(ex_wdata),
        .ex_waddr_o(ex_waddr),
        .ex_ready_o(ex_ready),
        .ex_hi_data_o(ex_hi_data),
        .ex_lo_data_o(ex_lo_data)
    );



    // EXE stage to MEM stage triger
    exe2mem datapath_exe2mem(
    	.clk_i(clk),
    	.rst_i(rst),
    	.flush_i(mem_flush),
    	.stall_i(mem_stall),

    	.rdata2_i(ex_regdata2_last),
    	.aluout_i(ex_wdata),
    	.waddr_i(ex_waddr),
    	.pc_i(ex_pc),
    	.op_i(ex_op),
    	.hi_data_i(ex_hi_data),
    	.lo_data_i(ex_lo_data),
    	.whilo_i(ex_hilo_we),
    	.rd_i(ex_rd),
    	.is_in_delayslot_i(ex_is_in_delayslot),
    	.except_i({ex_except[7:3],ov,ex_except[1:0]}),

	    // controller的触发器
		.rmem_i(ex_rmem),
		.wmem_i(ex_wmem),
		.wreg_i(ex_wreg),
		.wcp0_i(ex_cp0we),
		.memen_i(ex_memen),

	    // controller的触发器
		.rmem_o(mem_rmem),
		.wmem_o(mem_we),
		.wreg_o(mem_memwe),
		.wcp0_o(mem_cp0we),
		.memen_o(mem_en),

    	.rdata2_o(mem_rdata2),
    	.aluout_o(mem_wdata),
    	.waddr_o(mem_rdst),
    	.pc_o(mem_pc),
    	.op_o(mem_op),

    	.hi_data_o(mem_hi_alu_out),
    	.lo_data_o(mem_lo_alu_out),
    	.whilo_o(mem_hilo_we),
		
    	.rd_o(mem_rd),
    	.is_in_delayslot_o(mem_is_in_delayslot),
    	.except_o(mem_except)
    );

    // MEM STAGE
	MEM datapath_MEM(
        .clk(clk),
	    .rst(rst),
    
        .mem_pc(mem_pc),
        .mem_op(mem_op),

        .mem_aluout(mem_wdata),
        .mem_wdata(mem_rdata2),
        .mem_rdata(mem_rdata),

        .mem_except(mem_except),
        .mem_cp0we(mem_cp0we),
        .mem_rd(mem_rd),
        .ex_rd(ex_rd),
        .mem_is_in_delayslot(mem_is_in_delayslot),
        .mem_rmem(mem_rmem),
    
        .sel(sel),
        .mem_wdata_last(mem_wdata_last),
        .mem_finaldata(mem_finaldata),
        .mem_size(mem_size),
        .mem_excepttype(mem_excepttype),
        .epc_o(epc_o),
        .ex_cp0data(ex_cp0data),
        .mem_result(mem_result)
	);


    // MEM stage to WB stage triger
	mwm2wb datapath_mwm2wb(
		.clk_i(clk),
		.rst_i(rst),
		.flush_i(wb_flush),
		.stall_i(1'b0),

		.result_i(mem_result),
		.finaldata_i(mem_finaldata),
		.writereg_i(mem_rdst),
		.pc_i(mem_pc),
		.hi_alu_out_i(mem_hi_alu_out),
		.lo_alu_out_i(mem_lo_alu_out),
		.hilo_we_i(mem_hilo_we),

	    // controller的触发器
		.memtoreg_i(mem_rmem),
		.regwrite_i(mem_memwe),
	    // controller的触发器
		.memtoreg_o(wb_wmem),
		.regwrite_o(wb_wreg),

		.result_o(wb_wdata),
		.finaldata_o(wb_rdata),
		.writereg_o(wb_regdst),
		.pc_o(wb_pc),
		.hi_alu_out_o(wb_hi_alu_out),
		.lo_alu_out_o(wb_lo_alu_out),
		.hilo_we_o(wb_hilo_we)
	);

    // wb stage
	WB datapath_WB(
		clk,
		rst,
		wb_hilo_we,
		wb_hi_alu_out,
		wb_lo_alu_out,
		id_hi,
		id_lo
	);

endmodule
