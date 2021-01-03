`include "tlbdefines.vh"
module TLB(
	input  logic        clk,

	input  logic [2:0]  tlb_typeM, 	   	

	input  logic [31:0] inst_vaddr,
	input  logic [31:0] data_vaddr,

	input  logic [31:0] EntryHi_in,
	input  logic [31:0] PageMask_in,
	input  logic [31:0] EntryLo0_in,
	input  logic [31:0] EntryLo1_in,
	input  logic [31:0] Index_in,
	input  logic [31:0] Random_in,

	output logic [31:0] EntryHi_out,
	output logic [31:0] PageMask_out,
	output logic [31:0] EntryLo0_out,
	output logic [31:0] EntryLo1_out,
	output logic [31:0] Index_out,

    output logic        inst_V_flag,//inst_addr_valid
    output logic        data_V_flag,//data_addr_valid
	output logic        data_D_flag,

	output logic [31:0] inst_paddr_o,
	output logic [31:0] data_paddr_o,
	output logic        inst_found,
	output logic        data_found
);

//TLB instr
logic TLBP,TLBR,TLBWI,TLBWR;

assign TLBP = (tlb_typeM ==  `TLBP);
assign TLBR = (tlb_typeM ==  `TLBR);
assign TLBWI = (tlb_typeM == `TLBWI);
assign TLBWR = (tlb_typeM == `TLBWR);

//TLB regs
logic [31:0] PageMask [`TLB_LINE-1:0];//[31:29]:0,[28:13]:Mask,[12:0]:0
logic [31:0] EntryHi0 [`TLB_LINE-1:0];//[31:13]VPN2，虚拟地址的高位,[12:8]:0,[7:0]:ASID
logic [31:0] EntryLo0 [`TLB_LINE-1:0];//[31]:0,[30]:NE,[29:6]:PFN物理地址高位,[5:3]:Cache一致性,[2]:Dirty/Writeable,[1]:Valid,[0]Global
logic [31:0] EntryLo1 [`TLB_LINE-1:0];//[31]:0,[30]:NE,[29:6]:PFN物理地址高位,[5:3]:Cache一致性,[2]:Dirty/Writeable,[1]:Valid,[0]Global

//TLB Write
logic [`TLB_WIDTH-1:0] TLB_WritePos;
logic TLB_Write_en;
assign TLB_Write_en = (TLBWI | TLBWR) & (~Index_in[5]);//阅读了龙芯给的开源代码，由于index给了六位，但超出的部分是不写入的。
assign TLB_WritePos = TLBWR ? Random_in[`TLB_WIDTH-1:0] : Index_in[`TLB_WIDTH-1:0];

always @(posedge clk) begin
    if (TLB_Write_en) begin
        PageMask[TLB_WritePos] <= PageMask_in;
        EntryHi0[TLB_WritePos] <= EntryHi_in;
        EntryLo0[TLB_WritePos] <= EntryLo0_in;
        EntryLo1[TLB_WritePos] <= EntryLo1_in;
    end
end

//TLB Match
//-- Direct Sign
logic inst_direct,data_direct;
assign inst_direct = (inst_vaddr[31:30] == 2'b10);
assign data_direct = (data_vaddr[31:30] == 2'b10);
//-- ASID
logic [`ASID] current_ASID;
assign current_ASID = EntryHi_in[`ASID];
//-- TLB hit
//针对多匹配情况，根据龙芯LS232处理器核用户手册-V1.0 P14, 3.1.5描述，软件要控制不要让多项命中的情况发生，因此这里不做处理
//匹配采用===，这样在TLB没有初始化的情况下依然可以正常输出信号
//---- inst
logic inst_hit [`TLB_LINE-1:0];
logic inst_hit_exist;
logic [`TLB_WIDTH-1:0] inst_hit_idx;
genvar i;
generate
    for(i=0;i<`TLB_LINE;i++)
    begin
        assign inst_hit[i] = 
            (//match
                (EntryHi0[i][`ASID] === current_ASID)       | 
                (  inst_vaddr[12]  & EntryLo1[i][`GLOBAL])  | 
                ((~inst_vaddr[12]) & EntryLo0[i][`GLOBAL])
            )
            &
            (
                ((~PageMask[i][31:13]) & EntryHi0[i][31:13]) ===
                ((~PageMask[i][31:13]) & inst_vaddr [31:13])
            )
            ;
    end
endgenerate
assign inst_hit_exist = 
    inst_hit[ 0] | inst_hit[ 1] | inst_hit[ 2] | inst_hit[ 3] |
    inst_hit[ 4] | inst_hit[ 5] | inst_hit[ 6] | inst_hit[ 7] |
    inst_hit[ 8] | inst_hit[ 9] | inst_hit[10] | inst_hit[11] |
    inst_hit[12] | inst_hit[13] | inst_hit[14] | inst_hit[15] |
    inst_hit[16] | inst_hit[17] | inst_hit[18] | inst_hit[19] |
    inst_hit[20] | inst_hit[21] | inst_hit[22] | inst_hit[23] |
    inst_hit[24] | inst_hit[25] | inst_hit[26] | inst_hit[27] |
    inst_hit[28] | inst_hit[29] | inst_hit[30] | inst_hit[31];

assign inst_hit_idx = 
    (inst_hit[ 0] ?  0 : 0) | (inst_hit[ 1] ?  1 : 0) | (inst_hit[ 2] ?  2 : 0) | (inst_hit[ 3] ?  3 : 0) |
    (inst_hit[ 4] ?  4 : 0) | (inst_hit[ 5] ?  5 : 0) | (inst_hit[ 6] ?  6 : 0) | (inst_hit[ 7] ?  7 : 0) |
    (inst_hit[ 8] ?  8 : 0) | (inst_hit[ 9] ?  9 : 0) | (inst_hit[10] ? 10 : 0) | (inst_hit[11] ? 11 : 0) |
    (inst_hit[12] ? 12 : 0) | (inst_hit[13] ? 13 : 0) | (inst_hit[14] ? 14 : 0) | (inst_hit[15] ? 15 : 0) |
    (inst_hit[16] ? 16 : 0) | (inst_hit[17] ? 17 : 0) | (inst_hit[18] ? 18 : 0) | (inst_hit[19] ? 19 : 0) |
    (inst_hit[20] ? 20 : 0) | (inst_hit[21] ? 21 : 0) | (inst_hit[22] ? 22 : 0) | (inst_hit[23] ? 23 : 0) |
    (inst_hit[24] ? 24 : 0) | (inst_hit[25] ? 25 : 0) | (inst_hit[26] ? 26 : 0) | (inst_hit[27] ? 27 : 0) |
    (inst_hit[28] ? 28 : 0) | (inst_hit[29] ? 29 : 0) | (inst_hit[30] ? 30 : 0) | (inst_hit[31] ? 31 : 0);

//主要注意的是，由于MIPS Release 1采用了奇偶页面的设计，手册上的表格页大小指的是两个页面之一的大小。但匹配的时候相当于将那个大小*2之后进行匹配

//最终的地址逻辑是按照uCore代码写的，先把uCore跑通再说吧
assign inst_paddr_o = {
    inst_direct ? 
    (
        {3'b000,inst_vaddr[28:12]}
    )
    :
    (
        (
            (inst_vaddr[12] ? EntryLo1[inst_hit_idx][25:6] : EntryLo0[inst_hit_idx][25:6])
            &
            {1'b1,~PageMask[inst_hit_idx][31:13]}
        )
        |
        (
            inst_vaddr[31:12]
            &
            {1'b0,PageMask[inst_hit_idx][31:13]}
        )
    )
    ,
    inst_vaddr[11:0]
};

assign inst_V_flag = 
    inst_direct |
    (inst_hit_exist & (inst_vaddr[12] ? EntryLo1[inst_hit_idx][`VALID] : EntryLo0[inst_hit_idx][`VALID]) );

//---- data
logic data_hit [`TLB_LINE-1:0];
logic data_hit_exist;
logic [`TLB_WIDTH-1:0] data_hit_idx;
genvar j;
generate
    for(j=0;j<`TLB_LINE;j++)
    begin
        assign data_hit[j] = 
            (//match
                (EntryHi0[j][`ASID] === current_ASID)       | 
                (  data_vaddr[12]  & EntryLo1[j][`GLOBAL])  | 
                ((~data_vaddr[12]) & EntryLo0[j][`GLOBAL])
            )
            &
            (
                ((~PageMask[j][31:13]) & EntryHi0[j][31:13]) ===
                ((~PageMask[j][31:13]) & data_vaddr [31:13])
            )
            ;
    end
endgenerate
assign data_hit_exist = 
    data_hit[ 0] | data_hit[ 1] | data_hit[ 2] | data_hit[ 3] |
    data_hit[ 4] | data_hit[ 5] | data_hit[ 6] | data_hit[ 7] |
    data_hit[ 8] | data_hit[ 9] | data_hit[10] | data_hit[11] |
    data_hit[12] | data_hit[13] | data_hit[14] | data_hit[15] |
    data_hit[16] | data_hit[17] | data_hit[18] | data_hit[19] |
    data_hit[20] | data_hit[21] | data_hit[22] | data_hit[23] |
    data_hit[24] | data_hit[25] | data_hit[26] | data_hit[27] |
    data_hit[28] | data_hit[29] | data_hit[30] | data_hit[31];

assign data_hit_idx = 
    (data_hit[ 0] ?  0 : 0) | (data_hit[ 1] ?  1 : 0) | (data_hit[ 2] ?  2 : 0) | (data_hit[ 3] ?  3 : 0) |
    (data_hit[ 4] ?  4 : 0) | (data_hit[ 5] ?  5 : 0) | (data_hit[ 6] ?  6 : 0) | (data_hit[ 7] ?  7 : 0) |
    (data_hit[ 8] ?  8 : 0) | (data_hit[ 9] ?  9 : 0) | (data_hit[10] ? 10 : 0) | (data_hit[11] ? 11 : 0) |
    (data_hit[12] ? 12 : 0) | (data_hit[13] ? 13 : 0) | (data_hit[14] ? 14 : 0) | (data_hit[15] ? 15 : 0) |
    (data_hit[16] ? 16 : 0) | (data_hit[17] ? 17 : 0) | (data_hit[18] ? 18 : 0) | (data_hit[19] ? 19 : 0) |
    (data_hit[20] ? 20 : 0) | (data_hit[21] ? 21 : 0) | (data_hit[22] ? 22 : 0) | (data_hit[23] ? 23 : 0) |
    (data_hit[24] ? 24 : 0) | (data_hit[25] ? 25 : 0) | (data_hit[26] ? 26 : 0) | (data_hit[27] ? 27 : 0) |
    (data_hit[28] ? 28 : 0) | (data_hit[29] ? 29 : 0) | (data_hit[30] ? 30 : 0) | (data_hit[31] ? 31 : 0);

//主要注意的是，由于MIPS Release 1采用了奇偶页面的设计，手册上的表格页大小指的是两个页面之一的大小。但匹配的时候相当于将那个大小*2之后进行匹配

//最终的地址逻辑是按照uCore代码写的，不确定是否符合MIPS标准，先把uCore跑通再说吧

assign data_paddr_o = {
    data_direct ? 
    (
        {3'b000,data_vaddr[28:12]}
    )
    :
    (
        (
            (data_vaddr[12] ? EntryLo1[data_hit_idx][25:6] : EntryLo0[data_hit_idx][25:6])
            &
            {1'b1,~PageMask[data_hit_idx][31:13]}
        )
        |
        (
            data_vaddr[31:12]
            &
            {1'b0,PageMask[data_hit_idx][31:13]}
        )
    )
    ,
    data_vaddr[11:0]
};

assign inst_found = inst_direct | inst_hit_exist;
assign data_found = data_direct | data_hit_exist;

assign data_V_flag = 
    data_direct |
    (data_hit_exist & (data_vaddr[12] ? EntryLo1[data_hit_idx][`VALID] : EntryLo0[data_hit_idx][`VALID]) );

assign data_D_flag = 
    data_direct |
    (data_hit_exist & (data_vaddr[12] ? EntryLo1[data_hit_idx][`DIRTY] : EntryLo0[data_hit_idx][`DIRTY]) );

//TODO: NE, TLBP, TLBR 
endmodule