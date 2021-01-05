//encoding:UTF-8
module id2exe(
    input logic             rst,
    input logic             clk,
    input logic             flush_i,
    input logic             stall_i,

    input logic   [2:0]     id_alu_sel_i,
    input logic   [7:0]     id_alu_op_i,
    input logic   [31:0]    id_reg1_i,
    input logic   [31:0]    id_reg2_i,
    input logic             id_wreg_i,
    input logic   [4:0]     id_wd_i,
    input logic             id_mt_hi_i,
    input logic             id_mt_lo_i,
    input logic             id_mf_hi_i,
    input logic             id_mf_lo_i,
    input logic             id_rmem_i,
    input logic             id_wmem_i,
    input logic  [31:0]     id_mem_io_addr_i,
    input logic  [31:0]     id_pc_i,
    
    input logic   [31:0]    id_exception_i,//qf
    input logic   [31:0]    id_current_instr_addr_i,//qf
    input logic             id_in_delayslot_i, //qf

    input logic             next_is_in_delayslot_i,//qf   //传回给ID�?
    
    input logic   [4:0 ]    rd_i,

    input logic [`RegAddrBus]      reg1_addr_i,
    input logic [`RegAddrBus]      reg2_addr_i,

    input logic reg1_read_i,
    input logic reg2_read_i,

    input logic [31:0] id_inst_i,
    output logic [31:0] id_inst_o,

    output logic  [2:0]     exe_alu_sel_o,
    output logic  [7:0]     exe_alu_op_o,
    output logic  [31:0]    exe_reg1_o,
    output logic  [31:0]    exe_reg2_o,
    output logic            exe_wreg_o,
    output logic  [4:0]     exe_wd_o,
    output logic            exe_mt_hi_o,
    output logic            exe_mt_lo_o,
    output logic            exe_mf_hi_o,
    output logic            exe_mf_lo_o,
    output logic            exe_rmem_o,
    output logic            exe_wmem_o,
    output logic  [31:0]    exe_mem_io_addr_o,
    output logic  [31:0]    exe_pc_o,

    output logic  [31:0]    ex_exception_o,//qf
    output logic  [31:0]    ex_current_instr_addr_o,//qf
    output logic            ex_in_delayslot_o,//qf
    output logic            is_in_delayslot_o,//qf  //传回给ID�?
    output logic   [4:0 ]   rd_o,

    
    output logic [`RegAddrBus]      reg1_addr_o,
    output logic [`RegAddrBus]      reg2_addr_o,

    output logic reg1_read_o,
    output logic reg2_read_o


);

always@(posedge clk) begin
    if(rst==1'b1 || flush_i == 1'b1) begin
        exe_alu_sel_o            <=  3'b0;
        exe_alu_op_o             <=  8'b0;
        exe_reg1_o               <=  32'b0;
        exe_reg2_o               <=  32'b0;
        exe_wreg_o               <=  1'b0;
        exe_wd_o                 <=  5'b0;
        exe_mt_hi_o              <=  1'b0;
        exe_mt_lo_o              <=  1'b0;
        exe_mf_hi_o              <=  1'b0;
        exe_mf_lo_o              <=  1'b0;
        exe_rmem_o               <=  1'b0;
        exe_wmem_o               <=  1'b0;
        exe_mem_io_addr_o        <= 32'd0;
        exe_pc_o                 <=  32'b0;

        ex_exception_o           <= 32'd0;//qf
        ex_current_instr_addr_o  <= 32'd0;//qf
        ex_in_delayslot_o        <= 1'd0;//qf

        is_in_delayslot_o        <= 1'd0;//qf  //传回给ID�?
        rd_o                     <=5'b0;

        reg1_addr_o<=5'b0;
        reg2_addr_o<=5'b0;

        reg1_read_o<=1'b0;
        reg2_read_o<=1'b0;
id_inst_o<=32'b0;
    end 
    else if (stall_i == 1'b1) begin
        exe_alu_sel_o <=  exe_alu_sel_o;
        exe_alu_op_o  <=  exe_alu_op_o;
        exe_reg1_o    <=  exe_reg1_o;
        exe_reg2_o    <=  exe_reg2_o;
        exe_wreg_o    <=  exe_wreg_o;
        exe_wd_o      <=  exe_wd_o;
        exe_mt_hi_o   <=  exe_mt_hi_o;
        exe_mt_lo_o   <=  exe_mt_lo_o;
        exe_mf_hi_o   <=  exe_mf_hi_o;
        exe_mf_lo_o   <=  exe_mf_lo_o;
        exe_rmem_o    <=  exe_rmem_o;
        exe_wmem_o    <=  exe_wmem_o;  
        exe_mem_io_addr_o <= exe_mem_io_addr_o;
        exe_pc_o      <=  exe_pc_o;

        ex_exception_o           <= ex_exception_o;//qf
        ex_current_instr_addr_o  <= ex_current_instr_addr_o;//qf
        ex_in_delayslot_o        <= ex_in_delayslot_o;//qf

        is_in_delayslot_o        <= is_in_delayslot_o;//qf  //传回给ID�?
        rd_o<=rd_o;

        reg1_addr_o<=reg1_addr_o;
        reg2_addr_o<=reg2_addr_o;

        reg1_read_o<=reg1_read_o;
        reg2_read_o<=reg2_read_o;
id_inst_o<=id_inst_o;
    end
    else begin
        exe_alu_sel_o            <=  id_alu_sel_i;
        exe_alu_op_o             <=  id_alu_op_i;
        exe_reg1_o               <=  id_reg1_i;
        exe_reg2_o               <=  id_reg2_i;
        exe_wreg_o               <=  id_wreg_i;
        exe_wd_o                 <=  id_wd_i;
        exe_mt_hi_o              <=  id_mt_hi_i;
        exe_mt_lo_o              <=  id_mt_lo_i;
        exe_mf_hi_o              <=  id_mf_hi_i;
        exe_mf_lo_o              <=  id_mf_lo_i;
        exe_rmem_o               <=  id_rmem_i;
        exe_wmem_o               <=  id_wmem_i;  
        exe_mem_io_addr_o        <= id_mem_io_addr_i;
        exe_pc_o                 <=  id_pc_i;

        ex_exception_o           <=id_exception_i;//qf
        ex_current_instr_addr_o  <= id_current_instr_addr_i;//qf
        ex_in_delayslot_o        <= id_in_delayslot_i;//qf

        is_in_delayslot_o        <= next_is_in_delayslot_i;//qf  //传回给ID�?
        rd_o<=rd_i;

        reg1_addr_o<=reg1_addr_i;
        reg2_addr_o<=reg2_addr_i;

        reg1_read_o<=reg1_read_i;
        reg2_read_o<=reg2_read_i;
id_inst_o<=id_inst_i;
    end
end


endmodule