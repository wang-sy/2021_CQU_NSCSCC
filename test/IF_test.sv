module IF_test ();
    reg         rst_i;
    reg         clk_i;
    reg [31:0]  rom_data_i;
    reg [31:0]  ram_data_i;
    reg         int_i;
    reg         time_int_o;
    reg         rom_ce_o;
    reg [31:0]  rom_addr_o;
    reg [31:0]  ram_addr_o;
    reg [3:0]   ram_sel_o;
    reg         ram_we_o;
    reg         ram_ce_o;

    mips_cpu my_cpu(
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

    initial begin
        rst_i = 1'b1;
        clk_i = 1'b1;
        # 50 rst_i = 1'b0;
    end
    always #1 clk_i = ~ clk_i;
    
endmodule