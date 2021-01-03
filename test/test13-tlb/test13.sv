`timescale 1ns / 1ps
`include "tlbdefines.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/03 14:00:51
// Design Name: 
// Module Name: test13
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test13(
    );
    reg clk;
    reg [2:0]   tlb_typeM;
    reg [31:0]  inst_vaddr, data_vaddr;
    reg [31:0]  EntryHi_in, PageMask_in, EntryLo0_in, EntryLo1_in;
    reg [31:0]  Index_in, Random_in;
    wire [31:0] EntryHi_out, PageMask_out, EntryLo0_out, EntryLo1_out;
    wire [31:0] Index_out;
    wire [31:0] inst_paddr_o, data_paddr_o;
    wire inst_V_flag, data_V_flag;
    wire data_D_flag;
    wire inst_found, data_found;
    TLB tlb(
        .clk(clk),
        .tlb_typeM(tlb_typeM),
        .inst_vaddr(inst_vaddr),
        .data_vaddr(data_vaddr),
        .EntryHi_in(EntryHi_in),
        .PageMask_in(PageMask_in),
        .EntryLo0_in(EntryLo0_in),
        .EntryLo1_in(EntryLo1_in),
        .Index_in(Index_in),
        .Random_in(Random_in),
        .EntryHi_out(EntryHi_out),
        .PageMask_out(PageMask_out),
        .EntryLo0_out(EntryLo0_out),
        .EntryLo1_out(EntryLo1_out),
        .Index_out(Index_out),
        .inst_V_flag(inst_V_flag),
        .data_V_flag(data_V_flag),
        .data_D_flag(data_D_flag),
        .inst_paddr_o(inst_paddr_o),
        .data_paddr_o(data_paddr_o),
        .inst_found(inst_found),
        .data_found(data_found)
    );
    always #2 clk = ~clk;
    reg [5:0] i;
    initial begin
        clk = 0;
        Index_in = 0;
        Random_in = 0;
        EntryHi_in = 0;
        EntryLo0_in = 0;
        EntryLo1_in = 0;
        tlb_typeM = 3'b000;
        //Test kseg0 Direct
        inst_vaddr = 32'h92336666;
        data_vaddr = 32'h92331234;
        #4
        inst_vaddr = 32'ha2331234;
        data_vaddr = 32'ha2336666;
        //Test kseg1 Direct
        #4
        inst_vaddr = 32'h00003123;
        data_vaddr = 32'h00002666;
        //Test non Valid bit shouldn't match
        #4
        for(i=0;i<32;i++) begin
            tlb_typeM = `TLBWI;
            Index_in = {26'd0,i};
            PageMask_in = 0;
            EntryLo0_in = 0;
            EntryLo1_in = 0;
            EntryHi_in = 0;
            #4 
            $display("clear tlb index %d",i);
        end
        //Test TLBWI
        Index_in = 12;
        PageMask_in = 0;
        EntryHi_in = 32'h00002000;
        EntryLo0_in = {26'b11011,6'b111011};//Test unset dirty
        EntryLo1_in = {26'b11010,6'b111111};
        #4
        //Test TLBWR
        tlb_typeM = `TLBWR;
        Index_in = 0;
        Random_in = 12;
        EntryLo0_in = {26'b11011,6'b111111};//Test set dirty
        EntryLo1_in = {26'b11010,6'b111101};//Test set invalid
        #4
        //Test no action
        tlb_typeM = 0;
        EntryHi_in = 0;
        EntryLo0_in = 0;
        EntryLo1_in = 0;
        #4
        $finish;
    end
endmodule
