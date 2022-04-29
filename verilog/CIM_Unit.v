// The CIM Unit consists of 8 Cores. It supports concurrent weight update
// There will be two modes
// == 1. CIM + STD: CIM_Core_A points to the CIM core, STD_Core_A points to the STD Core
// == 2. Only CIM (No STD): Both CIM_Core_A and STD_Core_A point to the CIM Core 
module CIM_Unit(
    // input              IN_valid, 
    input              clk,
    input              rst_n,
    input        [2:0] CIM_Core_A, // address for determining which core to perform CIM operation
    input        [2:0] STD_Core_A, // address for determining which core to perform standard memory R/W
    input              STDW, // == 1 if standard write mode (weight updating)
    input              STDR, // == 1 if standard read mode
    input        [5:0] STD_row_A, // address for determining which row (1 out of 64) to read/write
    input      [287:0] weight_in, // update 4b x 8 x 9 weight when STDW
    // input              CIM_A,
    input      [255:0] act_in1, // 4b x 64
    input      [255:0] act_in2, // 4b x 64
    input      [255:0] act_in3, // 4b x 64
    output     [287:0] weight_out, // read out 4b x 8 x 9 (= 288) weight when STDR
    output    [1007:0] PSUM // 14b x 8 x 9(= 1008) output
);

// ================== param and var ==================
genvar i, ii;

// ================== reg and wire ===================
wire  [1007:0] PSUM_core       [0:7];
wire   [287:0] weight_out_core [0:7];

wire           STDW_core       [0:7];
wire           STDR_core       [0:7];

// ================== assignments ====================
assign weight_out = weight_out_core[STD_Core_A];
assign PSUM = PSUM_core[CIM_Core_A];
generate
    // STDW_core will only be 1 if STDW if true and the core address is correct
    for (ii = 0; ii < 8; ii = ii+1) begin
        assign STDW_core[ii] = STDW & (ii == STD_Core_A) & (STD_Core_A != CIM_Core_A);
    end
    // STDR_core will only be 1 if STDR if true and the core address is correct
    for (ii = 0; ii < 8; ii = ii+1) begin
        assign STDR_core[ii] = STDR & (ii == STD_Core_A) & (STD_Core_A != CIM_Core_A);
    end
endgenerate

// ================== Combinational ==================


// ================== call module ====================
generate
    for (i = 0; i < 8; i = i+1) begin
        Core core0(
            .clk(clk),
            .rst_n(rst_n),
            .STDW(STDW_core[i]),
            .STDR(STDR_core[i]),
            .STD_A(STD_row_A),
            .weight_in(weight_in), // 4b x 8
            .act_in1(act_in1), // 4b x 64
            .act_in2(act_in2), // 4b x 64
            .act_in3(act_in3), // 4b x 64
            .weight_out(weight_out_core[i]),// 4b x 8
            .PSUM(PSUM_core[i]) // 14b x 8 output
        );
    end
endgenerate

endmodule