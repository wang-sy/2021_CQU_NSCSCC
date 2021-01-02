module mips_cpu (
    input   logic           rst_i,
    input   logic           clk_i,
    input   logic  [5:0]    int_i
);

    
    logic [31:0]    rom_data;
    logic [31:0]    ram_data;

    logic           time_int;
    logic           rom_ce;
    logic [31:0]    rom_addr;
    logic [31:0]    ram_wdata;
    logic [31:0]    ram_addr;
    logic [3:0]     ram_sel;
    logic           ram_we;
    logic           ram_ce;


    datapath my_datapath(
        .rst_i(rst_i),
        .clk_i(clk_i),
        .rom_data_i(rom_data),
        .ram_data_i(ram_data),
        .int_i(int_i),
        .time_int_o(time_int),
        .rom_ce_o(rom_ce),
        .rom_addr_o(rom_addr),
        .ram_wdata_o(ram_wdata),
        .ram_addr_o(ram_addr),
        .ram_sel_o(ram_sel),
        .ram_we_o(ram_we),
        .ram_ce_o(ram_ce)
    );

    inst_ram inst_cache(
        .addra(rom_addr),
        .clka(~clk_i),
        .douta(rom_data),
        .ena(rom_ce)
    );

    data_mem data_cache(
        .addra(ram_addr),
        .clka(~clk_i),
        .dina(ram_wdata),
        .douta(ram_data),
        .ena(ram_ce),
        .wea(ram_sel)
    );

endmodule