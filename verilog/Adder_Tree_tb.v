`timescale 1ns/10ps
`define CYCLE 10.0

module Adder_Tree_tb;

// ========== clk generation ==============
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;


// ========== dump waveform ===============
initial begin
    $fsdbDumpfile("Adder_Tree.fsdb");
    $fsdbDumpvars(0, "+mda");
end

// ========== time out ====================
initial begin
    # (10000 * `CYCLE);
    $display("\n\033[1;31m=============================================");
	$display("           Simulation Time Out!      ");
	$display("=============================================\033[0m");
	$finish;
end

// ========== instantiate DUT =============
reg           rst_n = 1;
reg           STDW = 0, STDR = 0;
reg  [1007:0] PSUM = 0;
reg     [1:0] mode = 0;
wire  [287:0] res;

Adder_Tree Adder_Tree0(
    .clk(clk),
    .rst_n(rst_n),
    .PSUM(PSUM), // 14b x 8 x 9 input
    .mode(mode),
    .res(res)
);

// ========= input pattern ================
integer i;

initial begin
    // reset
    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;
    for (i = 0; i < 5; i = i+1) begin
        @(posedge clk);
    end

    // test mode 0
    @(posedge clk) mode <= 0;
    PSUM = 1008'b100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000100000000000001000000000000010000000000000;
    // test mode 1
    @(posedge clk);
    @(posedge clk) mode <= 1;

    // test mode 2
    @(posedge clk);
    @(posedge clk) mode <= 2;
end

endmodule