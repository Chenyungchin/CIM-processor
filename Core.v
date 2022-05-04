// A Core consists of 8 macro array
// every macro array receives the same input activation, but the weights are different between arrays
module Core(
    // input               IN_valid, 
    input               clk,
    input               rst_n,
    input               CIM_en,
    input               STDW, // == 1 if standard write mode (weight updating)
    input               STDR, // == 1 if standard read mode
    input         [5:0] STD_A, // address for determining which row (1 out of 64) to read/write
    input      [2303:0] weight_in, // update 4b x 8 x 9 x 8 (= 2304) weight when STDW
    // input               CIM_A,
    input       [255:0] act_in1, // 4b x 64
    input       [255:0] act_in2, // 4b x 64
    input       [255:0] act_in3, // 4b x 64
    input               slide_en, // signal controlling whether registers pass data horizontally to the next (pass signals when slide_en == 1)
    output     [2303:0] weight_out, // read out 4b x 8 x 9 x 8 (= 2303) weight when STDR
    output     [1151:0] PSUM // 18b x 8 x 8(= 1152) output
);

genvar i;
// ============ reg & wire =============================

// ============ Combinational ==========================

// ============ Sequential =============================

// ============ Module Instantiation ===================
generate
    for (i=0; i<8; i=i+1) begin
        Macro_Array macro_array0(
            .clk(clk),
            .rst_n(rst_n),
            .CIM_en(CIM_en),
            .STDW(STDW),
            .STDR(STDR),
            .STD_A(STD_A),
            .weight_in(weight_in[288*i+287 -: 288]), // 4b
            .act_in1(act_in1), // 4b x 64
            .act_in2(act_in2), // 4b x 64
            .act_in3(act_in3), // 4b x 64
            .slide_en(slide_en),
            .weight_out(weight_out[288*i+287 -: 288]),
            .PSUM(PSUM[144*i+143 -: 144]) // 14b output
        );
    end
endgenerate


endmodule 