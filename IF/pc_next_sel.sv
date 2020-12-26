/** 
* 根据现有信号，对下一时钟周期的pc进行选择
* 当前阶段直接选择pc + 4
*/
module pc_next_sel (
    input logic [31:0]pc_i,

    output logic [31:0]pc_o
);
    assign pc_o = pc_i + 32'd4;
endmodule