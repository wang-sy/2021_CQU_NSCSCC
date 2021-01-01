`include "defines.vh"
`include "id_defines.vh"
//encoding:UTF-8
module ID(
    // //输入
    input logic         clk,
    input logic         rst,

    //从IF/ID接收到信�?
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

    input logic         is_in_delayslot_i,  //qf

    // //输出
    output logic [4:0]  rs_o,
    output logic [4:0]  rt_o,
    output logic        reg1_read_o,
    output logic        reg2_read_o,

    output logic [7:0]  aluop_o,
    output logic [2:0]  alusel_o,
    output logic [31:0] reg1_o,
    output logic [31:0] reg2_o,

    output logic        mt_hi_o,
    output logic        mt_lo_o,
    output logic        mf_hi_o,
    output logic        mf_lo_o,

    output logic        branch_flag_o,
    output logic [31:0] branch_to_addr_o,
    output logic        rmem_o,
    output logic        wmem_o,
    output logic [31:0] mem_io_addr_o,

    output logic        wreg_o, //是否有数据要写寄存器
    output logic [4:0]  wd_o,  //write destination

    output logic [31:0] exception_o, //指明异常类型  //qf
    output logic [31:0] current_instr_addr_o, //指明当前的指令地�?  //qf
    output logic        is_in_delayslot_o,//qf
    output logic        next_is_in_delayslot_o,//qf

    output logic [4:0]  rd_o
);

    assign is_in_delayslot_o = is_in_delayslot_i;//qf
    assign current_instr_addr_o = pc_i;  //qf
    assign next_is_in_delayslot_o = branch_flag_o;
    assign rd_o = rd; 

    logic        except_type_is_syscall; //qf
    logic        except_type_is_eret;//qf
    logic        instr_valid;//qf

    assign exception_o  = { 19'b0, except_type_is_eret, 2'b0, instr_valid, except_type_is_syscall, 8'b0};


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
    // 在判断一些指令的时�?�，还需要用到后六位
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
    // 当前指令为立即数指令，或是需要使用指令中的数字作为操作数的时�?
    // 就使用本资源
    wire [31:0] special_num;

    regfile id_regfile(
        .clk(clk),
        .rst(rst),
        
        .raddr1(rs),// 寄存端口1的读地址
        .raddr2(rt),

        .we(we_i),// 写使�?
        .waddr(waddr_i),// 写寄存器地址
        .wdata(wdata_i), //  写寄存器数据

        .rdata1(reg1_data),
        .rdata2(reg2_data)
    );

    // 对读取出来的结果进行冒险决策
    // harzrd_reg1_data 才是当前寄存器中真正的�??
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

    logic do_branch;
    // 用于判断是否进入branch分支的模�?
    branch_controller id_branch_controller(
        .aluop_i(aluop_o),
        .reg1_i(harzrd_reg1_data),
        .reg2_i(harzrd_reg2_data),
        .do_branch_o(do_branch)
    );

    // 用于J类型的指�?
    wire [31:0] pc_puls8 = pc_i + 32'd8;
    wire [31:0] pc_puls4 = pc_i + 32'd4;
    wire [31:0] j_to_addr = {pc_puls4[31:28], inst_i[25:0] ,2'b0};
    wire [31:0] branch_to_addr = pc_puls4 + {sign_imm[29:0], 2'b0};
    // 用于访存
    wire [31:0] mem_io_addr = harzrd_reg1_data + sign_imm;

    // nop和ssnop不需要特殊实现，直接默认译码即可
    // 当前，将sync和pref当作空指令处�?
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
        mf_lo_o,
        branch_flag_o,
        branch_to_addr_o,
        rmem_o,
        wmem_o,
        mem_io_addr_o,
        except_type_is_syscall,
        except_type_is_eret,
        instr_valid
    } = (rst == 1'b1    )   ? `INIT_DECODE  : (
        (op == `EXE_ORI)    ? `ORI_DECODE   :
        (op == `EXE_ANDI)   ? `ANDI_DECODE  :
        (op == `EXE_XORI)   ? `XORI_DECODE  :
        (op == `EXE_LUI)    ? `LUI_DECODE   :
        (op == `EXE_PREF)   ? `INIT_DECODE  :
        (op == `EXE_ADDI)   ? `ADDI_DECODE  :
        (op == `EXE_ADDIU)  ? `ADDIU_DECODE :
        (op == `EXE_SLTI)   ? `SLTI_DECODE  :
        (op == `EXE_SLTIU)  ? `SLTIU_DECODE :
        (op == `EXE_J)      ? `J_DECODE     :
        (op == `EXE_JAL)    ? `JAL_DECODE   :
        (op == `EXE_BEQ)    ? `BEQ_DECODE   :
        (op == `EXE_BGTZ)   ? `BGTZ_DECODE  :
        (op == `EXE_BLEZ)   ? `BLEZ_DECODE  :
        (op == `EXE_BNE)    ? `BNE_DECODE   :
        (op == `EXE_LB)     ? `LB_DECODE    :
        (op == `EXE_LBU)    ? `LBU_DECODE   :
        (op == `EXE_LH)     ? `LH_DECODE    :
        (op == `EXE_LHU)    ? `LHU_DECODE   :
        (op == `EXE_LW)     ? `LW_DECODE    :
        (op == `EXE_SB)     ? `SB_DECODE    :
        (op == `EXE_SH)     ? `SH_DECODE    :
        (op == `EXE_SW)     ? `SW_DECODE    :
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
            (sel == `EXE_MULTU) ? `MULTU_DECODE : 
            // special 中的除法指令
            (sel == `EXE_DIV)   ? `DIV_DECODE   :
            (sel == `EXE_DIVU)  ? `DIVU_DECODE  : 
            // special 直接跳转指令
            (sel == `EXE_JR)    ? `JR_DECODE    :
            (sel == `EXE_JALR)  ? `JALR_DECODE  :

            //寄存器相互比较多trap指令
            (sel == `EXE_TEQ)     ?   `TEQ_DECODE     :
            (sel == `EXE_TGE)     ?   `TGE_DECODE     :
            // (sel == `EXE_TGEU)    ?   `RGEU_DECODE    :
            (sel == `EXE_TLT)     ?   `TLT_DECODE     :
            (sel == `EXE_TLTU)    ?   `TLTU_DECODE    :
            (sel == `EXE_TNE)     ?   `TNE_DECODE     :
            //系统调用指令
            (sel == `EXE_SYSCALL) ?   `SYSCALL_DECODE : `INIT_DECODE

        ) : (op == `EXE_SPECIAL2_INST) ? (
            // special2 中的mul指令
            (sel == `EXE_MUL) ? `MUL_DECODE : `INIT_DECODE
        ) : (op == `EXE_REGIMM_INST) ? (
            // 对branch指令的具体类型进行�?�择，需要判断rt
            (rt == `EXE_BGEZ    ) ? `BGEZ_DECODE    : 
            (rt == `EXE_BGEZAL  ) ? `BGEZAL_DECODE  : 
            (rt == `EXE_BLTZ    ) ? `BLTZ_DECODE    : 
            (rt == `EXE_BLTZAL  ) ? `BLTZAL_DECODE  :
            // 和立即数比较多trap指令
            (rt == `EXE_TEQI    ) ? `TEQI_DECODE    :
            (rt == `EXE_TGEI    ) ? `TGEI_DECODE    :
            (rt == `EXE_TGEIU   ) ? `TGEIU_DECODE   :
            (rt == `EXE_TLTI    ) ? `TLTI_DECODE    :
            (rt == `EXE_TLTIU   ) ? `TLTIU_DECODE   :
            (rt == `EXE_TNEI    ) ? `TNEI_DECODE    : `INIT_DECODE
        ) : inst_i==`EXE_ERET ? `ERET_DECODE : 
            //MFCO MFT0
            (inst_i[31:21]==11'b01000000000 && inst_i[10:0]==11'b0000000000) ? `MFC0_DECODE : 
            (inst_i[31:21]==11'b01000000100 && inst_i[10:0]==11'b0000000000) ? `MFT0_DECODE : `INIT_DECODE//qf
    );

    assign {rs_o, rt_o, reg1_read_o, reg2_read_o} = {rs, rt, reg1_read, reg2_read};

    assign reg1_o = (rst == 1'b1) ? `ZeroWord : 
                        (reg1_read == 1'b1) ? harzrd_reg1_data : special_num;
    assign reg2_o = (rst == 1'b1) ? `ZeroWord : 
                        (reg2_read == 1'b1) ? harzrd_reg2_data : special_num;

endmodule