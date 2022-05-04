`timescale 1ns/10ps
`define CYCLE 10.0

module Aggregator_tb;

// ================= clk generation =====================
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;


// ================= dump waveform ======================
// // vcd
// initial begin
//     $dumpfile("Aggregator.vcd");
//     $dumpvars(0, aggre0);
// end
// fsdb
initial begin
    $fsdbDumpfile("Aggregator.fsdb");
    $fsdbDumpvars(0, "+mda");
end

// ================== time out ==========================
initial begin
    # (10000 * `CYCLE);
    $display("\n\033[1;31m=============================================");
	$display("           Simulation Time Out!      ");
	$display("=============================================\033[0m");
	$finish;
end

// ================= instantiate DUT ====================
parameter IN_PRECISION = 3;
parameter OUT_PRECISION = 6;
parameter DIM = 3;
reg                           rst_n = 1;
reg                           clear = 0;
reg  [IN_PRECISION*DIM-1: 0]  aggre_in = 0;
wire [OUT_PRECISION*DIM-1: 0] aggre_out;

Aggregator #(
    .IN_PRECISION(IN_PRECISION),
    .OUT_PRECISION(OUT_PRECISION),
    .DIM(DIM)
) aggre0(
    .clk(clk),
    .rst_n(rst_n),
    .clear(clear),
    .aggre_in(aggre_in),
    .aggre_out(aggre_out)
);


// ===== input pattern & result checking ===========
initial begin
    // 10
    @(posedge clk) rst_n = 0;
    // 20
    @(posedge clk) 
    rst_n = 1;
    aggre_in = 9'b0;
    // 30
    @(posedge clk) aggre_in = 9'b001100101;
    // 40
    @(posedge clk) aggre_in = 9'b100011101;
    // 50
    @(posedge clk) aggre_in = 9'b101110001;
    // 60
    @(posedge clk)
    aggre_in = 9'b010101011;
    clear    = 1'b1;
    @(posedge clk);
    @(posedge clk);
    $finish;
end


endmodule