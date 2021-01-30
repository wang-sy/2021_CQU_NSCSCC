
module mwm2wb(
    input  logic        clk_i,
    input  logic        rst_i,
    input  logic        flush_i,
    input  logic        stall_i,

    input  logic [31:0] result_i,
    input  logic [31:0] finaldata_i,
    input  logic [4:0]  writereg_i,
    input  logic [31:0] pc_i,
    input  logic [31:0] hi_alu_out_i,
    input  logic [31:0] lo_alu_out_i,
    input  logic [1:0]  hilo_we_i,

    input   logic          memtoreg_i,
    input   logic          regwrite_i,

    output  logic          memtoreg_o,
    output  logic          regwrite_o,

    output logic [31:0] result_o,
    output logic [31:0] finaldata_o,
    output logic [4:0]  writereg_o,
    output logic [31:0] pc_o,
    output logic [31:0] hi_alu_out_o,
    output logic [31:0] lo_alu_out_o,
    output logic [1:0]  hilo_we_o
);

    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            result_o<=0;
            finaldata_o<=0;
            writereg_o<=0;
            pc_o<=0;
            hi_alu_out_o<=0;
            lo_alu_out_o<=0;
            hilo_we_o<=0;

            memtoreg_o<=0;
            regwrite_o<=0;

        end
        else if (flush_i == 1'b1) begin
            result_o<=0;
            finaldata_o<=0;
            writereg_o<=0;
            pc_o<=0;
            hi_alu_out_o<=0;
            lo_alu_out_o<=0;
            hilo_we_o<=0;        

            memtoreg_o<=0;
            regwrite_o<=0;

        end
        else if (stall_i == 1'b1) begin
            result_o<=result_o;
            finaldata_o<=finaldata_o;
            writereg_o<=writereg_o;
            pc_o<=pc_o;
            hi_alu_out_o<=hi_alu_out_o;
            lo_alu_out_o<=lo_alu_out_o;
            hilo_we_o<=hilo_we_o;        

            memtoreg_o<=memtoreg_o;
            regwrite_o<=regwrite_o;

        end
        else begin
            result_o<=result_i;
            finaldata_o<=finaldata_i;
            writereg_o<=writereg_i;
            pc_o<=pc_i;
            hi_alu_out_o<=hi_alu_out_i;
            lo_alu_out_o<=lo_alu_out_i;
            hilo_we_o<=hilo_we_i;        

            memtoreg_o<=memtoreg_i;
            regwrite_o<=regwrite_i;

        end
    end

endmodule