`timescale 1ns/10ps
`define CYCLE 10.0

module Core_tb;

// clk generation
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;


// dump waveform
// vcd
initial begin
    $dumpfile("Core.vcd");
    $dumpvars(0, core0);
end
// fsdb
// initial begin
//     $fsdbDumpfile("Core.fsdb");
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
reg           rst_n = 1;
reg           STDW = 0, STDR = 0;
reg     [5:0] STD_A = 0;
reg   [287:0] weight_in = 0;
reg   [255:0] act_in1 = 0, act_in2 = 0, act_in3 = 0;
reg           slide_en = 1;
wire  [287:0] weight_out;
wire [1007:0] PSUM;

Core core0(
    .clk(clk),
    .rst_n(rst_n),
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in), // 4b x 8
    .act_in1(act_in1), // 4b x 64
    .act_in2(act_in2), // 4b x 64
    .act_in3(act_in3), // 4b x 64
    .slide_en(slide_en), // 1b
    .weight_out(weight_out),// 4b x 8
    .PSUM(PSUM) // 14b x 8 output
);

// input pattern
integer i;

initial begin
    // update weight
    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;
    @(posedge clk) STDW = 1;
    @(posedge clk)
    for (i = 0; i < 64; i = i+1) begin
        STD_A = STD_A + 1;
        weight_in = 288'b0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001;
        @(posedge clk);
    end
    @(posedge clk)
    STDW = 0;
    STDR = 1;
    STD_A = 35;
    @(posedge clk)
    STDW = 0;
    STDR = 0;
    act_in1 <= 256'b0001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001;
    act_in2 <= 256'b0001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001;
    act_in3 <= 256'b0001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001;
    @(posedge clk)
    act_in1  <= 256'd1111;
    slide_en <= 1'b1;
    @(posedge clk)
    act_in1 <= 256'b10;
    @(posedge clk)
    act_in1 <= 256'b11;
    @(posedge clk)
    act_in1  <= 256'b100;
    slide_en <= 1'b0;
end

endmodule