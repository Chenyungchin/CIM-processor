

module Instruction_sram_32X32 (
	input              clk,
	input              ceb,
	input              web,
	input      [4:0]  A,
	input      [31:0] D,
	output reg [31:0] Q
);

reg [31:0] memory [0:31];
wire [31:0] wdata_w;
wire [31:0] rdata_w;

assign wdata_w = D;
assign rdata_w = (!ceb && web)? memory[A]: 32'hz;

always @(posedge clk ) begin 
	Q <= rdata_w;
end
always @(posedge clk) begin
	if(!(ceb) && !(web))
		memory[A] <= wdata_w;
	else
		memory[A] <= memory[A];
end

endmodule