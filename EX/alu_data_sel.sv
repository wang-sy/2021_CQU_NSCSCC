module alu_data_sel (
    input  logic            rst_i, 
    input  logic            mf_hi_i,
    input  logic            mf_lo_i,
    input  logic [`DataBus] reg1_i,
    input  logic [`DataBus] reg2_i,
    input  logic [`DataBus] hi_i,
    input  logic [`DataBus] lo_i,

    output logic [`DataBus] alu_data1_o,
    output logic [`DataBus] alu_data2_o
);
    assign alu_data1_o =    ( rst_i == 1'b1 ) ? `ZeroWord : 
                            ( mf_hi_i == 1'b1) ? hi_i :
                            ( mf_lo_i == 1'b1) ? lo_i : reg1_i;
    assign alu_data2_o =    ( rst_i == 1'b1 ) ? `ZeroWord : 
                            ( mf_hi_i == 1'b1) ? hi_i :
                            ( mf_lo_i == 1'b1) ? lo_i : reg2_i;
endmodule