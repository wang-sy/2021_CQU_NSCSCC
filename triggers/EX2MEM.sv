`include "defines.vh"
module EX2MEM (
    input logic                 clk_i,
    input logic                 rst_i,
    input logic                 stall_i,

    input logic [`RegAddrBus]   ex_wd_i,
    input logic                 ex_wreg_i,
    input logic [`DoubleRegBus] ex_wdata_i,
    input logic                 ex_mt_hi_i,
    input logic                 ex_mt_lo_i,
    input logic                 ex_mf_hi_i,
    input logic                 ex_mf_lo_i,

    input logic                 flush_i,
    input logic [`RegAddrBus]   ex_exception_type_i,
    input logic [`RegAddrBus]   ex_current_instr_addr_i,
    input logic                 ex_is_in_delayslot,

    output logic [`RegAddrBus]  mem_wd_o,
    output logic                mem_wreg_o,
    output logic [`DoubleRegBus]mem_wdata_o,
    output logic                mem_mt_hi_o,
    output logic                mem_mt_lo_o,
    output logic                mem_mf_hi_o,
    output logic                mem_mf_lo_o,

    output logic [`RegAddrBus]  mem_exception_type_o,
    output logic [`RegAddrBus]  mem_current_instr_addr_o,
    output logic                mem_is_in_delayslot
);
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            mem_wd_o <= `RegNumLog2'd0;
            mem_wreg_o <= 1'b0;
            mem_wdata_o <= `RegWidth'd0;
            mem_mt_hi_o <= 1'b0;
            mem_mt_lo_o <= 1'b0;
            mem_mf_hi_o <= 1'b0;
            mem_mf_lo_o <= 1'b0;
            mem_exception_type_o<=32'b0;
            mem_current_instr_addr_o<=32'b0;
            mem_is_in_delayslot<=1'b0;
        end
        else if(flush_i==1'b1) begin
            mem_wd_o <= `RegNumLog2'd0;
            mem_wreg_o <= 1'b0;
            mem_wdata_o <= `RegWidth'd0;
            mem_mt_hi_o <= 1'b0;
            mem_mt_lo_o <= 1'b0;
            mem_mf_hi_o <= 1'b0;
            mem_mf_lo_o <= 1'b0;
            mem_exception_type_o<=32'b0;
            mem_current_instr_addr_o<=32'b0;
            mem_is_in_delayslot<=1'b0;
        end
        else if(stall_i == 1'b1) begin
            mem_wd_o <= mem_wd_o;
            mem_wreg_o <= mem_wreg_o;
            mem_wdata_o <= mem_wdata_o;
            mem_mt_hi_o <= mem_mt_hi_o;
            mem_mt_lo_o <= mem_mt_lo_o;
            mem_mf_hi_o <= mem_mf_hi_o;
            mem_mf_lo_o <= mem_mf_lo_o;
        end
        else begin
            mem_wd_o <= ex_wd_i;
            mem_wreg_o <= ex_wreg_i;
            mem_wdata_o <= ex_wdata_i;
            mem_mt_hi_o <= ex_mt_hi_i;
            mem_mt_lo_o <= ex_mt_lo_i;
            mem_mf_hi_o <= ex_mf_hi_i;
            mem_mf_lo_o <= ex_mf_lo_i;
        end
    end
endmodule