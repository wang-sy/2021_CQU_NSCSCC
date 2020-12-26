//encoding:UTF-8
module wb(
    input clk,
    input rst,

    input [4:0]   mem_wd,
    input         mem_reg,
    input [31:0]  mem_wdata,

    output [4:0]  wb_wd,
    output        wb_reg,
    output [31:0] wb_wdata

);

always@(posedge clk) begin
    if(rst==1'b1) begin
        mem_wd      <=  5'b0;
        mem_reg     <=  1'b0;
        mem_wdata   <=  32'b0;
    end else begin
        wb_wd       <=  mem_wd;
        wb_reg      <=  mem_reg;
        wb_wdata    <=  mem_wdata;
    end
end

endmodule