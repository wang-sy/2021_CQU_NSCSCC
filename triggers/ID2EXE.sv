//encoding:UTF-8
module id2exe(
    input logic             rst,
    input logic             clk,
    input logic             stall_i,

    input logic   [2:0]     id_alu_sel_i,
    input logic   [7:0]     id_alu_op_i,
    input logic   [31:0]    id_reg1_i,
    input logic   [31:0]    id_reg2_i,
    input logic             id_wreg_i,
    input logic   [4:0]     id_wd_i,
    input logic             id_mt_hi_i,
    input logic             id_mt_lo_i,
    input logic             id_mf_hi_i,
    input logic             id_mf_lo_i,

    output logic  [2:0]     exe_alu_sel_o,
    output logic  [7:0]     exe_alu_op_o,
    output logic  [31:0]    exe_reg1_o,
    output logic  [31:0]    exe_reg2_o,
    output logic            exe_wreg_o,
    output logic  [4:0]     exe_wd_o,
    output logic            exe_mt_hi_o,
    output logic            exe_mt_lo_o,
    output logic            exe_mf_hi_o,
    output logic            exe_mf_lo_o
);

always@(posedge clk) begin
    if(rst==1'b1) begin
        exe_alu_sel_o <=  3'b0;
        exe_alu_op_o  <=  8'b0;
        exe_reg1_o    <=  32'b0;
        exe_reg2_o    <=  32'b0;
        exe_wreg_o    <=  1'b0;
        exe_wd_o      <=  5'b0;
        exe_mt_hi_o   <=  1'b0;
        exe_mt_lo_o   <=  1'b0;
        exe_mf_hi_o   <=  1'b0;
        exe_mf_lo_o   <=  1'b0;
    end 
    else if (stall_i == 1'b1) begin
        exe_alu_sel_o <=  exe_alu_sel_o;
        exe_alu_op_o  <=  exe_alu_op_o;
        exe_reg1_o    <=  exe_reg1_o;
        exe_reg2_o    <=  exe_reg2_o;
        exe_wreg_o    <=  exe_wreg_o;
        exe_wd_o      <=  exe_wd_o;
        exe_mt_hi_o   <=  exe_mt_hi_o;
        exe_mt_lo_o   <=  exe_mt_lo_o;
        exe_mf_hi_o   <=  exe_mf_hi_o;
        exe_mf_lo_o   <=  exe_mf_lo_o;
    end
    else begin
        exe_alu_sel_o <=  id_alu_sel_i;
        exe_alu_op_o  <=  id_alu_op_i;
        exe_reg1_o    <=  id_reg1_i;
        exe_reg2_o    <=  id_reg2_i;
        exe_wreg_o    <=  id_wreg_i;
        exe_wd_o      <=  id_wd_i;
        exe_mt_hi_o   <=  id_mt_hi_i;
        exe_mt_lo_o   <=  id_mt_lo_i;
        exe_mf_hi_o   <=  id_mf_hi_i;
        exe_mf_lo_o   <=  id_mf_lo_i;
    end
end




endmodule