`include "defines.vh"
module mem_io_controller (
    input logic [`AluOpBus]     aluop_i,
    input logic [`DoubleRegBus] wdata_i,
    input logic [`DataAddrBus]  mem_io_addr_i,
    input logic                 rmem_i,
    input logic                 wmem_i,
    input logic [`DataBus]      ram_data_i,

    output logic[`DataBus]      ram_wdata_o,
    output  logic [31:0]        ram_addr_o,
    output  logic [3:0]         ram_sel_o,
    output  logic               ram_we_o,
    output  logic               ram_ce_o,
    output  logic [`DataBus]    read_data_o
);  

    assign ram_addr_o = {mem_io_addr_i[31:2], 2'b00};
    assign ram_ce_o = (rmem_i | wmem_i);
    assign ram_we_o = wmem_i;
    
    assign read_data_o =(aluop_i == `EXE_LB_OP) ? (
                            (mem_io_addr_i[1:0] == 2'b00) ? {{24{ram_data_i[7]}}, ram_data_i[7:0]}     : 
                            (mem_io_addr_i[1:0] == 2'b01) ? {{24{ram_data_i[15]}}, ram_data_i[15:8]}   : 
                            (mem_io_addr_i[1:0] == 2'b10) ? {{24{ram_data_i[23]}}, ram_data_i[23:16]}  : 
                            (mem_io_addr_i[1:0] == 2'b11) ? {{24{ram_data_i[31]}}, ram_data_i[31:24]}  : `ZeroWord
                        ) :
                        (aluop_i == `EXE_LBU_OP) ? (
                            (mem_io_addr_i[1:0] == 2'b00) ? {{24{1'b0}}, ram_data_i[7:0]}    : 
                            (mem_io_addr_i[1:0] == 2'b01) ? {{24{1'b0}}, ram_data_i[15:8]}   : 
                            (mem_io_addr_i[1:0] == 2'b10) ? {{24{1'b0}}, ram_data_i[23:16]}  : 
                            (mem_io_addr_i[1:0] == 2'b11) ? {{24{1'b0}}, ram_data_i[31:24]}  : `ZeroWord
                        ) :
                        (aluop_i == `EXE_LH_OP) ? (
                            (mem_io_addr_i[1:0] == 2'b00) ? {{16{ram_data_i[15]}}, ram_data_i[15:0]} : 
                            (mem_io_addr_i[1:0] == 2'b10) ? {{16{ram_data_i[31]}}, ram_data_i[31:16]} :  `ZeroWord
                        ) :
                        (aluop_i == `EXE_LHU_OP) ? (
                            (mem_io_addr_i[1:0] == 2'b00) ? {{16{1'b0}}, ram_data_i[15:0]} : 
                            (mem_io_addr_i[1:0] == 2'b10) ? {{16{1'b0}}, ram_data_i[31:16]} :  `ZeroWord
                        ) :
                        (aluop_i == `EXE_LW_OP   ) ? (
                            ram_data_i
                        ) : `ZeroWord;
    
    assign ram_wdata_o = (aluop_i == `EXE_SB_OP) ? {wdata_i[7:0], wdata_i[7:0], wdata_i[7:0], wdata_i[7:0]}:
                        (aluop_i == `EXE_SH_OP) ?  {wdata_i[15:0], wdata_i[15:0]}:
                        (aluop_i == `EXE_SW_OP) ? wdata_i : `ZeroWord;   

    assign ram_sel_o =  (aluop_i == `EXE_SB_OP) ? (
                            (mem_io_addr_i[1:0] == 2'b00) ? 4'b0001  : 
                            (mem_io_addr_i[1:0] == 2'b01) ? 4'b0010  : 
                            (mem_io_addr_i[1:0] == 2'b10) ? 4'b0100  : 
                            (mem_io_addr_i[1:0] == 2'b11) ? 4'b1000  : 4'b0000
                        ) :
                        (aluop_i == `EXE_SH_OP) ? (
                            (mem_io_addr_i[1:0] == 2'b00) ? 4'b0011 : 
                            (mem_io_addr_i[1:0] == 2'b10) ? 4'b1100 :  4'b0000
                        ) :
                        (aluop_i == `EXE_SW_OP) ? 4'b1111 : `ZeroWord;   
                                    
                                    


endmodule