module MEM2WB (
    input logic                 clk_i,
    input logic                 rst_i,
    input logic                 stall_i,

    input logic [`RegAddrBus]   mem_wd_i,
    input logic                 mem_wreg_i,
    input logic [`DoubleRegBus] mem_wdata_i,
    input logic [31:0]          mem_pc_i,

    input logic                 flush_i, //qf

    input logic                 mem_cp0_reg_we,//qf
    input logic [4:0]           mem_cp0_reg_write_addr,//qf
    input logic [31:0]          mem_cp0_reg_data,//qf

    input logic [31:0]          mem_bad_addr_i,


    output logic [`RegAddrBus]  wb_wd_o,
    output logic                wb_wreg_o,
    output logic [`DoubleRegBus]wb_wdata_o,
    output logic [31:0]         wb_pc_o,

    output logic                wb_cp0_reg_we,//qf
    output logic [4:0]          wb_cp0_reg_write_addr,//qf

    output logic [31:0]          mem_bad_addr_o,

    output logic [31:0]         wb_cp0_reg_data //qf

);
    
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            wb_wd_o               <= `NOPRegAddr;
            wb_wreg_o             <= 1'b0;
            wb_wdata_o            <= `ZeroWord;
            wb_pc_o               <= 32'b0;
            wb_cp0_reg_we         <= 1'b0;//qf
            wb_cp0_reg_write_addr <= 32'b0;//qf
            wb_cp0_reg_data       <= 32'b0;//qf
            mem_bad_addr_o<=32'b0;
        end 
        else if(flush_i==1'b1) begin
            wb_wd_o               <= `NOPRegAddr;
            wb_wreg_o             <= 1'b0;
            wb_wdata_o            <= `ZeroWord;

            // 这些都不应该被清空
            wb_pc_o               <= mem_pc_i;
            wb_cp0_reg_we         <= mem_cp0_reg_we;//qf
            wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;//qf
            wb_cp0_reg_data       <= mem_cp0_reg_data;//qf
            mem_bad_addr_o<=mem_bad_addr_i;
        end
        else if (stall_i == 1'b1) begin
            wb_wd_o               <= wb_wd_o;
            wb_wreg_o             <= wb_wreg_o;
            wb_wdata_o            <= wb_wdata_o;
            wb_pc_o               <= wb_pc_o;
            wb_cp0_reg_we         <= wb_cp0_reg_we;//qf
            wb_cp0_reg_write_addr <= wb_cp0_reg_write_addr;//qf
            wb_cp0_reg_data       <= wb_cp0_reg_data;//qf
            mem_bad_addr_o<=mem_bad_addr_o;
        end
        else begin
            wb_wd_o               <= mem_wd_i;
            wb_wreg_o             <= mem_wreg_i;
            wb_wdata_o            <= mem_wdata_i;
            wb_pc_o               <= mem_pc_i;
            wb_cp0_reg_we         <= mem_cp0_reg_we;//qf
            wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;//qf
            wb_cp0_reg_data       <= mem_cp0_reg_data;//qf
            mem_bad_addr_o<=mem_bad_addr_i;
        end
    end
    
endmodule