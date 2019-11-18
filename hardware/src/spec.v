`ifdef SPEC_V
`else
`define SPEC_V

`define MATCH_BIT 3
`define PE_NUM    256
`define CALC_BIT  13 //$clog2(`PE_NUM +1) + `MATCH_BIT +1

`define SRAM_WORD_WIDTH  24
`define SRAM_ADDR_BIT    10
`define BUFFER_DEPTH     6
`define MAX_T_NUM_BIT    32

`define DNA_PER_WORD     8 // WORD_WIDTH/3
`define DNA_PER_WORD_BIT 3 // $clog2(DNA_PER_WORD)
`define PE_NUM_BIT       8 // $clog2(PE_NUM)
`define BUFFER_DEPTH_BIT 3 // $clog2(BUFFER_DEPTH+1)

`endif
