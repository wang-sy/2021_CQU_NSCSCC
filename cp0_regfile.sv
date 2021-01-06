`include "defines.vh"

module cp0_regfile(

    //  //input
	input  logic                    clk,
	input  logic                    rst,
	 
	 
	input  logic                    we_i,
	input  logic[4:0]               waddr_i,
	input  logic[4:0]               raddr_i,
	input  logic[`RegBus]           data_i,
	 
	input  logic[31:0]              excepttype_i,
	input  logic[5:0]               int_i,
	input  logic[`RegBus]           current_inst_addr_i,
	input  logic                    is_in_delayslot_i,

    input  logic [31:0]             bad_addr_i,

	//  //output
	output logic[`RegBus]           data_o,
	output logic[`RegBus]           count_o,
	output logic[`RegBus]           compare_o,
	output logic[`RegBus]           status_o,
	output logic[`RegBus]           cause_o,
	output logic[`RegBus]           epc_o,
	output logic[`RegBus]           config_o,
	output logic[`RegBus]           prid_o,
    output logic[`RegBus]           badvaddr,

	
	output logic                    timer_int_o
);

always @ (posedge clk) begin
    if(rst == `RstEnable) begin
        count_o     <= 32'b0;
        compare_o   <= 32'b0;
        status_o    <= 32'b00010000000000000000000000000000;
        cause_o     <= 32'b0;
        epc_o       <= 32'b0;
        config_o    <= 32'b00000000000000001000000000000000;
        prid_o      <= 32'b00000000010011000000000100000010;  //此处使用的leisilei都版本号，未进行自定义更改
        timer_int_o <= `InterruptNotAssert;
    end else begin
        count_o <= count_o + 1 ;
        cause_o[15:10] <= int_i;
        if(compare_o != 32'b0 && count_o == compare_o) begin
            timer_int_o <= `InterruptAssert;
        end
        if(we_i == `WriteEnable) begin
            case (waddr_i) 
                `CP0_REG_COUNT:		begin
                    count_o <= data_i;
                end
                `CP0_REG_COMPARE:	begin
                    compare_o   <= data_i;
                    timer_int_o <= `InterruptNotAssert;
                end
                `CP0_REG_STATUS:	begin
                    status_o <= data_i;
                end
                `CP0_REG_EPC:	begin
                    epc_o <= data_i;
                end
                `CP0_REG_CAUSE:	begin
                    cause_o[9:8] <= data_i[9:8];
                    cause_o[23] <= data_i[23];
                    cause_o[22] <= data_i[22];
                end					
            endcase
        end
        case (excepttype_i)
            32'h00000001:		begin
                if(is_in_delayslot_i == `InDelaySlot ) begin
                    epc_o <= current_inst_addr_i - 4 ;
                    cause_o[31] <= 1'b1;
                end else begin
                    epc_o <= current_inst_addr_i;
                    cause_o[31] <= 1'b0;
                end
                status_o[1] <= 1'b1;
                cause_o[6:2] <= 5'b00000;
            end
            32'h00000004:begin
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00100;
					badvaddr <= bad_addr_i;
				end
			32'h00000005:begin
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00101;
					badvaddr <= bad_addr_i;
			end

            32'h00000008:		begin
                if(status_o[1] == 1'b0) begin
                    if(is_in_delayslot_i == `InDelaySlot ) begin
                        epc_o <= current_inst_addr_i - 4 ;
                        cause_o[31] <= 1'b1;
                    end else begin
                    epc_o <= current_inst_addr_i;
                    cause_o[31] <= 1'b0;
                    end
                end
                status_o[1] <= 1'b1;
                cause_o[6:2] <= 5'b01000;			
            end
            
            32'h00000009:begin
                if(is_in_delayslot_i == `InDelaySlot) begin
                    /* code */
                    epc_o <= current_inst_addr_i - 4;
                    cause_o[31] <= 1'b1;
                end else begin
                    epc_o <= current_inst_addr_i;
                    cause_o[31] <= 1'b0;
                end
                status_o[1] <= 1'b1;
                cause_o[6:2] <= 5'b01001;
			end

            32'h0000000a:		begin
                if(status_o[1] == 1'b0) begin
                    if(is_in_delayslot_i == `InDelaySlot ) begin
                        epc_o <= current_inst_addr_i - 4 ;
                        cause_o[31] <= 1'b1;
                    end else begin
                    epc_o <= current_inst_addr_i;
                    cause_o[31] <= 1'b0;
                    end
                end
                status_o[1] <= 1'b1;
                cause_o[6:2] <= 5'b01010;					
            end
            32'h0000000d:		begin
                if(status_o[1] == 1'b0) begin
                    if(is_in_delayslot_i == `InDelaySlot ) begin
                        epc_o <= current_inst_addr_i - 4 ;
                        cause_o[31] <= 1'b1;
                    end else begin
                    epc_o <= current_inst_addr_i;
                    cause_o[31] <= 1'b0;
                    end
                end
                status_o[1] <= 1'b1;
                cause_o[6:2] <= 5'b01101;					
            end
            32'h0000000c:		begin
                if(status_o[1] == 1'b0) begin
                    if(is_in_delayslot_i == `InDelaySlot ) begin
                        epc_o <= current_inst_addr_i - 4 ;
                        cause_o[31] <= 1'b1;
                    end else begin
                    epc_o <= current_inst_addr_i;
                    cause_o[31] <= 1'b0;
                    end
                end
                status_o[1] <= 1'b1;
                cause_o[6:2] <= 5'b01100;					
            end				
            32'h0000000e:   begin
                status_o[1] <= 1'b0;
            end
            default:				begin
            end
        endcase			
    end
end

assign data_o = rst    == 1'b1            ? 32'b0:
                raddr_i==`CP0_REG_COUNT   ? count_o:
                raddr_i==`CP0_REG_COMPARE ? compare_o:
                raddr_i==`CP0_REG_STATUS  ? status_o:
                raddr_i==`CP0_REG_CAUSE   ? cause_o:
                raddr_i==`CP0_REG_EPC     ? epc_o:
                raddr_i==`CP0_REG_CONFIG  ? config_o:
                raddr_i==`CP0_REG_PRID    ? prid_o: 
                raddr_i==`CP0_REG_BADVADDR? badvaddr: 32'b0;

endmodule