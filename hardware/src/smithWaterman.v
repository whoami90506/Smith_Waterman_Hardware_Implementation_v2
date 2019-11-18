`ifdef SMITHWATERMAN_V
`else
`define SMITHWATERMAN_V

`include "src/parameter.v"

module SmithWaterman(
    input clk, 
    input rst_n, 
    input start_i,
    output reg busy_o,

    input [`MATCH_BIT-1 : 0] match_i,
    input [`MATCH_BIT-1 : 0] mismatch_i,
    input [`MATCH_BIT-1 : 0] alpha_i,
    input [`MATCH_BIT-1 : 0] beta_i,

    output select_T_o,
    input  [`SRAM_WORD_WIDTH-1 : 0] data_i,
    output [`SRAM_ADDR_BIT-1   : 0] addr_o,

    output [`CALC_BIT-1 : 0] result_o,
    output valid_o,
    output [`CALC_BIT-1 : 0] max_result_o,
    output [`MAX_T_NUM_BIT-1 : 0] match_idx_o,
    output change_q_o
);

reg _start_i;
reg [`MATCH_BIT-1 : 0] _match_i, _mismatch_i, _alpha_i, _beta_i;
reg [`SRAM_WORD_WIDTH-1 : 0] _data_i;
wire n_busy_o;

reg  [`CALC_BIT-1 : 0] match, mismatch, alpha, beta;
wire [`CALC_BIT-1 : 0] n_match, n_mismatch, n_alpha, n_beta;

//loader
wire [`SRAM_WORD_WIDTH-1 : 0] loader_T_data, loader_Q_data;
wire loader_T_valid, loader_Q_valid;

//ParserT
wire pT_busy, pT_request;
wire [`SRAM_ADDR_BIT-1 : 0] pT_addr;
wire [2:0] pT_t;

//ParserQ
wire pQ_busy, pQ_request, pQ_pouring;
wire [`SRAM_ADDR_BIT-1 : 0] pQ_addr;
wire [1:0] pQ_q;
wire [`PE_NUM-1 : 0] pQ_valid;

//PE
genvar idx;
wire [2:0] PE_t [0 : `PE_NUM];
wire [`CALC_BIT -1 : 0] PE_v   [0 : `PE_NUM];
wire [`CALC_BIT -1 : 0] PE_v_a [0 : `PE_NUM];
wire [`CALC_BIT -1 : 0] PE_f_b   [0 : `PE_NUM];
wire [`CALC_BIT -1 : 0] PE_max [0 : `PE_NUM];
wire [`PE_NUM -1 : 0] PE_update_w;

assign n_match    = _start_i ? {{(`CALC_BIT - `MATCH_BIT){1'd0}},     _match_i}                 : match;
assign n_mismatch = _start_i ? {{(`CALC_BIT - `MATCH_BIT){1'd1}}, ~_mismatch_i + `MATCH_BIT'd1} : mismatch;
assign n_alpha    = _start_i ? {{(`CALC_BIT - `MATCH_BIT){1'd1}},    ~_alpha_i + `MATCH_BIT'd1} : alpha;
assign n_beta     = _start_i ? {{(`CALC_BIT - `MATCH_BIT){1'd1}},     ~_beta_i + `MATCH_BIT'd1} : beta;

assign PE_t  [0] = pT_t;
assign PE_v  [0] = `CALC_BIT'd0;
assign PE_v_a[0] = alpha;
assign PE_f_b  [0] = beta;
assign PE_max[0] = `CALC_BIT'd0;

//buffer
wire [2:0] buf_q [0 : `PE_NUM -1];
wire [`PE_NUM-1 : 0] buf_full, buf_ready_one, buf_ready_two;

assign n_busy_o = (_start_i | pT_busy) | (pQ_busy | buf_ready_one[`PE_NUM-1]) | start_i;

Loader loader(.clk(clk), .rst_n(rst_n), .sel_T_o(select_T_o), .addr_o(addr_o), .data_i(_data_i), 
    .T_addr_i(pT_addr), .T_request_i(pT_request), .T_data_o(loader_T_data), .T_valid_o(loader_T_valid), 
    .Q_addr_i(pQ_addr), .Q_request_i(pQ_request), .Q_data_o(loader_Q_data), .Q_valid_o(loader_Q_valid) );

Parser_T pT(.clk(clk), .rst_n(rst_n), .start_i(_start_i), .q_ready_one_i(buf_ready_one[0]), .q_ready_two_i(buf_ready_two[0]), 
    .q_busy_i(pQ_busy), .busy_o(pT_busy), .data_i(loader_T_data), .valid_i(loader_T_valid), 
    .addr_o(pT_addr), .request_o(pT_request), .t_out_o(pT_t));

Parser_Q pQ(.clk(clk), .rst_n(rst_n), .start_i(_start_i), .buffer_full_i(buf_full[`PE_NUM-1]), .busy_o(pQ_busy), 
    .data_i(loader_Q_data), .valid_i(loader_Q_valid), .addr_o(pQ_addr), .request_o(pQ_request), 
    .q_out(pQ_q), .PE_valid_o(pQ_valid), .pouring_o(pQ_pouring));

generate
    for (idx = 0; idx < `PE_NUM; idx = idx+1) begin
        PE PE_cell(.clk(clk), .rst_n(rst_n), .t_in(PE_t[idx]), .q_in(buf_q[idx]), .t_out(PE_t[idx+1]), .update_q_ow(PE_update_w[idx]),
                   .v_in (PE_v[idx]  ), .v_in_a (PE_v_a[idx]  ), .f_in_b (PE_f_b[idx]  ), .max_in (PE_max[idx]  ),
                   .v_out(PE_v[idx+1]), .v_out_a(PE_v_a[idx+1]), .f_out_b(PE_f_b[idx+1]), .max_out(PE_max[idx+1]), 
                   .match_i(match), .mismatch_i(mismatch), .alpha_i(alpha), .beta_i(beta));

        Buffer buf_cell(.clk(clk), .rst_n(rst_n), .q_i({pQ_valid[idx], pQ_q}), .pouring_i(pQ_pouring), .update_iw(PE_update_w[idx]), 
                .q_o(buf_q[idx]), .full_o(buf_full[idx]), .ready_one_o(buf_ready_one[idx]), .ready_two_o(buf_ready_two[idx]));
    end
endgenerate

Parser_Out parserOut (.clk(clk), .rst_n(rst_n), .t_end_i(PE_t[`PE_NUM-1]), .max_i(PE_max[`PE_NUM]), .v_i(PE_v[`PE_NUM]), 
    .t_reset_i(PE_t[`PE_NUM]), .result_o(result_o), .valid_o(valid_o), .match_idx_o(match_idx_o), .change_q_o(change_q_o), 
    .max_result_o(max_result_o));

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        _start_i <= 1'b0;
        _data_i <= `SRAM_WORD_WIDTH'd0;
        busy_o <= 1'b0;

        _match_i <= `MATCH_BIT'd0;
        _mismatch_i <= `MATCH_BIT'd0;
        _alpha_i <= `MATCH_BIT'd0;
        _beta_i <= `MATCH_BIT'd0;

        match <= `CALC_BIT'd0;
        mismatch <= `CALC_BIT'd0;
        alpha <= `CALC_BIT'd0;
        beta <= `CALC_BIT'd0;
    end else begin
        _start_i <= start_i;
        _data_i <= data_i;
        busy_o <= n_busy_o;

        _match_i <= match_i;
        _mismatch_i <= mismatch_i;
        _alpha_i <= alpha_i;
        _beta_i <= beta_i;

        match <= n_match;
        mismatch <= n_mismatch;
        alpha <= n_alpha;
        beta <= n_beta;
    end
end

endmodule // SmithWaterman

`endif