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
module datapath (
    input   logic           rst_i,
    input   logic           clk_i,
    input   logic [31:0]    rom_data_i,
    input   logic [31:0]    ram_data_i,
    input   logic           int_i,

    output  logic           time_int_o,
    output  logic           rom_ce_o,
    output  logic [31:0]    rom_addr_o,
    output  logic [31:0]    ram_wdata_o,
    output  logic [31:0]    ram_addr_o,
    output  logic [3:0]     ram_sel_o,
    output  logic           ram_we_o,
    output  logic           ram_ce_o
);

    // id阶段的信号
    logic [31:0] id_pc;
    logic [31:0] id_inst;

    // id阶段的信号
    logic [`AluOpBus]       id_aluop;
    logic [`AluSelBus]      id_alusel;
    logic [`DataBus]        id_reg1;
    logic [`DataBus]        id_reg2;
    logic [`RegAddrBus]     id_wd;
    logic                   id_wreg;
    logic                   id_mt_hi;
    logic                   id_mt_lo;
    logic                   id_mf_hi;
    logic                   id_mf_lo;
    logic                   id_rmem;
    logic                   id_wmem;
    logic                   id_branch_flag;
    logic [31:0]            id_branch_to_addr;
    logic [31:0]            id_mem_io_addr;
    

    // ex阶段的信号
    logic [`AluOpBus]       ex_aluop;
    logic [`AluSelBus]      ex_alusel;
    logic [`DataBus]        ex_reg1;
    logic [`DataBus]        ex_reg2;
    logic [`RegAddrBus]     ex_wd;
    logic                   ex_wreg;
    logic                   ex_ok;
    logic [`DoubleRegBus]   ex_wdata;
    logic                   ex_mt_hi;
    logic                   ex_mt_lo;
    logic                   ex_mf_hi;
    logic                   ex_mf_lo;
    logic                   ex_rmem;
    logic                   ex_wmem;
    logic [31:0]            ex_mem_io_addr;


    // mem阶段的信号
    logic [`AluOpBus]       mem_aluop;
    logic [`RegAddrBus]     mem_wd;
    logic                   mem_wreg;
    logic [`DoubleRegBus]   mem_wdata_i;
    logic [`DoubleRegBus]   mem_wdata_o;
    logic                   mem_mt_hi;
    logic                   mem_mt_lo;
    logic                   mem_mf_hi;
    logic                   mem_mf_lo;
    logic [`DataBus]        mem_hi;
    logic [`DataBus]        mem_lo;
    logic                   mem_rmem;
    logic                   mem_wmem;
    logic [31:0]            mem_mem_io_addr;

    // wb阶段的信号
    logic [`RegAddrBus]     wb_wd;
    logic                   wb_wreg;
    logic [`DoubleRegBus]   wb_wdata;
    logic [`RegAddrBus]     wb_wd_control;
    logic                   wb_wreg_control;
    logic [`DataBus]        wb_wdata_control;

    // 各阶段的stall状态
    logic                   if_stall;
    logic                   if2id_stall;
    logic                   id2ex_stall;
    logic                   ex2mem_stall;
    logic                   mem2wb_stall;

    stall_controller datapath_stall_controller(
        .ex_ok_i(ex_ok),
        .if2id_stall_o(if2id_stall),
        .if_stall_o(if_stall),
        .id2ex_stall_o(id2ex_stall),
        .ex2mem_stall_o(ex2mem_stall),
        .mem2wb_stall_o(mem2wb_stall)
    );
    

    // IF为取指令模块，主要负责对PC进行更新
    // IF模块会与指令寄存器（ROM）进行交互
    // 交互后，会获取到rom_data_i，即：当前pc对应的指令
    IF datapath_if(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(if_stall),
        .branch_flag_i(id_branch_flag),
        .branch_to_addr_i(id_branch_to_addr),
        .pc_o(rom_addr_o),
        .ce_o(rom_ce_o)
    );

    // 从IF到ID的信号传递
    IF2ID datapath_if2id(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(if2id_stall),
        .if_pc_i(rom_addr_o),
        .if_inst_i(rom_data_i),
        .id_pc_o(id_pc),
        .id_inst_o(id_inst)
    );

    // ID阶段
    // 接收IF阶段获取的指令和指令地址
    // 主要进行四点操作：
    //  - 对指令进行译码
    //  - 对寄存器进行读取
    //  - 对下一跳可能的值进行计算
    //  - 根据wb阶段返回的信号对寄存器进行修改
    ID datapath_id(
        .clk(clk_i),
        .rst(rst_i),
        .pc_i(id_pc),
        .inst_i(id_inst),
        .we_i(wb_wreg_control),
        .waddr_i(wb_wd_control),
        .wdata_i(wb_wdata_control),
        .ex_we_i(ex_wreg),
        .ex_waddr_i(ex_wd),
        .ex_wdata_i(ex_wdata[31:0]),
        .mem_we_i(mem_wreg),
        .mem_waddr_i(mem_wd),
        .mem_wdata_i(mem_wdata_o[31:0]),
        .wb_we_i(wb_wreg),
        .wb_waddr_i(wb_wd),
        .wb_wdata_i(wb_wdata[31:0]),
        .aluop_o(id_aluop),
        .alusel_o(id_alusel),
        .reg1_o(id_reg1),
        .reg2_o(id_reg2),
        .mt_hi_o(id_mt_hi),
        .mt_lo_o(id_mt_lo),
        .mf_hi_o(id_mf_hi),
        .mf_lo_o(id_mf_lo),
        .branch_flag_o(id_branch_flag),
        .branch_to_addr_o(id_branch_to_addr),
        .rmem_o(id_rmem),
        .wmem_o(id_wmem),
        .mem_io_addr_o(id_mem_io_addr),
        .wreg_o(id_wreg),
        .wd_o(id_wd)
    );

    // 从ID到EX的信号传递
    id2exe datapath_id2ex(
        .rst(rst_i),
        .clk(clk_i),
        .stall_i(id2ex_stall),
        .id_alu_sel_i(id_alusel),
        .id_alu_op_i(id_aluop),
        .id_reg1_i(id_reg1),
        .id_reg2_i(id_reg2),
        .id_wreg_i(id_wreg),
        .id_wd_i(id_wd),
        .id_mt_hi_i(id_mt_hi),
        .id_mt_lo_i(id_mt_lo),
        .id_mf_hi_i(id_mf_hi),
        .id_mf_lo_i(id_mf_lo),
        .id_rmem_i(id_rmem),
        .id_wmem_i(id_wmem),
        .id_mem_io_addr_i(id_mem_io_addr),
        .exe_alu_sel_o(ex_alusel),
        .exe_alu_op_o(ex_aluop),
        .exe_reg1_o(ex_reg1),
        .exe_reg2_o(ex_reg2),
        .exe_wreg_o(ex_wreg),
        .exe_wd_o(ex_wd),
        .exe_mt_hi_o(ex_mt_hi),
        .exe_mt_lo_o(ex_mt_lo),
        .exe_mf_hi_o(ex_mf_hi),
        .exe_mf_lo_o(ex_mf_lo),
        .exe_rmem_o(ex_rmem),
        .exe_wmem_o(ex_wmem),
        .exe_mem_io_addr_o(ex_mem_io_addr)
    );

    // EX阶段
    // 负责接收ID阶段的译码结果以及读取的寄存器的值
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
        .mf_hi_i(ex_mf_hi),
        .mf_lo_i(ex_mf_lo),
        .hi_i(mem_hi),
        .lo_i(mem_lo),
        .ok_o(ex_ok),
        .wdata_o(ex_wdata)
    );

    // 从EX到MEM的信号传递
    EX2MEM datapath_ex2mem(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(ex2mem_stall),
        .ex_wd_i(ex_wd),
        .ex_wreg_i(ex_wreg),
        .ex_wdata_i(ex_wdata),
        .ex_mt_hi_i(ex_mt_hi),
        .ex_mt_lo_i(ex_mt_lo),
        .ex_mf_hi_i(ex_mf_hi),
        .ex_mf_lo_i(ex_mf_lo),
        .ex_rmem_i(ex_rmem),
        .ex_wmem_i(ex_wmem),
        .ex_aluop_i(ex_aluop),
        .ex_mem_io_addr_i(ex_mem_io_addr),
        .mem_wd_o(mem_wd),
        .mem_wreg_o(mem_wreg),
        .mem_wdata_o(mem_wdata_i),
        .mem_mt_hi_o(mem_mt_hi),
        .mem_mt_lo_o(mem_mt_lo),
        .mem_mf_hi_o(mem_mf_hi),
        .mem_mf_lo_o(mem_mf_lo),
        .mem_rmem_o(mem_rmem),
        .mem_wmem_o(mem_wmem),
        .mem_aluop_o(mem_aluop),
        .mem_mem_io_addr_o(mem_mem_io_addr)
    );

    // MEM阶段，负责进行访存操作
    // 访存操作主要分为两种：1、对内存进行读取；2、对内存进行写操作
    MEM datapath_mem(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .wd_i(mem_wd),
        .wreg_i(mem_wreg),
        .wdata_i(mem_wdata_i),
        .mt_hi_i(mem_mt_hi),
        .mt_lo_i(mem_mt_lo),
        .rmem_i(mem_rmem),
        .wmem_i(mem_wmem),
        .aluop_i(mem_aluop),
        .ram_data_i(ram_data_i),
        .mem_io_addr_i(mem_mem_io_addr),
        .hi_o(mem_hi),
        .lo_o(mem_lo),
        .wdata_o(mem_wdata_o),
        .ram_wdata_o(ram_wdata_o),
        .ram_addr_o(ram_addr_o),
        .ram_sel_o(ram_sel_o),
        .ram_we_o(ram_we_o),
        .ram_ce_o(ram_ce_o)
    );

    // 从MEM到WB的信号传递
    MEM2WB datapath_mem2wb(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(mem2wb_stall),
        .mem_wd_i(mem_wd),
        .mem_wreg_i(mem_wreg),
        .mem_wdata_i(mem_wdata_o),
        .wb_wd_o(wb_wd),
        .wb_wreg_o(wb_wreg),
        .wb_wdata_o(wb_wdata)
    );
    
    // 调用WB模块
    // WB模块主要负责接收前面传来的
    // wb_wd, wb_wreg, wb_wdata三个信号，并判断是否需要写回regfile
    // 根据判断的结果发出相应的控制信号
    wb datapath_wb(
        .clk(clk_i),
        .rst(rst_i),

        .mem_wd(wb_wd),
        .mem_reg(wb_wreg),
        .mem_wdata(wb_wdata),

        .wb_wd(wb_wd_control),
        .wb_reg(wb_wreg_control),
        .wb_wdata(wb_wdata_control)
    );
    

endmodule