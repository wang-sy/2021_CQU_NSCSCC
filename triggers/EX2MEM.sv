`include "defines.vh"
module EX2MEM (
    input logic                 clk_i,
    input logic                 rst_i,

    input logic [`RegAddrBus]   ex_wd_i,
    input logic                 ex_wreg_i,
    input logic [`DoubleRegBus] ex_wdata_i,
    input logic                 ex_mt_hi_i,
    input logic                 ex_mt_lo_i,
    input logic                 ex_mf_hi_i,
    input logic                 ex_mf_lo_i,

    output logic[`RegAddrBus]   mem_wd_o,
    output logic                mem_wreg_o,
    output logic[`DoubleRegBus] mem_wdata_o,
    output logic                mem_mt_hi_o,
    output logic                mem_mt_lo_o,
    output logic                mem_mf_hi_o,
    output logic                mem_mf_lo_o
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