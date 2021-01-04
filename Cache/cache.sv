module cache (
    input wire clk, rst,
    //mips core
    input         cpu_inst_req     ,
    input         cpu_inst_wr      ,
    input  [1 :0] cpu_inst_size    ,
    input  [31:0] cpu_inst_addr    ,
    input  [31:0] cpu_inst_wdata   ,
    output [31:0] cpu_inst_rdata   ,
    output        cpu_inst_addr_ok ,
    output        cpu_inst_data_ok ,

    input         cpu_data_req     ,
    input         cpu_data_wr      ,
    input  [1 :0] cpu_data_size    ,
    input  [31:0] cpu_data_addr    ,
    input  [31:0] cpu_data_wdata   ,
    output [31:0] cpu_data_rdata   ,
    output        cpu_data_addr_ok ,
    output        cpu_data_data_ok ,

    //axi interface
    output         cache_inst_req     ,
    output         cache_inst_wr      ,
    output  [1 :0] cache_inst_size    ,
    output  [31:0] cache_inst_addr    ,
    output  [31:0] cache_inst_wdata   ,
    input   [31:0] cache_inst_rdata   ,
    input          cache_inst_addr_ok ,
    input          cache_inst_data_ok ,

    output         cache_data_req     ,
    output         cache_data_wr      ,
    output  [1 :0] cache_data_size    ,
    output  [31:0] cache_data_addr    ,
    output  [31:0] cache_data_wdata   ,
    input   [31:0] cache_data_rdata   ,
    input          cache_data_addr_ok ,
    input          cache_data_data_ok
);

    i_cache i_cache(
        .clk(clk), .rst(rst),
        .cpu_inst_req     (cpu_inst_req     ),
        .cpu_inst_wr      (cpu_inst_wr      ),
        .cpu_inst_size    (cpu_inst_size    ),
        .cpu_inst_addr    (cpu_inst_addr    ),
        .cpu_inst_wdata   (cpu_inst_wdata   ),
        .cpu_inst_rdata   (cpu_inst_rdata   ),
        .cpu_inst_addr_ok (cpu_inst_addr_ok ),
        .cpu_inst_data_ok (cpu_inst_data_ok ),

        .cache_inst_req     (cache_inst_req     ),
        .cache_inst_wr      (cache_inst_wr      ),
        .cache_inst_size    (cache_inst_size    ),
        .cache_inst_addr    (cache_inst_addr    ),
        .cache_inst_wdata   (cache_inst_wdata   ),
        .cache_inst_rdata   (cache_inst_rdata   ),
        .cache_inst_addr_ok (cache_inst_addr_ok ),
        .cache_inst_data_ok (cache_inst_data_ok )
    );

    /*
    module d_cache (
    input wire clk, rst,
    //mips core
    input         cpu_data_req     , // CPU 是否正在请求
    input         cpu_data_wr      , // CPU 正在请求写入吗，如果1那么写入
    input  [1 :0] cpu_data_size    , // datasize
    input  [31:0] cpu_data_addr    , // goal_addr
    input  [31:0] cpu_data_wdata   , // write in data
    output [31:0] cpu_data_rdata   , // 返回的数据
    output        cpu_data_addr_ok , // 返回的使能信号，如果是1，则代表请求的地址有效
    output        cpu_data_data_ok , // 返回的使能信号，如果是1，则代表请求的操作已经完成

    //axi interface
    output         cache_data_req     , // 是否发出请求
    output         cache_data_wr      , // 是否需要写
    output  [1 :0] cache_data_size    , // 写的大小
    output  [31:0] cache_data_addr    , // 目标地址
    output  [31:0] cache_data_wdata   , // 写入的数据
    input   [31:0] cache_data_rdata   , // 输入，axibridge 返回的数据
    input          cache_data_addr_ok , // 输出的地址是否有效
    input          cache_data_data_ok   // 读写操作是否完成
);
    */

    wire d_cache_ok;
    assign {cpu_data_addr_ok, cpu_data_data_ok} = {d_cache_ok, d_cache_ok};

    wire [3:0]d_cache_in_wen;
    wire [3:0]d_cache_out_wen;

    d_cache m_d_cache(
        .p_a(cpu_data_addr), // 地址
        .p_dout(cpu_data_wdata), // 写入的数据
        .p_din(cpu_data_rdata), // 读取到的数据
        .p_strobe(cpu_data_req), // 是否发出请求
        .p_wen(d_cache_in_wen), // wen
        .p_size(cpu_data_size), // size 
        .p_rw(cpu_data_wr), // 是否是写
        .p_ready(d_cache_ok), // 是否完成
        .clk(clk), 
        .clrn(~rst),
        .m_a(cache_data_addr),  // 操作的地址
        .m_dout(cache_data_rdata), // 读取的数据
        .m_din(cache_data_wdata), // 写入的数据
        .m_strobe(cache_data_req), // 是否向内存发出请求
        .m_wen(d_cache_out_wen), // wen
        .m_size(cache_data_size), // 操作的大小
        .m_rw(cache_data_wr), // 是否是写请求
        .m_ready(cache_data_data_ok) // 内存是否ok
    );

endmodule