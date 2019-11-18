`ifdef LOADER_V
`else
`define LOADER_V

`include  "src/parameter.v"

module Loader(
    input clk, 
    input rst_n,

    output reg sel_T_o,
    output reg [`SRAM_ADDR_BIT-1 : 0] addr_o,
    input [`SRAM_WORD_WIDTH-1 : 0] data_i,

    input  [`SRAM_ADDR_BIT-1 : 0] T_addr_i,
    input  T_request_i,
    output [`SRAM_WORD_WIDTH-1 : 0] T_data_o,
    output reg T_valid_o,

    input  [`SRAM_ADDR_BIT-1 : 0] Q_addr_i,
    input  Q_request_i,
    output [`SRAM_WORD_WIDTH-1 : 0] Q_data_o,
    output reg Q_valid_o
);

reg n_sel_T_o;
reg [`SRAM_ADDR_BIT-1 : 0] n_addr_o;
wire n_T_valid_o, n_Q_valid_o;

reg request, n_request;

assign T_data_o = data_i;
assign Q_data_o = data_i;
assign n_T_valid_o = request & sel_T_o;
assign n_Q_valid_o = request & ~sel_T_o;

always @(*) begin
    if (T_request_i & ~T_valid_o & ~(request &  sel_T_o) )begin
        n_request = 1'd1;
        n_sel_T_o = 1'd1;
        n_addr_o = T_addr_i;

    end else if (Q_request_i & ~Q_valid_o & ~(request & ~sel_T_o) )begin
        n_request = 1'd1;
        n_sel_T_o = 1'd0;
        n_addr_o = Q_addr_i;

    end else begin
        n_request = 1'd0;
        n_sel_T_o = 1'd1;
        n_addr_o = T_addr_i;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        request <= 1'd0;
        sel_T_o <= 1'd0;
        addr_o <= `SRAM_ADDR_BIT'd0;
        T_valid_o <= 1'd0;
        Q_valid_o <= 1'd0;
    end else begin
        request <= n_request;
        sel_T_o <= n_sel_T_o;
        addr_o <= n_addr_o;
        T_valid_o <= n_T_valid_o;
        Q_valid_o <= n_Q_valid_o;
    end
end

endmodule
`endif