module mips_cpu (
    input   logic           rst_i,
    input   logic           clk_i,
    input   logic           int_i
);

    
    logic [31:0]    rom_data_i;
    logic [31:0]    ram_data_i;

    logic           time_int_o;
    logic           rom_ce_o;
    logic [31:0]    rom_addr_o;
    logic [31:0]    ram_addr_o;
    logic [3:0]     ram_sel_o;
    logic           ram_we_o;
    logic           ram_ce_o;


    datapath my_datapath(
        .rst_i(rst_i),
        .clk_i(clk_i),
        .rom_data_i(rom_data_i),
        .ram_data_i(ram_data_i),
        .int_i(int_i),
        .time_int_o(time_int_o),
        .rom_ce_o(rom_ce_o),
        .rom_addr_o(rom_addr_o),
        .ram_addr_o(ram_addr_o),
        .ram_sel_o(ram_sel_o),
        .ram_we_o(ram_we_o),
        .ram_ce_o(ram_ce_o)
    );

    inst_ram inst_cache(
        .addra(rom_addr_o),
        .clka(~clk_i),
        .douta(rom_data_i),
        .ena(rom_ce_o)
    );

endmodule