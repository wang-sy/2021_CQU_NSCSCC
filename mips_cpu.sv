module mycpu_top (
    
    input [5:0] ext_int,   //high active  //input

    input wire aclk,    
    input wire aresetn,   //low active

    // axi interface
    output wire[3:0] arid,
    output wire[31:0] araddr,
    output wire[7:0] arlen,
    output wire[2:0] arsize,
    output wire[1:0] arburst,
    output wire[1:0] arlock,
    output wire[3:0] arcache,
    output wire[2:0] arprot,
    output wire arvalid,
    input wire arready,
                
    input wire[3:0] rid,
    input wire[31:0] rdata,
    input wire[1:0] rresp,
    input wire rlast,
    input wire rvalid,
    output wire rready, 
               
    output wire[3:0] awid,
    output wire[31:0] awaddr,
    output wire[7:0] awlen,
    output wire[2:0] awsize,
    output wire[1:0] awburst,
    output wire[1:0] awlock,
    output wire[3:0] awcache,
    output wire[2:0] awprot,
    output wire awvalid,
    input wire awready,
    
    output wire[3:0] wid,
    output wire[31:0] wdata,
    output wire[3:0] wstrb,
    output wire wlast,
    output wire wvalid,
    input wire wready,
    
    input wire[3:0] bid,
    input wire[1:0] bresp,
    input bvalid,
    output bready,

    //debug interface
    output wire[31:0]   debug_wb_pc,
    output wire[3:0]    debug_wb_rf_wen,
    output wire[4:0]    debug_wb_rf_wnum,
    output wire[31:0]   debug_wb_rf_wdata

    /*
    input   logic           rst_i,
    input   logic           clk_i,
    input   logic  [5:0]    int_i*/ 
    // old local version
);


    wire rst_i = ~aresetn;
    logic           time_int;

    // cache io sign
    logic           stall_all;

    logic [31:0]    cpu_rom_addr;
    logic           cpu_rom_ce;
    logic           cpu_rom_stall;
    logic [31:0]    cpu_rom_data;
    logic [31:0]    cache_inst_rdata;
    logic           cache_inst_addr_ok;
    logic           cache_inst_data_ok;
    logic           cache_inst_req;
    logic           cache_inst_wr;
    logic [1:0]     cache_inst_size;
    logic [31:0]    cache_inst_addr;
    logic [31:0]    cache_inst_wdata;

    logic           cpu_ram_ce;
    logic [31:0]    cpu_ram_addr;
    logic [31:0]    cpu_ram_wdata;
    logic [3:0]     cpu_ram_sel;
    logic           cpu_ram_stall;
    logic [31:0]    cpu_ram_data;
    logic [31:0]    cache_data_rdata;
    logic           cache_data_addr_ok;
    logic           cache_data_data_ok;
    logic           cache_data_req;
    logic           cache_data_wr;
    logic [1:0]     cache_data_size;
    logic [31:0]    cache_data_addr;
    logic [31:0]    cache_data_wdata;

    logic           cache_inst_req_to_axi_interface;
    logic           cache_inst_wr_to_axi_interface;
    logic [1 :0]    cache_inst_size_to_axi_interface;
    logic [31:0]    cache_inst_addr_to_axi_interface;
    logic [31:0]    cache_inst_wdata_to_axi_interface;
    logic [31:0]    cache_inst_rdata_to_axi_interface;
    logic           cache_inst_addr_ok_to_axi_interface;
    logic           cache_inst_data_ok_to_axi_interface;
    logic           cache_data_req_to_axi_interface;
    logic           cache_data_wr_to_axi_interface;
    logic [1 :0]    cache_data_size_to_axi_interface;
    logic [31:0]    cache_data_addr_to_axi_interface;
    logic [31:0]    cache_data_wdata_to_axi_interface;
    logic [31:0]    cache_data_rdata_to_axi_interface;
    logic           cache_data_addr_ok_to_axi_interface;
    logic           cache_data_data_ok_to_axi_interface;

    logic           cpu_flush;

    datapath my_datapath(
        .rst_i(rst_i),
        .clk_i(aclk),
        .rom_data_i(cpu_rom_data),
        .ram_data_i(cpu_ram_data),
        .int_i(ext_int),
        .inst_stall_i(cpu_rom_stall),
        .data_stall_i(cpu_ram_stall),
        .time_int_o(time_int),
        .rom_ce_o(cpu_rom_ce),
        .rom_addr_o(cpu_rom_addr),
        .ram_wdata_o(cpu_ram_wdata),
        .ram_addr_o(cpu_ram_addr),
        .ram_sel_o(cpu_ram_sel),
        .ram_we_o(cpu_ram_we),
        .ram_ce_o(cpu_ram_ce),
        .stall_all_o(stall_all),
        .cpu_flush_o(cpu_flush),
        .debug_wb_pc(debug_wb_pc),
        .debug_wb_rf_wen(debug_wb_rf_wen),
        .debug_wb_rf_wnum(debug_wb_rf_wnum),
        .debug_wb_rf_wdata(debug_wb_rf_wdata)
    );

    // 使用写好的 sram2sram_like桥，将数据通路(datapath)与cache连通

    i_sram2sram_like top_i_sram2sram_like(
        .clk_i(aclk),
        .rst_i(rst_i),
        .cpu_rom_addr_i(cpu_rom_addr),
        .cpu_rom_ce_i(cpu_rom_ce),
        .stall_all_i(stall_all),
        .cpu_rom_stall_o(cpu_rom_stall),
        .cpu_rom_data_o(cpu_rom_data),
        .cache_inst_rdata_i(cache_inst_rdata),
        .cache_inst_addr_ok_i(cache_inst_addr_ok),
        .cache_inst_data_ok_i(cache_inst_data_ok),
        .cache_inst_req_o(cache_inst_req),
        .cache_inst_wr_o(cache_inst_wr),
        .cache_inst_size_o(cache_inst_size),
        .cache_inst_addr_o(cache_inst_addr),
        .cache_inst_wdata_o(cache_inst_wdata)
    );

    d_sram2sram_like top_d_sram2sram_like(
        .clk_i(aclk),
        .rst_i(rst_i),
        .cpu_ram_ce_i(cpu_ram_ce),
        .cpu_ram_addr_i(cpu_ram_addr),
        .cpu_ram_wdata_i(cpu_ram_wdata),
        .cpu_ram_sel_i(cpu_ram_sel),
        .stall_all_i(stall_all),
        .cpu_ram_stall_o(cpu_ram_stall),
        .cpu_ram_data_o(cpu_ram_data),
        .cache_data_rdata_i(cache_data_rdata),
        .cache_data_addr_ok_i(cache_data_addr_ok),
        .cache_data_data_ok_i(cache_data_data_ok),
        .cache_data_req_o(cache_data_req),
        .cache_data_wr_o(cache_data_wr),
        .cache_data_size_o(cache_data_size),
        .cache_data_addr_o(cache_data_addr),
        .cache_data_wdata_o(cache_data_wdata)
    );

    // 将桥的信号导入到cache
    // 同时，将cache的信号导入到axi interface上

    cache top_cache(
        .clk(aclk), 
        .rst(rst_i),
        // cpu side 
        .cpu_flush_i        (cpu_flush),
        .cpu_inst_req       (cache_inst_req), // 对于指令的读请求
        .cpu_inst_wr        (cache_inst_wr), // 对于指令的写请求
        .cpu_inst_size      (cache_inst_size), // 请求的指令大小
        .cpu_inst_addr      (cache_inst_addr), // 请求的地址
        .cpu_inst_wdata     (cache_inst_wdata), // 写入的数据
        // cpu side data
        .cpu_inst_rdata     (cache_inst_rdata), // 读取到的数据
        .cpu_inst_addr_ok   (cache_inst_addr_ok), // 指令的地址ok
        .cpu_inst_data_ok   (cache_inst_data_ok), // 指令的数据ok

        // cpu side io data
        .cpu_data_req       (cache_data_req),
        .cpu_data_wr        (cache_data_wr),
        .cpu_data_size      (cache_data_size),
        .cpu_data_addr      (cache_data_addr),
        .cpu_data_wdata     (cache_data_wdata),
        .cpu_data_wen       (cpu_ram_sel),
        // cpu side read dada
        .cpu_data_rdata     (cache_data_rdata),
        .cpu_data_addr_ok   (cache_data_addr_ok),
        .cpu_data_data_ok   (cache_data_data_ok),

        //axi interface
        .cache_inst_req(cache_inst_req_to_axi_interface),
        .cache_inst_wr(cache_inst_wr_to_axi_interface),
        .cache_inst_size(cache_inst_size_to_axi_interface),
        .cache_inst_addr(cache_inst_addr_to_axi_interface),
        .cache_inst_wdata(cache_inst_wdata_to_axi_interface),
        .cache_inst_rdata(cache_inst_rdata_to_axi_interface),
        .cache_inst_addr_ok(cache_inst_addr_ok_to_axi_interface),
        .cache_inst_data_ok(cache_inst_data_ok_to_axi_interface),

        .cache_data_req(cache_data_req_to_axi_interface),
        .cache_data_wr(cache_data_wr_to_axi_interface),
        .cache_data_size(cache_data_size_to_axi_interface),
        .cache_data_addr(cache_data_addr_to_axi_interface),
        .cache_data_wdata(cache_data_wdata_to_axi_interface),
        .cache_data_rdata(cache_data_rdata_to_axi_interface),
        .cache_data_addr_ok(cache_data_addr_ok_to_axi_interface),
        .cache_data_data_ok(cache_data_data_ok_to_axi_interface)
    );


    cpu_axi_interface top_cpu_axi_interface(
        .clk(aclk),
        .resetn(aresetn),
        //inst sram-like 
        .inst_req(cache_inst_req_to_axi_interface),
        .inst_wr(cache_inst_wr_to_axi_interface),
        .inst_size(cache_inst_size_to_axi_interface),
        .inst_addr(cache_inst_addr_to_axi_interface),
        .inst_wdata(cache_inst_wdata_to_axi_interface),
        .inst_rdata(cache_inst_rdata_to_axi_interface),
        .inst_addr_ok(cache_inst_addr_ok_to_axi_interface),
        .inst_data_ok(cache_inst_data_ok_to_axi_interface),
        //data sram-like 
        .data_req(cache_data_req_to_axi_interface),
        .data_wr(cache_data_wr_to_axi_interface),
        .data_size(cache_data_size_to_axi_interface),
        .data_addr(cache_data_addr_to_axi_interface),
        .data_wdata(cache_data_wdata_to_axi_interface),
        .data_rdata(cache_data_rdata_to_axi_interface),
        .data_addr_ok(cache_data_addr_ok_to_axi_interface),
        .data_data_ok(cache_data_data_ok_to_axi_interface),

        // axi 
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
        .rid(rid),
        .rdata(rdata),
        .rresp(rresp),
        .rlast(rlast),
        .rvalid(rvalid),
        .rready(rready),
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
        .wid(wid),
        .wdata(wdata),
        .wstrb(wstrb),
        .wlast(wlast),
        .wvalid(wvalid),
        .wready(wready),
        .bid(bid),
        .bresp(bresp),
        .bvalid(bvalid),
        .bready(bready)
    );

endmodule