//encoding:UTF-8
module regfile(
    input   logic       clk,
    input   logic       rst,

    // //输入
    input   logic[4:0]    raddr1,//寄存器1的读地址
    input   logic[4:0]    raddr2,

    input   logic         we,//写使能信号
    input   logic [4:0]    waddr,//写寄存器地址
    input   logic [31:0]   wdata, //写寄存器数据

    // //输出
    output  logic [31:0]  rdata2,
    output  logic [31:0]  rdata1
);

//32个32位宽的寄存器
logic [31:0] regs [31:0];

//写寄存器
always@(posedge  clk) begin
    if(rst==1'b0) begin
        if(we==1'b1) begin
            regs[waddr]<=wdata;
        end
    end
end

assign rdata1 = (rst==1'b1 || raddr1==5'b0) ? 32'd0 :
                (raddr1==waddr && we==1'b1) ? wdata : regs[raddr1];

assign rdata2 = (rst==1'b1 || raddr2==5'b0) ? 32'd0 :
                (raddr2==waddr && we==1'b1) ? wdata : regs[raddr2];        

endmodule