`include "defines.vh"
module EX_test ();
    logic clk_i;
    logic rst_i;
    logic [`AluOpBus]aluop_i;
    logic [`AluSelBus]alusel_i;
    logic [`DataBus]reg1_i;
    logic [`DataBus]reg2_i;
    logic [`RegAddrBus]wd_i;
    logic wreg_i;
    logic [`RegAddrBus]wd_o;
    logic wreg_o;
    logic [`DataBus]wdata_o;

    EX my_ex(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .aluop_i(aluop_i),
        .alusel_i(alusel_i),
        .reg1_i(reg1_i),
        .reg2_i(reg2_i),
        .wd_i(wd_i),
        .wreg_i(wreg_i),
        .wd_o(wd_o),
        .wreg_o(wreg_o),
        .wdata_o(wdata_o)
    );

    initial begin
        clk_i = 1'b1;
        rst_i = 1'b1;
        # 100
        rst_i = 1'b0;

        # 100
        aluop_i = `EXE_ORI_OP;
        alusel_i = `EXE_RES_LOGIC;
        reg1_i = 32'd7;
        reg2_i = 32'd24;
        # 100 
        reg1_i = 32'd3;
        reg2_i = 32'd24;
    end
    always #1 clk_i = ~ clk_i;


endmodule