// A CIM Macro_Array consists of 9 CIM Macros (layout: 3x3) and a 9-input adder tree
// This design adopts horizontal pipeline, thus, the columns are separated by flip-flops
module Macro_Array(
    // input               IN_valid, 
    input               clk,
    input               rst_n,
    input               CIM_en,
    input               STDW, // == 1 if standard write mode (weight updating)
    input               STDR, // == 1 if standard read mode
    input         [5:0] STD_A, // address for determining which row (1 out of 64) to read/write
    input       [287:0] weight_in, // update 4b x 8 x 9 weight when STDW
    // input               CIM_A,
    input       [255:0] act_in1, // 4b x 64
    input       [255:0] act_in2, // 4b x 64
    input       [255:0] act_in3, // 4b x 64
    input               slide_en, // signal controlling whether registers pass data horizontally to the next (pass signals when slide_en == 1)
    output      [287:0] weight_out, // read out 4b x 8 x 9 (= 288) weight when STDR
    output      [143:0] PSUM // 18b x 8(= 144) output
);


// ====================regs & wires======================
// the input "act_in1~3" are for column0
reg   [255:0] act_column1_in1;
reg   [255:0] act_column1_in2;
reg   [255:0] act_column1_in3;
reg   [255:0] act_column2_in1;
reg   [255:0] act_column2_in2;
reg   [255:0] act_column2_in3;

wire  [111:0] PSUM_conv [0:8]; 


// ==================== Combinational ================


// ==================== Sequential ===================

// horizontal pipeline: pass the input activation horizontally
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin // reset
        act_column1_in1 <= 256'b0;
        act_column1_in2 <= 256'b0;
        act_column1_in3 <= 256'b0;
        act_column2_in1 <= 256'b0;
        act_column2_in2 <= 256'b0;
        act_column2_in3 <= 256'b0;
    end
    else begin
        if (slide_en) begin // pass the data horizontally
            act_column1_in1 <= act_in1;
            act_column1_in2 <= act_in2;
            act_column1_in3 <= act_in3;
            act_column2_in1 <= act_column1_in1;
            act_column2_in2 <= act_column1_in2;
            act_column2_in3 <= act_column1_in3;
        end
        else begin // retain the orginal value
            act_column1_in1 <= act_column1_in1;
            act_column1_in2 <= act_column1_in2;
            act_column1_in3 <= act_column1_in3;
            act_column2_in1 <= act_column2_in1;
            act_column2_in2 <= act_column2_in2;
            act_column2_in3 <= act_column2_in3;
        end
    end
end

// ================= Macro Array =====================
// row0
Macro macro00(
    .CIM_en(CIM_en),
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[31: 0]), // 4b x 8
    .act_in(act_in1), // 4b x 64
    .weight_out(weight_out[31: 0]),// 4b x 8
    .PSUM(PSUM_conv[0]) // 14b x 8 output
);

Macro macro10(
    .CIM_en(CIM_en),
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[63: 32]), // 4b x 8
    .act_in(act_column1_in1), // 4b x 64
    .weight_out(weight_out[63: 32]),// 4b x 8
    .PSUM(PSUM_conv[1]) // 14b x 8 output
);

Macro macro20(
    .CIM_en(CIM_en),
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[95: 64]), // 4b x 8
    .act_in(act_column2_in1), // 4b x 64
    .weight_out(weight_out[95: 64]),// 4b x 8
    .PSUM(PSUM_conv[2]) // 14b x 8 output
);

// row1
Macro macro01(
    .CIM_en(CIM_en),
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[127: 96]), // 4b x 8
    .act_in(act_in2), // 4b x 64
    .weight_out(weight_out[127: 96]),// 4b x 8
    .PSUM(PSUM_conv[3]) // 14b x 8 output
);

Macro macro11(
    .CIM_en(CIM_en),
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[159: 128]), // 4b x 8
    .act_in(act_column1_in2), // 4b x 64
    .weight_out(weight_out[159: 128]),// 4b x 8
    .PSUM(PSUM_conv[4]) // 14b x 8 output
);

Macro macro21(
    .CIM_en(CIM_en),
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[191: 160]), // 4b x 8
    .act_in(act_column2_in2), // 4b x 64
    .weight_out(weight_out[191: 160]),// 4b x 8
    .PSUM(PSUM_conv[5]) // 14b x 8 output
);

// row2
Macro macro02(
    .CIM_en(CIM_en),
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[223: 192]), // 4b x 8
    .act_in(act_in3), // 4b x 64
    .weight_out(weight_out[223: 192]),// 4b x 8
    .PSUM(PSUM_conv[6]) // 14b x 8 output
);

Macro macro12(
    .CIM_en(CIM_en),
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[255: 224]), // 4b x 8
    .act_in(act_column1_in3), // 4b x 64
    .weight_out(weight_out[255: 224]),// 4b x 8
    .PSUM(PSUM_conv[7]) // 14b x 8 output
);

Macro macro22(
    .CIM_en(CIM_en),
    .STDW(STDW),
    .STDR(STDR),
    .STD_A(STD_A),
    .weight_in(weight_in[287: 256]), // 4b x 8
    .act_in(act_column2_in3), // 4b x 64
    .weight_out(weight_out[287: 256]),// 4b x 8
    .PSUM(PSUM_conv[8]) // 14b x 8 output
);

// 9-to-1 adder tree
Adder_Tree adder_tree0(
    .PSUM({PSUM_conv[8], PSUM_conv[7], PSUM_conv[6], PSUM_conv[5], PSUM_conv[4], PSUM_conv[3], PSUM_conv[2], PSUM_conv[1], PSUM_conv[0]}),
    .res(PSUM) // 14b x 8
);


endmodule