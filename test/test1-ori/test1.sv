module test1 ();
    
    logic           rst_i;
    logic           clk_i;
    logic           int_i;

    mips_cpu my_cpu(
        .rst_i(rst_i),
        .clk_i(clk_i),
        .int_i(int_i)
    );

    initial begin
        rst_i = 1'b1;
        clk_i = 1'b0;
        int_i = 1'b0;
        # 47 rst_i = 1'b0;
    end
    always #2 clk_i = ~clk_i;
endmodule