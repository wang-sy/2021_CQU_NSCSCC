`include "defines.vh"

module cp0_logicfile(

    // //input
	input  logic                   clk,
	input  logic                   rst,

	input  logic                   we_i,
	input  logic [4:0]             waddr_i,
	input  logic [31:0]            data_i,
	input  logic [5:0]             int_i,

	input  logic [4:0]             raddr_i,

    // //output
	output logic [31:0]            data_o,
	output logic [31:0]            count_o,
	output logic [31:0]            compare_o,
	output logic [31:0]            status_o,
	output logic [31:0]            cause_o,
	output logic [31:0]            epc_o,
	output logic [31:0]            config_o,
	output logic [31:0]            prid_o,
	
	output logic                   timer_int_o
);

always@(posedge clk) begin
    if(rst==1'b1) begin
        data_o      <=  32'b0;
        count_o     <=  32'b0;
        compare_o   <=  32'b0;
        status_o    <=  32'b0;
        cause_o     <=  32'b0;
        epc_o       <=  32'b0;
        config_o    <=  32'b0;
		prid_o      <=  32'b00000000010011000000000100000010; //注意：此处不是我的处理器标志
        timer_int_o <=  1'b0;
    end 
    else begin
        count_o         <=  count_o+1;
        cause_o[15:10]  <=  int_i;
        if(compare_o!=32'b0 && compare_o==timer_int_o) begin
            timer_int_o<=1'b1;
        end
        if(we_i==1'b1) begin
            case(waddr_i)
                `CP0_REG_COUNT:begin
                    count_o<=data_i;
                end
                `CP0_REG_COMPARE:begin
                    compare_o<=data_i;
                end
                `CP0_REG_STATUS:begin
                    status_o<=data_i;
                end
                `CP0_REG_CAUSE:begin
					cause_o[23]  <= data_i[23];
					cause_o[22]  <= data_i[22];
                    cause_o[9:8] <= data_i[9:8];
                end
                `CP0_REG_EPC:begin
                    epc_o<=data_i;
                end
                default:;
            endcase
        end
    end
end

assign data_o = rst    == 1'b1            ? 32'b0:
                raddr_i==`CP0_REG_COUNT   ? count_o:
                raddr_i==`CP0_REG_COMPARE ? compare_o:
                raddr_i==`CP0_REG_STATUS  ? status_o:
                raddr_i==`CP0_REG_CAUSE   ? cause_o:
                raddr_i==`CP0_REG_EPC     ? epc_o:
                raddr_i==`CP0_REG_CONFIG  ? config_o:
                raddr_i==`CP0_REG_PRID    ? prid_o:32'b0;

endmodule