module d_sram2sram_like (
    input logic         clk_i,
    input logic         rst_i,
    // cpu side input
    input logic         cpu_ram_ce_i,
    input logic [31:0]  cpu_ram_addr_i,
    input logic [31:0]  cpu_ram_wdata_i,
    input logic [3:0]   cpu_ram_sel_i,
    input logic         stall_all_i,
    // cpu side output
    output logic        cpu_ram_stall_o,
    output logic [31:0] cpu_ram_data_o,

    
    // sram_like side input 
    input logic [31:0]  cache_data_rdata_i,
    input logic         cache_data_addr_ok_i,
    input logic         cache_data_data_ok_i,

    // sram_like side output 
    output logic        cache_data_req_o,
    output logic        cache_data_wr_o,
    output logic [1:0]  cache_data_size_o,
    output logic [31:0] cache_data_addr_o,
    output logic [31:0] cache_data_wdata_o
);

    logic addr_rcv;      //地址握手成功
    logic do_finish;     //读事务结束

    // 记录地址是否握手成功
    // 当且仅当在地址确认成功，并且没有获取到数据时为1
    always @(posedge clk_i) begin
        addr_rcv <= rst_i               ? 1'b0 :
                    (cache_data_req_o & cache_data_addr_ok_i & ~cache_data_data_ok_i) ? 1'b1 :
                    cache_data_data_ok_i  ? 1'b0 : addr_rcv;
    end
    
    // 记录当前是否获取到了数据
    // 如果当前从sramlike获取到了数据则置为1，如果当前在全局stall中，则将状态锁存
    always @(posedge clk_i) begin
        do_finish <= rst_i              ? 1'b0 :
                     cache_data_data_ok_i ? 1'b1 :
                     ~stall_all_i       ? 1'b0 : do_finish;
    end

    // 记录获取到的数据
    // 同样是为了锁存，仅在rst或是获取到新的数据时刷新
    logic [31:0] data_rdata_save;
    always @(posedge clk_i) begin
        data_rdata_save <= rst_i                ? 32'b0             :
                           cache_data_data_ok_i   ? cache_data_rdata_i  : data_rdata_save;
    end
    

    //sram like
    assign cache_data_req_o   = cpu_ram_ce_i & ~addr_rcv & ~do_finish;
    assign cache_data_wr_o    = cpu_ram_ce_i & (|cpu_ram_sel_i);
    assign cache_data_size_o  =   (cpu_ram_sel_i==4'b0001 || cpu_ram_sel_i==4'b0010 ||
                                 cpu_ram_sel_i==4'b0100 || cpu_ram_sel_i==4'b1000)  ? 2'b00 :
                                (cpu_ram_sel_i==4'b0011 || cpu_ram_sel_i==4'b1100 ) ? 2'b01 : 2'b10;
    assign cache_data_addr_o  = cpu_ram_addr_i;
    assign cache_data_wdata_o = cpu_ram_wdata_i;

    //sram
    assign cpu_ram_data_o   = data_rdata_save;
    assign cpu_ram_stall_o  = cpu_ram_ce_i & ~do_finish;
    
endmodule