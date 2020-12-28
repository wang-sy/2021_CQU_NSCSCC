module MEM2WB (
    input logic                 clk_i,
    input logic                 rst_i,
    input logic                 stall_i,

    input logic [`RegAddrBus]   mem_wd_i,
    input logic                 mem_wreg_i,
    input logic [`DoubleRegBus] mem_wdata_i,

    output logic [`RegAddrBus]  wb_wd_o,
    output logic                wb_wreg_o,
    output logic [`DoubleRegBus]wb_wdata_o
);
    
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            wb_wd_o <= `NOPRegAddr;
            wb_wreg_o <= 1'b0;
            wb_wdata_o <= `ZeroWord;
        end
        else if (stall_i == 1'b1) begin
            wb_wd_o <= wb_wd_o;
            wb_wreg_o <= wb_wreg_o;
            wb_wdata_o <= wb_wdata_o;
        end
        else begin
            wb_wd_o <= mem_wd_i;
            wb_wreg_o <= mem_wreg_i;
            wb_wdata_o <= mem_wdata_i;
        end
    end
    
endmodule