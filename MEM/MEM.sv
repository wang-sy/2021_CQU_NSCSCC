`include "defines.vh"
module MEM (
    input logic                 clk_i,
    input logic                 rst_i,

    input logic [`RegAddrBus]   wd_i,
    input logic                 wreg_i,
    input logic [`DoubleRegBus] wdata_i,

    input logic                 mt_hi_i,
    input logic                 mt_lo_i,

    input logic                 rmem_i,
    input logic                 wmem_i,
    input logic [`AluOpBus]     aluop_i,
    input logic [`DataBus]      ram_data_i,
    input logic [31:0]          mem_io_addr_i,

    input logic [`RegAddrBus]   exception_type_i,  //qf
    input logic [`RegAddrBus]   current_instr_addr_i,  //qf
    input logic                 is_in_delayslot_i,  //qf

	input logic [`RegAddrBus]   cp0_status_i,  //qf
	input logic [`RegAddrBus]   cp0_cause_i,  //qf
	input logic [`RegAddrBus]   cp0_epc_i,  //qf

    input logic                 wb_cp0_reg_we,  //qf
	input logic [4:0]           wb_cp0_reg_write_addr,  //qf
	input logic [`RegAddrBus]   wb_cp0_reg_data,  //qf


    output logic[`DataBus]      hi_o,
    output logic[`DataBus]      lo_o,
    output logic[`DoubleRegBus] wdata_o,
    output logic[`DataBus]      ram_wdata_o,
    output logic[31:0]          ram_addr_o,
    output logic[3:0]           ram_sel_o,
    output logic                ram_we_o,
    output logic                ram_ce_o,

    output logic[31:0]          exception_type_o,  //qf
	output logic[`RegAddrBus]   current_instr_address_o,  //qf

	output logic                is_in_delayslot_o,  //qf
	output logic[`RegAddrBus]   cp0_epc_o  //qf

);

    assign is_in_delayslot_o = is_in_delayslot_i;
    assign current_instr_address_o = current_instr_address_i;

    logic [`RegAddrBus] CP0_Status_Newest;
    logic [`RegAddrBus] CP0_Cause_Newest;
    logic [`RegAddrBus] CP0_Epc_Newest;
    
    //最新的Staus寄存器
    assign CP0_Status_Newest = rst_i == 1'b1 ? 32'b0 ; 
                               (wb_cp0_reg_we==1'b1 && wb_cp0_reg_write_addr==`CP0_REG_STATUS) ? wb_cp0_reg_data : cp0_status_i;
    //最新的Cause寄存器
    assign CP0_Cause_Newest    = rst_i == 1'b1 ? 32'b0 ; 
                               (wb_cp0_reg_we==1'b1 && wb_cp0_reg_write_addr==`CP0_REG_CAUSE) ? 
                               {{cp0_cause_i[31:24]},{wb_cp0_reg_data[23:22]},{cp0_cause_i[21:10]},{wb_cp0_reg_data[9:8]},{cp0_cause_i[7:0]}} : cp0_cause_i;
    //最新的Epc寄存器
    assign CP0_Epc_Newest      = rst_i == 1'b1 ? 32'b0 ; 
                               (wb_cp0_reg_we==1'b1 && wb_cp0_reg_write_addr==`CP0_REG_EPC) ? wb_cp0_reg_data : cp0_epc_i;
    //输出最新cp0_epc
    assign cp0_epc_o = CP0_Epc_Newest;

    //exception_type_o
    exception exception_type(
        .rst_i(rst_i),
        .exception_type_i(exception_type_i),
        .cp0_status_i(cp0_status_i),
        .cp0_cause_i(cp0_cause_i),
        .exception_type_o(exception_type_o)
    );

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

    logic [`DataBus]  mem_read_data;
    assign wdata_o = (aluop_i == `EXE_LB_OP ||  aluop_i == `EXE_LBU_OP ||  aluop_i == `EXE_LH_OP ||
                      aluop_i == `EXE_LHU_OP ||  aluop_i == `EXE_LW_OP ) ? {mem_read_data, mem_read_data} : wdata_i;
    // 对io进行控制
    // 有异常就取消对MEMORY的写操作
    assign logic wmem_i_last = wmem_i & (~(|exception_type_o));

    mem_io_controller mem_mem_io_controller(
        .aluop_i(aluop_i),
        .wdata_i(wdata_i),
        .mem_io_addr_i(mem_io_addr_i),
        .rmem_i(rmem_i),
        .wmem_i(wmem_i_last),
        .ram_data_i(ram_data_i),

        .ram_wdata_o(ram_wdata_o),
        .ram_addr_o(ram_addr_o),
        .ram_sel_o(ram_sel_o),
        .ram_we_o(ram_we_o),
        .ram_ce_o(ram_ce_o),
        .read_data_o(mem_read_data)
    );
endmodule