module mul_ip(
    input logic clk, rst, signed_mul,
    input logic [31:0]  a, b,
    input logic         ena,
    output logic [63:0] res,
    output logic        ready
);
    reg [2:0] cnt = 3'b100;

    wire [31:0] a_s2u = signed_mul ? (a[31] ? {~(a[31:0] - 1)} : a) : a;
    wire [31:0] b_s2u = signed_mul ? (b[31] ? {~(b[31:0] - 1)} : b) : b;

    wire neg = ~(a[31] == b[31]);

    wire [63:0] u_res;

    // If datapath pipeline is stalled, the signed_mul should be unchanged.
    assign res = (signed_mul & neg) ? ((~u_res[63:0]) + 1) : u_res;
    // Whether the multiplication is finished.
    always @(posedge clk, posedge rst) begin
        if (rst | ~ena) begin
            cnt <= 0;
            ready <= 0;
        end
        else if (cnt == 3'b100) begin
            cnt <= 0;
            ready <= 1;
        end
        else if (ena) begin
            cnt <= cnt + 1;
            ready <= 0;
        end 
        else begin
            cnt <= cnt;
            ready <= ready;
        end
    end
    //////////////////////////////////////////////////////
    //  IP Type:            Multiplier                  //
    //  Instance Name:      unsigned_mult               //
    //  Multiplier Type:    Parallel Multiplier         //
    //  A Oprand Sign:      unsigned                    //
    //  A Oprand Width:     32                          // 
    //  B Oprand Sign:      unsigned                    //
    //  B Oprand Width:     32                          // 
    //  Pipeline Stage:     5                           //
    //  Clock Enable:       YES                         //
    //  Synchronous Clear:  YES                         //
    //////////////////////////////////////////////////////
    unsigned_mult alu_unsigned_mult(
            .CLK(clk),
            .A(a_s2u),
            .B(b_s2u),
            .CE(ena),
            .SCLR(rst),
            .P(u_res)
    );

endmodule