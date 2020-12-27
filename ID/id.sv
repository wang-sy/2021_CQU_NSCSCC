`include "defines.vh"
`include "id_defines.vh"
//encoding:UTF-8
module ID(
    // //输入
    input logic         clk,
    input logic         rst,
    //从IF/ID接收到信号
    input logic [31:0]  pc_i,
    input logic [31:0]  inst_i,
    //WB级传输进来的信号
    input logic         we_i,
    input logic  [4:0]  waddr_i,
    input logic  [31:0] wdata_i,

    // 用于冒险
    input logic         ex_we_i,
    input logic  [4:0]  ex_waddr_i,
    input logic  [31:0] ex_wdata_i,
    input logic         mem_we_i,
    input logic  [4:0]  mem_waddr_i,
    input logic  [31:0] mem_wdata_i,
    input logic         wb_we_i,
    input logic  [4:0]  wb_waddr_i,
    input logic  [31:0] wb_wdata_i,
    


    // //输出
    output logic [7:0]  aluop_o,
    output logic [2:0]  alusel_o,
    output logic [31:0] reg1_o,
    output logic [31:0] reg2_o,

    output logic        mt_hi_o,
    output logic        mt_lo_o,
    output logic        mf_hi_o,
    output logic        mf_lo_o,

    output logic        wreg_o, //是否有数据要写寄存器
    output logic [4:0]  wd_o  //write destination
);

    //寄存器堆接收到的信号
    logic [31:0] reg1_data;
    logic [31:0] reg2_data;
    // 经过冒险决策后的读取结果
    logic [31:0] harzrd_reg1_data;
    logic [31:0] harzrd_reg2_data;


    //读寄存器
    wire        reg1_read; //是否读寄存器1
    wire        reg2_read;

    //定义指令字段信号
    //op   re   rt  immediate
    // 在判断一些指令的时候，还需要用到后六位
    wire [5:0]  op = inst_i[31:26];
    wire [4:0]  rs = inst_i[25:21];
    wire [4:0]  rt = inst_i[20:16];
    wire [4:0]  rd = inst_i[15:11];
    wire [4:0]  sa = inst_i[10:6];
    wire [15:0] im = inst_i[15:0];
    wire [5:0]  sel = inst_i[5:0];

    wire [31:0] sign_imm = {{16{inst_i[15]}},inst_i[15:0]};
    wire [31:0] unsi_imm = {16'b0,inst_i[15:0]};
    wire [31:0] lui_imm = {inst_i[15:0], 16'b0};
    wire [31:0] sa_imm = {27'b0, sa}; // 专门用于shift指令的立即数
    // 当前指令为立即数指令，或是需要使用指令中的数字作为操作数的时候
    // 就使用本资源
    wire [31:0] special_num;


    regfile id_regfile(
        .clk(clk),
        .rst(rst),
        
        .raddr1(rs),// 寄存端口1的读地址
        .raddr2(rt),

        .we(we_i),// 写使能
        .waddr(waddr_i),// 写寄存器地址
        .wdata(wdata_i), //  写寄存器数据

        .rdata1(reg1_data),
        .rdata2(reg2_data)
    );

    // 对读取出来的结果进行冒险决策
    // harzrd_reg1_data 才是当前寄存器中真正的值
    reg_harzrd id_reg_harzrd(
        .rst_i(rst),
        .reg_addr1_i(rs),
        .reg_addr2_i(rt),
        .reg_data1_i(reg1_data),
        .reg_data2_i(reg2_data),
        .ex_we_i(ex_we_i),
        .ex_waddr_i(ex_waddr_i),
        .ex_wdata_i(ex_wdata_i),
        .mem_we_i(mem_we_i),
        .mem_waddr_i(mem_waddr_i),
        .mem_wdata_i(mem_wdata_i),
        .wb_we_i(wb_we_i),
        .wb_waddr_i(wb_waddr_i),
        .wb_wdata_i(wb_wdata_i),
        .rdata1_o(harzrd_reg1_data),
        .rdata2_o(harzrd_reg2_data)
    );

    // nop和ssnop不需要特殊实现，直接默认译码即可
    // 当前，将sync和pref当作空指令处理
    assign { 
        aluop_o,
        alusel_o,
        wreg_o,
        wd_o,
        reg1_read,
        reg2_read,
        special_num,
        mt_hi_o,
        mt_lo_o,
        mf_hi_o,
        mf_lo_o
    } = (rst == 1'b1) ? `INIT_DECODE : (
        (op == `EXE_ORI)    ? `ORI_DECODE   :
        (op == `EXE_ANDI)   ? `ANDI_DECODE  :
        (op == `EXE_XORI)   ? `XORI_DECODE  :
        (op == `EXE_LUI)    ? `LUI_DECODE   :
        (op == `EXE_PREF)   ? `INIT_DECODE  :
        (op == `EXE_ADDI)   ? `ADDI_DECODE  :
        (op == `EXE_ADDIU)  ? `ADDIU_DECODE :
        (op == `EXE_SLTI)   ? `SLTI_DECODE  :
        (op == `EXE_SLTIU)  ? `SLTIU_DECODE :
        (op == `EXE_SPECIAL_INST) ? (
            // special 中的逻辑指令
            (sel == `EXE_AND)   ? `AND_DECODE   :
            (sel == `EXE_OR)    ? `OR_DECODE    :
            (sel == `EXE_XOR)   ? `XOR_DECODE   :
            (sel == `EXE_NOR)   ? `NOR_DECODE   :
            // special 中的shift指令
            (sel == `EXE_SLL)   ? `SLL_DECODE   :
            (sel == `EXE_SRL)   ? `SRL_DECODE   :
            (sel == `EXE_SRA)   ? `SRA_DECODE   :
            (sel == `EXE_SLLV)  ? `SLLV_DECODE  :
            (sel == `EXE_SRLV)  ? `SRLV_DECODE  :
            (sel == `EXE_SRAV)  ? `SRAV_DECODE  :
            // special 中的移动指令
            (sel == `EXE_MOVN)  ?  `MOVN_DECODE : 
            (sel == `EXE_MOVZ)  ?  `MOVZ_DECODE :
            (sel == `EXE_MFHI)  ?  `MFHI_DECODE :
            (sel == `EXE_MTHI)  ?  `MTHI_DECODE :
            (sel == `EXE_MFLO)  ?  `MFLO_DECODE :
            (sel == `EXE_MTLO)  ?  `MTLO_DECODE : 
            // special 中的算数指令
            (sel == `EXE_ADD)   ?  `ADD_DECODE  : 
            (sel == `EXE_ADDU)  ?  `ADDU_DECODE :
            (sel == `EXE_SUB)   ?  `SUB_DECODE  :
            (sel == `EXE_SUBU)  ?  `SUBU_DECODE :
            (sel == `EXE_SLT)   ?  `SLT_DECODE  :
            (sel == `EXE_SLTU)  ?  `SLTU_DECODE :
            // special 中的sync
            (sel == `EXE_SYNC)  ? `INIT_DECODE  : 
            // special 中的乘法指令，这两条乘法指令会直接将结果写入hilo
            (sel == `EXE_MULT)  ? `MULT_DECODE  :
            (sel == `EXE_MULTU) ? `MULTU_DECODE : `INIT_DECODE
        ) : (op == `EXE_SPECIAL2_INST) ? (
            // special2 中的mul指令
            (sel == `EXE_MUL) ? `MUL_DECODE : `INIT_DECODE
        ) : `INIT_DECODE
    );

    assign reg1_o = (rst == 1'b1) ? `ZeroWord : 
                        (reg1_read == 1'b1) ? harzrd_reg1_data : special_num;
    assign reg2_o = (rst == 1'b1) ? `ZeroWord : 
                        (reg2_read == 1'b1) ? harzrd_reg2_data : special_num;

endmodule