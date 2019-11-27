`ifdef PE_V
`else
`define PE_V

`include "src/parameter.v"

module PE(
    input clk,
    input rst_n,

    input      [`CALC_BIT-1 :0] match_i, mismatch_i, alpha_i, beta_i,
    input      [2 :0] t_i, q_i,
    output reg [2 :0] t_o, t_internal_o,
    input      [`CALC_BIT-1 :0] v_i, f_i, max_i,
    output reg [`CALC_BIT-1 :0] v_o, f_o, max_o,
    output update_q_ow
);

//buffer
reg [`CALC_BIT -1 : 0] v_diag;

//internel
reg  [`CALC_BIT -1 : 0]   e_reg,   f_internal,   diag_0_internal, max_internal;
reg  [`CALC_BIT -1 : 0] n_e_reg, n_f_internal, n_diag_0_internal;
wire [`CALC_BIT -1 : 0] n_max_internal;

//wire
wire [`CALC_BIT -1 : 0] LUT_w;
wire [`CALC_BIT -1 : 0] max_f_diag_w, n_v_o;

assign LUT_w          = (t_i[1:0] == q_i[1:0]) ? v_diag + match_i : v_diag + mismatch_i;
assign max_e_f        = $signed(e_reg) > $signed(f_internal) ? e_reg : f_internal;
assign max_f_diag_w   = $signed(f_internal) > $signed(diag_0_internal) ? f_internal : diag_0_internal;
assign update_q_ow    = (t_i == 3'b001);
assign n_v_o          = $signed(max_f_diag_w) > $signed(e_reg) ? max_f_diag_w : e_reg;
assign n_max_internal = max_i > v_i ? max_i : v_i;

always @(*) begin
    if(t_i[2] & q_i[2]) begin // calculating
        n_e_reg           = $signed(max_f_diag_w + alpha_i) > $signed(e_reg + beta_i ) ? max_f_diag_w + alpha_i : e_reg + beta_i ;
        n_f_internal      = $signed(f_i          + beta_i ) > $signed(v_i   + alpha_i) ? f_i          + beta_i  : v_i   + alpha_i;
        n_diag_0_internal = LUT_w[`CALC_BIT-1] ? 0 : LUT_w;
    end else begin 
        n_e_reg           = 0;
        n_f_internal      = 0;
        n_diag_0_internal = 0;

    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        t_o             <= 3'b0;
        t_internal_o    <= 3'b0;
        v_o             <= 0;
        f_o             <= 0;
        max_o           <= 0;
        v_diag          <= 0;
        e_reg           <= 0;
        f_internal      <= 0;
        diag_0_internal <= 0;
        max_internal    <= 0;
    end else begin
        t_o             <= t_internal_o;
        t_internal_o    <= t_i;
        v_o             <= n_v_o;
        f_o             <= f_internal;
        max_o           <= max_internal;
        v_diag          <= v_i;
        e_reg           <= n_e_reg;
        f_internal      <= n_f_internal;
        diag_0_internal <= n_diag_0_internal;
        max_internal    <= n_max_internal;
    end
end
endmodule

`endif