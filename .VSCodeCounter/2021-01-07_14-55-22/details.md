# Details

Date : 2021-01-07 14:55:22

Directory c:\Users\wangsy\Desktop\2021_CQU_NSCSCC

Total : 55 files,  7067 codes, 557 comments, 933 blanks, all 8557 lines

[summary](results.md)

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [Cache/cache.sv](/Cache/cache.sv) | System Verilog | 95 | 47 | 17 | 159 |
| [Cache/d_cache.sv](/Cache/d_cache.sv) | System Verilog | 185 | 21 | 26 | 232 |
| [Cache/d_sram2sram_like.sv](/Cache/d_sram2sram_like.sv) | System Verilog | 55 | 13 | 12 | 80 |
| [Cache/i_cache.sv](/Cache/i_cache.sv) | System Verilog | 64 | 21 | 17 | 102 |
| [Cache/i_sram2sram_like.sv](/Cache/i_sram2sram_like.sv) | System Verilog | 52 | 13 | 12 | 77 |
| [EX/EX.sv](/EX/EX.sv) | System Verilog | 106 | 9 | 39 | 154 |
| [EX/alu.sv](/EX/alu.sv) | System Verilog | 123 | 31 | 36 | 190 |
| [EX/alu_data_sel.sv](/EX/alu_data_sel.sv) | System Verilog | 18 | 0 | 1 | 19 |
| [EX/div.sv](/EX/div.sv) | System Verilog | 93 | 31 | 9 | 133 |
| [EX/div_ip.sv](/EX/div_ip.sv) | System Verilog | 48 | 17 | 11 | 76 |
| [EX/ex_reg_hazard.sv](/EX/ex_reg_hazard.sv) | System Verilog | 25 | 9 | 11 | 45 |
| [EX/mul_ip.sv](/EX/mul_ip.sv) | System Verilog | 40 | 14 | 5 | 59 |
| [ID/branch_controller.sv](/ID/branch_controller.sv) | System Verilog | 16 | 4 | 4 | 24 |
| [ID/id.sv](/ID/id.sv) | System Verilog | 227 | 37 | 37 | 301 |
| [ID/id_defines.vh](/ID/id_defines.vh) | Verilog | 74 | 14 | 10 | 98 |
| [ID/reg_harzrd.sv](/ID/reg_harzrd.sv) | System Verilog | 28 | 9 | 7 | 44 |
| [ID/regfile.sv](/ID/regfile.sv) | System Verilog | 24 | 5 | 8 | 37 |
| [IF/IF.sv](/IF/IF.sv) | System Verilog | 34 | 6 | 12 | 52 |
| [IF/pc_next_sel.sv](/IF/pc_next_sel.sv) | System Verilog | 12 | 4 | 4 | 20 |
| [IF/pc_reg.sv](/IF/pc_reg.sv) | System Verilog | 27 | 10 | 5 | 42 |
| [MEM/MEM.sv](/MEM/MEM.sv) | System Verilog | 111 | 11 | 28 | 150 |
| [MEM/ade_exception.sv](/MEM/ade_exception.sv) | System Verilog | 50 | 0 | 5 | 55 |
| [MEM/exception.sv](/MEM/exception.sv) | System Verilog | 23 | 2 | 9 | 34 |
| [MEM/hilo_reg.sv](/MEM/hilo_reg.sv) | System Verilog | 25 | 2 | 5 | 32 |
| [MEM/mem_io_controller.sv](/MEM/mem_io_controller.sv) | System Verilog | 56 | 0 | 9 | 65 |
| [README.md](/README.md) | Markdown | 6 | 0 | 3 | 9 |
| [WB/wb.sv](/WB/wb.sv) | System Verilog | 20 | 1 | 9 | 30 |
| [cp0_regfile.sv](/cp0_regfile.sv) | System Verilog | 182 | 5 | 17 | 204 |
| [cpu_axi_interface.v](/cpu_axi_interface.v) | Verilog | 126 | 48 | 11 | 185 |
| [datapath.sv](/datapath.sv) | System Verilog | 519 | 48 | 147 | 714 |
| [debug_controller.sv](/debug_controller.sv) | System Verilog | 47 | 0 | 8 | 55 |
| [defines.vh](/defines.vh) | Verilog | 232 | 12 | 31 | 275 |
| [docs/cyy/diary.md](/docs/cyy/diary.md) | Markdown | 61 | 0 | 47 | 108 |
| [docs/fanqin/CP0模块.md](/docs/fanqin/CP0模块.md) | Markdown | 3 | 0 | 1 | 4 |
| [docs/fanqin/异常处理模块.md](/docs/fanqin/异常处理模块.md) | Markdown | 2 | 0 | 0 | 2 |
| [docs/wsy/Day1.md](/docs/wsy/Day1.md) | Markdown | 21 | 0 | 26 | 47 |
| [docs/wsy/Day2.md](/docs/wsy/Day2.md) | Markdown | 21 | 0 | 36 | 57 |
| [docs/wsy/Day3.md](/docs/wsy/Day3.md) | Markdown | 16 | 0 | 26 | 42 |
| [docs/wsy/Day4.md](/docs/wsy/Day4.md) | Markdown | 7 | 0 | 8 | 15 |
| [docs/wsy/添加axi桥.md](/docs/wsy/添加axi桥.md) | Markdown | 34 | 0 | 49 | 83 |
| [mips_cpu.sv](/mips_cpu.sv) | System Verilog | 247 | 19 | 29 | 295 |
| [stall_flush_controller.sv](/stall_flush_controller.sv) | System Verilog | 85 | 14 | 15 | 114 |
| [test/EX_test.sv](/test/EX_test.sv) | System Verilog | 42 | 0 | 5 | 47 |
| [test/ID_test.sv](/test/ID_test.sv) | System Verilog | 42 | 26 | 22 | 90 |
| [test/IF_test.sv](/test/IF_test.sv) | System Verilog | 34 | 0 | 3 | 37 |
| [test/test1-ori/test1.sv](/test/test1-ori/test1.sv) | System Verilog | 17 | 0 | 3 | 20 |
| [test/test13-tlb/test13.sv](/test/test13-tlb/test13.sv) | System Verilog | 102 | 28 | 3 | 133 |
| [tlb.sv](/tlb.sv) | System Verilog | 251 | 21 | 30 | 302 |
| [tlbdefines.vh](/tlbdefines.vh) | Verilog | 15 | 0 | 0 | 15 |
| [triggers/EX2MEM.sv](/triggers/EX2MEM.sv) | System Verilog | 132 | 0 | 14 | 146 |
| [triggers/ID2EXE.sv](/triggers/ID2EXE.sv) | System Verilog | 135 | 1 | 29 | 165 |
| [triggers/IF2ID.sv](/triggers/IF2ID.sv) | System Verilog | 36 | 3 | 7 | 46 |
| [triggers/MEM2WB.sv](/triggers/MEM2WB.sv) | System Verilog | 65 | 1 | 13 | 79 |
| [unsigned_divd/unsigned_divd.xml](/unsigned_divd/unsigned_divd.xml) | XML | 1,916 | 0 | 1 | 1,917 |
| [unsigned_mult/unsigned_mult.xml](/unsigned_mult/unsigned_mult.xml) | XML | 1,040 | 0 | 1 | 1,041 |

[summary](results.md)