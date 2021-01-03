`include "defines.vh"

module MyCPU(

	input logic         aclk,
    input logic         aresetn,
	input logic         nmi,
	input logic[5:0]    int_i, //6位硬件中断

///////////////////////////// axi port/////////////////////////////////
// 连接axi_interface
    //ar
    output logic[3:0]   arid,
    output logic[31:0]  araddr,
    output logic[7:0]   arlen,
    output logic[2:0]   arsize,
    output logic[1:0]   arburst,
    output logic[1:0]   arlock,
    output logic[3:0]   arcache,
    output logic[2:0]   arprot,
    output logic        arvalid,
    input  logic        arready,
    //r              
    input  logic[3:0]   rid,
    input  logic[31:0]  rdata,
    input  logic[1:0]   rresp,
    input  logic        rlast,
    input  logic        rvalid,
    output logic        rready,
    //aw           
    output logic[3:0]   awid,
    output logic[31:0]  awaddr,
    output logic[3:0]   awlen,
    output logic[2:0]   awsize,
    output logic[1:0]   awburst,
    output logic[1:0]   awlock,
    output logic[3:0]   awcache,
    output logic[2:0]   awprot,
    output logic        awvalid,
    input  logic        awready,
    //w          
    output logic[3:0]   wid,
    output logic[31:0]  wdata,
    output logic[3:0]   wstrb,
    output logic        wlast,
    output logic        wvalid,
    input  logic        wready,
    //b              
    input  logic[3:0]   bid,
    input  logic[1:0]   bresp,
    input  logic        bvalid,
    output logic        bready,
///////////////////////////// axi port /////////////////////////////////

/////////////////////////// 连接mips_cpu ////////////////////////////////////////
	//debug signals  // Trace文件信号对比
	output logic [31:0] debug_wb_pc,
	output logic [3 :0] debug_wb_rf_wen,
	output logic [4 :0] debug_wb_rf_wnum,
	output logic [31:0] debug_wb_rf_wdata,
/////////////////////////// 连接mips_cpu ////////////////////////////////////////

//////////////////////////// 暂不使用////////////////////////////////////////////
	//EJTAG 
	input logic         EJTAG_TCK,
	input logic         EJTAG_TDI,
	input logic         EJTAG_TMS,
	input logic         EJTAG_TRST,
	input logic         EJTAG_TDO,
	input logic         prrst_to_core,
	input logic         testmode
//////////////////////////// 暂不使用////////////////////////////////////////////

    );

    
    // axi接口
    axi_interface MyCPU_axi_interface(
        .clk               (aclk), 
        .resetn            (aresetn), 

        //inst sram-like 
        .inst_req          (),
        .inst_wr           (),
        .inst_size         (),
        .inst_addr         (),
        .inst_wdata        (),
        .inst_rdata        (),
        .inst_addr_ok      (),
        .inst_data_ok      (),
        
        //data sram-like 
        .data_req          (),
        .data_wr           (),
        .data_wen          (),
        .data_size         (),
        .data_addr         (),
        .data_wdata        (),
        .data_rdata        (),
        .data_addr_ok      (),
        .data_data_ok      (),

///////////////////////////////////axi///////////////////////////////////
        //ar        
        .arid               (arid),
        .araddr             (araddr),
        .arlen              (arlen),
        .arsize             (arsize),
        .arburst            (arburst),
        .arlock             (arlock),
        .arcache            (arcache),
        .arprot             (arprot),
        .arvalid            (arvalid),
        .arready            (arready),

        .rid                (rid),
        .rdata              (rdata),
        .rresp              (rresp),
        .rlast              (rlast),
        .rvalid             (rvalid),
        .rready             (rready),

        .awid               (awid),
        .awaddr             (awaddr),
        .awlen              (awlen),
        .awsize             (awsize),
        .awburst            (awburst),
        .awlock             (awlock),
        .awcache            (awcache),
        .awprot             (awprot),
        .awvalid            (awvalid),
        .awready            (awready),

        .wid                (wid),
        .wdata              (wdata),
        .wstrb              (wstrb),
        .wlast              (wlast),
        .wvalid             (wvalid),
        .wready             (wready),
                
        .bid                (bid),
        .bresp              (bresp),
        .bvalid             (bvalid),
        .bready             (bready)
///////////////////////////////////axi///////////////////////////////////
	);

    	d_confreg_port d_confreg_port(
            //cpu side
            .clk 			(),
            .rst 			(),
            .memwriteM 		(),
            .sel 			(),
            .data_sram_size (),
            .aluoutM 		(),
            .writedata2M 	(),
            .memenM 		(),
            .readdataM 		(),

            //mem side
            .data_req       (),
            .data_wr        (),
            .data_wen       (),
            .data_size      (),
            .data_addr      (),
            .data_wdata     (),
            .data_rdata     (),
            .data_addr_ok   (),
            .data_data_ok   ()
		);
endmodule