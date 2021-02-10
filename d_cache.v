`timescale 1ns / 1ps


module d_cache #(parameter A_WIDTH = 32,
    parameter C_INDEX = 6)(
        input wire[A_WIDTH-1:0] p_a,
        input wire[31:0] p_dout,
        output wire[31:0] p_din,
        input wire p_strobe,
        input wire[3:0] p_wen,
		input wire[1:0] p_size,
        input wire p_rw, //0: read, 1:write
        output wire p_ready,
        // output wire cache_miss,
        input wire clk,clrn,
        output wire[A_WIDTH-1:0] m_a,
        input wire[31:0] m_dout,
        output wire[31:0] m_din,
        output wire m_strobe,
        output wire[3:0] m_wen,
		output wire[1:0] m_size,
        output wire m_rw,
        input wire m_ready
    );
  
    wire flag;
    assign flag =  (aluoutM[31:16] == 16'hbfaf) ? 1'b1 : 1'b0;
    

    wire                memwriteM;          //p_rw
    wire [3:0]          sel;                //p_wen
    wire [1:0]    data_sram_size;     //P_size
    wire [31:0]   aluoutM;            //p_a
    wire [31:0]   writedata2M;        //p_dout
    wire          memenM;            //p_strobe
    wire [31:0]  readdataM;          //p_din
    wire              cache_ready;

    assign memwriteM = p_rw;
    assign sel = p_wen;
    assign data_sram_size = p_size;
    assign aluoutM = p_a;
    assign writedata2M = p_dout;
    assign memenM = p_strobe;
    assign p_din = flag ? m_dout : readdataM;
    assign p_ready = cache_ready;

    wire rst;
    wire            data_req;
    wire            data_wr;
    wire [3:0]  data_wen;
    wire [1:0]  data_size;
    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire [31:0] data_rdata;
    wire        data_data_ok;

    assign rst = ~clrn;
    assign data_data_ok = m_ready;
    assign data_rdata= m_dout ;
    assign m_a =flag ? {16'h1faf,aluoutM[15:0]} : data_addr;
    assign m_din = flag ? p_dout : data_wdata;
    assign m_strobe = flag ? p_strobe : data_req;
    assign m_wen = flag? p_wen : data_wen;
    assign m_size = flag? p_size: data_size;
    assign m_rw =flag ? p_rw : data_wr;
    assign data_data_ok = m_ready;



    localparam      CPU_EXEC    =   0;
    localparam      WR_DRAM     =   1;
    localparam      RD_DRAM     =   2;

    integer i;

    localparam T_WIDTH = A_WIDTH - C_INDEX -2;  //tag width:
    localparam C_WIDTH = 32 + T_WIDTH + 2;
    //cache interface
    // dram side(write)
    wire                    dram_wr_req;        //  request writing data to dram
    wire        [31:0]      dram_wr_addr;       //  write data address
    wire        [31:0]      dram_wr_data;       //  write data
    wire                    dram_wr_val;        //  write a word valid
    // dram side(read)
    wire                    dram_rd_req;        //  request reading data from dram
    wire        [31:0]      dram_rd_addr;       //  read data address
    wire                    dram_rd_val;    //  read a word valid

    //cache memery
    //reg   [52:0]          D_SRAM[(1<<C_INDEX)-1:0];
    reg                     d_valid [0:(1<<C_INDEX)-1];
    reg                     d_dirty [0:(1<<C_INDEX)-1];
    reg     [T_WIDTH-1:0]   d_tags  [0:(1<<C_INDEX)-1];
    reg     [7:0]           d_data1 [0:(1<<C_INDEX)-1];
    reg     [7:0]           d_data2 [0:(1<<C_INDEX)-1];
    reg     [7:0]           d_data3 [0:(1<<C_INDEX)-1];
    reg     [7:0]           d_data4 [0:(1<<C_INDEX)-1];

    //sign in cache
    reg     [1:0]           state;                      // FSM
    //wire  [C_WIDTH-1:0]   D_SRAM_block;               // { val(1), dirty(1), tag(21), data(32) }
    wire                    cache_hit,dirty;                        // dirty bit
    wire    [T_WIDTH-1:0]   tagout;
    wire    [31:0]          c_out;

    //cache
    wire [C_INDEX-1:0]  index   =   aluoutM[C_INDEX+1:2];
    wire [T_WIDTH-1:0]  tag     =   aluoutM[A_WIDTH-1:C_INDEX+2];
    wire                valid   =   d_valid[index];

    //read from cache
    //assign    D_SRAM_block    =   {d_valid[index],d_dirty[index],d_tags[index],d_data1[index],d_data2[index],d_data3[index],d_data4[index]};
    assign  tagout          =   d_tags[index];
    assign  c_out           =   {d_data1[index],d_data2[index],d_data3[index],d_data4[index]};

    //cache control
    assign  cache_hit       =   valid & (tag==tagout) & memenM & !flag ;
    assign  dirty           =   d_dirty[index];
    assign  dram_wr_addr    =   {tagout,index,2'b00};
    assign  dram_rd_addr    =   aluoutM;

    assign cache_ready      =   (memenM & cache_hit & !flag) || (memenM && flag && m_ready);

    assign readdataM        =   cache_hit ? c_out : data_rdata;

    assign data_req  = (dram_rd_req ) || (dram_wr_req);
    assign data_wr   = dram_wr_req ? 1 : 0;
    assign data_addr = dram_wr_req ? dram_wr_addr : 
                        dram_rd_req ?  dram_rd_addr : 32'b0;
    assign data_wdata = dram_wr_data;
    //assign dram_rd_data = data_rdata;
    assign dram_wr_val = dram_wr_req ? data_data_ok : 0;
    assign dram_rd_val = dram_rd_req ? data_data_ok : 0; 
 
    assign data_wen = 4'b1111;
    assign data_size = 2'b10;

// cpu/dram writes data_cache
    always@(posedge clk)
    begin
        if(rst)                     //init cache memery
        begin
            //TODO: 这个地方应该用generate替换，不然Cache大了会炸时序
            for(i=0;i<(1<<C_INDEX);i=i+1)
            begin
                d_valid[i] <= 1'b0;
                d_dirty[i] <= 1'b0;
            end
        end
        else if(dram_rd_val)    // dram write cache block
        begin
            //D_SRAM[index] <=  {1'b1, 1'b0, aluoutM[31:13],data_rdata};
            d_valid[index]  <=  1'b1;
            d_dirty[index]  <=  1'b0;
            d_tags[index]   <=  tag;
            d_data1[index]  <=  data_rdata[31:24];
            d_data2[index]  <=  data_rdata[23:16];
            d_data3[index]  <=  data_rdata[15:8];
            d_data4[index]  <=  data_rdata[7:0];

        end
        else if( cache_hit & memenM & memwriteM )       //hit cache
        begin
            // wirte dirty bit
            //D_SRAM[index][51]     <=  1'b1;
            d_dirty[index]      <=  1'b1;
            case (sel)
                4'b1111:begin//sw
                    d_data1[index] <= writedata2M[31:24];
                    d_data2[index] <= writedata2M[23:16];
                    d_data3[index] <= writedata2M[15:8];
                    d_data4[index] <= writedata2M[7:0];
                end
                4'b1100:begin//sh
                    d_data1[index] <= writedata2M[31:24];
                    d_data2[index] <= writedata2M[23:16];
                end
                4'b0011:begin//sh
                    d_data3[index] <= writedata2M[15:8];
                    d_data4[index] <= writedata2M[7:0];
                end
                4'b1000:begin//sb
                    d_data1[index] <= writedata2M[31:24];
                end
                4'b0100:begin
                    d_data2[index] <= writedata2M[23:16];
                end
                4'b0010:begin
                    d_data3[index] <= writedata2M[15:8];
                end
                4'b0001:begin
                    d_data4[index] <= writedata2M[7:0];
                end
            default: ;
            endcase
        end
    end

    // data_cache writes dram
    //assign dram_wr_data = D_SRAM[index][31:0];
    assign dram_wr_data =c_out;

    // data_cache state machine
    always@(posedge clk)
    begin
        if(rst)
            state   <=  CPU_EXEC;
        else
            case(state)
                CPU_EXEC:if( ~cache_hit & dirty & memenM & !flag)          // dirty block write back to dram
                            state   <=  WR_DRAM;
                        else if( ~cache_hit & memenM & !flag)          // request new block from dram
                            state   <=  RD_DRAM;
                        else
                            state   <=  CPU_EXEC;
                WR_DRAM:if(dram_wr_val & dram_wr_req)
                            state   <=  RD_DRAM;
                        else
                            state   <=  WR_DRAM;
                RD_DRAM:if(dram_rd_val & dram_rd_req)
                            state   <=  CPU_EXEC;   
                        else
                            state   <=  RD_DRAM;
                default:    state   <=  CPU_EXEC;   
            endcase
    end

    // dram write/read request
    assign  dram_wr_req =   ( WR_DRAM == state );
    assign  dram_rd_req =   ( RD_DRAM == state );

endmodule
