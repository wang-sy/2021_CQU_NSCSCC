/** 
* 根据现有信号，对下一时钟周期的pc进行选择
* 当前阶段直接选择pc + 4
*/
`include "defines.vh"
module pc_next_sel (
    input logic         clk_i,
    input logic         rst_i,
    input logic [31:0]  pc_i,
    input logic         branch_flag_i,
    input logic [31:0]  branch_to_addr_i,

    output logic [31:0] pc_o
);

    assign pc_o =   (rst_i == 1'b1) ? `ZeroWord :
                    (branch_flag_i == 1'b1) ? branch_to_addr_i : pc_i + 32'd4;
endmodule