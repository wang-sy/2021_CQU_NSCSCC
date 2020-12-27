`include "defines.vh"


//    instname          ALU_OP          ALU_SEL                 wreg    wd      reg1_read   reg2_read   special_num
`define INIT_DECODE {   8'b0,           3'b0,                   1'b0,   5'b0,   1'b0,       1'b0,       `ZeroWord}
// logic insts
`define ORI_DECODE {    `EXE_ORI_OP,    `EXE_RES_LOGIC,         1'b1,   rt,     1'b1,       1'b0,       unsi_imm}
`define ANDI_DECODE{    `EXE_ANDI_OP,   `EXE_RES_LOGIC,         1'b1,   rt,     1'b1,       1'b0,       unsi_imm}
`define XORI_DECODE{    `EXE_XORI_OP,   `EXE_RES_LOGIC,         1'b1,   rt,     1'b1,       1'b0,       unsi_imm}
`define LUI_DECODE{     `EXE_LUI_OP,    `EXE_RES_LOGIC,         1'b1,   rt,     1'b0,       1'b0,       lui_imm}
`define AND_DECODE {    `EXE_AND_OP,    `EXE_RES_LOGIC,         1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}
`define OR_DECODE {     `EXE_OR_OP,     `EXE_RES_LOGIC,         1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}
`define XOR_DECODE {    `EXE_XOR_OP,    `EXE_RES_LOGIC,         1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}
`define NOR_DECODE {    `EXE_NOR_OP,    `EXE_RES_LOGIC,         1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}
// shift insts
`define SLL_DECODE{     `EXE_SLL_OP,    `EXE_RES_SHIFT,         1'b1,   rt,     1'b0,       1'b1,       sa_imm}
`define SRL_DECODE{     `EXE_SRL_OP,    `EXE_RES_SHIFT,         1'b1,   rt,     1'b0,       1'b1,       sa_imm}
`define SRA_DECODE {    `EXE_SRA_OP,    `EXE_RES_SHIFT,         1'b1,   rd,     1'b0,       1'b1,       sa_imm}
`define SLLV_DECODE {   `EXE_SLLV_OP,   `EXE_RES_SHIFT,         1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}
`define SRLV_DECODE {   `EXE_SRLV_OP,   `EXE_RES_SHIFT,         1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}
`define SRAV_DECODE {   `EXE_SRAV_OP,   `EXE_RES_SHIFT,         1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}


`define ADD_DECODE {    `EXE_ADD_OP,    `EXE_RES_ARITHMETIC,    1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}
`define ADDU_DECODE {   `EXE_ADDU_OP,   `EXE_RES_ARITHMETIC,    1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}
`define SUB_DECODE {    `EXE_SUB_OP,    `EXE_RES_ARITHMETIC,    1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}
`define SUBU_DECODE {   `EXE_SUBU_OP,   `EXE_RES_ARITHMETIC,    1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}
`define SLT_DECODE {    `EXE_SLT_OP,    `EXE_RES_ARITHMETIC,    1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}
`define SLTU_DECODE {   `EXE_SLTU_OP,   `EXE_RES_ARITHMETIC,    1'b1,   rd,     1'b1,       1'b1,       `ZeroWord}