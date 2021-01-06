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
    input   logic [5:0]     int_i,  //赛宇 坑我 不给宽度
    input   logic           inst_stall_i,
    input   logic           data_stall_i,

    output  logic           rom_ce_o,
    output  logic [31:0]    rom_addr_o,
    output  logic [31:0]    ram_wdata_o,
    output  logic [31:0]    ram_addr_o,
    output  logic [3:0]     ram_sel_o,
    output  logic           ram_we_o,
    output  logic           ram_ce_o,
    output  logic           time_int_o,  //定时中断，暂未进行信号赋值
    output  logic           stall_all_o, // 全局流水线停顿，在进行（乘除法运算、id取指时可能出现）
    output  logic           cpu_flush_o,

    //debug interface
    output wire[31:0]   debug_wb_pc,
    output wire[3:0]    debug_wb_rf_wen,
    output wire[4:0]    debug_wb_rf_wnum,
    output wire[31:0]   debug_wb_rf_wdata
);

    debug_controller datapath_debug_controller(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .debug_pc_i(wb_pc),
        .debug_wena_i(wb_wreg),
        .debug_wd_i(wb_wd),
        .debug_wdata_i(wb_wdata[31:0]),
        .debug_wb_pc_o(debug_wb_pc),
        .debug_wb_rf_wen_o(debug_wb_rf_wen),
        .debug_wb_rf_wnum_o(debug_wb_rf_wnum),
        .debug_wb_rf_wdata_o(debug_wb_rf_wdata)
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
    logic [4:0]             id_rs;
    logic [4:0]             id_rt;
    logic                   id_reg1_read;
    logic                   id_reg2_read;
    

    // ex阶段的信号
    logic [31:0]            ex_pc;
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
    logic [31:0]            mem_pc;
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
    logic [31:0]            wb_pc;
    logic [`RegAddrBus]     wb_wd;
    logic                   wb_wreg;
    logic [`DoubleRegBus]   wb_wdata;
    logic [`RegAddrBus]     wb_wd_control;
    logic                   wb_wreg_control;
    logic [`DoubleRegBus]   wb_wdata_control;

    // 各阶段的stall状态
    logic                   if_stall;
    logic                   if2id_stall;
    logic                   id2ex_stall;
    logic                   id2ex_flush;
    logic                   ex2mem_stall;
    logic                   mem2wb_stall;

    logic controller_flush;
    logic [31:0] controller_new_pc;


////////////////////////////////////////////////////////////////////////////////////////
    logic                ex2mem_cp0_reg_we;//qf
    logic [4:0]          ex2mem_cp0_reg_write_addr;//qf
    logic [31:0]         ex2mem_cp0_reg_data; //qf

    logic [31:0] cp0_data_o;
    logic [31:0] cp0_count_o;
    logic [31:0] cp0_compare_o;
    logic [31:0] cp0_status_o;
    logic [31:0] cp0_cause_o;
    logic [31:0] cp0_epc_o;
    logic [31:0] cp0_config_o;
    logic [31:0] cp0_prid_o;
    logic        cp0_timer_int_o;

    logic [31:0] id_exception_o;
    logic [31:0] id_current_instr_addr_o;
    logic  id_is_in_delayslot_o;
    logic  id_next_is_in_delayslot_o;

    logic [4:0]  id_rd_o;
    logic [4:0]  id2exe_rd_o;
    logic [31:0] id2exe_exception_o;
    logic [31:0] id2exe_current_instr_addr_o;
    logic        id2exe_in_delayslot_o;

    logic id2exe_is_in_delayslot_o;

    logic [31:0] ex_exception_o;
    logic [31:0] ex_current_instr_addr_o;
    logic        ex_in_delayslot_o;
    logic [4:0]  ex_cp0_reg_read_addr;

    logic        ex_cp0_reg_we;//qf
    logic [4:0]  ex_cp0_reg_write_addr;//qf
    logic [31:0] ex_cp0_reg_data; //qf
    logic [31:0] ex2mem_exception_o;
    logic [31:0] ex2mem_current_instr_addr_o;
    logic        ex2mem_in_delayslot_o;
    logic        ex2mem_flush;
    logic        id2ex_flush;

    logic [31:0] mem_exception_type_o;
    logic        mem_wb_cp0_reg_we;
    logic [4:0] mem_wb_cp0_reg_write_addr;
    logic [31:0] mem_wb_cp0_reg_data;

    logic                mem_cp0_reg_we;//qf
    logic [4:0]          mem_cp0_reg_write_addr;//qf
    logic [31:0]         mem_cp0_reg_data; //qf
    logic [31:0]         mem_current_instr_addr_o;
    logic                mem_in_delayslot_o;
    logic [31:0]         mem_cp0_epc_o;

    logic                mem2wb_cp0_reg_we;//qf
    logic [4:0]          mem2wb_cp0_reg_write_addr;//qf
    logic [31:0]         mem2wb_cp0_reg_data; //qf

    logic                wb_cp0_reg_we_control;//qf
    logic [4:0]          wb_cp0_reg_write_addr_control;//qf
    logic [31:0]         wb_cp0_reg_data_control; //qf
    logic [31:0]         exe2mem_inst_o;
    logic id2exe_reg1_read;
    logic id2exe_reg2_read;

    assign cpu_flush_o = controller_flush;

////////////////////////////////////////////////////////////////////////////////////////

    stall_flush_controller datapath_stall_flush_controller(
        .rst_i(rst_i),
        .ex_ok_i(ex_ok),
        .cp0_epc_i(mem_cp0_epc_o),//ex2mem_exception_o

        // .exception_type_i(mem_exception_type_o),//
        .exception_type_i(ex2mem_exception_o),//
        .exception_type_encode_i(mem_exception_type_o),

        .inst_stall_i(inst_stall_i),
        .data_stall_i(data_stall_i),
        .mem_wd_i(mem_wd),
        .mem_rmem_i(mem_rmem),
        .id2exe_reg1_addr_i(id2exe_reg1_addr_o),
        .id2exe_reg2_addr_i(id2exe_reg2_addr_o),
        .id2exe_reg1_read_ena_i(id2exe_reg1_read),
        .id2exe_reg2_read_ena_i(id2exe_reg2_read),
        .id_alu_op_i(id_aluop),
        .id_reg1_addr_i(id_reg1_addr_o),
        .id_reg2_addr_i(id_reg2_addr_o),
        .id_reg1_read_ena_i(id_reg1_read),
        .id_reg2_read_ena_i(id_reg2_read),
        .ex_wreg_i(ex_wreg),
        .ex_wd_i(ex_wd),

        .if2id_stall_o(if2id_stall),
        .if_stall_o(if_stall),
        .id2ex_stall_o(id2ex_stall),
        .ex2mem_stall_o(ex2mem_stall),
        .mem2wb_stall_o(mem2wb_stall),
        .stall_all_o(stall_all_o),
        .ex2mem_flush_o(ex2mem_flush),
        .id2ex_flush_o(id2ex_flush),
        .flush(controller_flush),//
        .new_pc(controller_new_pc)//
    );

    cp0_regfile datapath_cp0_regfile(
	    .clk(clk_i),
	    .rst(rst_i),

	    .raddr_i(ex_cp0_reg_read_addr),//

	    .we_i(wb_cp0_reg_we_control),//
	    .waddr_i(wb_cp0_reg_write_addr_control),//
	    .data_i(wb_cp0_reg_data_control),//

	    .excepttype_i(mem_exception_type_o),//
	    .int_i(int_i),//

        .bad_addr_i(mem_bad_addr),


	    .current_inst_addr_i(mem_current_instr_addr_o),//
	    .is_in_delayslot_i(mem_in_delayslot_o),//

	    .data_o(cp0_data_o),//
	    .count_o(cp0_count_o),//
	    .compare_o(cp0_compare_o),//
	    .status_o(cp0_status_o),//
	    .cause_o(cp0_cause_o),//
	    .epc_o(cp0_epc_o),//
	    .config_o(cp0_config_o),//
	    .prid_o(cp0_prid_o),//
	    .timer_int_o(cp0_timer_int_o)//
    );

    // IF为取指令模块，主要负责对PC进行更新
    // IF模块会与指令寄存器（ROM）进行交互
    // 交互后，会获取到rom_data_i，即：当前pc对应的指令

    logic addr_exception;

    IF datapath_if(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(if_stall),

        .flush_i(controller_flush),
        .new_pc_i(controller_new_pc),

        .branch_flag_i(id_branch_flag),
        .branch_to_addr_i(id_branch_to_addr),

        .pc_o(rom_addr_o),
        .ce_o(rom_ce_o),
        .addr_exception(addr_exception)
    );
    
    logic if2id_addr_exception;
    // 从IF到ID的信号传递
    IF2ID datapath_if2id(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(if2id_stall),

        .if_pc_i(rom_addr_o),
        .if_inst_i(rom_data_i),
        .addr_exception_i(addr_exception),

        .flush_i(controller_flush),
        
        .id_pc_o(id_pc),
        .id_inst_o(id_inst),
        .addr_exception_o(if2id_addr_exception)
    );

    // ID阶段
    // 接收IF阶段获取的指令和指令地址
    // 主要进行四点操作：
    //  - 对指令进行译码
    //  - 对寄存器进行读取
    //  - 对下一跳可能的值进行计算
    //  - 根据wb阶段返回的信号对寄存器进行修改
    logic [4:0] id_reg1_addr_o;
    logic [4:0] id_reg2_addr_o;

    ID datapath_id(
        .clk(clk_i),
        .rst(rst_i),

        .pc_i(id_pc),
        .inst_i(id_inst),
        .addr_exception_i(if2id_addr_exception),

        .we_i(wb_wreg_control),
        .waddr_i(wb_wd_control),
        .wdata_i(wb_wdata_control[31:0]),

        .ex_we_i(ex_wreg),
        .ex_waddr_i(ex_wd),
        .ex_wdata_i(ex_wdata[31:0]),
        .mem_we_i(mem_wreg),
        .mem_waddr_i(mem_wd),
        .mem_wdata_i(mem_wdata_o[31:0]),
        .wb_we_i(wb_wreg),
        .wb_waddr_i(wb_wd),
        .wb_wdata_i(wb_wdata[31:0]),

        .is_in_delayslot_i(id2exe_is_in_delayslot_o),//

        .rs_o(id_rs),
        .rt_o(id_rt),

        .reg1_read_o(id_reg1_read),
        .reg2_read_o(id_reg2_read),

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
        .wd_o(id_wd),

        .exception_o(id_exception_o),//
        .current_instr_addr_o(id_current_instr_addr_o),//
        .is_in_delayslot_o(id_is_in_delayslot_o),//
        .next_is_in_delayslot_o(id_next_is_in_delayslot_o),//

        .rd_o(id_rd_o),
        
        .reg1_addr_o(id_reg1_addr_o),
        .reg2_addr_o(id_reg2_addr_o),
        
        .inst_o(id_inst_o)
    );
    logic [31:0] id_inst_o;
    logic [31:0] id2exe_inst_o;
    

    logic [4:0] id2exe_reg1_addr_o;
    logic [4:0] id2exe_reg2_addr_o;

    // 从ID到EX的信号传递
    id2exe datapath_id2ex(
        .rst(rst_i),
        .clk(clk_i),
        .flush_i(controller_flush | id2ex_flush),
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
        .id_pc_i(id_pc),

        .id_exception_i(id_exception_o),
        .id_current_instr_addr_i(id_current_instr_addr_o),
        .id_in_delayslot_i(id_is_in_delayslot_o),

        .next_is_in_delayslot_i(id_next_is_in_delayslot_o),

        .id_inst_i(id_inst),
        .id_inst_o(id2exe_inst_o),
 
        .rd_i(id_rd_o),
        
        .reg1_addr_i(id_reg1_addr_o),
        .reg2_addr_i(id_reg2_addr_o),

        .reg1_read_i(id_reg1_read),
        .reg2_read_i(id_reg2_read),

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
        .exe_mem_io_addr_o(ex_mem_io_addr),
        .exe_pc_o(ex_pc),

        .ex_exception_o(id2exe_exception_o),
        .ex_current_instr_addr_o(id2exe_current_instr_addr_o),
        .ex_in_delayslot_o(id2exe_in_delayslot_o),
        .is_in_delayslot_o(id2exe_is_in_delayslot_o),

        .rd_o(id2exe_rd_o),

        .reg1_addr_o(id2exe_reg1_addr_o),
        .reg2_addr_o(id2exe_reg2_addr_o),

        .reg1_read_o(id2exe_reg1_read),
        .reg2_read_o(id2exe_reg2_read)

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

        .exception_type_i(id2exe_exception_o),
        .current_instr_addr_i(id2exe_current_instr_addr_o),
        .is_in_delayslot_i(id2exe_in_delayslot_o),

        .cp0_reg_data_i(cp0_data_o),//qf

        .reg1_addr_i(id2exe_reg1_addr_o),
        .reg2_addr_i(id2exe_reg2_addr_o),

        .mem_we_i(mem_wreg),
        .mem_waddr_i(mem_wd),
        .mem_wdata_i(mem_wdata_o[31:0]),

        .wb_we_i(wb_wreg),
        .wb_waddr_i(wb_wd),
        .wb_wdata_i(wb_wdata[31:0]),

        .reg1_read_i(id2exe_reg1_read),
        .reg2_read_i(id2exe_reg2_read),


        .mem_cp0_reg_we(mem_cp0_reg_we),//qf
        .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr),//qf
        .mem_cp0_reg_data(mem_cp0_reg_data),//qf

        .wb_cp0_reg_we(wb_cp0_reg_we_control),//qf
        .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_control),//qf
        .wb_cp0_reg_data(wb_cp0_reg_data_control),//qf

        .rd(id2exe_rd_o),

        .ok_o(ex_ok),
        .wdata_o(ex_wdata),

        .exception_type_o(ex_exception_o),
        .current_instr_addr_o(ex_current_instr_addr_o),
        .is_in_delayslot_o(ex_in_delayslot_o),

        .cp0_reg_read_addr(ex_cp0_reg_read_addr),//qf

        .cp0_reg_we_o(ex_cp0_reg_we),//qf
        .cp0_reg_write_addr_o(ex_cp0_reg_write_addr),//qf
        .cp0_reg_data_o(ex_cp0_reg_data)//qf
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
        .ex_pc_i(ex_pc),

        .flush_i(controller_flush | ex2mem_flush),
        .ex_exception_type_i(ex_exception_o),
        .ex_current_instr_addr_i(ex_current_instr_addr_o),
        .ex_is_in_delayslot(ex_in_delayslot_o),

        .ex_cp0_reg_we(ex_cp0_reg_we),//qf
        .ex_cp0_reg_write_addr(ex_cp0_reg_write_addr),//qf
        .ex_cp0_reg_data(ex_cp0_reg_data),//qf

        .id_inst_i(id2exe_inst_o),
        .id_inst_o(exe2mem_inst_o),
 

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
        .mem_mem_io_addr_o(mem_mem_io_addr),
        .mem_pc_o(mem_pc),

        .mem_exception_type_o(ex2mem_exception_o),
        .mem_current_instr_addr_o(ex2mem_current_instr_addr_o),
        .mem_is_in_delayslot(ex2mem_in_delayslot_o),

        .mem_cp0_reg_we(ex2mem_cp0_reg_we),//qf
        .mem_cp0_reg_write_addr(ex2mem_cp0_reg_write_addr),//qf
        .mem_cp0_reg_data(ex2mem_cp0_reg_data)//qf

    );


    // MEM阶段，负责进行访存操作
    // 访存操作主要分为两种：1、对内存进行读取；2、对内存进行写操作
    logic [31:0] mem_bad_addr;

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
        
        .exception_type_i(ex2mem_exception_o),
        .current_instr_addr_i(ex2mem_current_instr_addr_o),
        .is_in_delayslot_i(ex2mem_in_delayslot_o),

        .cp0_status_i(cp0_status_o),
        .cp0_cause_i(cp0_status_o),
        .cp0_epc_i(cp0_epc_o),

        .inst_i(exe2mem_inst_o),

        .wb_cp0_reg_we(mem2wb_cp0_reg_we),
        .wb_cp0_reg_write_addr(mem2wb_cp0_reg_write_addr),
        .wb_cp0_reg_data(mem2wb_cp0_reg_data),

        // .wb_cp0_reg_we(mem2wb_cp0_reg_we),//qf
        // .wb_cp0_reg_write_addr(mem2wb_cp0_reg_write_addr),//qf
        // .wb_cp0_reg_data(mem2wb_cp0_reg_data) //qf


        .cp0_reg_we_i(ex2mem_cp0_reg_we),//qf
        .cp0_reg_write_addr_i(ex2mem_cp0_reg_write_addr),//qf
        .cp0_reg_data_i(ex2mem_cp0_reg_data),//qf

        .hi_o(mem_hi),
        .lo_o(mem_lo),
        .wdata_o(mem_wdata_o),
        .ram_wdata_o(ram_wdata_o),
        .ram_addr_o(ram_addr_o),
        .ram_sel_o(ram_sel_o),
        .ram_we_o(ram_we_o),
        .ram_ce_o(ram_ce_o),

        .exception_type_o(mem_exception_type_o),
        .current_instr_address_o(mem_current_instr_addr_o),
        .is_in_delayslot_o(mem_in_delayslot_o),
        .cp0_epc_o(mem_cp0_epc_o),

        .cp0_reg_we_o(mem_cp0_reg_we),//qf
        .cp0_reg_write_addr_o(mem_cp0_reg_write_addr),//qf
        .cp0_reg_data_o(mem_cp0_reg_data),//qf

        .bad_addr_o(mem_bad_addr)

    );

    logic [31:0] mem2wb_bad_addr;

    // 从MEM到WB的信号传递
    MEM2WB datapath_mem2wb(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(mem2wb_stall),

        .mem_wd_i(mem_wd),
        .mem_wreg_i(mem_wreg),
        .mem_wdata_i(mem_wdata_o),
        .mem_pc_i(mem_pc),

        .flush_i(controller_flush),//controller_flush),

        .mem_bad_addr_i(mem_bad_addr),

        .mem_cp0_reg_we(mem_cp0_reg_we),//qf
        .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr),//qf
        .mem_cp0_reg_data(mem_cp0_reg_data),//qf

        .wb_wd_o(wb_wd),
        .wb_wreg_o(wb_wreg),
        .wb_wdata_o(wb_wdata),
        .wb_pc_o(wb_pc),

        .wb_cp0_reg_we(mem2wb_cp0_reg_we),//qf
        .wb_cp0_reg_write_addr(mem2wb_cp0_reg_write_addr),//qf

        .mem_bad_addr_o(mem2wb_bad_addr),

        .wb_cp0_reg_data(mem2wb_cp0_reg_data) //qf
    );

    wb datapath_wb(
        .clk(clk_i),
        .rst(rst_i),

        .wb_wd(wb_wd),
        .wb_reg(wb_wreg),
        .wb_wdata(wb_wdata),

        .wb_cp0_reg_we(mem2wb_cp0_reg_we),//qf
        .wb_cp0_reg_write_addr(mem2wb_cp0_reg_write_addr),//qf
        .wb_cp0_reg_data(mem2wb_cp0_reg_data), //qf

//区分64为与32位
        .wb_wd_control(wb_wd_control),
        .wb_reg_control(wb_wreg_control),
        .wb_wdata_control(wb_wdata_control),

        .wb_cp0_reg_we_control(wb_cp0_reg_we_control),//qf
        .wb_cp0_reg_write_addr_control(wb_cp0_reg_write_addr_control),//qf
        .wb_cp0_reg_data_control(wb_cp0_reg_data_control) //qf
    );
    

endmodule