module div_ip(
        input logic clk, rst, signed_div,
        input logic [31:0]  a, b,
        input logic         ena,
        output logic [63:0] res,
        output logic        ready
        );
    reg [3:0] cnt = 4'b1111;

    wire [31:0] a_s2u = signed_div ? (a[31] ? {~(a[31:0] - 1)} : a) : a;
    wire [31:0] b_s2u = signed_div ? (b[31] ? {~(b[31:0] - 1)} : b) : b;

    wire quotient_neg = ~(a[31] == b[31]);
    wire remainder_neg = a[31];

    wire s_valid_o;
    wire u_valid_o;

    wire [63:0] u_res;

    // If datapath pipeline is stalled, the signed_div should be unchanged.
    assign res = signed_div ?   {remainder_neg  ? (~u_res[31:0]) + 1 : u_res[31:0], 
                                quotient_neg  ? (~u_res[63:32]) + 1 : u_res[63:32]} 
                                : {u_res[31:0], u_res[63:32]};

    // Whether the multiplication is finished.
    always @(posedge clk, posedge rst) begin
        if (rst | ~ena) begin
            cnt <= 0;
            ready <= 0;
        end
        else if (cnt == 4'b1111) begin
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
    //  IP Type:            Divider Generator           //
    //  Instance Name:      unsigned_divd               //
    //  Algorithm Type:     Radix 2                     //
    //  Oprand Sign:        unsigned                    //
    //  Dividend Width:     32                          // 
    //  Divisor  Width:     32                          //
    //  Output Channel:     Remainder                   //
    //  Fractional Width:   32                          //
    //  Clocks per Division:1                           //
    //  Latency Config:     Manual                      //
    //  Latency:            16                          //
    //  ACLKEN:             YES                         //
    //  ARESETN:            YES                         //
    //////////////////////////////////////////////////////

    unsigned_divd alu_unsigned_divd (
        .aclk(clk),                             // input wire aclk
        .aclken(ena),                           // input wire aclken
        .aresetn(~rst),                         // input wire aresetn
        .s_axis_divisor_tvalid(ena),          // input wire s_axis_divisor_tvalid
        .s_axis_divisor_tdata(b_s2u),               // input wire [31 : 0] s_axis_divisor_tdata
        .s_axis_dividend_tvalid(ena),         // input wire s_axis_dividend_tvalid
        .s_axis_dividend_tdata(a_s2u),              // input wire [31 : 0] s_axis_dividend_tdata
        .m_axis_dout_tvalid(u_valid_o),         // output wire m_axis_dout_tvalid
        .m_axis_dout_tdata(u_res)               // output wire [63 : 0] m_axis_dout_tdata
    );


endmodule
