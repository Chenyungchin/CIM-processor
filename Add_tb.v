`timescale 1ns / 10ps
`define CYCLE 10.0
`define PATTERN 100

module Add_tb;

// clk generation
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;

// dump waveform
// vcd
// initial begin
//     $dumpfile("add.vcd");
//     $dumpvars;
// end
// fsdb
initial begin
    $fsdbDumpfile("add.fsdb");
    $fsdbDumpvars(0, "+mda");
end


// time out
initial begin
    #(100000 * `CYCLE);
    $display("\n\033[1;31m=============================================");
	$display("           Simulation Time Out!      ");
	$display("=============================================\033[0m");
	$finish;
end

// instantiate DUT
reg  [3:0] a, b;
wire [4:0] c;

Add add0(
    .a(a),
    .b(b),
    .c(c)
);

// Initial memory
reg [3:0] INPUT_A_MEM  [0:`PATTERN-1];
reg [3:0] INPUT_B_MEM  [0:`PATTERN-1];
reg [4:0] GOLDEN_C_MEM [0:`PATTERN-1];

initial begin
    $readmemb("pattern/add_pattern/add_in_a.dat", INPUT_A_MEM);
    $readmemb("pattern/add_pattern/add_in_b.dat", INPUT_B_MEM);
    $readmemb("pattern/add_pattern/add_out_c.dat", GOLDEN_C_MEM);
end

// input pattern & check result
integer i, j;
integer err_num = 0;

initial begin
    for (i=0; i<10; i=i+1) begin
        @(posedge clk);
    end
    for (i=0; i<`PATTERN; i=i+1) begin
        a = INPUT_A_MEM[i];
        b = INPUT_B_MEM[i];
        @(posedge clk);
    end
    a = 'bx;
    b = 'bx;
end

// check output 
initial begin
    for (j=0; j<11; j=j+1) begin
        @(negedge clk);
    end
    for (j=0; j<`PATTERN; j=j+1) begin
        if (GOLDEN_C_MEM[j] === c && c !== 4'bx) begin
            $display("\033[1;92mPattern %3d passed. / Input A:%4d / Input B:%4d / Output C: %4d / Golden C: %4d\033[0m", j, INPUT_A_MEM[j],INPUT_B_MEM[j],c, GOLDEN_C_MEM[j]);
        end
        else begin
            $display("\033[1;31mPattern %3d failed. / Input A:%4d / Input B:%4d / Output C: %4d / Golden C: %4d\033[0m", j, INPUT_A_MEM[j],INPUT_B_MEM[j],c, GOLDEN_C_MEM[j]);
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