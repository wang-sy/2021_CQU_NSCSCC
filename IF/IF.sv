`include "defines.vh"
/**
* IF阶段的封装代码
* @param rst 复位信号
* @param clk 时钟信号
* @param rom_data_i 从指令寄存器中获取的指令数据
* @param ram_data_i 从数据寄存器中获取的数据
* @param int_i 外部中断信号
* @param time_int_o 时钟中断信号
* @param rom_ce_o 指令寄存器使能信号
* @param rom_addr_o 访问指令寄存器的地址
* @param ram_addr_o 访问数据寄存器的地址
* @param ram_sel_o 字节选择信号，在写入数据时有用
* @param ram_we_o 是否对数据寄存器进行写操作，1时表示写操作
* @param ram_ce_o 数据寄存器的使能信号
*/
module IF (
    input logic clk_i,
    input logic rst_i,

    output logic [31:0]pc_o,
    output logic ce_o
);

    wire [31:0]pc_next;

    // PC寄存器
    pc_reg if_pc(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .pc_i(pc_next),
        .pc_o(pc_o),
        .ce_o(ce_o)
    );

    // 对下一时序的 pc 进行选择
    pc_next_sel if_pc_next_sel(
        .pc_i(pc_o),
        .pc_o(pc_next)
    );
    
    
endmodule