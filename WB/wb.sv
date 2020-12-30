//encoding:UTF-8
`include "defines.vh"
module wb(
    input  logic                    clk,
    input  logic                    rst,

    input  logic [4:0]              mem_wd,
    input  logic                    mem_reg,
    input  logic [`DoubleRegBus]    mem_wdata,

    input  logic                    flush_i,

    output logic  [4:0]             wb_wd,
    output logic                    wb_reg,
    output logic  [`DataBus]        wb_wdata
);

always@(posedge clk) begin
    if(rst==1'b1) begin
        wb_wd      <=  5'b0;
        wb_reg     <=  1'b0;
        wb_wdata   <=  32'b0;
    end
    else if(flush_i==1'b1) begin
        wb_wd      <=  5'b0;
        wb_reg     <=  1'b0;
        wb_wdata   <=  32'b0;
    end 
    else begin
        wb_wd       <=  mem_wd;
        wb_reg      <=  mem_reg;
        wb_wdata    <=  mem_wdata[31:0];
    end
end

endmodule