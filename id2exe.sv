`timescale 1ns / 1ps

`include "defines.vh"
module id2exe(
    input   logic          clk_i,
    input   logic          rst_i,
    input   logic          flush_i,
    input   logic          stall_i,

    // // input 
    input   logic [31:0]   rdata1_i,
    input   logic [31:0]   rdata2_i,
    input   logic [31:0]   sign_imm_i,
    input   logic [4:0]    rs_i,
    input   logic [4:0]    rt_i,
    input   logic [4:0]    rd_i,
    input   logic [4:0]    sa_i,
    input   logic [4:0]    alucontrol_i,
    input   logic [31:0]   pc_i,
    input   logic          bal_i,
    input   logic          jal_i,
    input   logic          jalr_i,
    input   logic          is_in_delayslot_i,
    input   logic  [5:0]   op_i,
    input   logic  [1:0]   hilo_we_i,
    input   logic  [31:0]  hi_i,
    input   logic  [31:0]  lo_i,
    input   logic  [7:0]   except_i,
    input   logic          rmem_i,
    input   logic          wmem_i,
    input   logic          use_imm_i,

    input   logic          regdst_i,
    input   logic          wreg_i,
    input   logic          wcp0_i,
    input   logic          memen_i,

    output  logic          rmem_o,
    output  logic          wmem_o,
    output  logic          use_imm_o,
    output  logic          regdst_o,
    output  logic          wreg_o,
    output  logic          wcp0_o,
    output  logic          memen_o,


    output  logic  [31:0]  rdata1_o,
    output  logic  [31:0]  rdata2_o,
    output  logic  [31:0]  sign_imm_o,
    output  logic  [4:0]   rs_o,
    output  logic  [4:0]   rt_o,
    output  logic  [4:0]   rd_o,
    output  logic  [4:0]   sa_o,
    output  logic  [4:0]   alucontrol_o,
    output  logic  [31:0]  pc_o,

    output  logic          bal_o,
    output  logic          jal_o,
    output  logic          jalr_o,
    output  logic          is_in_delayslot_o,
    output  logic  [5:0]   op_o,
    output  logic  [1:0]   whilo_o,
    output  logic  [31:0]  hi_o,
    output  logic  [31:0]  lo_o,
    output  logic  [7:0]   except_o
);

    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            rdata1_o<=0;
            rdata2_o<=0;
            sign_imm_o<=0;
            rs_o<=0;
            rt_o<=0;
            rd_o<=0;
            sa_o<=0;
            alucontrol_o<=0;
            pc_o<=0;
            bal_o<=0;
            jal_o<=0;
            jalr_o<=0;
            is_in_delayslot_o<=0;
            op_o<=0;
            whilo_o<=0;
            hi_o<=0;
            lo_o<=0;
            except_o<=0;
            rmem_o<=0;
            wmem_o<=0;
            use_imm_o<=0;
            regdst_o<=0;
            wreg_o<=0;
            wcp0_o<=0;
            memen_o<=0;

        end
        else if (flush_i == 1'b1) begin
            rdata1_o<=0;
            rdata2_o<=0;
            sign_imm_o<=0;
            rs_o<=0;
            rt_o<=0;
            rd_o<=0;
            sa_o<=0;
            alucontrol_o<=0;
            pc_o<=0;
            bal_o<=0;
            jal_o<=0;
            jalr_o<=0;
            is_in_delayslot_o<=0;
            op_o<=0;
            whilo_o<=0;
            hi_o<=0;
            lo_o<=0;
            except_o<=0;
            rmem_o<=0;
            wmem_o<=0;
            use_imm_o<=0;
            regdst_o<=0;
            wreg_o<=0;
            wcp0_o<=0;
            memen_o<=0;
        end
        else if (stall_i == 1'b1) begin
            rdata1_o<=rdata1_o;
            rdata2_o<=rdata2_o;
            sign_imm_o<=sign_imm_o;
            rs_o<=rs_o;
            rt_o<=rt_o;
            rd_o<=rd_o;
            sa_o<=sa_o;
            alucontrol_o<=alucontrol_o;
            pc_o<=pc_o;
            bal_o<=bal_o;
            jal_o<=jal_o;
            jalr_o<=jalr_o;
            is_in_delayslot_o<=is_in_delayslot_o;
            op_o<=op_o;
            whilo_o<=whilo_o;
            hi_o<=hi_o;
            lo_o<=lo_o;
            except_o<=except_o;
            rmem_o<=rmem_o;
            wmem_o<=wmem_o;
            use_imm_o<=use_imm_o;
            regdst_o<=regdst_o;
            wreg_o<=wreg_o;
            wcp0_o<=wcp0_o;
            memen_o<=memen_o;
        end
        else begin
            rdata1_o<=rdata1_i;
            rdata2_o<=rdata2_i;
            sign_imm_o<=sign_imm_i;
            rs_o<=rs_i;
            rt_o<=rt_i;
            rd_o<=rd_i;
            sa_o<=sa_i;
            alucontrol_o<=alucontrol_i;
            pc_o<=pc_i;
            bal_o<=bal_i;
            jal_o<=jal_i;
            jalr_o<=jalr_i;
            is_in_delayslot_o<=is_in_delayslot_i;
            op_o<=op_i;
            whilo_o<=hilo_we_i;
            hi_o<=hi_i;
            lo_o<=lo_i;
            except_o<=except_i;
            rmem_o<=rmem_i;
            wmem_o<=wmem_i;
            use_imm_o<=use_imm_i;
            regdst_o<=regdst_i;
            wreg_o<=wreg_i;
            wcp0_o<=wcp0_i;
            memen_o<=memen_i;
        end
    end

endmodule