`include "defines.vh"


//    instname          ALU_OP          ALU_SEL                 wreg                        wd                              reg1_read   reg2_read   special_num     mt_hi       mt_lo       mf_hi       mf_lo       branch_flag     branch_to_addr          rmem_o          wmem_o      mem_io_addr
`define INIT_DECODE {   8'b0,           3'b0,                   1'b0,                       5'b0,                           1'b0,       1'b0,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
// logic insts
`define ORI_DECODE {    `EXE_ORI_OP,    `EXE_RES_LOGIC,         1'b1,                       rt,                             1'b1,       1'b0,       unsi_imm,       1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define ANDI_DECODE{    `EXE_ANDI_OP,   `EXE_RES_LOGIC,         1'b1,                       rt,                             1'b1,       1'b0,       unsi_imm,       1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define XORI_DECODE{    `EXE_XORI_OP,   `EXE_RES_LOGIC,         1'b1,                       rt,                             1'b1,       1'b0,       unsi_imm,       1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define LUI_DECODE{     `EXE_LUI_OP,    `EXE_RES_LOGIC,         1'b1,                       rt,                             1'b0,       1'b0,       lui_imm,        1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define AND_DECODE {    `EXE_AND_OP,    `EXE_RES_LOGIC,         1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define OR_DECODE {     `EXE_OR_OP,     `EXE_RES_LOGIC,         1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define XOR_DECODE {    `EXE_XOR_OP,    `EXE_RES_LOGIC,         1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define NOR_DECODE {    `EXE_NOR_OP,    `EXE_RES_LOGIC,         1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
// shift insts
`define SLL_DECODE{     `EXE_SLL_OP,    `EXE_RES_SHIFT,         1'b1,                       rt,                             1'b0,       1'b1,       sa_imm,         1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define SRL_DECODE{     `EXE_SRL_OP,    `EXE_RES_SHIFT,         1'b1,                       rt,                             1'b0,       1'b1,       sa_imm,         1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define SRA_DECODE {    `EXE_SRA_OP,    `EXE_RES_SHIFT,         1'b1,                       rd,                             1'b0,       1'b1,       sa_imm,         1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define SLLV_DECODE {   `EXE_SLLV_OP,   `EXE_RES_SHIFT,         1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define SRLV_DECODE {   `EXE_SRLV_OP,   `EXE_RES_SHIFT,         1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define SRAV_DECODE {   `EXE_SRAV_OP,   `EXE_RES_SHIFT,         1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
// mov insts
//    instname          ALU_OP          ALU_SEL                 wreg                        wd                              reg1_read   reg2_read   special_num     mt_hi       mt_lo       mf_hi       mf_lo       branch_flag     branch_to_addr          rmem_o          wmem_o
`define MOVN_DECODE{    `EXE_MOVN_OP,   `EXE_RES_MOVE,          (harzrd_reg2_data != 0),    rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define MOVZ_DECODE{    `EXE_MOVZ_OP,   `EXE_RES_MOVE,          (harzrd_reg2_data == 0),    rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define MFHI_DECODE {   `EXE_MFHI_OP,   `EXE_RES_MOVE,          1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b1,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define MTHI_DECODE {   `EXE_MTHI_OP,   `EXE_RES_MOVE,          1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b1,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define MFLO_DECODE {   `EXE_MFLO_OP,   `EXE_RES_MOVE,          1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b1,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define MTLO_DECODE {   `EXE_MTLO_OP,   `EXE_RES_MOVE,          1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b1,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
//    instname          ALU_OP          ALU_SEL                 wreg                        wd                              reg1_read   reg2_read   special_num     mt_hi       mt_lo       mf_hi       mf_lo       branch_flag     branch_to_addr          rmem_o          wmem_o
//    instname          
`define ADDI_DECODE{    `EXE_ADDI_OP,   `EXE_RES_ARITHMETIC,    1'b1,                       rt,                             1'b1,       1'b0,       sign_imm,       1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define ADDIU_DECODE{   `EXE_ADDIU_OP,  `EXE_RES_ARITHMETIC,    1'b1,                       rt,                             1'b1,       1'b0,       sign_imm,       1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define SLTI_DECODE{    `EXE_SLTI_OP,   `EXE_RES_ARITHMETIC,    1'b1,                       rt,                             1'b1,       1'b0,       sign_imm,       1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define SLTIU_DECODE{   `EXE_SLTIU_OP,  `EXE_RES_ARITHMETIC,    1'b1,                       rt,                             1'b1,       1'b0,       sign_imm,       1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define ADD_DECODE {    `EXE_ADD_OP,    `EXE_RES_ARITHMETIC,    1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define ADDU_DECODE {   `EXE_ADDU_OP,   `EXE_RES_ARITHMETIC,    1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define SUB_DECODE {    `EXE_SUB_OP,    `EXE_RES_ARITHMETIC,    1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define SUBU_DECODE {   `EXE_SUBU_OP,   `EXE_RES_ARITHMETIC,    1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define SLT_DECODE {    `EXE_SLT_OP,    `EXE_RES_ARITHMETIC,    1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define SLTU_DECODE {   `EXE_SLTU_OP,   `EXE_RES_ARITHMETIC,    1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define MUL_DECODE{     `EXE_MUL_OP,    `EXE_RES_ARITHMETIC,    1'b1,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define MULT_DECODE{    `EXE_MULT_OP,   `EXE_RES_MUL,           1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b1,       1'b1,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define MULTU_DECODE{   `EXE_MULTU_OP,  `EXE_RES_MUL,           1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b1,       1'b1,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define DIV_DECODE{     `EXE_DIV_OP,    `EXE_RES_DIV,           1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b1,       1'b1,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
`define DIVU_DECODE{    `EXE_DIVU_OP,   `EXE_RES_DIV,           1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b1,       1'b1,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b0,       `ZeroWord}
//    instname          ALU_OP          ALU_SEL                 wreg                        wd                              reg1_read   reg2_read   special_num     mt_hi       mt_lo       mf_hi       mf_lo       branch_flag     branch_to_addr          rmem_o          wmem_o

`define J_DECODE    {   `EXE_J_OP,      `EXE_RES_ARITHMETIC,    1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b1,           j_to_addr,              1'b0,           1'b0,       `ZeroWord}
`define JAL_DECODE  {   `EXE_JAL_OP,    `EXE_RES_ARITHMETIC,    1'b1,                       5'd31,                          1'b1,       1'b0,       pc_puls8,       1'b0,       1'b0,       1'b0,       1'b0,       1'b1,           j_to_addr,              1'b0,           1'b0,       `ZeroWord}
`define JR_DECODE   {   `EXE_JR_OP,     `EXE_RES_ARITHMETIC,    1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b1,           harzrd_reg1_data,       1'b0,           1'b0,       `ZeroWord}
`define JALR_DECODE {   `EXE_JALR_OP,   `EXE_RES_ARITHMETIC,    1'b1,                       (rd == 5'd0 ? 5'd31 : rd) ,     1'b1,       1'b0,       pc_puls8,       1'b0,       1'b0,       1'b0,       1'b0,       1'b1,           harzrd_reg1_data,       1'b0,           1'b0,       `ZeroWord}
`define BEQ_DECODE{     `EXE_BEQ_OP,    `EXE_RES_NOP,           1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       do_branch,      branch_to_addr,         1'b0,           1'b0,       `ZeroWord} 
`define BGTZ_DECODE{    `EXE_BGTZ_OP,   `EXE_RES_NOP,           1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       do_branch,      branch_to_addr,         1'b0,           1'b0,       `ZeroWord} 
`define BLEZ_DECODE{    `EXE_BLEZ_OP,   `EXE_RES_NOP,           1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       do_branch,      branch_to_addr,         1'b0,           1'b0,       `ZeroWord} 
`define BNE_DECODE{     `EXE_BNE_OP,    `EXE_RES_NOP,           1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       do_branch,      branch_to_addr,         1'b0,           1'b0,       `ZeroWord}  
`define BGEZ_DECODE{    `EXE_BGEZ_OP,   `EXE_RES_NOP,           1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       do_branch,      branch_to_addr,         1'b0,           1'b0,       `ZeroWord} 
`define BGEZAL_DECODE{  `EXE_BGEZAL_OP, `EXE_RES_ARITHMETIC,    do_branch,                  5'd31,                          1'b1,       1'b0,       pc_puls8,       1'b0,       1'b0,       1'b0,       1'b0,       do_branch,      branch_to_addr,         1'b0,           1'b0,       `ZeroWord}   
`define BLTZ_DECODE{    `EXE_BLTZ_OP,   `EXE_RES_NOP,           1'b0,                       rd,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       do_branch,      branch_to_addr,         1'b0,           1'b0,       `ZeroWord} 
`define BLTZAL_DECODE{  `EXE_BLTZAL_OP, `EXE_RES_ARITHMETIC,    do_branch,                  5'd31,                          1'b1,       1'b0,       pc_puls8,       1'b0,       1'b0,       1'b0,       1'b0,       do_branch,      branch_to_addr,         1'b0,           1'b0,       `ZeroWord}  
//    instname          ALU_OP          ALU_SEL                 wreg                        wd                              reg1_read   reg2_read   special_num     mt_hi       mt_lo       mf_hi       mf_lo       branch_flag     branch_to_addr          rmem_o          wmem_o

// load store insts
`define LB_DECODE{      `EXE_LB_OP,     `EXE_RES_LOAD_STORE,    1'b1,                       rt,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b1,           1'b0,       mem_io_addr}  
`define LBU_DECODE{     `EXE_LBU_OP,    `EXE_RES_LOAD_STORE,    1'b1,                       rt,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b1,           1'b0,       mem_io_addr} 
`define LH_DECODE{      `EXE_LH_OP,     `EXE_RES_LOAD_STORE,    1'b1,                       rt,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b1,           1'b0,       mem_io_addr}   
`define LHU_DECODE{     `EXE_LHU_OP,    `EXE_RES_LOAD_STORE,    1'b1,                       rt,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b1,           1'b0,       mem_io_addr} 
`define LW_DECODE{      `EXE_LW_OP,     `EXE_RES_LOAD_STORE,    1'b1,                       rt,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b1,           1'b0,       mem_io_addr}  

`define SB_DECODE{      `EXE_SB_OP,     `EXE_RES_LOAD_STORE,    1'b0,                       rt,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b1,       mem_io_addr}   
`define SH_DECODE{      `EXE_SH_OP,     `EXE_RES_LOAD_STORE,    1'b0,                       rt,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b1,       mem_io_addr} 
`define SW_DECODE{      `EXE_SW_OP,     `EXE_RES_LOAD_STORE,    1'b0,                       rt,                             1'b1,       1'b1,       `ZeroWord,      1'b0,       1'b0,       1'b0,       1'b0,       1'b0,           `ZeroWord,              1'b0,           1'b1,       mem_io_addr}  
