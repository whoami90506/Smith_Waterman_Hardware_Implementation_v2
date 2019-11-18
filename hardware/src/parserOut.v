`ifdef PARSER_OUT_V
`else
`define PARSER_OUT_V

`include "src/parameter.v"

module Parser_Out (
    input clk, 
    input rst_n,

    input [2:0] t_end_i,
    input [2:0] t_reset_i,
    input  [`CALC_BIT-1 : 0] max_i,
    input  [`CALC_BIT-1 : 0] v_i,
    output reg [`CALC_BIT-1 : 0] result_o, max_result_o,
    output reg valid_o,
    output reg [`MAX_T_NUM_BIT-1 : 0] match_idx_o,
    output reg change_q_o 
);

reg [`CALC_BIT-1 : 0] n_result_o;
wire n_valid_o, n_change_q_o;

//state
reg run;

//match index
reg [`CALC_BIT-1 : 0] n_max_result_o;
reg [`MAX_T_NUM_BIT-1 : 0] t_index, n_t_index;
reg [`MAX_T_NUM_BIT-1 : 0] n_match_idx_o;

assign n_valid_o = run & (~t_end_i[2]);
assign n_change_q_o = t_end_i == `END;

always @(*) begin
    if(t_reset_i[2]) begin
        if(result_o < max_i) n_result_o = max_i > v_i ? max_i : v_i;
        else n_result_o = result_o > v_i ? result_o : v_i;
        
    end else n_result_o = max_i > v_i ? max_i : v_i;
end

//match index
always @(*) begin
    if(change_q_o) begin
        n_max_result_o = `CALC_BIT'd0;
        n_match_idx_o = `MAX_T_NUM_BIT'd0;
        n_t_index = `MAX_T_NUM_BIT'd0;

    end else if (n_valid_o) begin
        n_max_result_o    = (n_result_o > max_result_o) ? n_result_o : max_result_o;
        n_match_idx_o = (n_result_o > max_result_o) ? t_index : match_idx_o;
        n_t_index = t_index + `MAX_T_NUM_BIT'd1;

    end else begin
        n_max_result_o = max_result_o;
        n_match_idx_o = match_idx_o;
        n_t_index = t_index;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        run <= 1'b0;
        result_o <= `CALC_BIT'd0;
        valid_o <= 1'd0;
        change_q_o <= 1'b0;

        max_result_o <= `CALC_BIT'd0;
        match_idx_o <= `MAX_T_NUM_BIT'd0;
        t_index <= `MAX_T_NUM_BIT'd0;
    end else begin
        run <= t_end_i[2];
        result_o <= n_result_o;
        valid_o <= n_valid_o;
        change_q_o <= n_change_q_o;

        max_result_o <= n_max_result_o;
        match_idx_o <= n_match_idx_o;
        t_index <= n_t_index;
    end
end

endmodule
`endif