`ifdef PARSER_Q_V
`else
`define PARSER_Q_V

`include "src/parameter.v"

module Parser_Q(
    input clk,
    input rst_n,

    input start_i,
    input buffer_full_i,
    output reg busy_o,

    input [`SRAM_WORD_WIDTH-1 : 0] data_i,
    input valid_i,
    output reg [`SRAM_ADDR_BIT-1 : 0] addr_o,
    output reg request_o,

    output reg [1:0] q_out,
    output reg [`PE_NUM-1 : 0] PE_valid_o,
    output reg pouring_o, pouring_last_o
);

reg [`SRAM_WORD_WIDTH-1 : 0] data_reg, n_data_reg;
reg [`SRAM_ADDR_BIT-1 : 0] n_addr_o;
reg n_request_o;

wire [1:0] n_q_out;
reg [`PE_NUM-1 : 0] n_PE_valid_o;
reg n_pouring_o;

//state
reg [1:0] state, n_state;
wire n_busy_o;
reg [`PE_NUM_BIT-1 : 0] q_counter, n_q_counter;
parameter IDLE = 2'b00;
parameter INIT = 2'b01;
parameter CALC = 2'b10;
parameter WAIT = 2'b11;

//ddr
reg [`SRAM_WORD_WIDTH-1 : 0] buffer, n_buffer;
reg [`DNA_PER_WORD_BIT-1 : 0] buffer_counter, n_buffer_counter;
wire [`DNA_PER_WORD-1 : 0] data_end;

assign n_busy_o = n_state != IDLE;
assign n_q_out = buffer[`SRAM_WORD_WIDTH-2 -: 2];

genvar i_g;
generate
    for (i_g = 0; i_g < `DNA_PER_WORD; i_g = i_g+1) assign data_end[i_g] = (data_i[`SRAM_WORD_WIDTH-1 -3*i_g -: 3] == `END);
endgenerate

//control
always @(*) begin
    case (state)
        IDLE : n_state = start_i ? INIT : IDLE;
        INIT : n_state = valid_i ? CALC : INIT;
        CALC : begin
            if(~buffer[`SRAM_WORD_WIDTH-1])n_state = buffer[`SRAM_WORD_WIDTH-1 -: 3] == `END ? IDLE : WAIT;
            else n_state = CALC;
        end
        WAIT : n_state = (q_counter == `PE_NUM_BIT'd1) && ~buffer_full_i ? CALC : WAIT;
    endcase
end

//buffer
always @(*) begin
    case(state)
        IDLE : begin
            n_data_reg = `SRAM_WORD_WIDTH'd0;
            n_addr_o = `SRAM_ADDR_BIT'd0;
            n_request_o = start_i;
        end

        INIT : begin
            n_data_reg = `SRAM_WORD_WIDTH'd0;
            n_addr_o = valid_i ? `SRAM_ADDR_BIT'd1 : `SRAM_ADDR_BIT'd0;
            n_request_o = 1'b1;
        end

        CALC : begin
            n_data_reg = valid_i ? data_i : data_reg;
            if(valid_i)n_addr_o = data_end ? `SRAM_ADDR_BIT'd0 : addr_o + `SRAM_ADDR_BIT'd1;
            else n_addr_o = addr_o;
            n_request_o = request_o ? ~valid_i : (buffer_counter == `DNA_PER_WORD -1);
        end
        
        WAIT : begin
            n_data_reg = valid_i ? data_i : data_reg;
            if(valid_i)n_addr_o = data_end ? `SRAM_ADDR_BIT'd0 : addr_o + `SRAM_ADDR_BIT'd1;
            else n_addr_o = addr_o;
            n_request_o = request_o ? ~valid_i : 1'b0;
        end
    endcase
end

//ddr
always @(*) begin
    case(state)
        CALC : begin
            n_buffer = (buffer_counter == `DNA_PER_WORD -1) ? data_reg : buffer << 3;
            n_buffer_counter = (buffer_counter == `DNA_PER_WORD -1) ? `DNA_PER_WORD_BIT'd0 : buffer_counter + `DNA_PER_WORD_BIT'd1;
        end

        WAIT : begin
            n_buffer = buffer;
            n_buffer_counter = buffer_counter;
        end

        //IDLE INIT
        default : begin
            n_buffer = data_i;
            n_buffer_counter = 0;
        end 
    endcase
end

//q_out
always @(*) begin
    n_PE_valid_o = `PE_NUM'd0;

    case(state)
        CALC : begin
            n_q_counter = buffer[`SRAM_WORD_WIDTH-1] ? q_counter + `PE_NUM_BIT'd1 : `PE_NUM_BIT'd0;
            n_PE_valid_o[q_counter] = buffer[`SRAM_WORD_WIDTH-1];
            n_pouring_o = buffer[`SRAM_WORD_WIDTH-1];
        end

        WAIT : begin
            if(q_counter == `PE_NUM_BIT'd0)n_q_counter = `PE_NUM_BIT'd1;
            else n_q_counter = buffer_full_i ? `PE_NUM_BIT'd1 : `PE_NUM_BIT'd0;
            
            n_pouring_o = 1'b0;
        end
        default : begin
            n_q_counter = `PE_NUM_BIT'd0;
            n_pouring_o = 1'b0;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        state <= IDLE;
        busy_o <= 1'b0;
        
        addr_o <= `SRAM_ADDR_BIT'd0;
        request_o <= 1'b0;

        q_out <= 2'd0;
        PE_valid_o <= `PE_NUM'd0;
        pouring_o <= 1'b0;
        pouring_last_o <= 1'b0;

        data_reg <= `SRAM_ADDR_BIT'd0;
        q_counter <= `PE_NUM_BIT'd0;
        buffer <= `SRAM_WORD_WIDTH'd0;
        buffer_counter <= `DNA_PER_WORD_BIT'd0;
    end else begin
        state <= n_state;
        busy_o <= n_busy_o;
        
        addr_o <= n_addr_o;
        request_o <= n_request_o;

        q_out <= n_q_out;
        PE_valid_o <= n_PE_valid_o;
        pouring_o <= n_pouring_o;
        pouring_last_o <= pouring_o;

        data_reg <= n_data_reg;
        q_counter <= n_q_counter;
        buffer <= n_buffer;
        buffer_counter <= n_buffer_counter;
    end
end
endmodule // Parser_Q
`endif