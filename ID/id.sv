`include "defines.vh"
`include "id_defines.vh"
//encoding:UTF-8
module ID(
    // //输入
    input clk,
    input logic         rst,
    //从IF/ID接收到信�?
    input logic [31:0] pc_i,
    input logic [31:0] inst_i,
    //WB级传输进来的信号
    input         we_i,
    input logic  [4:0]  waddr_i,
    input logic  [31:0] wdata_i,


    // //输出
    output logic [7:0]  aluop_o,
    output logic [2:0]  alusel_o,
    output logic [31:0] reg1_o,
    output  logic[31:0] reg2_o,

    output  logic      wreg_o, //是否有数据要写寄存器
    output  logic[4:0]  wd_o  //write destination
);

//寄存器堆接收到的信号
logic [31:0] reg1_data_i;
logic [31:0] reg2_data_i;

//读寄存器�?
logic        reg1_read_o; //是否读寄存器1
logic [4:0]  reg1_addr_o; //读寄存器地址
logic        reg2_read_o;
logic [4:0]  reg2_addr_o;

//定义指令字段信号
//op   re   rt  immediate
logic [5:0]  op;
logic [4:0]  rs;
logic [4:0]  rt;
logic [15:0] im;

logic [31:0] sign_imm;
logic [31:0] unsi_imm;

//指令字段信号赋�??
assign op=inst_i[31:26];
assign rs=inst_i[25:21];
assign rt=inst_i[20:16];
assign im=inst_i[15:0];
//无符号立即数
assign unsi_imm={16'b0,inst_i[15:0]};
//符号扩展
assign sign_imm={{16{inst_i[16]}},inst_i[15:0]};

regfile datapath_regfile(
    .clk(clk),
    .rst(rst),
    
    .re1(reg1_read_o), //寄存�?1的读使能
    .raddr1(reg1_addr_o),//寄存�?1的读地址
    .re2(reg2_read_o),
    .raddr2(reg2_addr_o),

    .we(we_i),//写使能信�?
    .waddr(waddr_i),//写寄存器地址
    .wdata(wdata_i), //写寄存器数据

    .rdata1(reg1_data_i),
    .rdata2(reg2_data_i)
);

assign { 
    aluop_o,
    alusel_o,
    wreg_o,
    wd_o,
    reg1_read_o,
    reg1_addr_o,
    reg2_read_o,
    reg2_addr_o
} = (rst == 1'b1) ? `INIT_DECODE :
        (op == `EXE_ORI) ? `ORI_DECODE :
    `INIT_DECODE;

assign reg1_o = (rst == 1'b1) ? `ZeroWord : 
                    (reg1_read_o==1'b1) ? reg1_data_i : unsi_imm;
assign reg2_o = (rst == 1'b1) ? `ZeroWord : 
                    (reg2_read_o==1'b1) ? reg2_data_i : unsi_imm;

endmodule