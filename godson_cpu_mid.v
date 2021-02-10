module godson_cpu_mid(
    //global
    input coreclock,
    input [4:0] interrupt_i,
    input nmi,
    input areset_n,
    //read address channel
    output [3:0] arid,
    output [31:0] araddr,
    output [3:0] arlen,
    output [2:0] arsize,
    output [1:0] arburst,
    output [1:0] arlock,
    output [3:0] arcache,
    output [2:0] arprot,
    output arvalid, 
    input arready,
    //read data channel
    input [3:0] rid,
    input [31:0] rdata,
    input [1:0] rresp,
    input rlast,
    input rvalid,
    output rready,
    //write address channel
    output [3:0] awid,
    output [31:0] awaddr,
    output [3:0] awlen,
    output [2:0] awsize,
    output [1:0] awburst,
    output [1:0] awlock,
    output [3:0] awcache,
    output [2:0] awprot,
    output awvalid,
    input awready,
    //write data channel
    output [3:0] wid,
    output [31:0] wdata,
    output [3:0] wstrb,
    output wlast,
    output wvalid,
    input wready,
    //write response channel
    input [3:0] bid,
    input [1:0] bresp,
    input bvalid,
    output bready,
    //EJTAG
    input EJTAG_TCK,
    input EJTAG_TDI,
    input EJTAG_TMS,
    input EJTAG_TRST,
    output EJTAG_TDO,
    output prrst_to_core,
    input testmode
);

wire [31:0] debug_wb_pc;
wire [3 :0] debug_wb_rf_wen;
wire [4 :0] debug_wb_rf_wnum;
wire [31:0] debug_wb_rf_wdata;

mycpu_top mycpu(
    .ext_int({1'b0,interrupt_i}),
    .aclk(coreclock),
    .aresetn(areset_n),
     // axi port
    //ar
    .arid(arid),
    .araddr(araddr),
    .arlen(arlen),
    .arsize(arsize),
    .arburst(arburst),
    .arlock(arlock),
    .arcache(arcache),
    .arprot(arprot),
    .arvalid(arvalid),
    .arready(arready),
    //r              
    .rid(rid),
    .rdata(rdata),
    .rresp(rresp),
    .rlast(rlast),
    .rvalid(rvalid),
    .rready(rready),
    //aw           
    .awid(awid),
    .awaddr(awaddr),
    .awlen(awlen),
    .awsize(awsize),
    .awburst(awburst),
    .awlock(awlock),
    .awcache(awcache),
    .awprot(awprot),
    .awvalid(awvalid),
    .awready(awready),
    //w          
    .wid(wid),
    .wdata(wdata),
    .wstrb(wstrb),
    .wlast(wlast),
    .wvalid(wvalid),
    .wready(wready),
    //b              
    .bid(bid),
    .bresp(bresp),
    .bvalid(bvalid),
    .bready(bready),
    //debug signals
    .debug_wb_pc(debug_wb_pc),
    .debug_wb_rf_wen(debug_wb_rf_wen),
    .debug_wb_rf_wnum(debug_wb_rf_wnum),
    .debug_wb_rf_wdata(debug_wb_rf_wdata)
);

endmodule