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

    output logic[`DataBus]      hi_o,
    output logic[`DataBus]      lo_o,
    output logic[`DoubleRegBus] wdata_o,
    output logic[`DataBus]      ram_wdata_o,
    output logic[31:0]          ram_addr_o,
    output logic[3:0]           ram_sel_o,
    output logic                ram_we_o,
    output logic                ram_ce_o
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
    mem_io_controller mem_mem_io_controller(
        .aluop_i(aluop_i),
        .wdata_i(wdata_i),
        .mem_io_addr_i(mem_io_addr_i),
        .rmem_i(rmem_i),
        .wmem_i(wmem_i),
        .ram_data_i(ram_data_i),

        .ram_wdata_o(ram_wdata_o),
        .ram_addr_o(ram_addr_o),
        .ram_sel_o(ram_sel_o),
        .ram_we_o(ram_we_o),
        .ram_ce_o(ram_ce_o),
        .read_data_o(mem_read_data)
    );
endmodule