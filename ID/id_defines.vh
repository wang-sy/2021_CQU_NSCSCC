`include "defines.vh"


//    instname          ALU_OP          ALU_SEL                 wreg                        wd      reg1_read   reg2_read   special_num     mt_hi       mt_lo       mf_hi       mf_lo
`define INIT_DECODE {   8'b0,           3'b0,                   1'b0,                       5'b0,   1'b0,       1'b0,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
// logic insts
`define ORI_DECODE {    `EXE_ORI_OP,    `EXE_RES_LOGIC,         1'b1,                       rt,     1'b1,       1'b0,       unsi_imm,       1'b0,       1'b0,       1'b0,       1'b0}
`define ANDI_DECODE{    `EXE_ANDI_OP,   `EXE_RES_LOGIC,         1'b1,                       rt,     1'b1,       1'b0,       unsi_imm,       1'b0,       1'b0,       1'b0,       1'b0}
`define XORI_DECODE{    `EXE_XORI_OP,   `EXE_RES_LOGIC,         1'b1,                       rt,     1'b1,       1'b0,       unsi_imm,       1'b0,       1'b0,       1'b0,       1'b0}
`define LUI_DECODE{     `EXE_LUI_OP,    `EXE_RES_LOGIC,         1'b1,                       rt,     1'b0,       1'b0,       lui_imm,        1'b0,       1'b0,       1'b0,       1'b0}
`define AND_DECODE {    `EXE_AND_OP,    `EXE_RES_LOGIC,         1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define OR_DECODE {     `EXE_OR_OP,     `EXE_RES_LOGIC,         1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define XOR_DECODE {    `EXE_XOR_OP,    `EXE_RES_LOGIC,         1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define NOR_DECODE {    `EXE_NOR_OP,    `EXE_RES_LOGIC,         1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
// shift insts
`define SLL_DECODE{     `EXE_SLL_OP,    `EXE_RES_SHIFT,         1'b1,                       rt,     1'b0,       1'b1,       sa_imm,         1'b0,       1'b0,       1'b0,       1'b0}
`define SRL_DECODE{     `EXE_SRL_OP,    `EXE_RES_SHIFT,         1'b1,                       rt,     1'b0,       1'b1,       sa_imm,         1'b0,       1'b0,       1'b0,       1'b0}
`define SRA_DECODE {    `EXE_SRA_OP,    `EXE_RES_SHIFT,         1'b1,                       rd,     1'b0,       1'b1,       sa_imm,         1'b0,       1'b0,       1'b0,       1'b0}
`define SLLV_DECODE {   `EXE_SLLV_OP,   `EXE_RES_SHIFT,         1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define SRLV_DECODE {   `EXE_SRLV_OP,   `EXE_RES_SHIFT,         1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define SRAV_DECODE {   `EXE_SRAV_OP,   `EXE_RES_SHIFT,         1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
// mov insts
//    instname          ALU_OP          ALU_SEL                 wreg                        wd      reg1_read   reg2_read   special_num     mt_hi       mt_lo       mf_hi       mf_lo
`define MOVN_DECODE{    `EXE_MOVN_OP,   `EXE_RES_MOVE,          (harzrd_reg2_data != 0),    rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define MOVZ_DECODE{    `EXE_MOVZ_OP,   `EXE_RES_MOVE,          (harzrd_reg2_data == 0),    rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define MFHI_DECODE {   `EXE_MFHI_OP,   `EXE_RES_MOVE,          1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b1,       1'b0}
`define MTHI_DECODE {   `EXE_MTHI_OP,   `EXE_RES_MOVE,          1'b0,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b1,       1'b0,       1'b0,       1'b0}
`define MFLO_DECODE {   `EXE_MFLO_OP,   `EXE_RES_MOVE,          1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b1}
`define MTLO_DECODE {   `EXE_MTLO_OP,   `EXE_RES_MOVE,          1'b0,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b1,       1'b0,       1'b0}

//    instname          
`define ADDI_DECODE{    `EXE_ADDI_OP,   `EXE_RES_ARITHMETIC,    1'b1,                       rt,     1'b1,       1'b0,       sign_imm,       1'b0,       1'b0,       1'b0,       1'b0}
`define ADDIU_DECODE{   `EXE_ADDIU_OP,  `EXE_RES_ARITHMETIC,    1'b1,                       rt,     1'b1,       1'b0,       sign_imm,       1'b0,       1'b0,       1'b0,       1'b0}
`define SLTI_DECODE{    `EXE_SLTI_OP,   `EXE_RES_ARITHMETIC,    1'b1,                       rt,     1'b1,       1'b0,       sign_imm,       1'b0,       1'b0,       1'b0,       1'b0}
`define SLTIU_DECODE{   `EXE_SLTIU_OP,  `EXE_RES_ARITHMETIC,    1'b1,                       rt,     1'b1,       1'b0,       sign_imm,       1'b0,       1'b0,       1'b0,       1'b0}
`define ADD_DECODE {    `EXE_ADD_OP,    `EXE_RES_ARITHMETIC,    1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define ADDU_DECODE {   `EXE_ADDU_OP,   `EXE_RES_ARITHMETIC,    1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define SUB_DECODE {    `EXE_SUB_OP,    `EXE_RES_ARITHMETIC,    1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define SUBU_DECODE {   `EXE_SUBU_OP,   `EXE_RES_ARITHMETIC,    1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define SLT_DECODE {    `EXE_SLT_OP,    `EXE_RES_ARITHMETIC,    1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define SLTU_DECODE {   `EXE_SLTU_OP,   `EXE_RES_ARITHMETIC,    1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define MUL_DECODE{     `EXE_MUL_OP,    `EXE_RES_ARITHMETIC,    1'b1,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0}
`define MULT_DECODE{    `EXE_MULT_OP,   `EXE_RES_MUL,           1'b0,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b1,       1'b1,       1'b0,       1'b0}
`define MULTU_DECODE{   `EXE_MULTU_OP,  `EXE_RES_MUL,           1'b0,                       rd,     1'b1,       1'b1,       `ZeroWord,      1'b1,       1'b1,       1'b0,       1'b0}