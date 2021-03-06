
`include "defines.vh"
module ade_exception(
	input  logic [5:0]  op_i    ,
	input  logic [31:0] addr_i  ,
    input  logic [31:0] pc_i    ,

	output logic        adelM_o ,
    output logic        adesM_o ,

    output logic [31:0] bad_addr_o
    );
	
	always @(*) begin
		bad_addr_o  <=  pc_i;
		adesM_o     <=  1'b0;
		adelM_o     <=  1'b0;
		case (op_i) //op_i
			`EXE_LW:begin
				if(addr_i[1:0] != 2'b00) begin //addr_i
					adelM_o <= 1'b1;
					bad_addr_o <= addr_i;
				end 
			end
			`EXE_LH,`EXE_LHU:begin
                case (addr_i[1:0])
					2'b10:;
					2'b00:;
					default :begin
                        adelM_o <= 1'b1;
                        bad_addr_o <= addr_i;
					end 
				endcase
			end
			`EXE_SW:begin 
				if(addr_i[1:0] == 2'b00) begin
				end else begin 
					adesM_o <= 1'b1;
					bad_addr_o <= addr_i;
				end
			end
			`EXE_SH:begin
				case (addr_i[1:0])
					2'b10:;
					2'b00:;
					default :begin 
						adesM_o <= 1'b1;
						bad_addr_o <= addr_i;
					end 
				endcase
			end
		endcase
	end
endmodule
