

module Activation_sram_32X768 (
	input              clk,
	input              ceb,
	input              web,
	input              WB_from_PIP, // true when writing the CIM calculated value to act_mem, need to write 256 bit a time
	input      [4:0]   A_row,
	input      [4:0]   A_col,
	input      [255:0] D,
	output reg [767:0] Q
);

reg  [767:0] memory   [0:31];
wire [31:0]  wdata_w_32b;
wire [255:0] wdata_w_256b;
wire [767:0] rdata_w;

assign wdata_w_32b  = D[31:0];
assign wdata_w_256b = D;
assign rdata_w = (!ceb && web)? memory[A_row]: 768'hz;

always @(posedge clk ) begin 
	Q <= rdata_w;
end
always @(posedge clk) begin
	if(!(ceb) && !(web)) begin
		if (WB_from_PIP)  memory[A_row][256*(A_col[1:0]+1)-1 -: 256] <= wdata_w_256b;
		else              memory[A_row][32*(A_col+1)-1 -: 32]        <= wdata_w_32b;
	end
		
	else
		memory[A_row]   <= memory[A_row];
end

endmodule