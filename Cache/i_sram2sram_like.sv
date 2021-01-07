module i_sram2sram_like (
    input logic         clk_i,
    input logic         rst_i,
    // cpu side input
    input logic         cpu_flush_i,
    input logic [31:0]  cpu_rom_addr_i,
    input logic         cpu_rom_ce_i,
    input logic         stall_all_i,
    // cpu side output
    output logic        cpu_rom_stall_o,
    output logic [31:0] cpu_rom_data_o,

    
    // sram_like side input 
    input logic [31:0]  cache_inst_rdata_i,
    input logic         cache_inst_addr_ok_i,
    input logic         cache_inst_data_ok_i,

    // sram_like side output 
    output logic        cache_inst_req_o,
    output logic        cache_inst_wr_o,
    output logic [1:0]  cache_inst_size_o,
    output logic [31:0] cache_inst_addr_o,
    output logic [31:0] cache_inst_wdata_o
);
    // 对 flush进行记录，当flush后，不再记录本次的读取结果
    logic is_clear;
    logic addr_rcv;      //地址握手成功
    logic do_finish;     //读事务结束

    
    always @(posedge clk_i) begin
        is_clear <= rst_i ? 1'b1 :
                    cpu_flush_i ? 1'b0 :
                    cache_inst_data_ok_i ? 1'b1 : is_clear;
    end

    // 记录地址是否握手成功
    // 当且仅当在地址确认成功，并且没有获取到数据时为1
    always @(posedge clk_i) begin
        addr_rcv <= rst_i               ? 1'b0 :
                    (cache_inst_req_o & cache_inst_addr_ok_i & ~cache_inst_data_ok_i) ? 1'b1 :
                    cache_inst_data_ok_i  ? 1'b0 : addr_rcv;
    end
    
    // 记录当前是否获取到了数据
    // 如果当前从sramlike获取到了数据则置为1，如果当前在全局stall中，则将状态锁存
    always @(posedge clk_i) begin
        do_finish <= rst_i              ? 1'b0 :
                     (is_clear & cache_inst_rdata_i) ? 1'b0 : // 如果当前不需要被忽略并且获取到了数据，那么就直接返回
                     cpu_flush_i        ? 1'b0 :
                     ~is_clear          ? 1'b0 :
                     cache_inst_data_ok_i ? 1'b1 :
                     ~stall_all_i       ? 1'b0 : do_finish;
    end

    // 记录获取到的数据
    // 同样是为了锁存，仅在rst或是获取到新的数据时刷新
    logic [31:0] inst_rdata_save;
    always @(posedge clk_i) begin
        inst_rdata_save <= rst_i                ? 32'b0             :
                           ~is_clear            ? 1'b0 :
                           cache_inst_data_ok_i   ? cache_inst_rdata_i  : inst_rdata_save;
    end
    

    //sram like
    assign cache_inst_req_o   = cpu_rom_ce_i & ~do_finish;
    assign cache_inst_wr_o    = 1'b0;
    assign cache_inst_size_o  = 2'b10;
    assign cache_inst_addr_o  = cpu_rom_addr_i;
    assign cache_inst_wdata_o = 32'b0;

    // 如果当前不在clear，并且收到了信号，那么就直接将结果进行返回
    //sram
    assign cpu_rom_data_o   = (is_clear & cache_inst_rdata_i) ? cache_inst_rdata_i : inst_rdata_save;
    assign cpu_rom_stall_o  = (is_clear & cache_inst_rdata_i) ? 1'b0 : (cpu_rom_ce_i & ~do_finish & ~cpu_flush_i);
    
endmodule