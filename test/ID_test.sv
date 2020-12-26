`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/26 17:45:11
// Design Name: 
// Module Name: test_id
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_id(

    );
    



// //输入
reg clk;
reg         rst;
//从IF/ID接收到信�?
reg [31:0] pc_i;
reg [31:0] inst_i;
//WB级传输进来的信号
reg    we_i;
reg  [4:0]  waddr_i;
reg  [31:0] wdata_i;
// //输出
wire [7:0]  aluop_o;
wire [2:0]  alusel_o;
wire [31:0] reg1_o;
wire[31:0] reg2_o;
wire      wreg_o; //是否有数据要写寄存器
wire[4:0]  wd_o;  //write destination

ID ID_TEST(
    clk,
    rst,
    
    pc_i,
    inst_i,
    //WB级传输进来的信号
    we_i,
    waddr_i,
    data_i,


    // //输出
     aluop_o,
     alusel_o,
     reg1_o,
     reg2_o,

    wreg_o, //是否有数据要写寄存器
     wd_o  //write destination
);




initial begin
        rst = 1'b1;
        clk = 1'b1;
        # 50 rst = 1'b0;

        


        inst_i = 32'b00110100000000010001000100000000;
        //WB级传输进来的信号
        we_i=1'b1;
        waddr_i=5'b00001;
        wdata_i=32'b1101;

    end
    always #1 clk = ~ clk;
endmodule
