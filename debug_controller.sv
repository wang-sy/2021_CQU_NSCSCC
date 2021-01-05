module debug_controller (
    input logic         clk_i,
    input logic         rst_i,

    input logic [31:0]  debug_pc_i,
    input logic         debug_wena_i,
    input logic [4:0]   debug_wd_i,
    input logic [31:0]  debug_wdata_i,

    output logic[31:0]  debug_wb_pc_o,
    output logic[3:0]   debug_wb_rf_wen_o,
    output logic[4:0]   debug_wb_rf_wnum_o,
    output logic[31:0]  debug_wb_rf_wdata_o
);

    logic pre_write;
    logic [31:0] pre_pc;

    always @(posedge clk_i ) begin
        if (rst_i == 1'b1) begin
            debug_wb_pc_o         <= 32'd0;
            debug_wb_rf_wen_o     <= 4'd0;
            debug_wb_rf_wnum_o    <= 5'd0;
            debug_wb_rf_wdata_o   <= 32'd0;
            pre_pc              <= 32'd0;
            pre_write           <= 1'b0;
        end
        else if (pre_pc != debug_pc_i) begin // pc发生切换
        
            debug_wb_pc_o         <= debug_pc_i;
            debug_wb_rf_wnum_o    <= debug_wd_i;
            debug_wb_rf_wdata_o   <= debug_wdata_i;
            pre_pc                <= debug_pc_i;
            if(debug_wena_i == 1'b1) begin // 切换时在写
                debug_wb_rf_wen_o     <= 4'b1111;  
                pre_write             <= 1'b1;
            end
            else begin
                debug_wb_rf_wen_o     <= 4'b0000;  
                pre_write             <= 1'b0;
            end
        end
        else begin // pc没有发生切换
            pre_write <= (pre_write == 1'b1) ? 1'b1 : debug_wena_i;
            debug_wb_pc_o         <= debug_pc_i;
            debug_wb_rf_wnum_o    <= debug_wd_i;
            debug_wb_rf_wdata_o   <= debug_wdata_i;
            pre_pc                <= debug_pc_i;
            debug_wb_rf_wen_o     <= (pre_write == 1'b1) ? 4'b0000 : {4{debug_wena_i}};
        end
    end

    
    
endmodule