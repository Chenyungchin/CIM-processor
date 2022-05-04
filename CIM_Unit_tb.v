`timescale 1ns/10ps
`define CYCLE 10.0
`define PATTERN 85

module CIM_Unit_tb;

// ================= clk generation =====================
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;


// ================= dump waveform ======================
// vcd
// initial begin
//     $dumpfile("CIM_Unit.vcd");
//     $dumpvars(0, cim_unit0);
// end
// fsdb
initial begin
    $fsdbDumpfile("CIM_Unit.fsdb");
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
reg           rst_n;
reg           CIM_Core_A;
reg           CIM_en;
reg           STDW, STDR;
reg     [5:0] STD_A;
reg  [2303:0] weight_in;
reg   [255:0] act_in1, act_in2, act_in3;
reg           slide_en;
wire [2303:0] weight_out;
wire  [143:0] PSUM;

CIM_Unit cim_unit0(
    .clk(clk),
    .rst_n(rst_n),
    .CIM_Core_A(CIM_Core_A),
    .CIM_en(CIM_en),
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in), // 4b
    .act_in1(act_in1), // 4b x 64
    .act_in2(act_in2), // 4b x 64
    .act_in3(act_in3), // 4b x 64
    .slide_en(slide_en),
    .weight_out(weight_out),
    .PSUM(PSUM) // 14b output
);

// ============== Initial Memory ====================
reg [2:0]   INPUT_CMD_MEM          [0:`PATTERN-1];
reg [5:0]   INPUT_STD_A_MEM        [0:`PATTERN-1];
reg [287:0] INPUT_WEIGHT_IN_MEM    [0:`PATTERN-1];
reg [255:0] INPUT_ACT_IN1_MEM      [0:`PATTERN-1];
reg [255:0] INPUT_ACT_IN2_MEM      [0:`PATTERN-1];
reg [255:0] INPUT_ACT_IN3_MEM      [0:`PATTERN-1];
reg [287:0] GOLDEN_WEIGHT_OUT_MEM  [0:`PATTERN-1];
reg [143:0] GOLDEN_PSUM_MEM        [0:`PATTERN-1];

initial begin
    $readmemb("pattern/Macro_Array_pattern/command.dat", INPUT_CMD_MEM);
    $readmemb("pattern/Macro_Array_pattern/STD_A.dat", INPUT_STD_A_MEM);
    $readmemb("pattern/Macro_Array_pattern/weight_in.dat", INPUT_WEIGHT_IN_MEM);
    $readmemb("pattern/Macro_Array_pattern/act_in1.dat", INPUT_ACT_IN1_MEM);
    $readmemb("pattern/Macro_Array_pattern/act_in2.dat", INPUT_ACT_IN2_MEM);
    $readmemb("pattern/Macro_Array_pattern/act_in3.dat", INPUT_ACT_IN3_MEM);
    $readmemb("pattern/Macro_Array_pattern/weight_out.dat", GOLDEN_WEIGHT_OUT_MEM);
    $readmemb("pattern/Macro_Array_pattern/PSUM.dat", GOLDEN_PSUM_MEM);
end

// ===== input pattern & result checking ===========
integer i, j;
integer err_num = 0;

// input pattern
initial begin
    rst_n = 0;
    slide_en = 1;
    @(posedge clk) rst_n = 1;
    for (i=0; i<10; i=i+1) begin
        @(posedge clk);
    end
    for (i=0; i<`PATTERN; i=i+1) begin
        CIM_en = INPUT_CMD_MEM[i][2];
        STDW   = INPUT_CMD_MEM[i][1];
        STDR   = INPUT_CMD_MEM[i][0];
        STD_A  = INPUT_STD_A_MEM[i];
        weight_in = INPUT_WEIGHT_IN_MEM[i];
        act_in1 <= INPUT_ACT_IN1_MEM[i];
        act_in2 <= INPUT_ACT_IN2_MEM[i];
        act_in3 <= INPUT_ACT_IN3_MEM[i];
        @(posedge clk);
    end
    CIM_en = 'bx;
    STDW   = 'bx;
    STDR   = 'bx;
    STD_A  = 'bx;
    weight_in = 'bx;
    act_in1 = 'bx;
    act_in2 = 'bx;
    act_in3 = 'bx;
end

// check output
initial begin
    @(posedge clk);
    for (j=0; j<11; j=j+1) begin
        @(negedge clk);
    end
    for (j=0; j<`PATTERN; j=j+1) begin
        if (GOLDEN_PSUM_MEM[j] === PSUM && PSUM !== 14'bx) begin
            $display("\033[1;92mPattern %3d passed. / Output PSUM: %43d / Golden PSUM: %43d\033[0m", j, PSUM, GOLDEN_PSUM_MEM[j]);
        end
        else begin
            $display("\033[1;31mPattern %3d failed. / Output PSUM: %43d / Golden PSUM: %43d\033[0m", j, PSUM, GOLDEN_PSUM_MEM[j]);
            err_num = err_num + 1;
        end
        @(negedge clk);
    end

    if (err_num != 0) begin
        $display("\n\033[1;31m=============================================");
		$display("              Simulation failed              ");
		$display("=============================================\033[0m");
    end
    else begin
        $display("\n\033[1;92m=============================================");
		$display("              Simulation passed              ");
		$display("=============================================\033[0m");
    end

    $finish;
end


endmodule