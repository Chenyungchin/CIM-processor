

module Weight_sram_32X2304 (
	input               clk,
	input               ceb,
	input               web,
	input      [4:0]    A_row,
	input      [6:0]    A_col,
	input      [31:0]   D,
	output reg [2303:0] Q
);

reg  [2303:0] memory [0:31];
wire [31:0]   wdata_w;
wire [2303:0] rdata_w;

assign wdata_w = D;
assign rdata_w = (!ceb && web)? memory[A_row]: 2304'hz;

always @(posedge clk ) begin 
	Q <= rdata_w;
end
always @(posedge clk) begin
	if(!(ceb) && !(web))
		memory[A_row][32*(A_col+1)-1 -: 32] <= wdata_w;
	else
		memory[A_row][32*(A_col+1)-1 -: 32] <= memory[A_row][32*(A_col+1)-1 -: 32];
end

endmodule