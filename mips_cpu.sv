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

    // id阶段的信号
    logic [31:0] id_pc;
    logic [31:0] id_inst;

    // ex阶段的信号
    logic [`AluOpBus]       ex_aluop;
    logic [`AluSelBus]      ex_alusel;
    logic [`DataBus]        ex_reg1;
    logic [`DataBus]        ex_reg2;
    logic [`RegAddrBus]     ex_wd;
    logic                   ex_wreg;
    logic [`RegAddrBus]     ex_wdata;

    // mem阶段的信号
    logic [`RegAddrBus]     mem_wd;
    logic                   mem_wreg;
    logic [`RegAddrBus]     mem_wdata;


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

    // EX阶段
    // 负责接收ID阶段的译码结果以及读取的寄存器值
    // 并且通过译码结果进行选择，对读出的寄存器进行不同的运算，将结果写入ex_wdata
    EX datapath_ex(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .aluop_i(ex_aluop),
        .alusel_i(ex_alusel),
        .reg1_i(ex_reg1),
        .reg2_i(ex_reg2),
        .wd_i(ex_wd),
        .wreg_i(ex_wreg),
        .wdata_o(ex_wdata)
    );

    // 从EX到MEM的信号传递
    EX2MEM datapath_ex2mem(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ex_wd_i(ex_wd),
        .ex_wreg_i(ex_wreg),
        .ex_wdata_i(ex_wdata),
        .mem_wd_o(mem_wd),
        .mem_wreg_o(mem_wreg),
        .mem_wdata_o(mem_wdata)
    );
    

endmodule