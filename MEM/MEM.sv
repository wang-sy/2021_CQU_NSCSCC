`include "defines.vh"
module MEM (
    input logic                 clk_i,
    input logic                 rst_i,

    input logic [`RegAddrBus]   wd_i,
    input logic                 wreg_i,
    input logic [`DoubleRegBus] wdata_i,

    input logic                 mt_hi_i,
    input logic                 mt_lo_i,

    input logic [`RegAddrBus]   exception_type_i,
    input logic [`RegAddrBus]   current_instr_addr_i,
    input logic                 is_in_delayslot_i,

	input logic [`RegAddrBus]   cp0_status_i,
	input logic [`RegAddrBus]   cp0_cause_i,
	input logic [`RegAddrBus]   cp0_epc_i,

    input logic                 wb_cp0_reg_we,
	input logic [4:0]           wb_cp0_reg_write_addr,
	input logic [`RegAddrBus]   wb_cp0_reg_data,

    output logic[`DataBus]      hi_o,
    output logic[`DataBus]      lo_o,

    output logic[31:0]          excepttion_type_o,
	output logic[`RegAddrBus]   current_instr_address_o,

	output logic                is_in_delayslot_o,
	output logic[`RegAddrBus]   cp0_epc_o
);

    assign is_in_delayslot_o = is_in_delayslot_i;
    assign current_instr_address_o = current_instr_address_i;

    /*assign {wd_o, wreg_o, wdata_o} = (rst_i == 1'b1) ? {`NOPRegAddr, 1'b0, `ZeroWord} :
                                     {wd_i, wreg_i, wdata_i};*/
    // mem阶段的hilo寄存器
    hilo_reg mem_hilo_reg(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .new_hi_i(wdata_i[63:32]),
        .w_hi_i(mt_hi_i),
        .new_lo_i(wdata_i[31:0]),
        .w_lo_i(mt_lo_i),
        .hi_o(hi_o),
        .lo_o(lo_o)
    );
endmodule