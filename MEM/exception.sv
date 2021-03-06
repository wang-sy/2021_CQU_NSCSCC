module exception(
	input  logic        rst_i,

	input  logic [31:0] exception_type_i,
	input  logic [31:0] cp0_status_i,
    input  logic [31:0] cp0_cause_i,

    input  logic        adel,
    input  logic        ades,

    input  logic [1:0]  soft_int,  //此处不使用

	output logic [31:0] exception_type_o
);

logic [31:0]cp0_cause_harzrd;
// 拼接而成，暂时没有考虑硬件中断
assign cp0_cause_harzrd = {cp0_cause_i[31:10], soft_int, cp0_cause_i[7:0]};


//assign exception_o  = { 17'b0,addr_exception_i,except_type_is_break, except_type_is_eret, 2'b0, ~instr_valid_rejudge, except_type_is_syscall, 8'b0};
assign exception_type_o =   rst_i == 1'b1 ? 32'b0 : 
                            (((cp0_cause_harzrd[15:8] & cp0_status_i[15:8]) != 8'h00) &&(cp0_status_i[1] == 1'b0) && (cp0_status_i[0] == 1'b1))==1'b1 ? 32'h00000001 : 
                            (adel ||exception_type_i[14])   ==   1'b1 ? 32'h00000004 :      
                            ades                          ==   1'b1 ? 32'h00000005 :     
                            exception_type_i[8]           ==   1'b1 ? 32'h00000008 :
                            exception_type_i[9]           ==   1'b1 ? 32'h0000000a :

                            exception_type_i[13]          ==   1'b1 ? 32'h00000009 :                            
                            exception_type_i[11]          ==   1'b1 ? 32'h0000000c :
                            exception_type_i[10]          ==   1'b1 ? 32'h0000000d :
                            exception_type_i[12]          ==   1'b1 ? 32'h0000000e :  32'h0;
endmodule
