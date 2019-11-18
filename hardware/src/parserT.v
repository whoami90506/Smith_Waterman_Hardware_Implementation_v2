`ifdef PARSER_T_V
`else
`define PARSER_T_V

`include "src/parameter.v"

module Parser_T(
    input clk,
    input rst_n,

    input start_i,
    input q_ready_one_i,
    input q_ready_two_i,
    input q_busy_i,
    output reg busy_o,

    input [`SRAM_WORD_WIDTH-1 : 0] data_i,
    input valid_i,
    output reg [`SRAM_ADDR_BIT-1 : 0] addr_o,
    output reg request_o,
    
    output reg [2:0] t_out_o
);


reg [2:0] n_t_out_o;
wire n_busy_o;

//state
parameter IDLE = 2'b00;
parameter INIT = 2'b01;
parameter CALC = 2'b10;
parameter WAIT = 2'b11;

reg [1:0] state, n_state;
reg first;
wire n_first;

integer i;
genvar i_g;

//ddr
parameter REG_DEPTH = 3;
parameter REG_COUNTER = $clog2(REG_DEPTH+1);

reg [`SRAM_WORD_WIDTH-1 : 0] data_reg [ 0 : REG_DEPTH-1 ];
reg [`SRAM_WORD_WIDTH-1 : 0] n_data_reg [ 0 : REG_DEPTH-1 ];
reg [REG_COUNTER-1 : 0] data_counter, n_data_counter;
reg [`SRAM_ADDR_BIT-1 : 0] n_addr_o;
reg n_request_o;
wire [`DNA_PER_WORD-1 : 0] data_end;

//buffer
reg [`SRAM_WORD_WIDTH-1 : 0] buffer, n_buffer;
reg [`DNA_PER_WORD_BIT-1 : 0] buffer_counter, n_buffer_counter;
wire buffer_switch;

assign n_first = first ? n_state != CALC : n_state == IDLE;
assign n_busy_o = (n_state != IDLE);
assign buffer_switch = (buffer_counter == `DNA_PER_WORD -1) || (buffer[`SRAM_WORD_WIDTH-1 -: 3] == `END);

generate
    for (i_g = 0; i_g < `DNA_PER_WORD; i_g = i_g+1) assign data_end[i_g] = (data_i[`SRAM_WORD_WIDTH-1 -3*i_g -: 3] == `END);
endgenerate

//control
always @(*) begin
    case (state)
        IDLE : n_state = start_i ? INIT : IDLE;

        INIT : begin
            if(valid_i)n_state = q_ready_one_i ? CALC : WAIT;
            else n_state = INIT;
        end

        CALC : begin
            if(buffer[`SRAM_WORD_WIDTH-1 -: 3] == `END)begin
                if(~q_busy_i)n_state = q_ready_two_i ? CALC : IDLE;
                else n_state = q_ready_two_i ? CALC : WAIT;
            end
            else n_state = CALC;
        end

        WAIT : begin
            if(first) n_state = q_ready_one_i ? CALC : WAIT;
            else n_state = q_ready_two_i | ~q_busy_i ? CALC : WAIT;
            
        end
    endcase
end

//reg
always @(*) begin
    case(state)
        IDLE : begin
            for (i = 0; i < REG_DEPTH; i = i+1) n_data_reg[i] = `SRAM_WORD_WIDTH'd0;
            n_data_counter = 0;
            n_addr_o = `SRAM_ADDR_BIT'd0;
            n_request_o = start_i;
        end
        
        INIT : begin
            for (i = 0; i < REG_DEPTH; i = i+1) n_data_reg[i] = `SRAM_WORD_WIDTH'd0;
            n_data_counter = 0;
            n_addr_o = valid_i ? `SRAM_ADDR_BIT'd1 : `SRAM_ADDR_BIT'd0;
            n_request_o = 1'b1;
        end

        CALC : begin
            case({buffer_switch, valid_i})
                2'b00 : begin
                    for (i = 0; i < REG_DEPTH; i = i+1) n_data_reg[i] = data_reg[i];
                    n_data_counter = data_counter;
                end

                2'b01 : begin
                    if(data_counter < REG_DEPTH) begin
                        for (i = 0; i < REG_DEPTH; i = i+1) n_data_reg[i] = (i == data_counter) ? data_i : data_reg[i];
                        n_data_counter = data_counter + 1;
                    end else begin
                        for (i = 0; i < REG_DEPTH; i = i+1) n_data_reg[i] =   data_reg[i];
                        n_data_counter = data_counter;
                    end
                end

                2'b10 : begin
                    if(data_counter) begin
                        for (i = 0; i < REG_DEPTH; i = i+1) n_data_reg[i] = ( i+1 < data_counter ) ? data_reg[i+1] : data_reg[i];
                        n_data_counter = data_counter -1;
                    end else begin
                        for (i = 0; i < REG_DEPTH; i = i+1) n_data_reg[i] =   data_reg[i];
                        n_data_counter = data_counter;
                    end
                end

                2'b11 : begin
                    for (i = 0; i < REG_DEPTH; i = i+1) begin
                        if(i+2 < data_counter)n_data_reg[i] = n_data_reg[i+1];
                        else if (i+1 == data_counter)n_data_reg[i] = data_i;
                        else n_data_reg[i] = data_reg[i];
                    end
                    n_data_counter = data_counter;
                end
                
            endcase

            n_request_o = n_data_counter < REG_DEPTH;
            if(valid_i)n_addr_o = data_end ? `SRAM_ADDR_BIT'd0 : addr_o + `SRAM_ADDR_BIT'd1;
            else n_addr_o = addr_o;
        end

        WAIT : begin
            if(valid_i)begin
                if(data_counter < REG_DEPTH) begin
                    for (i = 0; i < REG_DEPTH; i = i+1) n_data_reg[i] = (i == data_counter) ? data_i : data_reg[i];
                    n_data_counter = data_counter + 1;
                end else begin
                    for (i = 0; i < REG_DEPTH; i = i+1) n_data_reg[i] =   data_reg[i];
                    n_data_counter = data_counter;
                end
            end else begin
                for (i = 0; i < REG_DEPTH; i = i+1) n_data_reg[i] = data_reg[i];
                n_data_counter = data_counter;
            end

            n_request_o = n_data_counter < REG_DEPTH; 
            if(valid_i)n_addr_o = data_end ? `SRAM_ADDR_BIT'd0 : addr_o + `SRAM_ADDR_BIT'd1;
            else n_addr_o = addr_o;
        end
    endcase
end

//buffer
always @(*) begin
    case(state)
        CALC : begin
            n_buffer = buffer_switch ? data_reg[0] : buffer << 3;
            n_buffer_counter = buffer_switch ? `DNA_PER_WORD_BIT'd0 : buffer_counter + `DNA_PER_WORD_BIT'd1;
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

//t_out
always @(*) begin
    case(state)
        CALC : begin
            if(buffer[`SRAM_WORD_WIDTH-1 -: 3] == `END)n_t_out_o = (~q_busy_i | q_ready_two_i) ? `END : 3'b000;
            else n_t_out_o = buffer[`SRAM_WORD_WIDTH-1 -: 3];
        end 
        WAIT : n_t_out_o = ( ~first & ( ~q_busy_i | q_ready_two_i) ) ? `END : 3'b000;
        default : n_t_out_o = 3'b000;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        state <= IDLE;
        busy_o <= 1'b0;
        first <= 1'b1;
        
        for ( i= 0; i < REG_DEPTH; i = i+1)data_reg[i] <= `SRAM_WORD_WIDTH'd0;
        data_counter <= 0;
        addr_o <= `SRAM_ADDR_BIT'd0;
        request_o <= 1'b0;
        t_out_o <= 3'd0;

        buffer <= `SRAM_WORD_WIDTH'd0;
        buffer_counter <= `DNA_PER_WORD_BIT'd0;
    end else begin
        state <= n_state;
        busy_o <= n_busy_o;
        first <= n_first;
        
        for ( i= 0; i < REG_DEPTH; i = i+1)data_reg[i] <= n_data_reg[i];
        data_counter <= n_data_counter;
        addr_o <= n_addr_o;
        request_o <= n_request_o;
        t_out_o <= n_t_out_o;

        buffer <= n_buffer;
        buffer_counter <= n_buffer_counter;
    end
end
endmodule // Parser_T
`endif