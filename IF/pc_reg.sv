`include "defines.vh"
/**
* PC寄存器的实现
* @param clk_i 时钟信号
* @param rst_i 复位信号
* @param pc_i 输入的PC信号，检测到时钟上升沿后被赋值给pc_o
* @param pc_o 输出的PC信号
* @param ce_o 输出的使能信号
*/
module pc_reg (
    input   logic           clk_i,
    input   logic           rst_i,
    input   logic [31:0]    pc_i,

    output  logic [31:0]    pc_o,
    output  logic           ce_o
);

    assign ce_o = ~ rst_i;

    always @ (posedge clk_i) begin
        if(rst_i == 1'b1) begin
            pc_o <= `ZeroWord;
        end
        else begin
            pc_o <= pc_i;
        end
    end

endmodule