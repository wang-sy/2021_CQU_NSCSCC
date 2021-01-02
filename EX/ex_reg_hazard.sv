`include "defines.vh"
module ex_reg_harzrd (
    // 用于读取的地址和数据
    input logic             rst_i,

    input logic     [4:0]   reg_addr1_i,
    input logic     [4:0]   reg_addr2_i,

    input logic     [31:0]  reg_data1_i,
    input logic     [31:0]  reg_data2_i,

    input logic             reg1_read_i,
    input logic             reg2_read_i,

    // 用于判断冒险的数据

    input logic             mem_we_i,
    input logic     [4:0]   mem_waddr_i,
    input logic     [31:0]  mem_wdata_i,

    input logic             wb_we_i,
    input logic     [4:0]   wb_waddr_i,
    input logic     [31:0]  wb_wdata_i,

    // 读取到的结果
    output logic    [31:0]  rdata1_o,
    output logic    [31:0]  rdata2_o
);

    // 这是数据冒险模块，在这里，我们需要对读取的数据进行选择：
    // 这里的冒险主要针对RAW，冒险的方法是：
    // 1、判断当前计算阶段的目标寄存器是否是当前寄存器，如果是就将计算结果当作读取结果
    // 2、判断当前访存阶段的写入目标，是否是当前寄存器，如果是就将访存阶段的结果当作读取结果
    // 3、判断当前回写阶段的写入目标，是否是当前寄存器，如果是就将回写阶段的结果当作读取结果
    // 4、都不是的情况下，就将读取结果作为最终结果

    assign rdata1_o =   (rst_i == 1'b1) ? `ZeroWord :
                        (mem_we_i == 1'b1 && mem_waddr_i == reg_addr1_i && reg1_read_i==1'b1) ? mem_wdata_i :
                        (wb_we_i == 1'b1 && wb_waddr_i == reg_addr1_i && reg1_read_i==1'b1) ? wb_wdata_i : reg_data1_i;
    
    assign rdata2_o =   (rst_i == 1'b1) ? `ZeroWord :
                        (mem_we_i == 1'b1 && mem_waddr_i == reg_addr2_i && reg2_read_i==1'b1) ? mem_wdata_i : 
                        (wb_we_i == 1'b1 && wb_waddr_i == reg_addr2_i && reg2_read_i==1'b1) ? wb_wdata_i : reg_data2_i;

endmodule