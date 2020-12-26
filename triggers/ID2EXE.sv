//encoding:UTF-8
module id2exe(
    input logic  rst,
    input logic  clk,

    input logic   [2:0]   id_alu_sel,
    input logic   [7:0]   id_alu_op,
    input logic   [31:0]  id_reg1,
    input logic   [31:0]  id_reg2,
    input logic           id_wreg,
    input logic   [4:0]   id_wd,
    
    output logic  [2:0]   exe_alu_sel,
    output logic  [7:0]   exe_alu_op,
    output logic  [31:0]  exe_reg1,
    output logic  [31:0]  exe_reg2,
    output logic          exe_wreg,
    output logic  [4:0]   exe_wd
);

always@(posedge clk) begin
    if(rst==1'b1) begin
        exe_alu_sel <=  3'b0;
        exe_alu_op  <=  8'b0;
        exe_reg1    <=  32'b0;
        exe_reg2    <=  32'b0;
        exe_wreg    <=  1'b0;
        exe_wd      <=  5'b0;
    end else begin
        exe_alu_sel <=  id_alu_sel;
        exe_alu_op  <=  id_alu_op;
        exe_reg1    <=  id_reg1;
        exe_reg2    <=  id_reg2;
        exe_wreg    <=  id_wreg;
        exe_wd      <=  id_wd;
    end
end




endmodule