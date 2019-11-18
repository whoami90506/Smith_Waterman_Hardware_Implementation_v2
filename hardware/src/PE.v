`ifdef PE_V
`else
`define PE_V

`include "src/parameter.v"

module PE(
    input clk,
    input rst_n,

    input      [`CALC_BIT-1 :0] match_i, mismatch_i, alpha_i, beta_i,
    input      [2 :0] t_in, q_in,
    output reg [2 :0] t_out,
    input      [`CALC_BIT-1 :0] v_in,  v_in_a,  f_in_b,  max_in,
    output reg [`CALC_BIT-1 :0] v_out, v_out_a, f_out_b, max_out,
    output update_q_ow
);

reg  [`CALC_BIT-1 :0] n_v_out, n_f_out_b;
wire [`CALC_BIT-1 :0] n_v_out_a, n_max_out, n_f_out;

//memory
reg [`CALC_BIT-1 :0] v_diag, e_reg_b;
reg [`CALC_BIT-1 :0] n_v_diag, n_e_reg_b;
wire [`CALC_BIT-1 : 0] n_e_reg;

//temp
wire [`CALC_BIT-1 : 0] e_f_max, diag_result, v_compare_0;

assign n_v_out_a = n_v_out + alpha_i;
assign n_f_out   = $signed(v_in_a)  > $signed(f_in_b) ? v_in_a  : f_in_b;
assign n_e_reg   = $signed(v_out_a) > $signed(e_reg_b) ? v_out_a : e_reg_b;
assign n_max_out = v_in > max_in ? v_in : max_in;
assign e_f_max   = $signed(n_e_reg) > $signed(n_f_out) ? n_e_reg : n_f_out;
assign diag_result = (t_in[1:0] == q_in[1:0]) ? v_diag + match_i : v_diag + mismatch_i;
assign v_compare_0 = diag_result[`CALC_BIT-1] ? 0 : diag_result;
assign update_q_ow = (t_in == 3'b001);

always @(*) begin
    
    if(t_in[2] & q_in[2]) begin // calculating
        n_e_reg_b = n_e_reg + beta_i;
        n_f_out_b = n_f_out + beta_i;
        n_v_out = $signed(e_f_max) > $signed(v_compare_0) ? e_f_max : v_compare_0;
        n_v_diag = v_in;
    end else begin 
        n_v_out   = 0;
        n_e_reg_b = beta_i;
        n_f_out_b = beta_i;
        n_v_diag = 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        t_out <= 3'd0;
        v_out <= 0;
        v_out_a <= 0;
        f_out_b <= 0;
        max_out <= 0;

        v_diag <= 0;
        e_reg_b <= 0;
    end else begin
        t_out <= t_in;
        v_out <= n_v_out;
        v_out_a <= n_v_out_a;
        f_out_b <= n_f_out_b;
        max_out <= n_max_out;

        v_diag <= n_v_diag;
        e_reg_b <= n_e_reg_b;
    end
end
endmodule

`endif