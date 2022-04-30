// A CIM Macro consists of 8 CIM PEs
module Macro(
    // input              IN_valid, 
    input              STDW, // == 1 if standard write mode (weight updating)
    input              STDR, // == 1 if standard read mode
    input        [5:0] STD_A, // address for determining which row (1 out of 64) to read/write
    input       [31:0] weight_in, // update 4b x 8 weight when STDW
    // input              CIM_A,
    input      [255:0] act_in, // 4b x 64
    output      [31:0] weight_out, // read out 4b x 8 weight when STDR
    output     [111:0] PSUM // 14b x 8 output
);

genvar i;

for (i = 0; i < 8; i = i+1) begin
    PE pe0(
        .STDW(STDW),
        .STDR(STDR),
        .STD_A(STD_A),
        .weight_in(weight_in[4*i+3 -: 4]), // 4b
        .act_in(act_in), // 4b x 64
        .weight_out(weight_out[4*i+3 -: 4]),
        .PSUM(PSUM[14*i+13 -: 14]) // 14b output
    );
end


endmodule