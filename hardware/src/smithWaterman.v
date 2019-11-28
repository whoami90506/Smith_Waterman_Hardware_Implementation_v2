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
reg post_busy;
wire n_busy_o;

reg  [`MATCH_BIT-1 : 0] match_r, mismatch_r, alpha_r, beta_r;
reg  [`MATCH_BIT   : 0] mis_a_r, ab_r, ma_a_r;
wire [`MATCH_BIT-1 : 0] n_match_r, n_mismatch_r, n_alpha_r, n_beta_r;
wire [`MATCH_BIT   : 0] n_mis_a_r, n_ab_r, n_ma_a_r;
wire [ `CALC_BIT-1 : 0] match, mismatch, alpha, beta, a2, ab, ma_a, mis_a;

//loader
wire [`SRAM_WORD_WIDTH-1 : 0] loader_T_data, loader_Q_data;
wire loader_T_valid, loader_Q_valid;

//ParserT
wire pT_busy, pT_request;
wire [`SRAM_ADDR_BIT-1 : 0] pT_addr;
wire [2:0] pT_t, pT_next_t_w;

//ParserQ
wire pQ_busy, pQ_request, pQ_pouring, pQ_pouring_last;
wire [`SRAM_ADDR_BIT-1 : 0] pQ_addr;
wire [1:0] pQ_q;
wire [`PE_NUM-1 : 0] pQ_valid;

//buffer
wire [2:0] buf_q [0 : `PE_NUM];
wire [2:0] buf_next_q_w [0 : `PE_NUM];
wire [`PE_NUM-1 : 0] buf_full, buf_ready_one, buf_ready_two;
assign buf_next_q_w[`PE_NUM] = 3'd0;
assign buf_q[`PE_NUM] = 3'd0;

//PE
genvar idx;
wire [2:0] PE_t [0 : `PE_NUM];
wire [2:0] PE_t_internal [0 : `PE_NUM-1];
wire [`CALC_BIT -1 : 0] PE_v   [0 : `PE_NUM];
wire [`CALC_BIT -1 : 0] PE_f   [0 : `PE_NUM];
wire [`CALC_BIT -1 : 0] PE_max [0 : `PE_NUM];
wire [`CALC_BIT -1 : 0] PE_v_diag_lut [0 : `PE_NUM];
wire [`PE_NUM -1 : 0] PE_update_w;
reg  [`CALC_BIT -1 : 0] PE_0_v_diag_lut;
wire  [`CALC_BIT -1 : 0] n_PE_0_v_diag_lut;

assign n_match_r    = _start_i & (~busy_o | ~post_busy ) ? _match_i                                     : match_r;
assign n_mismatch_r = _start_i & (~busy_o | ~post_busy ) ? ~_mismatch_i + `MATCH_BIT'd1                 : mismatch_r;
assign n_alpha_r    = _start_i & (~busy_o | ~post_busy ) ? ~_alpha_i + `MATCH_BIT'd1                    : alpha_r;
assign n_beta_r     = _start_i & (~busy_o | ~post_busy ) ? ~_beta_i + `MATCH_BIT'd1                     : beta_r;
assign n_ma_a_r     = _start_i & (~busy_o | ~post_busy ) ? {1'b0, _match_i} - {1'b0, _alpha_i}          : ma_a_r;
assign n_mis_a_r    = _start_i & (~busy_o | ~post_busy ) ? ~({1'b0, _mismatch_i} + {1'b0, _alpha_i}) +1 : mis_a_r;
assign n_ab_r       = _start_i & (~busy_o | ~post_busy ) ? ~({1'b0, _alpha_i} + {1'b0, _beta_i}) +1     : ab_r;

assign match    = {{(`CALC_BIT - `MATCH_BIT){1'd0}}  , match_r    };
assign mismatch = {{(`CALC_BIT - `MATCH_BIT){1'd1}}  , mismatch_r };
assign alpha    = {{(`CALC_BIT - `MATCH_BIT){1'd1}}  , alpha_r    };
assign beta     = {{(`CALC_BIT - `MATCH_BIT){1'd1}}  , beta_r     };
assign ab       = {{(`CALC_BIT - `MATCH_BIT-1){1'd1}}, ab_r       };
assign mis_a    = {{(`CALC_BIT - `MATCH_BIT-1){1'd1}}, mis_a_r    };
assign a2       = {{(`CALC_BIT - `MATCH_BIT-1){1'd1}}, alpha_r, 1'b0};
assign ma_a     = {{(`CALC_BIT - `MATCH_BIT){ma_a_r[`MATCH_BIT]}}, ma_a_r };

assign PE_t  [0] = pT_t;
assign PE_v  [0] = `CALC_BIT'd0;
assign PE_f  [0] = 0;
assign PE_max[0] = `CALC_BIT'd0;
assign n_PE_0_v_diag_lut = (pT_next_t_w[1:0] == buf_next_q_w[0][1:0] ) ? match : mismatch; 
assign PE_v_diag_lut[0] = PE_0_v_diag_lut;

assign n_busy_o = (_start_i | pT_busy) | (pQ_busy | buf_ready_one[`PE_NUM-1]) | start_i;

Loader loader(.clk(clk), .rst_n(rst_n), .sel_T_o(select_T_o), .addr_o(addr_o), .data_i(_data_i), 
    .T_addr_i(pT_addr), .T_request_i(pT_request), .T_data_o(loader_T_data), .T_valid_o(loader_T_valid), 
    .Q_addr_i(pQ_addr), .Q_request_i(pQ_request), .Q_data_o(loader_Q_data), .Q_valid_o(loader_Q_valid) );

Parser_T pT(.clk(clk), .rst_n(rst_n), .start_i(_start_i), .q_ready_one_i(buf_ready_one[0]), .q_ready_two_i(buf_ready_two[0]), 
    .q_busy_i(pQ_busy), .busy_o(pT_busy), .data_i(loader_T_data), .valid_i(loader_T_valid), 
    .addr_o(pT_addr), .request_o(pT_request), .t_out_o(pT_t), .next_t_ow(pT_next_t_w));

Parser_Q pQ(.clk(clk), .rst_n(rst_n), .start_i(_start_i), .buffer_full_i(buf_full[`PE_NUM-1]), .busy_o(pQ_busy), 
    .data_i(loader_Q_data), .valid_i(loader_Q_valid), .addr_o(pQ_addr), .request_o(pQ_request), 
    .q_out(pQ_q), .PE_valid_o(pQ_valid), .pouring_o(pQ_pouring), .pouring_last_o(pQ_pouring_last));

generate
    for (idx = 0; idx < `PE_NUM; idx = idx+1) begin
        PE PE_cell(.clk(clk), .rst_n(rst_n), .t_i(PE_t[idx]), .q_i(buf_q[idx]), .t_o(PE_t[idx+1]), .update_q_ow(PE_update_w[idx]),
                   .v_i(PE_v[idx]  ), .f_i(PE_f[idx]  ), .max_i(PE_max[idx]  ), .t_internal_o(PE_t_internal[idx]),
                   .v_o(PE_v[idx+1]), .f_o(PE_f[idx+1]), .max_o(PE_max[idx+1]), 
                   .match_i(match), .mismatch_i(mismatch), .alpha_i(alpha), .beta_i(beta), 
                   .a2_i(a2), .ab_i(ab), .ma_a_i(ma_a), .mis_a_i(mis_a));

        Buffer buf_cell(.clk(clk), .rst_n(rst_n), .q_i({pQ_valid[idx], pQ_q}), .pouring_i(pQ_pouring), .update_iw(PE_update_w[idx]), 
                .q_o(buf_q[idx]), .full_o(buf_full[idx]), .ready_one_o(buf_ready_one[idx]), .ready_two_o(buf_ready_two[idx]), 
                .pouring_last_i(pQ_pouring_last));
    end
endgenerate

Parser_Out parserOut (.clk(clk), .rst_n(rst_n), .t_end_i(PE_t_internal[`PE_NUM-1]), .max_i(PE_max[`PE_NUM]), .v_i(PE_v[`PE_NUM]), 
    .t_reset_i(PE_t[`PE_NUM]), .result_o(result_o), .valid_o(valid_o), .match_idx_o(match_idx_o), .change_q_o(change_q_o), 
    .max_result_o(max_result_o));

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        _start_i <= 1'b0;
        _data_i <= `SRAM_WORD_WIDTH'd0;
        busy_o <= 1'b0;
        post_busy <= 1'b0;

        _match_i <= `MATCH_BIT'd0;
        _mismatch_i <= `MATCH_BIT'd0;
        _alpha_i <= `MATCH_BIT'd0;
        _beta_i <= `MATCH_BIT'd0;

        match_r    <= `MATCH_BIT'd0;
        mismatch_r <= {`MATCH_BIT{1'd1}};
        alpha_r    <= {`MATCH_BIT{1'd1}};
        beta_r     <= {`MATCH_BIT{1'd1}};
        ma_a_r     <= `MATCH_BIT'd0;
        mis_a_r    <= {`MATCH_BIT{1'd1}};
        ab_r       <= {`MATCH_BIT{1'd1}};
    end else begin
        _start_i  <= start_i;
        _data_i   <= data_i;
        busy_o    <= n_busy_o;
        post_busy <= busy_o;

        _match_i    <= match_i;
        _mismatch_i <= mismatch_i;
        _alpha_i    <= alpha_i;
        _beta_i     <= beta_i;

        match_r    <= n_match_r;
        mismatch_r <= n_mismatch_r;
        alpha_r    <= n_alpha_r;
        beta_r     <= n_beta_r;
        ma_a_r     <= n_ma_a_r;
        mis_a_r    <= n_mis_a_r;
        ab_r       <= n_ab_r;
    end
end

endmodule // SmithWaterman

`endif