
module exe2mem(
    input   logic          clk_i,
    input   logic          rst_i,
    input   logic          flush_i,
    input   logic          stall_i,

    input   logic [31:0]   rdata2_i,
    input   logic [31:0]   aluout_i,
    input   logic [4:0]    waddr_i,
    input   logic [31:0]   pc_i,
    input   logic [5:0]    op_i,
    input   logic [31:0]   hi_data_i,
    input   logic [31:0]   lo_data_i,
    input   logic [1:0]    whilo_i,
    input   logic [4:0]    rd_i,
    input   logic          is_in_delayslot_i,
    input   logic [7:0]    except_i,

    input   logic          rmem_i,
    input   logic          wmem_i,
    input   logic          wreg_i,
    input   logic          wcp0_i,
    input   logic          memen_i,

    output  logic          rmem_o,
    output  logic          wmem_o,
    output  logic          wreg_o,
    output  logic          wcp0_o,
    output  logic          memen_o,

    output  logic [31:0]   rdata2_o,
    output  logic [31:0]   aluout_o,
    output  logic [4:0]    waddr_o,
    output  logic [31:0]   pc_o,
    output  logic [5:0]    op_o,
    
    output  logic [31:0]   hi_data_o,
    output  logic [31:0]   lo_data_o,
    output  logic [1:0]    whilo_o,

    output  logic [4:0]    rd_o,
    output  logic          is_in_delayslot_o,
    output  logic [7:0]    except_o

);

    always @(posedge clk_i) begin
        if (rst_i == 1'b1) begin
            rdata2_o<=0;
            aluout_o<=0;
            waddr_o<=0;
            pc_o<=0;
            op_o<=0;
            hi_data_o<=0;
            lo_data_o<=0;
            whilo_o<=0;
            rd_o<=0;
            is_in_delayslot_o<=0;
            except_o<=0;

            rmem_o<=0;
            wmem_o<=0;
            wreg_o<=0;
            wcp0_o<=0;
            memen_o<=0;

        end
        else if (flush_i == 1'b1) begin
            rdata2_o<=0;
            aluout_o<=0;
            waddr_o<=0;
            pc_o<=0;
            op_o<=0;
            hi_data_o<=0;
            lo_data_o<=0;
            whilo_o<=0;
            rd_o<=0;
            is_in_delayslot_o<=0;
            except_o<=0;

            rmem_o<=0;
            wmem_o<=0;
            wreg_o<=0;
            wcp0_o<=0;
            memen_o<=0;
        end
        else if (stall_i == 1'b1) begin
            rdata2_o<=rdata2_o;
            aluout_o<=aluout_o;
            waddr_o<=waddr_o;
            pc_o<=pc_o;
            op_o<=op_o;
            hi_data_o<=hi_data_o;
            lo_data_o<=lo_data_o;
            whilo_o<=whilo_o;
            rd_o<=rd_o;
            is_in_delayslot_o<=is_in_delayslot_o;
            except_o<=except_o;

            rmem_o<=rmem_o;
            wmem_o<=wmem_o;
            wreg_o<=wreg_o;
            wcp0_o<=wcp0_o;
            memen_o<=memen_o;

        end
        else begin
            rdata2_o<=rdata2_i;
            aluout_o<=aluout_i;
            waddr_o<=waddr_i;
            pc_o<=pc_i;
            op_o<=op_i;
            hi_data_o<=hi_data_i;
            lo_data_o<=lo_data_i;
            whilo_o<=whilo_i;
            rd_o<=rd_i;
            is_in_delayslot_o<=is_in_delayslot_i;
            except_o<=except_i;

            rmem_o<=rmem_i;
            wmem_o<=wmem_i;
            wreg_o<=wreg_i;
            wcp0_o<=wcp0_i;
            memen_o<=memen_i;

        end
    end

endmodule