`include "defines.vh"
/**
* CPU顶层模块
* @param rst 复位信号
* @param clk 时钟信号
* @param rom_data_i 从指令寄存器中获取的指令数据
* @param ram_data_i 从数据寄存器中获取的数据
* @param int_i 外部中断信号
* @param time_int_o 时钟中断信号
* @param rom_ce_o 指令寄存器使能信号
* @param rom_addr_o 访问指令寄存器的地址
* @param ram_addr_o 访问数据寄存器的地址
* @param ram_sel_o 字节选择信号，在写入数据时有效
* @param ram_we_o 是否对数据寄存器进行写操作，1时表示写操作
* @param ram_ce_o 数据寄存器的使能信号
*/
module mips_cpu (
    input   logic           rst_i,
    input   logic           clk_i,
    input   logic [31:0]    rom_data_i,
    input   logic [31:0]    ram_data_i,
    input   logic           int_i,

    output  logic           time_int_o,
    output  logic           rom_ce_o,
    output  logic [31:0]    rom_addr_o,
    output  logic [31:0]    ram_addr_o,
    output  logic [3:0]     ram_sel_o,
    output  logic           ram_we_o,
    output  logic           ram_ce_o
);

    logic [31:0] id_pc;
    logic [31:0] id_inst;

    // IF为取指令模块，主要负责对PC进行更新
    // IF模块会与指令寄存器（ROM）进行交互
    // 交互后，会获取到rom_data_i，即：当前pc对应的指令
    IF datapath_if(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .pc_o(rom_addr_o),
        .ce_o(rom_ce_o)
    );

    // 从IF到ID的信号传递
    IF2ID datapath_if2id(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .if_pc_i(rom_addr_o),
        .if_inst_i(rom_data_i),
        .id_pc_o(id_pc),
        .id_inst_o(id_inst)
    );
    

endmodule