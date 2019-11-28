`ifdef BUFFER_V
`else
`define BUFFER_V

`include "src/parameter.v"

module Buffer (
    input clk,
    input rst_n,

    input [2:0] q_i,
    input pouring_i, pouring_last_i,

    input update_iw,
    output reg [2:0] q_o,

    output reg full_o, ready_one_o, ready_two_o,
    output [2:0] next_q_ow
);

wire [2:0] n_q_o;
wire n_full_o, n_ready_one_o, n_ready_two_o;

reg [`BUFFER_DEPTH_BIT-1 : 0] size, n_size;
reg [`BUFFER_DEPTH_BIT-1 : 0] read_ptr, n_read_ptr;  
reg [`BUFFER_DEPTH_BIT-1 : 0] write_ptr, n_write_ptr;  

reg [2:0]   data [0 : `BUFFER_DEPTH -1];
reg [2:0] n_data [0 : `BUFFER_DEPTH -1];
reg got_data;
wire n_got_data;
wire get, send;

assign n_q_o = data[n_read_ptr];
assign n_full_o = n_size == `BUFFER_DEPTH;
assign n_ready_one_o = n_size >= 1;
assign n_ready_two_o = n_size >= 2;
assign n_got_data = got_data ? pouring_i : q_i[2];
assign get = (q_i[2] | (pouring_last_i & ~pouring_i & ~got_data)) & ~(full_o & ~update_iw);
assign send = update_iw && (size != `BUFFER_DEPTH_BIT'd0);
assign next_q_ow = n_q_o;

integer i;
always @(*) begin
    for(i = 0; i < `BUFFER_DEPTH; i = i+1)n_data[i] = data[i];

    case({get, send})
        
        2'b00 : begin
            n_read_ptr = read_ptr;
            n_write_ptr = write_ptr;
            n_size = size;
        end

        2'b10 : begin // get
            n_read_ptr = read_ptr;
            n_write_ptr = (write_ptr == `BUFFER_DEPTH-1) ? `BUFFER_DEPTH_BIT'd0 : write_ptr + `BUFFER_DEPTH_BIT'd1;
            n_size = size + `BUFFER_DEPTH_BIT'd1;
            n_data[write_ptr] = q_i[2] ? q_i : 3'b000;
        end

        2'b01 : begin //send
            n_read_ptr = (read_ptr == `BUFFER_DEPTH-1) ? `BUFFER_DEPTH_BIT'd0 : read_ptr + `BUFFER_DEPTH_BIT'd1;
            n_write_ptr = write_ptr;
            n_size = size - `BUFFER_DEPTH_BIT'd1;
            //n_data[read_ptr] = 3'b000;
        end

        2'b11 : begin
            n_read_ptr = (read_ptr == `BUFFER_DEPTH-1) ? `BUFFER_DEPTH_BIT'd0 : read_ptr + `BUFFER_DEPTH_BIT'd1;
            n_write_ptr = (write_ptr == `BUFFER_DEPTH-1) ? `BUFFER_DEPTH_BIT'd0 : write_ptr + `BUFFER_DEPTH_BIT'd1;
            n_size = size;
            n_data[write_ptr] = q_i[2] ? q_i : 3'b000;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        q_o <= 3'b000;
        full_o <= 1'b0;
        ready_one_o <= 1'b0;
        ready_two_o <= 1'b0;

        size <= `BUFFER_DEPTH_BIT'd0;
        read_ptr <= `BUFFER_DEPTH_BIT'd0;
        write_ptr <= `BUFFER_DEPTH_BIT'd0;

        for(i = 0; i < `BUFFER_DEPTH; i = i+1)data[i] <= 3'b000;
        got_data <= 1'b0;

    end else begin
        q_o <= n_q_o;
        full_o <= n_full_o;
        ready_one_o <= n_ready_one_o;
        ready_two_o <= n_ready_two_o;

        size <= n_size;
        read_ptr <= n_read_ptr;
        write_ptr <= n_write_ptr;

        for(i = 0; i < `BUFFER_DEPTH; i = i+1)data[i] <= n_data[i];
        got_data <= n_got_data;
    end
end

endmodule
`endif