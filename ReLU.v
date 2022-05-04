// pass the data through relu for activation function, the quantize the precision back to 4 bit
// IN_PRECISION is the input precision
// OUT_PRECISION is the output precision
module ReLU #(
    parameter IN_PRECISION = 18,
    parameter OUT_PRECISION = 4
)(
    input                              clk,
    input                              rst_n,
    input      [IN_PRECISION*64-1 : 0] relu_in, 
    output     [OUT_PRECISION*64-1: 0] relu_out
);

genvar i;
generate
    for (i=0; i<64; i=i+1) begin
        // if sign bit of relu_in is 0, then output the ms4b of relu_in (not include sign bit), else output 0
        assign relu_out[OUT_PRECISION*(i+1)-1 -: OUT_PRECISION] = (relu_in[IN_PRECISION*(i+1)-1] == 0) ? relu_in[IN_PRECISION*(i+1)-2 -: OUT_PRECISION] : 0;
    end
endgenerate


endmodule