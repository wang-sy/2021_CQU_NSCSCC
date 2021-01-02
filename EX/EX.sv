`include "defines.vh"
// 执行阶段
module EX (
    input logic                 clk_i,
    input logic                 rst_i,

    input logic [`AluOpBus]     aluop_i,
    input logic [`AluSelBus]    alusel_i,

    input logic [`RegAddrBus]      reg1_addr_i,
    input logic [`RegAddrBus]      reg2_addr_i,

    input logic [`DataBus]      reg1_i,
    input logic [`DataBus]      reg2_i,
    
    input logic [`RegAddrBus]   wd_i,
    input logic                 wreg_i,

    input logic                 mf_hi_i,
    input logic                 mf_lo_i,
    input logic [`DataBus]      hi_i,
    input logic [`DataBus]      lo_i,

    input logic [`DataBus]      exception_type_i,//qf
    input logic [`DataBus]      current_instr_addr_i,//qf
    input logic                 is_in_delayslot_i,//qf

    input logic [`DataBus]      cp0_reg_data_i,//qf

    input logic                 mem_cp0_reg_we,//qf
    input logic [4:0]           mem_cp0_reg_write_addr,//qf
    input logic [`DataBus]      mem_cp0_reg_data,//qf

    input logic                 wb_cp0_reg_we,//qf
    input logic [4:0]           wb_cp0_reg_write_addr,//qf
    input logic [`DataBus]      wb_cp0_reg_data,//qf
    input [4:0]                 rd,//这信号还是无中生有

    input logic             mem_we_i,
    input logic     [4:0]   mem_waddr_i,
    input logic     [31:0]  mem_wdata_i,

    input logic             wb_we_i,
    input logic     [4:0]   wb_waddr_i,
    input logic     [31:0]  wb_wdata_i,

    input logic reg1_read_i,
    input logic reg2_read_i,

    output logic                ok_o,
    output logic [`DoubleRegBus]wdata_o,

    output logic [`DataBus]     exception_type_o,//qf
    output logic [`DataBus]     current_instr_addr_o,//qf
    output logic                is_in_delayslot_o,//qf

    output logic [4:0]          cp0_reg_read_addr,//qf
    
    //要写入CP0的地址、数据
    output logic                cp0_reg_we_o,//qf
    output logic [4:0]          cp0_reg_write_addr_o,//qf
    output logic [`DataBus]     cp0_reg_data_o//qf

);

    assign current_instr_addr_o = current_instr_addr_i;  //qf
    assign is_in_delayslot_o    = is_in_delayslot_i;  //qf
    assign cp0_reg_read_addr    = rd;

    logic [`DataBus] alu_data1;
    logic [`DataBus] alu_data2;

    logic [`DataBus] alu_data1_hazard;
    logic [`DataBus] alu_data2_hazard;


    // 对进入alu的数据进行选择
    // 当前阶段主要对：
    //  - 寄存器的值
    //  - hilo寄存器的值
    // 进行选择
    alu_data_sel ex_alu_data_sel(
        .rst_i(rst_i),
        .mf_hi_i(mf_hi_i),
        .mf_lo_i(mf_lo_i),
        .reg1_i(reg1_i),
        .reg2_i(reg2_i),
        .hi_i(hi_i),
        .lo_i(lo_i),
        .alu_data1_o(alu_data1),
        .alu_data2_o(alu_data2)
    );



    ex_reg_harzrd ex_ex_reg_harzrd (
        .rst_i(rst_i),

        .reg_addr1_i(reg1_addr_i),
        .reg_addr2_i(reg2_addr_i),

        .reg_data1_i(alu_data1),
        .reg_data2_i(alu_data2),

        .reg1_read_i(reg1_read_i),
        .reg2_read_i(reg2_read_i),

        .mem_we_i(mem_we_i),
        .mem_waddr_i(mem_waddr_i),
        .mem_wdata_i(mem_wdata_i),

        .wb_we_i(wb_we_i),
        .wb_waddr_i(wb_waddr_i),
        .wb_wdata_i(wb_wdata_i),

        .rdata1_o(alu_data1_hazard),
        .rdata2_o(alu_data2_hazard)
    );


    // alu运算单元: 通过前面传来的信号进行运算，将结果赋值给wdata_o
    // 在当前阶段div指令执行时需要多个周期，因此会输出一个ok信号，在ok为0时，需要其他流水级stall
    alu ex_alu(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .aluop_i(aluop_i),
        .alusel_i(alusel_i),
        .reg1_i(alu_data1_hazard),
        .reg2_i(alu_data2_hazard),
        .hi_i(hi_i),
        .lo_i(lo_i),
        .exception_type_i(exception_type_i),//qf

        .cp0_reg_data_i(cp0_reg_data_i),  //qf

        .mem_cp0_reg_we(mem_cp0_reg_we),//qf
        .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr),//qf
        .mem_cp0_reg_data(mem_cp0_reg_data),//qf

        .wb_cp0_reg_we(wb_cp0_reg_we),//qf
        .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr),//qf
        .wb_cp0_reg_data(wb_cp0_reg_data),//qf
        .rd(rd),

        .ok_o(ok_o),
        .wdata_o(wdata_o),
        .exception_type_o(exception_type_o),//qf

        .cp0_reg_we_o(cp0_reg_we_o),//qf
        .cp0_reg_write_addr_o(cp0_reg_write_addr_o),//qf
        .cp0_reg_data_o(cp0_reg_data_o)//qf
    );

endmodule