`timescale 1ns / 1ps
`include "defines.h"

// cputop顶层模块
/*
	对于这个模块
	我们将硬件中断进行了处理，我们发现之前学长为了偷懒直接将硬件中断当作六个零传入了（TAT）
	现在我们对他进行了处理，它会被传到datapath进行具体的处理

*/
module mycpu_top(
	input 	wire	[5:0] 	ext_int,
	input 	wire 			aclk,aresetn,
	
	 // axi port
    //ar
    output 	wire	[3:0] 	arid,      	//read request id, fixed 4'b0
    output 	wire	[31:0] 	araddr,   	//read request address
    output 	wire	[7:0] 	arlen,     	//read request transfer length(beats), fixed 4'b0
    output 	wire	[2:0] 	arsize,    	//read request transfer size(bytes per beats)
    output 	wire	[1:0] 	arburst,   	//transfer type, fixed 2'b01
    output 	wire	[1:0] 	arlock,    	//atomic lock, fixed 2'b0
    output 	wire	[3:0] 	arcache,   	//cache property, fixed 4'b0
    output 	wire	[2:0] 	arprot,    	//protect property, fixed 3'b0
    output 	wire	 		arvalid,    //read request address valid
    input 	wire	 		arready,    //slave end ready to receive address transfer
    //r              
    input 	wire	[3:0] 	rid,        //equal to arid, can be ignored
    input 	wire	[31:0] 	rdata,     	//read data
    input 	wire	[1:0] 	rresp,     	//this read request finished successfully, can be ignored
    input 	wire	 		rlast,      //the last beat data for this request, can be ignored
    input 	wire	 		rvalid,     //read data valid
    output 	wire	 		rready,     //master end ready to receive data transfer
    //aw           
    output 	wire	[3:0] 	awid,      	//write request id, fixed 4'b0
    output 	wire	[31:0] 	awaddr,   	//write request address
    output 	wire	[3:0] 	awlen,     	//write request transfer length(beats), fixed 4'b0
    output 	wire	[2:0] 	awsize,    	//write request transfer size(bytes per beats)
    output 	wire	[1:0] 	awburst,   	//transfer type, fixed 2'b01
    output 	wire	[1:0] 	awlock,    	//atomic lock, fixed 2'b01
    output 	wire	[3:0] 	awcache,   	//cache property, fixed 4'b01
    output 	wire	[2:0] 	awprot,    	//protect property, fixed 3'b01
    output 	wire	 		awvalid,    //write request address valid
    input 	wire	 		awready,    //slave end ready to receive address transfer
    //w          
    output 	wire	[3:0] 	wid,       	//equal to awid, fixed 4'b0
    output 	wire	[31:0] 	wdata,    	//write data
    output 	wire	[3:0] 	wstrb,     	//write data strobe select bit
    output 	wire	 		wlast,      //the last beat data signal, fixed 1'b1
    output 	wire	 		wvalid,     //write data valid
    input 	wire	 		wready,     //slave end ready to receive data transfer
    //b              
    input  	wire	[3:0]	bid,       	//equal to wid,awid, can be ignored
    input  	wire	[1:0] 	bresp,     	//this write request finished successfully, can be ignored
    input 	wire	 		bvalid,     //write data valid
    output 	wire	 		bready,     //master end ready to receive write response

	//debug signals
	output 	wire	 [31:0] debug_wb_pc,
	output 	wire	 [3 :0] debug_wb_rf_wen,
	output 	wire	 [4 :0] debug_wb_rf_wnum,
	output 	wire	 [31:0] debug_wb_rf_wdata

    );

	//sram signal
	//cpu inst sram
	wire 	       	inst_sram_en;
	wire 	[3 :0] 	inst_sram_wen;
	wire 	[31:0] 	inst_sram_addr;
	wire 	[31:0] 	inst_sram_wdata;
	wire 	[31:0] 	inst_sram_rdata;
	//cpu data sram
	wire 	       	data_sram_en,data_sram_write;
	wire 	[1 :0] 	data_sram_size;
	wire 	[3 :0] 	data_sram_wen;
	wire 	[31:0] 	data_sram_addr;
	wire 	[31:0] 	data_sram_wdata;
	wire 	[31:0] 	data_sram_rdata;

	// the follow definitions are between controller and datapath.
	// also use some of them  link the IPcores
	wire 	rst,clk;
	// fetch stage
	wire	[31:0] 	pcF;
	wire	[31:0] 	instrF;

	// decode stage
	wire 	[31:0] 	instrD;
	wire 			pcsrcD;
	wire 			jumpD;
	wire 			jalD;
	wire 			jrD;
	wire 			balD;
	wire 			jalrD;
	wire 			branchD;
	wire 			equalD;
	wire 			invalidD;
	wire 	[1:0] 	hilo_weD;
	wire 	[4:0] 	alucontrolD;
	wire            stallD;

	// execute stage
	wire 			regdstE;
	wire 			alusrcE;
	wire 			memtoregE;
	wire 			regwriteE;
	wire 			flushE;
	wire 			stallE;

	// mem stage
	wire 			memwriteM;
	wire 			memenM;
	wire	[31:0] 	aluoutM;
	wire 	[31:0]	writedata2M;
	wire 	[31:0]	excepttypeM;
	wire 			cp0weM;
	wire	[31:0] 	readdataM;
	wire 	[3:0] 	sel;
	wire 			memtoregM;
	wire			regwriteM;
	wire 			stallM;
	wire			flushM;

	// writeback stage
	wire 			memtoregW;
	wire 			regwriteW;
	wire 	[31:0] 	pcW;
	wire 	[4:0] 	writeregW;
	wire 	[31:0] 	resultW;
	wire 			flushW;


	//cache mux signal
	wire 			cache_miss;
	wire 			sel_i;
	wire	[31:0] 	i_addr;
	wire 	[31:0]	d_addr;
	wire 	[31:0]	m_addr;
	wire 			m_fetch;
	wire 			m_ld_st;
	wire 			mem_access;
	wire 			mem_write;
	wire 			m_st;
	wire 			mem_ready;
	wire 			m_i_ready;
	wire 			m_d_ready;
	wire 			i_ready;
	wire 			d_ready;
	wire	[31:0] 	mem_st_data;
	wire 	[31:0]	mem_data;
	wire	[1:0] 	mem_size;
	wire 	[1:0] 	d_size;// size not use
	wire	[3:0] 	m_sel,d_wen;
	wire 			stallreq_from_if;
	wire 			stallreq_from_mem;



	// inst_sram_parameters
	assign 	rst 				= aresetn;
	assign 	clk 				= aclk;
	assign 	inst_sram_en 		= 1'b1;
	assign 	inst_sram_wen 		= 4'b0;
	assign 	inst_sram_addr 		= pcF;
	assign 	inst_sram_wdata 	= 32'b0;
	assign 	instrF 				= inst_sram_rdata;

	//data_sram_parameters
	assign 	data_sram_en		= memenM & ~(|excepttypeM);
	assign 	data_sram_write 	= memwriteM;
	assign 	data_sram_wen 		= sel;
	assign 	data_sram_addr 		= aluoutM;
	assign 	data_sram_wdata 	= writedata2M;
	assign 	readdataM 			= data_sram_rdata;

	//trace parameters
	assign 	debug_wb_pc 		= pcW;
	assign 	debug_wb_rf_wen 	= {4{regwriteW}};// the soft interrupt need to be solved 
	assign 	debug_wb_rf_wnum 	= writeregW;
	assign 	debug_wb_rf_wdata 	= resultW;

	datapath dp(
		.clk				(clk),
		.rst				(~rst),
		.if_pc				(pcF),
		.if_instr				(instrF),
		.id_equal				(equalD),
		.id_stall				(stallD),
		.id_instr				(instrD),
		.ex_flush				(flushE),
		.ex_stall				(stallE),
		.mem_wdata			(aluoutM),
		.mem_wdata_last		(writedata2M),
		.mem_size				(data_sram_size),
		.mem_rdata			(readdataM),
		.sel				(sel),
		.mem_stall				(stallM),
		.mem_flush				(flushM),
		.mem_excepttype		(excepttypeM),
		.wb_pc				(pcW),
		.wb_regdst			(writeregW),
		.wb_wdata			(resultW),
		.wb_flush				(flushW),
		.stallreq_from_if	(stallreq_from_if),
		.stallreq_from_mem	(stallreq_from_mem),
		
		.mem_we			(memwriteM),// mips使用
		.mem_en				(memenM)// mips使用
	);
	

	i_cache i_cache(
		// cpu 端交互信号
		.p_flush			(|excepttypeM),
        .p_a				(inst_sram_addr),
        .p_din				(inst_sram_rdata),
        .p_strobe			(inst_sram_en),
        .p_ready			(i_ready),
		.cache_miss			(cache_miss),
		// 内存端交互信号
        .clk				(aclk),
		.clrn				(aresetn),
        .m_a				(i_addr),
        .m_dout				(mem_data),
        .m_strobe			(m_fetch),
        .m_ready			(m_i_ready)
		
    );

	d_cache d_cache(
		// cpu 端交互信号
        .p_a				(data_sram_addr),
        .p_dout				(data_sram_wdata),
        .p_din				(data_sram_rdata),
        .p_strobe			(data_sram_en),
		.p_wen				(data_sram_wen),
		.p_size				(data_sram_size),
        .p_rw				(data_sram_write), //0: read, 1:write
        .p_ready			(d_ready),
		// 内存端交互信号
        .clk				(aclk),
		.clrn				(aresetn),
        .m_a				(d_addr),
        .m_dout				(mem_data),
        .m_din				(mem_st_data),
        .m_strobe			(m_ld_st),
		.m_wen				(d_wen),
		.m_size				(d_size),
        .m_rw				(m_st),
        .m_ready			(m_d_ready)
    );

	
	// cache的选择部分
	// 存在的原因： axi_interface一次只能读写地方
	// 执行逻辑：	i_cache优先原则
	assign sel_i 				= cache_miss;
	assign m_addr 				= sel_i ? i_addr : d_addr;
	assign mem_access 			= sel_i ? m_fetch : m_ld_st;
	assign mem_size 			= sel_i ? 2'b10 : d_size;
	assign m_sel 				= sel_i ? 4'b1111 : d_wen;
	assign mem_write 			= sel_i ? 1'b0 : m_st;

	//demux
	assign m_i_ready 			= mem_ready & sel_i;
	assign m_d_ready 			= mem_ready & ~sel_i;
	
	assign stallreq_from_if 	= ~i_ready;
	assign stallreq_from_mem	= data_sram_en & ~d_ready;

	axi_interface interface(
		.clk				(aclk),
		.resetn				(aresetn),
		
		 //cache port
		.mem_a				(m_addr),
		.mem_access			(mem_access),
		.mem_write			(mem_write),
		.mem_size			(mem_size),
		.mem_sel			(m_sel),
		.mem_ready			(mem_ready),
		.mem_st_data		(mem_st_data),
		.mem_data			(mem_data),

		.arid      			(arid      ),
		.araddr    			(araddr    ),
		.arlen     			(arlen     ),
		.arsize    			(arsize    ),
		.arburst   			(arburst   ),
		.arlock    			(arlock    ),
		.arcache   			(arcache   ),
		.arprot    			(arprot    ),
		.arvalid   			(arvalid   ),
		.arready   			(arready   ),
					
		.rid       			(rid       ),
		.rdata     			(rdata     ),
		.rresp     			(rresp     ),
		.rlast     			(rlast     ),
		.rvalid    			(rvalid    ),
		.rready    			(rready    ),
				
		.awid      			(awid      ),
		.awaddr    			(awaddr    ),
		.awlen     			(awlen     ),
		.awsize    			(awsize    ),
		.awburst   			(awburst   ),
		.awlock    			(awlock    ),
		.awcache   			(awcache   ),
		.awprot    			(awprot    ),
		.awvalid   			(awvalid   ),
		.awready   			(awready   ),
		
		.wid       			(wid       ),
		.wdata     			(wdata     ),
		.wstrb     			(wstrb     ),
		.wlast     			(wlast     ),
		.wvalid    			(wvalid    ),
		.wready    			(wready    ),
		
		.bid       			(bid       ),
		.bresp     			(bresp     ),
		.bvalid    			(bvalid    ),
		.bready    			(bready    )
	);
endmodule
