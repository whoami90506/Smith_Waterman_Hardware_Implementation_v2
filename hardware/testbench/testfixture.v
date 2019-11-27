`timescale 1ns/1ps
`define CYCLE    2.23           	        // Modify your clock period here
`define TERMINATION  50000

`define DATA_T "./testbench/dat/target01.dat"
`define DATA_Q "./testbench/dat/query01.dat"

`define TB_MATCH    `MATCH_BIT'd6
`define TB_MISMATCH `MATCH_BIT'd1
`define TB_ALPHA    `MATCH_BIT'd2
`define TB_BETA     `MATCH_BIT'd1

//`define DEBUG

`ifdef SYN
	`define SDF
	`define SDFFILE "syn/SmithWaterman_syn.sdf"
`endif

`include "src/parameter.v"

module testfixture ();

//control
reg clk, rst_n;
reg down, has_started;
integer t_idx, q_idx;

//main module
reg start;
reg [`SRAM_WORD_WIDTH-1 : 0] data;
wire [`SRAM_ADDR_BIT-1 : 0] addr;
wire [`CALC_BIT-1 : 0 ] result, max_result;
wire [`MAX_T_NUM_BIT-1 : 0] match_idx;
wire valid, busy, sel_T, change_q;
SmithWaterman u_SmithWaterman(.clk(clk), .rst_n(rst_n), .start_i(start), .busy_o(busy), 
							  .select_T_o(sel_T), .data_i(data), .addr_o(addr), 
							  .result_o(result), .valid_o(valid), .match_idx_o(match_idx), .change_q_o(change_q), .max_result_o(max_result),
							  .match_i(`TB_MATCH), .mismatch_i(`TB_MISMATCH), .alpha_i(`TB_ALPHA), .beta_i(`TB_BETA));

//memory
parameter SRAM_ADDR = 1 << `SRAM_ADDR_BIT;
reg [`SRAM_WORD_WIDTH-1 : 0] T_mem [0 : SRAM_ADDR -1];
reg [`SRAM_WORD_WIDTH-1 : 0] Q_mem [0 : SRAM_ADDR -1];

initial begin
	clk = 1'b1;
	rst_n = 1'b1;
	down = 1'b0;
	start = 1'b0;
	t_idx = 0;
	q_idx = 0;
	has_started = 1'b0;

	//reset
	@(negedge clk); rst_n = 1'b0;
	#(`CYCLE * 10); rst_n = 1'b1;

	`ifdef DEBUG
		$monitor("[%10t] state of pT, pQ : %b, %b", $time, u_SmithWaterman.pT.state, u_SmithWaterman.pQ.state);
	`endif

	#(`CYCLE *5 ); start = 1'b1;
	$display("[%10t] start calculating.", $time);
	#(`CYCLE    ); start = 1'b0;
	has_started = 1'b1;

end

initial begin
	$timeformat(-9, 0, " ns", 17);

	`ifdef SYN
		$fsdbDumpfile("sw_syn.fsdb");
	`else
		$fsdbDumpfile("sw.fsdb"); 
		$fsdbDumpMDA;
	`endif
	$fsdbDumpvars;

	`ifdef SDF
		$sdf_annotate(`SDFFILE, u_SmithWaterman);
	`endif

	$readmemb(`DATA_T, T_mem);
	$readmemb(`DATA_Q, Q_mem);

	$display("======================================================================");
	$display("Start simulation !");
	`ifdef DEBUG
		$display("DEBUG mode");
	`endif
	$display("======================================================================");
	//$finish;
end

always @(negedge clk) begin
	data = sel_T ? T_mem[addr] : Q_mem[addr];

	if(valid) begin
		$display("[%10t] result of target[%3d] and query[%3d]: %5d", $time, t_idx, q_idx, result);
		
		if (change_q) begin
			$display("[%10t] the most similar target to query[%3d]: target[%3d], score = %5d", $time, q_idx, match_idx, max_result);
			$display("====== query %0d finish ======", q_idx);

			t_idx = 0;
			q_idx = q_idx +1;
		end else begin
			t_idx = t_idx +1;
		end
	end

	if(has_started & ~busy) begin
		$display("[%10t] busy = 0", $time);
		down = 1'b1;
	end

end

always  #(`CYCLE/2.0) clk = ~clk;

initial begin
	#(`TERMINATION * `CYCLE);
	$display("================================================================================================================");
	$display("(/`n`)/ ~#  There is something wrong with your code!!"); 
	$display("Time out!! The simulation didn't finish after %0d cycles!!, Please check it!!!", `TERMINATION); 
	$display("================================================================================================================");
	#`CYCLE $finish;
end

initial begin
	@(posedge down);
	$display("============================================================================");
    // $display("\n");
    // $display("        ****************************              ");
    // $display("        **                        **        /|__/|");
    //$display("        **  Congratulations !!    **      / O,O  |");
    // $display("        **                        **    /_____   |");
    //$display("        **  Simulation Complete!! **   /^ ^ ^ \\  |");
    // $display("        **                        **  |^ ^ ^ ^ |w|");
    // $display("        *************** ************   \\m___m__|_|");
    // $display("\n");
    //$display("============================================================================");

	# `CYCLE $finish;
end
endmodule
