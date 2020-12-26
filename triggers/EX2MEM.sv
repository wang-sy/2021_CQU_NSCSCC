`include "defines.vh"
module EX2MEM (
    input logic                 clk_i,
    input logic                 rst_i,

    input logic [`RegAddrBus]   ex_wd_i,
    input logic                 ex_wreg_i,
    input logic [`DataBus]       ex_wdata_i,

    output logic[`RegAddrBus]   mem_wd_o,
    output logic                mem_wreg_o,
    output logic[`DataBus]       mem_wdata_o
);
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            mem_wd_o <= `RegNumLog2'd0;
            mem_wreg_o <= 1'b0;
            mem_wdata_o <= `RegWidth'd0;
        end
        else begin
            mem_wd_o <= ex_wd_i;
            mem_wreg_o <= ex_wreg_i;
            mem_wdata_o <= ex_wdata_i;
        end
    end
endmodule