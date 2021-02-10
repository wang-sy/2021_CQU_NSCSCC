`timescale 1ns / 1ps

`include "defines.vh"

module EXE(
    input logic          clk,
	input logic          rst,
    
    // // input
    input logic [31 : 0] ex_rdata1_i,
    input logic [31 : 0] ex_rdata2_i,

    input logic [31 : 0] wb_wdata_i,
    input logic [31 : 0] mem_wdata_i,

    input logic [31 : 0] ex_hi_i,
    input logic [31 : 0] ex_lo_i,

    input logic [31 : 0] mem_hi_alu_out_i,
    input logic [31 : 0] wb_hi_alu_out_i,
    input logic [31 : 0] mem_lo_alu_out_i,
    input logic [31 : 0] wb_lo_alu_out_i,

    input logic [31 : 0] ex_sign_imm_i,
    input logic          use_imm_i,

    input logic [31 : 0] ex_cp0_data_i,
    input logic [4 : 0]  ex_sa_i,
    input logic [4 : 0]  ex_alucontrol_i,

    input logic [31 : 0] ex_pc_i,
    input logic          ex_jal_i,
    input logic          ex_jalr_i,
    input logic          ex_bal_i,
    input logic [4 : 0]  ex_rd_i,
    input logic          ex_regdst_i,
    input logic          ex_start_i,

    input logic [4:0]    ex_rs_i,
    input logic [4:0]    ex_rt_i,

	input logic [4:0]    mem_waddr_i,
	input logic          mem_we_i,
	input logic [4:0]    wb_waddr_i,
	input logic          wb_we_i,

    input logic [1:0]    ex_hilo_we_i,
    input logic [1:0]    mem_hilo_we_i,
    input logic [1:0]    wb_hilo_we_i,

    input logic [4:0]    mem_rd_i,
	input logic          mem_wcp0_i,

    output logic [31 : 0] rdata2_o,
    output logic          ov_o,
    output logic [31 : 0] exe_aluout_o,
    output logic [4 : 0]  ex_waddr_o,
    output logic          ex_ready_o,
    output logic [31 : 0] ex_hi_data_o,
    output logic [31 : 0] ex_lo_data_o
    );

    // not used 
    logic [31 : 0]        srca2E;
    logic [31 : 0]        srcb3E;
    logic [31 : 0]        cp0data2E;
    logic [31 : 0]        hi2E;
    logic [31 : 0]        lo2E;
    logic [31 : 0]        aluoutE;
    logic [31 : 0]        hi_alu_outE;
    logic [31 : 0]        lo_alu_outE;
    logic [4  : 0]        writereg1E;
    logic [31 : 0]        hi_div_outE;
    logic [31 : 0]        lo_div_outE;
    logic                 div_signalE;
	
    exe_reg_harzrd exe_exe_reg_harzrd (
        // 用于读取的地址和数据
        .rst_i(rst),

        .reg_addr1_i(ex_rs_i),
        .reg_addr2_i(ex_rt_i),

        .reg_data1_i(ex_rdata1_i),
        .reg_data2_i(ex_rdata2_i),

        .mem_we_i(mem_we_i),
        .mem_waddr_i(mem_waddr_i),
        .mem_wdata_i(mem_wdata_i),

        .wb_we_i(wb_we_i),
        .wb_waddr_i(wb_waddr_i),
        .wb_wdata_i(wb_wdata_i),

        .rdata1_o(srca2E),
        .rdata2_o(rdata2_o)
    );
    
    assign {hi2E,lo2E} = (ex_hilo_we_i==2'b00 & (mem_hilo_we_i==2'b10 | mem_hilo_we_i==2'b01 | mem_hilo_we_i==2'b11)) ? {mem_hi_alu_out_i,mem_lo_alu_out_i}: 
						 (ex_hilo_we_i==2'b00 & (wb_hilo_we_i==2'b10 | wb_hilo_we_i==2'b01 | wb_hilo_we_i==2'b11)) ? {wb_hi_alu_out_i,wb_lo_alu_out_i} : {ex_hi_i,ex_lo_i};

    assign srcb3E = use_imm_i==1'b1 ? ex_sign_imm_i : rdata2_o;

    assign cp0data2E = ((ex_rd_i!=0)&(ex_rd_i == mem_rd_i)&(mem_wcp0_i)) ? mem_wdata_i : ex_cp0_data_i;

	alu alu(clk,srca2E,srcb3E,ex_sa_i,ex_alucontrol_i,hi2E,lo2E,cp0data2E,aluoutE,ov_o,hi_alu_outE,lo_alu_outE);

    assign exe_aluout_o = (ex_jal_i | ex_jalr_i | ex_bal_i) ?  ex_pc_i+8 : aluoutE;
    assign writereg1E = ex_regdst_i==1'b1 ? ex_rd_i : ex_rt_i;

    assign ex_waddr_o = (ex_bal_i | ex_jal_i) ? 5'b11111: writereg1E;

	divider_Primary div_Primary (clk,rst,ex_alucontrol_i,srca2E,srcb3E,1'b0,{hi_div_outE,lo_div_outE},ex_ready_o,ex_start_i);

	assign div_signalE = ((ex_alucontrol_i == `DIV_CONTROL)|(ex_alucontrol_i == `DIVU_CONTROL))? 1 : 0;

    assign ex_hi_data_o = div_signalE ? hi_div_outE : hi_alu_outE;
    assign ex_lo_data_o = div_signalE ? lo_div_outE : lo_alu_outE;


endmodule   