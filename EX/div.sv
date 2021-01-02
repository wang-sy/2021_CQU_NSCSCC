module nt(input [95:0] x0, input [31:0] num,
          output reg [191:0] x1, output reg ready);
   always @(*) begin
      ready = 0;
      x1 = (x0 * ((2 << 96) - num * x0)) >> 96;
      ready = 1;
   end
endmodule // nt
module div(
         input clk, rst, signed_div,
         input [31:0]      a, b,
         input             start, annul,
         output reg [63:0] result,
         output reg        ready
      );

   parameter coef = 33'h1e1e1e1e1,
     incept = 66'h2d2d2d2d2d2d2e000;

   reg [31:0]                num1, num2;

   reg [127:0]               lr;
   wire [191:0]              lr_temp;

   integer                   i;
   parameter nt_it_total = 4, align_it_total = 4;
   reg [2:0]                 nt_it, align_it;

   parameter S_START = 0,
     S_APPROX = 1,
     S_NT = 2,
     S_MULT = 3,
     S_RESULT = 4,
     S_READY = 5,
     S_ALIGN = 6;

   reg [3:0]                 state;

   reg [31:0]                nnum2;
   reg [5:0]                 nnum2_exp;
 //lr为96位，端口为128位 看见了改一下
   nt nt_iterator(lr, nnum2, lr_temp, lr_ready);

   always @(posedge clk, posedge rst) begin
      if (rst) begin
         state <= S_START;
         ready <= 0;
         nt_it <= 0;
         align_it <= 0;
      end else
        case (state)
          S_START: begin
             if (start) begin
                ready <= 0;
                nt_it <= 0;
                align_it <= 0;
                if (signed_div && a[31] == 1'b1)
                  num1 <= ~a + 1;
                else
                  num1 <= a;

                if (signed_div && b[31] == 1'b1)
                  num2 = ~b + 1;
                else
                  num2 = b;
                nnum2_exp <= 32;
                nnum2 <= num2;
             end
             state <= start ? S_ALIGN : S_START;
          end
          S_ALIGN: begin
             for (i = 0; i < 8 && nnum2[31] == 0; i = i + 1) begin
                nnum2_exp = nnum2_exp - 1;
                nnum2 = nnum2 << 1;
             end
             align_it = align_it + 1;
             if (nnum2[31] != 0 || align_it == 4)
               state <= annul ? S_START : S_APPROX;
             else
               state <= annul ? S_START : S_ALIGN;
          end
          S_APPROX: begin
             lr <= incept - coef * nnum2;
             state <= annul ? S_START : S_NT;
          end
          S_NT: begin
             state <= annul ? S_START : S_NT;
             if (lr_ready) begin
                lr <= lr_temp;
                nt_it = nt_it + 1;
                if (nt_it == nt_it_total)
                  state <= annul ? S_START : S_MULT;
             end
          end
          S_MULT: begin
             lr <= num1 * lr;
             state <= annul ? S_START : S_RESULT;
          end
          S_RESULT: begin
             result = 0;
             if (signed_div && a[31] != b[31])
               result[31:0] = ~((lr >> 64) >> nnum2_exp) + 1;
             else
               result[31:0] = (lr >> 64) >> nnum2_exp;

             if (signed_div)
               result[63:32] = $signed(a) - $signed(b) * $signed(result[31:0]);
             else
               result[63:32] = a - b * result[31:0];

             if (signed_div ?
                 ($signed(result[63:32]) >= $signed(num2)) :
                 (result[63:32] >= num2)) begin
                result[31:0] <= result[31:0] + 1;
                result[63:32] <= result[63:32] - b;
             end
             state <= annul ? S_START : S_READY;
          end
          S_READY: begin
             ready <= 1;
             if (!start) begin
                state <= S_START;
                ready <= 0;
             end
          end
          default: state <= S_START;
        endcase
   end

endmodule