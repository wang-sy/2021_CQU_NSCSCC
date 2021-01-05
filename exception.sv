module exception(
	input  logic        rst_i,

	input  logic [31:0] exception_type_i,
	input  logic [31:0] cp0_status_i,
    input  logic [31:0] cp0_cause_i,

	output logic [31:0] exception_type_o
);

assign exception_type_o =   rst_i == 1'b1 ? 32'b0 : 
                            (((cp0_cause_i[15:8] & cp0_status_i[15:8]) != 8'h00) &&(cp0_status_i[1] == 1'b0) && (cp0_status_i[0] == 1'b1))==1'b1 ? 32'h00000001 : 
                            exception_type_i[8]   ==   1'b1 ? 32'h00000008 :
                            exception_type_i[9]   ==   1'b1 ? 32'h0000000a :

                            exception_type_i[13]  ==   1'b1 ? 32'h00000009 :

                            exception_type_i[11]  ==   1'b1 ? 32'h0000000c :
                            exception_type_i[10]  ==   1'b1 ? 32'h0000000d :
                            exception_type_i[12]  ==   1'b1 ? 32'h0000000e :  32'h0;
endmodule

