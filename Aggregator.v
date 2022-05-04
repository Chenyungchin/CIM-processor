// input: 18x8x8 output: 21x8x8
// the 3 bit increment is because it takes 8 CIM cycles to finish a 512-size filter conv.
// "clear" signal need to be sent for every new accumulations. (sent simultaneously with the new partial sum from CIM_Unit)
module Aggregator #(
    parameter IN_PRECISION = 18,
    parameter OUT_PRECISION = 21,
    parameter DIM = 64
)(
    input            clk,
    input            rst_n,
    input            clear,
    input   [IN_PRECISION*DIM-1:0] aggre_in, // input size: 18x8x8 = 1152
    output  [OUT_PRECISION*DIM-1:0] aggre_out // output size: 21x8x8 = 1344
);

reg   [OUT_PRECISION*DIM-1:0] aggre_buffer;

genvar i;
integer j;
generate
    for (i=0; i<DIM; i=i+1) begin
        assign aggre_out[OUT_PRECISION*(i+1)-1 -: OUT_PRECISION] = aggre_buffer[OUT_PRECISION*(i+1)-1 -: OUT_PRECISION] + aggre_in[IN_PRECISION*(i+1)-1 -: IN_PRECISION];
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        aggre_buffer <= 0;
    end
    else begin
        if (clear) begin
            // flush the value in the buffer
            aggre_buffer <= 0;
        end
        else begin
            // store the output value to the register
            aggre_buffer <= aggre_out;
        end
    end
end

endmodule