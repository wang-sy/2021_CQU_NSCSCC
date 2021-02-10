`include "defines.vh"


`define JR_DECODE       {11'b0_0_0_0_0_0_0_0_1_0_0, `ZERO_CONTROL,  3'b000}
`define JALR_DECODE     {11'b1_1_0_0_0_0_0_0_0_0_1, `ZERO_CONTROL,  3'b000}

`define MFHI_DECODE     {11'b1_1_0_0_0_0_0_0_0_0_0, `MFHI_CONTROL,  3'b000}
`define MFLO_DECODE     {11'b1_1_0_0_0_0_0_0_0_0_0, `MFLO_CONTROL,  3'b000}
`define MTHI_DECODE     {11'b0_0_0_0_0_0_0_0_0_0_0, `MTHI_CONTROL,  3'b010}
`define MTLO_DECODE     {11'b0_0_0_0_0_0_0_0_0_0_0, `MTLO_CONTROL,  3'b001}

`define MULTU_DECODE    {11'b0_0_0_0_0_0_0_0_0_0_0, `MULTU_CONTROL, 3'b011}
`define MULT_DECODE     {11'b0_0_0_0_0_0_0_0_0_0_0, `MULT_CONTROL,  3'b011}
`define DIVU_DECODE     {11'b0_0_0_0_0_0_0_0_0_0_0, `DIVU_CONTROL,  3'b011}
`define DIV_DECODE      {11'b0_0_0_0_0_0_0_0_0_0_0, `DIV_CONTROL,   3'b011}

`define AND_DECODE      {11'b1_1_0_0_0_0_0_0_0_0_0, `AND_CONTROL,   3'b000}
`define OR_DECODE       {11'b1_1_0_0_0_0_0_0_0_0_0, `OR_CONTROL,    3'b000}
`define XOR_DECODE      {11'b1_1_0_0_0_0_0_0_0_0_0, `XOR_CONTROL,   3'b000}
`define NOR_DECODE      {11'b1_1_0_0_0_0_0_0_0_0_0, `NOR_CONTROL,   3'b000}
`define ADD_DECODE      {11'b1_1_0_0_0_0_0_0_0_0_0, `ADD_CONTROL,   3'b000}
`define ADDU_DECODE     {11'b1_1_0_0_0_0_0_0_0_0_0, `ADDU_CONTROL,  3'b000}
`define SUB_DECODE      {11'b1_1_0_0_0_0_0_0_0_0_0, `SUB_CONTROL,   3'b000}
`define SUBU_DECODE     {11'b1_1_0_0_0_0_0_0_0_0_0, `SUBU_CONTROL,  3'b000}
`define SLT_DECODE      {11'b1_1_0_0_0_0_0_0_0_0_0, `SLT_CONTROL,   3'b000}
`define SLTU_DECODE     {11'b1_1_0_0_0_0_0_0_0_0_0, `SLTU_CONTROL,  3'b000}
`define SLL_DECODE      {11'b1_1_0_0_0_0_0_0_0_0_0, `SLL_CONTROL,   3'b000}
`define SRL_DECODE      {11'b1_1_0_0_0_0_0_0_0_0_0, `SRL_CONTROL,   3'b000}
`define SRA_DECODE      {11'b1_1_0_0_0_0_0_0_0_0_0, `SRA_CONTROL,   3'b000}
`define SLLV_DECODE     {11'b1_1_0_0_0_0_0_0_0_0_0, `SLLV_CONTROL,  3'b000}
`define SRLV_DECODE     {11'b1_1_0_0_0_0_0_0_0_0_0, `SRLV_CONTROL,  3'b000}
`define SRAV_DECODE     {11'b1_1_0_0_0_0_0_0_0_0_0, `SRAV_CONTROL,  3'b000}

`define BREAK_DECODE    {11'b0_0_0_0_0_0_0_0_0_0_0, `ZERO_CONTROL,  3'b000}
`define SYSCALL_DECODE  {11'b0_0_0_0_0_0_0_0_0_0_0, `ZERO_CONTROL,  3'b000}

`define J_DECODE        {11'b0_0_0_0_0_0_1_0_0_0_0, `ZERO_CONTROL,  3'b000 }
`define JAL_DECODE      {11'b1_0_0_0_0_0_0_1_0_0_0, `ZERO_CONTROL,  3'b000 }

`define BEQ_DECODE      {11'b0_0_0_1_0_0_0_0_0_0_0, `ZERO_CONTROL,  3'b000}
`define BNE_DECODE      {11'b0_0_0_1_0_0_0_0_0_0_0, `ZERO_CONTROL,  3'b000}
`define BGTZ_DECODE     {11'b0_0_0_1_0_0_0_0_0_0_0, `ZERO_CONTROL,  3'b000 }
`define BLEZ_DECODE     {11'b0_0_0_1_0_0_0_0_0_0_0, `ZERO_CONTROL,  3'b000}

`define BLTZ_DECODE     {11'b0_0_0_1_0_0_0_0_0_0_0, `ZERO_CONTROL,  3'b000 }
`define BLTZAL_DECODE   {11'b1_0_0_1_0_0_0_0_0_1_0, `ZERO_CONTROL,  3'b000}
`define BGEZ_DECODE     {11'b0_0_0_1_0_0_0_0_0_0_0, `ZERO_CONTROL,  3'b000 }
`define BGEZAL_DECODE   {11'b1_0_0_1_0_0_0_0_0_1_0, `ZERO_CONTROL,  3'b000 }

`define ANDI_DECODE     {11'b1_0_1_0_0_0_0_0_0_0_0, `AND_CONTROL,   3'b000 }
`define XORI_DECODE     {11'b1_0_1_0_0_0_0_0_0_0_0, `XOR_CONTROL,   3'b000}
`define LUI_DECODE      {11'b1_0_1_0_0_0_0_0_0_0_0, `LUI_CONTROL,   3'b000 }
`define ORI_DECODE      {11'b1_0_1_0_0_0_0_0_0_0_0, `OR_CONTROL,    3'b000 }
`define ADDI_DECODE     {11'b1_0_1_0_0_0_0_0_0_0_0, `ADD_CONTROL,   3'b000 }
`define ADDIU_DECODE    {11'b1_0_1_0_0_0_0_0_0_0_0, `ADD_CONTROL,   3'b000}
`define SLTI_DECODE     {11'b1_0_1_0_0_0_0_0_0_0_0, `SLT_CONTROL,   3'b000}
`define SLTIU_DECODE    {11'b1_0_1_0_0_0_0_0_0_0_0, `SLTU_CONTROL,  3'b000}

`define LW_DECODE       {11'b1_0_1_0_0_1_0_0_0_0_0, `ADD_CONTROL,   3'b100}
`define SW_DECODE       {11'b0_0_1_0_1_0_0_0_0_0_0, `ADD_CONTROL,   3'b100}
`define LB_DECODE       {11'b1_0_1_0_0_1_0_0_0_0_0, `ADD_CONTROL,   3'b100}
`define LBU_DECODE      {11'b1_0_1_0_0_1_0_0_0_0_0, `ADD_CONTROL,   3'b100}
`define LH_DECODE       {11'b1_0_1_0_0_1_0_0_0_0_0, `ADD_CONTROL,   3'b100}
`define LHU_DECODE      {11'b1_0_1_0_0_1_0_0_0_0_0, `ADD_CONTROL,   3'b100 }
`define SH_DECODE       {11'b0_0_1_0_1_0_0_0_0_0_0, `ADD_CONTROL,   3'b100}
`define SB_DECODE       {11'b0_0_1_0_1_0_0_0_0_0_0, `ADD_CONTROL,   3'b100}

`define MTC0_DECODE     {11'b0_0_0_0_0_0_0_0_0_0_0, `MTC0_CONTROL,  3'b000 }
`define MFC0_DECODE     {11'b1_0_0_0_0_0_0_0_0_0_0, `MFC0_CONTROL,  3'b000}
`define ERET_DECODE     {11'b1_0_0_0_0_0_0_0_0_0_0, `ZERO_CONTROL,  3'b000}