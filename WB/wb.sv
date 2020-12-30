//encoding:UTF-8
`include "defines.vh"
module wb(
    input  logic                    clk,
    input  logic                    rst,

    input  logic [4:0]              wb_wd,
    input  logic                    wb_reg,
    input  logic [`DoubleRegBus]    wb_wdata,

    input logic                     wb_cp0_reg_we,//qf
    input logic [4:0]               wb_cp0_reg_write_addr,//qf
    input logic [31:0]              wb_cp0_reg_data, //qf


    output logic  [4:0]             wb_wd_control,
    output logic                    wb_reg_control,
    output logic  [`DoubleRegBus]   wb_wdata_control,

    output logic                    wb_cp0_reg_we_control,//qf
    output logic [4:0]              wb_cp0_reg_write_addr_control,//qf
    output logic [31:0]             wb_cp0_reg_data_control //qf

);

assign {wb_wd_control, wb_reg_control, wb_wdata_control} = {wb_wd, wb_reg, wb_wdata};

assign {wb_cp0_reg_we_control, wb_cp0_reg_write_addr_control, wb_cp0_reg_data_control} = {wb_cp0_reg_we, wb_cp0_reg_write_addr, wb_cp0_reg_data};

endmodule