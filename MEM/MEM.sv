`include "defines.vh"
module MEM (
    input logic                 clk_i,
    input logic                 rst_i,
    
    input logic [`RegAddrBus]   wd_i,
    input logic                 wreg_i,
    input logic [`DataBus]      wdata_i
);

    /*assign {wd_o, wreg_o, wdata_o} = (rst_i == 1'b1) ? {`NOPRegAddr, 1'b0, `ZeroWord} :
                                     {wd_i, wreg_i, wdata_i};*/
    
endmodule