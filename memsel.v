`timescale 1ns / 1ps

`include "defines.vh"
module memsel(
	input wire[31:0] pc,
	input wire[5:0] op,
	input wire[31:0] addr,//equal aluoutM
	input wire[31:0] writedata,readdata, 
	// output wire memwrite,
	output reg [3:0] sel, 
	output reg[31:0] writedata2,finaldata,bad_addr,
	output reg adelM,adesM,
	output reg[1:0] size

    );
	
	always @(*) begin
		bad_addr <= pc;//previous: pc - 8
		adesM <= 1'b0;
		adelM <= 1'b0;
		writedata2 <= writedata;
		case (op)
			`LW:begin
				size <= 2'b10;
				if(addr[1:0] != 2'b00) begin
					adelM <= 1'b1;
					bad_addr <= addr;
					sel <= 4'b0000;
				end else begin
                    sel <= 4'b1111;
                end
			end
			`LB,`LBU:begin
				size <= 2'b00;
				case (addr[1:0])
					2'b11:sel <= 4'b1000;
					2'b10:sel <= 4'b0100;
					2'b01:sel <= 4'b0010;
					2'b00:sel <= 4'b0001;
					default : /* default */;
				endcase
			end
			`LH,`LHU:begin
				size <= 2'b01;
                case (addr[1:0])
					2'b10:sel <= 4'b1100;
					2'b00:sel <= 4'b0011;
					default :begin
                        adelM <= 1'b1;
                        bad_addr <= addr;
						sel <= 4'b0000;
					end 
				endcase
			end
			`SW:begin 
				size <= 2'b10;
				if(addr[1:0] == 2'b00) begin
					/* code */
					sel <= 4'b1111;
				end else begin 
					adesM <= 1'b1;
					bad_addr <= addr;
					sel <= 4'b0000;
				end
			end
			`SH:begin
				size <= 2'b01;
				writedata2 <= {writedata[15:0],writedata[15:0]};
				case (addr[1:0])
					2'b10:sel <= 4'b1100;
					2'b00:sel <= 4'b0011;
					default :begin 
						adesM <= 1'b1;
						bad_addr <= addr;
						sel <= 4'b0000;
					end 
				endcase
			end
			`SB:begin
				size <= 2'b00;
				writedata2 <= {writedata[7:0],writedata[7:0],writedata[7:0],writedata[7:0]};
				case (addr[1:0])
					2'b11:sel <= 4'b1000;
					2'b10:sel <= 4'b0100;
					2'b01:sel <= 4'b0010;
					2'b00:sel <= 4'b0001;
					default : /* default */;
				endcase
			end
			default : sel <= 4'b0000;
		endcase
		// bad_addr <= pc - 8;
		case (op)
			`LW:begin 
				if(addr[1:0] == 2'b00) begin
					/* code */
					finaldata <= readdata;
				end
			end
			`LB:begin 
				case (addr[1:0])
					2'b11: finaldata <= {{24{readdata[31]}},readdata[31:24]};
					2'b10: finaldata <= {{24{readdata[23]}},readdata[23:16]};
					2'b01: finaldata <= {{24{readdata[15]}},readdata[15:8]};
					2'b00: finaldata <= {{24{readdata[7]}},readdata[7:0]};
					default : /* default */;		        
				endcase
			end
			`LBU:begin 
				case (addr[1:0])
					2'b11: finaldata <= {{24{1'b0}},readdata[31:24]};
					2'b10: finaldata <= {{24{1'b0}},readdata[23:16]};
					2'b01: finaldata <= {{24{1'b0}},readdata[15:8]};
					2'b00: finaldata <= {{24{1'b0}},readdata[7:0]};
					default : /* default */;
				endcase
			end
			`LH:begin 
				case (addr[1:0])
					2'b10: finaldata <= {{16{readdata[31]}},readdata[31:16]};
					2'b00: finaldata <= {{16{readdata[15]}},readdata[15:0]};
					default :;
				endcase
			end
			`LHU:begin 
				case (addr[1:0])
					2'b10: finaldata <= {{16{1'b0}},readdata[31:16]};
					2'b00: finaldata <= {{16{1'b0}},readdata[15:0]};
					default :;
				endcase
			end
			default : finaldata <= `ZeroWord;
		endcase
	end
	
endmodule
