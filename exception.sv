module exception(
	input  logic        rst_i,

	input  logic [31:0] exception_type_i,
	input  logic [31:0] cp0_status_i,
    input  logic [31:0] cp0_cause_i,

	output logic [31:0] exception_type_o
);

assign exception_type_o =   rst_i == 1'b1 ? 32'b0 : 
                            (((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00) &&(cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1))==1'b1 ? 32'h00000001 : 
                            exception_type_i[8]   ==   1'b1?32'h00000008 :
                            exception_type_i[9]   ==   1'b1?32'h0000000a :
                            exception_type_i[11]  ==   1'b1?32'h0000000c :
                            exception_type_i[10]  ==   1'b1?32'h0000000d :
                            exception_type_i[12]  ==   1'b1?32'h0000000e :  32'b0;
endmodule

