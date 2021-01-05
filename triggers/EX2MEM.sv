`include "defines.vh"
module EX2MEM (
    input logic                 clk_i,
    input logic                 rst_i,
    input logic                 stall_i,

    input logic [`RegAddrBus]   ex_wd_i,
    input logic                 ex_wreg_i,
    input logic [`DoubleRegBus] ex_wdata_i,
    input logic                 ex_mt_hi_i,
    input logic                 ex_mt_lo_i,
    input logic                 ex_mf_hi_i,
    input logic                 ex_mf_lo_i,
    input logic                 ex_rmem_i,
    input logic                 ex_wmem_i,
    input logic [`AluOpBus]     ex_aluop_i,
    input logic  [31:0]         ex_mem_io_addr_i,
    input logic [31:0]          ex_pc_i,

    input logic                 flush_i,  //qf
    input logic [31:0]          ex_exception_type_i,//qf
    input logic [31:0]   ex_current_instr_addr_i,//qf
    input logic                 ex_is_in_delayslot,//qf

    input logic                 ex_cp0_reg_we,//qf
    input logic [4:0]           ex_cp0_reg_write_addr,//qf
    input logic [31:0]          ex_cp0_reg_data,//qf

    
    input logic [31:0] id_inst_i,
    output logic [31:0] id_inst_o,


    output logic[`RegAddrBus]   mem_wd_o,
    output logic                mem_wreg_o,
    output logic[`DoubleRegBus] mem_wdata_o,
    output logic                mem_mt_hi_o,
    output logic                mem_mt_lo_o,
    output logic                mem_mf_hi_o,
    output logic                mem_mf_lo_o,
    output logic                mem_rmem_o,
    output logic                mem_wmem_o,
    output logic [`AluOpBus]    mem_aluop_o,
    output logic  [31:0]        mem_mem_io_addr_o,
    output logic [31:0]         mem_pc_o,

    output logic [31:0]         mem_exception_type_o,  //qf
    output logic [31:0]         mem_current_instr_addr_o, //qf
    output logic                mem_is_in_delayslot, //qf

    output logic                mem_cp0_reg_we,//qf
    output logic [4:0]          mem_cp0_reg_write_addr,//qf
    output logic [31:0]         mem_cp0_reg_data//qf

);
    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            mem_wd_o <= `RegNumLog2'd0;
            mem_wreg_o <= 1'b0;
            mem_wdata_o <= `RegWidth'd0;
            mem_mt_hi_o <= 1'b0;
            mem_mt_lo_o <= 1'b0;
            mem_mf_hi_o <= 1'b0;
            mem_mf_lo_o <= 1'b0;
            mem_rmem_o  <= 1'b0;
            mem_wmem_o  <= 1'b0;
            mem_aluop_o <= 8'd0;
            mem_mem_io_addr_o <= 32'd0;
            mem_pc_o    <= 32'd0;
            mem_exception_type_o<= 32'b0;//qf
            mem_current_instr_addr_o<= 32'b0;//qf
            mem_is_in_delayslot<=1'b0; //qf

            mem_cp0_reg_we<=1'b0;//qf
            mem_cp0_reg_write_addr<=32'b0;//qf
            mem_cp0_reg_data<=32'b0;//qf
            id_inst_o<=32'b0;
        end
        else if (flush_i == 1'b1) begin
            mem_wd_o <= `RegNumLog2'd0;
            mem_wreg_o <= 1'b0;
            mem_wdata_o <= `RegWidth'd0;
            mem_mt_hi_o <= 1'b0;
            mem_mt_lo_o <= 1'b0;
            mem_mf_hi_o <= 1'b0;
            mem_mf_lo_o <= 1'b0;
            mem_rmem_o  <= 1'b0;
            mem_wmem_o  <= 1'b0;
            mem_aluop_o <= 8'd0;
            mem_pc_o    <= 32'd0;
            mem_mem_io_addr_o <= 32'd0;
            mem_exception_type_o<= 32'b0;//qf
            mem_current_instr_addr_o<= 32'b0;//qf
            mem_is_in_delayslot<=1'b0; //qf
            mem_cp0_reg_we<=1'b0;//qf
            mem_cp0_reg_write_addr<=32'b0;//qf
            mem_cp0_reg_data<=32'b0;//qf
            id_inst_o<=32'b0;
        end
        else if(stall_i == 1'b1) begin
            mem_wd_o <= mem_wd_o;
            mem_wreg_o <= mem_wreg_o;
            mem_wdata_o <= mem_wdata_o;
            mem_mt_hi_o <= mem_mt_hi_o;
            mem_mt_lo_o <= mem_mt_lo_o;
            mem_mf_hi_o <= mem_mf_hi_o;
            mem_mf_lo_o <= mem_mf_lo_o;
            mem_rmem_o  <= mem_rmem_o;
            mem_wmem_o  <= mem_wmem_o;
            mem_aluop_o <= mem_aluop_o;
            mem_pc_o    <= mem_pc_o;
            mem_mem_io_addr_o <= mem_mem_io_addr_o;
            mem_exception_type_o<= mem_exception_type_o;//qf
            mem_current_instr_addr_o<= mem_current_instr_addr_o;//qf
            mem_is_in_delayslot<=mem_is_in_delayslot; //qf

            mem_cp0_reg_we<=mem_cp0_reg_we;//qf
            mem_cp0_reg_write_addr<=mem_cp0_reg_write_addr;//qf
            mem_cp0_reg_data<=mem_cp0_reg_data;//qf
            id_inst_o<=id_inst_o;

        end
        else begin
            mem_wd_o <= ex_wd_i;
            mem_wreg_o <= ex_wreg_i;
            mem_wdata_o <= ex_wdata_i;
            mem_mt_hi_o <= ex_mt_hi_i;
            mem_mt_lo_o <= ex_mt_lo_i;
            mem_mf_hi_o <= ex_mf_hi_i;
            mem_mf_lo_o <= ex_mf_lo_i;
            mem_rmem_o  <= ex_rmem_i;
            mem_wmem_o  <= ex_wmem_i;
            mem_aluop_o <= ex_aluop_i;
            mem_pc_o    <= ex_pc_i;
            mem_mem_io_addr_o <= ex_mem_io_addr_i;
            mem_exception_type_o<= ex_exception_type_i;//qf
            mem_current_instr_addr_o<= ex_current_instr_addr_i;//qf
            mem_is_in_delayslot<=ex_is_in_delayslot; //qf

            mem_cp0_reg_we <= ex_cp0_reg_we;//qf
            mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr;//qf
            mem_cp0_reg_data <= ex_cp0_reg_data;//qf
            id_inst_o<=id_inst_i;
        end
    end
endmodule