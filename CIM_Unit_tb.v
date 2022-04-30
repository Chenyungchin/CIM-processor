`timescale 1ns/10ps
`define CYCLE 10.0

module CIM_Unit_tb;

// ========== clk generation ==============
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;


// ========== dump waveform ===============
// vcd
initial begin
    $dumpfile("CIM_Unit.vcd");
    $dumpvars(0, CIM_Unit0);
end
// fsdb
// initial begin
//     $fsdbDumpfile("CIM_Unit.fsdb");
//     $fsdbDumpvars(0, "+mda");
// end

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
reg           CIM_Core_A = 0;
reg           CIM_en = 0, STR_en = 0;
reg     [5:0] STD_row_A = 0;
reg   [287:0] weight_in = 0;
reg   [255:0] act_in1 = 0, act_in2 = 0, act_in3 = 0;
wire  [287:0] weight_out;
wire [1007:0] PSUM;

CIM_Unit CIM_Unit0(
    .clk(clk),
    .rst_n(rst_n),
    .CIM_Core_A(CIM_Core_A),
    .CIM_en(CIM_en),
    .STR_en(STD_en),
    .STDW(STDW),
    .STDR(STDR),
    .STD_row_A(STD_row_A),
    .weight_in(weight_in), // 4b x 8
    .act_in1(act_in1), // 4b x 64
    .act_in2(act_in2), // 4b x 64
    .act_in3(act_in3), // 4b x 64
    .weight_out(weight_out),// 4b x 8
    .PSUM(PSUM) // 14b x 8 output
);

// ========= input pattern ================
integer i;

initial begin
    // update weight
    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;
    @(posedge clk) STDW = 1;
    // store data into core4
    @(posedge clk)
    STD_Core_A = 3'd4;
    for (i = 0; i < 64; i = i+1) begin
        STD_row_A = STD_row_A + 1;
        weight_in = 288'b0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001;
        @(posedge clk);
    end
    @(posedge clk)
    // read data from core4
    STDW = 0;
    STDR = 1;
    STD_row_A = 35;
    @(posedge clk)
    // operate CIM at core 4 and store data into core3
    CIM_Core_A = 3'd4;
    STD_Core_A = 3'd3;
    STDW = 1;
    STDR = 0;
    act_in1 <= 256'b0001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001;
    act_in2 <= 256'b0001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001;
    act_in3 <= 256'b0001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001;
    for (i = 0; i < 64; i = i+1) begin
        STD_row_A = STD_row_A + 1;
        weight_in = 288'b0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001;
        @(posedge clk);
    end

    // read data from core3
    STDW = 0;
    STDR = 1;
    STD_row_A = 26;
end

endmodule