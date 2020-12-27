`include "defines.vh"
// hilo寄存器
module hilo_reg (
    input logic [31:0]  clk_i,
    input logic [31:0]  rst_i,

    input logic [31:0]  new_hi_i,
    input logic         w_hi_i,
    input logic [31:0]  new_lo_i,
    input logic         w_lo_i,

    output logic[31:0]  hi_o,
    output logic[31:0]  lo_o
);
    reg [31:0] hi_reg;
    reg [31:0] lo_reg;

    // output assign
    assign {hi_o, lo_o} = {hi_reg, lo_reg};

    always @ (posedge clk_i) begin
        if (rst_i == 1'b1) begin
            hi_reg <= `ZeroWord;
            lo_reg <= `ZeroWord;
        end
        else begin
            hi_reg <= (w_hi_i == 1'b1) ? new_hi_i : hi_reg;
            lo_reg <= (w_lo_i == 1'b1) ? new_lo_i : lo_reg;
        end
    end
    
endmodule