// A CIM Core consists of 9 CIM Macros (layout: 3x3)
// This design adopts horizontal pipeline, thus, the columns are separated by flip-flops
module Core(
    // input               IN_valid, 
    input               clk,
    input               rst_n,
    input               STDW, // == 1 if standard write mode (weight updating)
    input               STDR, // == 1 if standard read mode
    input         [5:0] STD_A, // address for determining which row (1 out of 64) to read/write
    input       [287:0] weight_in, // update 4b x 8 x 9 weight when STDW
    // input               CIM_A,
    input       [255:0] act_in1, // 4b x 64
    input       [255:0] act_in2, // 4b x 64
    input       [255:0] act_in3, // 4b x 64
    output      [287:0] weight_out, // read out 4b x 8 x 9 (= 288) weight when STDR
    output      [1007:0] PSUM // 14b x 8 x 9(= 1008) output
);

genvar i;
integer j, k;
// ====================regs & wires======================
// the input "act_in1~3" are for column0
reg   [255:0] act_column1_in1;
reg   [255:0] act_column1_in2;
reg   [255:0] act_column1_in3;
reg   [255:0] act_column2_in1;
reg   [255:0] act_column2_in2;
reg   [255:0] act_column2_in3;


// ==================== Combinational ================


// ==================== Sequential ===================

// horizontal pipeline: pass the input activation horizontally
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        act_column1_in1 <= 256'b0;
        act_column1_in2 <= 256'b0;
        act_column1_in3 <= 256'b0;
        act_column2_in1 <= 256'b0;
        act_column2_in2 <= 256'b0;
        act_column2_in3 <= 256'b0;
    end
    else begin
        act_column1_in1 <= act_in1;
        act_column1_in2 <= act_in2;
        act_column1_in3 <= act_in3;
        act_column2_in1 <= act_column1_in1;
        act_column2_in2 <= act_column1_in2;
        act_column2_in3 <= act_column1_in3;
    end
end

// ================= Macro Array =====================
// row0
Macro macro00(
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[31: 0]), // 4b x 8
    .act_in(act_in1), // 4b x 64
    .weight_out(weight_out[31: 0]),// 4b x 8
    .PSUM(PSUM[111:0]) // 14b x 8 output
);

Macro macro10(
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[63: 32]), // 4b x 8
    .act_in(act_column1_in1), // 4b x 64
    .weight_out(weight_out[63: 32]),// 4b x 8
    .PSUM(PSUM[223:112]) // 14b x 8 output
);

Macro macro20(
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[95: 64]), // 4b x 8
    .act_in(act_column2_in1), // 4b x 64
    .weight_out(weight_out[95: 64]),// 4b x 8
    .PSUM(PSUM[335:224]) // 14b x 8 output
);

// row1
Macro macro01(
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[127: 96]), // 4b x 8
    .act_in(act_in2), // 4b x 64
    .weight_out(weight_out[127: 96]),// 4b x 8
    .PSUM(PSUM[447:336]) // 14b x 8 output
);

Macro macro11(
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[159: 128]), // 4b x 8
    .act_in(act_column1_in2), // 4b x 64
    .weight_out(weight_out[159: 128]),// 4b x 8
    .PSUM(PSUM[559:448]) // 14b x 8 output
);

Macro macro21(
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[191: 160]), // 4b x 8
    .act_in(act_column2_in2), // 4b x 64
    .weight_out(weight_out[191: 160]),// 4b x 8
    .PSUM(PSUM[671:560]) // 14b x 8 output
);

// row2
Macro macro02(
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[223: 192]), // 4b x 8
    .act_in(act_in3), // 4b x 64
    .weight_out(weight_out[223: 192]),// 4b x 8
    .PSUM(PSUM[783:672]) // 14b x 8 output
);

Macro macro12(
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[255: 224]), // 4b x 8
    .act_in(act_column1_in3), // 4b x 64
    .weight_out(weight_out[255: 224]),// 4b x 8
    .PSUM(PSUM[895:784]) // 14b x 8 output
);

Macro macro22(
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[287: 256]), // 4b x 8
    .act_in(act_column2_in3), // 4b x 64
    .weight_out(weight_out[287: 256]),// 4b x 8
    .PSUM(PSUM[1007:896]) // 14b x 8 output
);



endmodule