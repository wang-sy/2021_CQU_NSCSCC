//encoding:UTF-8
module wb(
    input  logic clk,
    input  logic rst,

    input  logic [4:0]   mem_wd,
    input  logic         mem_reg,
    input  logic [31:0]  mem_wdata,

    output logic  [4:0]  wb_wd,
    output logic         wb_reg,
    output logic  [31:0] wb_wdata

);

always@(posedge clk) begin
    if(rst==1'b1) begin
        wb_wd      <=  5'b0;
        wb_reg     <=  1'b0;
        wb_wdata   <=  32'b0;
    end else begin
        wb_wd       <=  mem_wd;
        wb_reg      <=  mem_reg;
        wb_wdata    <=  mem_wdata;
    end
end

endmodule