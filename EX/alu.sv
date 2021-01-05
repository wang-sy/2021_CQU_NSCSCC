`include "defines.vh"
module alu (
    input                       clk_i,
    input logic                 rst_i,
    input logic [`AluOpBus]     aluop_i,
    input logic [`AluSelBus]    alusel_i,
    input logic [`DataBus]      reg1_i,
    input logic [`DataBus]      reg2_i,
    input logic [`DataBus]      hi_i,
    input logic [`DataBus]      lo_i,

    input logic [`DataBus]      exception_type_i,//qf
    input logic [`DataBus]      cp0_reg_data_i,  //qf

    input logic                 mem_cp0_reg_we,//qf
    input logic [4:0]           mem_cp0_reg_write_addr,//qf
    input logic [`DataBus]      mem_cp0_reg_data,//qf

    input logic                 wb_cp0_reg_we,//qf
    input logic [4:0]           wb_cp0_reg_write_addr,//qf
    input logic [`DataBus]      wb_cp0_reg_data,//qf
    input       [4:0]           rd, //qf


    output logic                ok_o,
    output logic [`DoubleRegBus]wdata_o,

    output logic [`DataBus]     exception_type_o,//qf

    //要写入CP0的地址、数据
    output logic                cp0_reg_we_o,//qf
    output logic [4:0]          cp0_reg_write_addr_o,//qf
    output logic [`DataBus]     cp0_reg_data_o//qf


);

logic trap_exception;  //自陷异常
logic overflow_exception; //溢出异常

logic div_ready;
logic [63:0]div_res;

assign exception_type_o={exception_type_i[31:12],overflow_exception,trap_exception,exception_type_i[9:8],8'b0};

//                              条件                            结果
    wire [31:0]logic_res = ( aluop_i == `EXE_ORI_OP  || aluop_i == `EXE_OR_OP )   ? (reg1_i | reg2_i   )  :
                           ( aluop_i == `EXE_ANDI_OP || aluop_i == `EXE_AND_OP)   ? (reg1_i & reg2_i   )  :
                           ( aluop_i == `EXE_XORI_OP || aluop_i == `EXE_XOR_OP)   ? (reg1_i ^ reg2_i   )  :
                           ( aluop_i == `EXE_LUI_OP ) ? (reg2_i            )  :
                           ( aluop_i == `EXE_NOR_OP ) ? (~(reg1_i | reg2_i))  : `ZeroWord;
 
    wire [31:0]shift_res =  ( aluop_i == `EXE_SLL_OP || aluop_i == `EXE_SLLV_OP)  ? ( reg2_i << reg1_i[4:0] )  : 
                            ( aluop_i == `EXE_SRL_OP || aluop_i == `EXE_SRLV_OP)  ? ( reg2_i >> reg1_i[4:0] )  : 
                            ( aluop_i == `EXE_SRA_OP || aluop_i == `EXE_SRAV_OP)  ? ( ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0] )  : `ZeroWord;
    
    wire [31:0] cp0_reg_data_hazard = (mem_cp0_reg_we == 1'b1 && mem_cp0_reg_write_addr == rd) ? mem_cp0_reg_data :
                                      (wb_cp0_reg_we == 1'b1 && wb_cp0_reg_write_addr == rd) ? wb_cp0_reg_data : cp0_reg_data_i;

    wire [31:0]move_res =   ( aluop_i == `EXE_MOVN_OP || aluop_i == `EXE_MOVZ_OP || aluop_i == `EXE_MTHI_OP || aluop_i == `EXE_MTLO_OP) ? reg1_i : 
                            ( aluop_i == `EXE_MFHI_OP ) ? hi_i :
                            ( aluop_i == `EXE_MFLO_OP ) ? lo_i : 
                            ( aluop_i == `EXE_MFC0_OP ) ? cp0_reg_data_hazard : `ZeroWord;

    assign {cp0_reg_we_o, cp0_reg_write_addr_o, cp0_reg_data_o} = (aluop_i == `EXE_MTC0_OP) ? {1'b1, rd, reg2_i} : {1'b0,5'b0,32'b0};
    
    wire [31:0]arithmetic_res;
    wire overflow_byte;
    assign {overflow_byte, arithmetic_res} =    ( aluop_i ==  `EXE_ADD_OP   || aluop_i ==  `EXE_ADDI_OP     ) ? ({reg1_i[31], reg1_i} + {reg2_i[31], reg2_i}) :
                                                ( aluop_i ==  `EXE_ADDU_OP  || aluop_i ==  `EXE_ADDIU_OP    ) ? ({1'b0, reg1_i} + {1'b0, reg2_i}) :
                                                ( aluop_i ==  `EXE_SUB_OP   ) ? ({reg1_i[31], reg1_i} - {reg2_i[31], reg2_i}) :
                                                ( aluop_i ==  `EXE_SUBU_OP  ) ? ({1'b0, reg1_i} - {1'b0, reg2_i}) :
                                                ( aluop_i ==  `EXE_SLT_OP   || aluop_i ==  `EXE_SLTI_OP     ) ? ($signed(reg1_i) < $signed(reg2_i)) :
                                                ( aluop_i ==  `EXE_SLTU_OP  || aluop_i ==  `EXE_SLTIU_OP    ) ? (({1'b0, reg1_i} < {1'b0, reg2_i})) : 
                                                ( aluop_i ==  `EXE_MUL_OP   ) ? (reg1_i * reg2_i) : 
                                                ( aluop_i ==  `EXE_JAL_OP   || aluop_i ==  `EXE_JALR_OP     ) ? ({1'b0, reg2_i}) : 
                                                ( aluop_i ==  `EXE_BGEZAL_OP|| aluop_i ==  `EXE_BLTZAL_OP   ) ? ({1'b0, reg2_i}) : ({1'b0, `ZeroWord});

    wire overflow = (aluop_i == `EXE_ADD_OP || aluop_i == `EXE_ADDI_OP || aluop_i ==  `EXE_SUB_OP) & (overflow_byte ^ arithmetic_res[31]);
    
    //算术溢出
    assign overflow_exception = overflow;

    //////////////////////////////////////此处使用的leisilei的判断方法，将改为更加简单快速的判断///////////////////
    logic  reg1_lt_reg2;
	assign reg1_lt_reg2 =  ((aluop_i == `EXE_SLT_OP)     || (aluop_i == `EXE_TLT_OP) ||         /////
	                              (aluop_i == `EXE_TLTI_OP)    || (aluop_i == `EXE_TGE_OP) ||         /////
	                              (aluop_i == `EXE_TGEI_OP))   ?                                      /////
						          ((reg1_i[31] && !reg2_i[31]) ||                                     /////
							      (!reg1_i[31] && !reg2_i[31]  && arithmetic_res[31])          ||         /////
			                      (reg1_i[31] && reg2_i[31]    && arithmetic_res[31]))                    /////
			                     :(reg1_i < reg2_i);                                                 /////
//////////////////////////////////////此处将改为更加简单快速的判断///////////////////////////////////////////

    // Trap指令运算
    assign trap_exception = rst_i   ==   1'b1 ? 1'b0 : 
                            ((aluop_i==`EXE_TEQ_OP||aluop_i==`EXE_TEQI_OP)&&(reg1_i == reg2_i)) ? 1'b1 : 
                            ((aluop_i==`EXE_TGE_OP||aluop_i==`EXE_TGEI_OP||aluop_i==`EXE_TGEIU_OP||aluop_i==`EXE_TGEU_OP)&&reg1_lt_reg2==1'b0) ? 1'b1:
                            ((aluop_i==`EXE_TLT_OP||aluop_i==`EXE_TLTI_OP||aluop_i==`EXE_TLTIU_OP||aluop_i==`EXE_TLTU_OP)&&reg1_lt_reg2==1'b1) ? 1'b1:
                            ((aluop_i==`EXE_TNE_OP||aluop_i==`EXE_TNEI_OP)&&reg1_i != reg2_i) ? 1'b1 : 1'b0;


    // 这一部分是临时存在的，为了应付带符号乘法的测试
    // 在后期会将其替换为多周期乘法器以提升频率
    wire [31:0] unsign_reg1 = (reg1_i[31] == 1'b1) ? ~(reg1_i - 1) : reg1_i;
    wire [31:0] unsign_reg2 = (reg2_i[31] == 1'b1) ? ~(reg2_i - 1) : reg2_i;
    wire [1:0] not_positive = {reg1_i[31] == 1'b1, reg2_i[31] == 1'b1};

    wire [63:0]mul_res =    (aluop_i == `EXE_MULT_OP)   ?  (
                                (not_positive == 2'b11 || not_positive == 2'b00) ? (unsign_reg1 * unsign_reg2) : 
                                ( (~(unsign_reg1 * unsign_reg2)) + 1)
                            )  :
                            (aluop_i == `EXE_MULTU_OP)  ?  ({1'b0, reg1_i} * {1'b0, reg2_i})    : ({`ZeroWord, `ZeroWord});

    
    wire  div_ena = (rst_i == 1'b1) ? 1'b0 :
                    (aluop_i == `EXE_DIV_OP || aluop_i == `EXE_DIVU_OP) ? (
                        (div_ready == 1'b0) ? 1'b1 : 1'b0
                    ) : 1'b0;

    wire div_signed = (aluop_i == `EXE_DIV_OP) ? 1'b1 : 1'b0;

    // 除法器，直接使用了雷斯磊书中的
    // 除法需要多周期，在进行除法的过程中需要将其他的流水级进行stall
    div ex_alu_div(
        .clk(clk_i),
        .rst(rst_i),
        .signed_div_i(div_signed),
        .opdata1_i(reg1_i),
        .opdata2_i(reg2_i),
        .start_i(div_ena),
        .annul_i(1'b0), // 除法取消
        .result_o(div_res),
        .ready_o(div_ready)
    );

    wire [31:0] load_store_res =(aluop_i == `EXE_LB_OP) ? reg1_i + reg2_i   :
                                (aluop_i == `EXE_LBU_OP)? reg1_i + reg2_i   :
                                (aluop_i == `EXE_LH_OP) ? reg1_i + reg2_i   :
                                (aluop_i == `EXE_LHU_OP)? reg1_i + reg2_i   :
                                (aluop_i == `EXE_LW_OP) ? reg1_i + reg2_i   :
                                (aluop_i == `EXE_SB_OP) ? reg2_i            :
                                (aluop_i == `EXE_SH_OP) ? reg2_i            :
                                (aluop_i == `EXE_SW_OP) ? reg2_i            : `ZeroWord;
    
    assign ok_o =   (rst_i == 1'b1) ? 1'b1 : 
                    (div_ena == 1'b1 && div_ready == 1'b0) ? 1'b0 : 1'b1;


    assign wdata_o =    (rst_i == 1'b1) ? {`ZeroWord, `ZeroWord} : 
                        (alusel_i == `EXE_RES_LOGIC) ? {logic_res, logic_res} : 
                        (alusel_i == `EXE_RES_SHIFT) ? {shift_res, shift_res} :
                        (alusel_i == `EXE_RES_MOVE ) ? {move_res, move_res}  :
                        (alusel_i == `EXE_RES_LOAD_STORE) ? {load_store_res, load_store_res} : 
                        (alusel_i == `EXE_RES_ARITHMETIC) ? (
                            (overflow == 1'b0) ? {arithmetic_res, arithmetic_res} : {`ZeroWord, `ZeroWord}
                        ) : (alusel_i == `EXE_RES_MUL) ? mul_res :
                        (alusel_i == `EXE_RES_DIV) ? (
                            (div_ready == 1'b1) ? div_res : {`ZeroWord, `ZeroWord}
                        ) : {`ZeroWord, `ZeroWord};

endmodule