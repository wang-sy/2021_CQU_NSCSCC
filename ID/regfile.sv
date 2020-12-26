//encoding:UTF-8
module regfile(
    input   logic       clk,
    input   logic       rst,

    // //输入
    input     logic     re1, //寄存器1的读使能
    input  logic[4:0]    raddr1,//寄存器1的读地址
    input  logic        re2,
    input logic[4:0]    raddr2,

    input logic         we,//写使能信号
    input logic [4:0]    waddr,//写寄存器地址
    input logic [31:0]   wdata, //写寄存器数据

    // //输出
    output logic [31:0]  rdata1,
    output logic [31:0]  rdata2
);

//32个32位宽的寄存器
logic [31:0] regs [31:0];

//写寄存器
always@(negedge  clk) begin
    if(rst==1'b0) begin
        if(we==1'b1) begin
            regs[waddr]<=wdata;
        end
    end
end

//读寄存器1
always@(*) begin
    if(rst==1'b1 || raddr1==5'b0 || re1==1'b0) begin
        rdata1 <=32'b0;
    end 
    else 
    if(raddr1==waddr && we==1'b1) begin
        rdata1<=wdata;
    end else begin
        rdata1<=regs[raddr1];
    end
end

//读寄存器2
//读寄存器1
always@(*) begin
    if(rst==1'b1 || raddr2==5'b0 || re1==2'b0) begin
        rdata2 <=32'b0;
    end 
    else 
    if(raddr2==waddr && we==1'b1) begin
        rdata2<=wdata;
    end else begin
        rdata2<=regs[raddr2];
    end
end

endmodule