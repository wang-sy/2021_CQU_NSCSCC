module exception(
	input  logic       rst,
	input  logic [7:0] except,
	input  logic [4:0] tlb_except2M,
	input  logic       Trap,
    input  logic       CpU,
	input  logic       adel,
    input  logic       ades,
	input  logic[31:0] cp0_status,
    input  logic[31:0] cp0_cause,
	output logic[31:0] excepttype
);

assign excepttype = rst==1'b1 ? 32'b0 : 
                    (((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00) &&(cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1))==1'b1 ? 32'h00000001 : 
                    (except[7] == 1'b1 || adel == 1'b1)==1'b1?32'h00000004 :
                    ades==1'b1?32'h00000005 :
                    Trap==1'b1?32'h0000000d :
                    CpU==1'b1?32'h0000000b :
                    tlb_except2M[4] == 1'b1?32'h00000010 :
                    tlb_except2M[3] == 1'b1?32'h00000011 :
                    tlb_except2M[2] == 1'b1?32'h00000012 :
                    tlb_except2M[1] == 1'b1?32'h00000013 :
                    tlb_except2M[0] == 1'b1?32'h00000014 :
                    except[6] == 1'b1?32'h00000008 :
                    except[5] == 1'b1?32'h00000009 :
                    except[4] == 1'b1?32'h0000000e :
                    except[3] == 1'b1?32'h0000000a :
                    except[2] == 1'b1?32'h0000000c : 32'b0;
endmodule

