`timescale 1ns/10ps
`define CYCLE 10.0

module Macro_tb;

// clk generation
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;


// dump waveform
// vcd
// vcd
initial begin
    $dumpfile("Macro.vcd");
    $dumpvars(0, macro0);
end
// fsdb
// initial begin
//     $fsdbDumpfile("Macro.fsdb");
//     $fsdbDumpvars(0, "+mda");
// end

// time out
initial begin
    # (10000 * `CYCLE);
    $display("\n\033[1;31m=============================================");
	$display("           Simulation Time Out!      ");
	$display("=============================================\033[0m");
	$finish;
end

// instantiate DUT
reg          STDW = 0, STDR = 0;
reg    [5:0] STD_A = 0;
reg   [31:0] weight_in = 0;
reg  [255:0] act_in = 0;
wire  [31:0] weight_out;
wire [111:0] PSUM;

Macro macro0(
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in), // 4b x 8
    .act_in(act_in), // 4b x 64
    .weight_out(weight_out),// 4b x 8
    .PSUM(PSUM) // 14b x 8 output
);

// input pattern
integer i;

initial begin
    // update weight
    @(posedge clk) STDW = 1;
    @(posedge clk)
    for (i = 0; i < 64; i = i+1) begin
        STD_A = STD_A + 1;
        weight_in = 32'b0000_0001_0010_0011_0100_0101_0110_0111;
        @(posedge clk);
    end
    @(posedge clk)
    STDW = 0;
    STDR = 1;
    STD_A = 35;
    @(posedge clk)
    STDW = 0;
    STDR = 0;
    act_in = 256'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
end

endmodule