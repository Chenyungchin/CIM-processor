// The adder tree adds the partial sum to get the results and normalize them back to 4b
// The adder tree supports 3 accumulation modes
// ========================== modes ===================================== 
// == (0). 9-to-1 mode: for 3x3 convolution and fully connected layer
// == (1). 3-to-1 mode: for 7x7 and 5x5 convolutional input layer (channel length = 3)
// == (2). 1-to-1 mode: for 3x3 convolutional input layer (channel length = 3)
// ========================== res =======================================
// mode0: (14b x 9) x 8     ==> 18b x 8,     18b x 8 ==> 4b x 8         (stored in the LSB 32b of res)
// mode1: (14b x 3) x 3 x 8 ==> 16b x 3 x 8, 16b x 3 x 8 ==> 4b x 3 x 8 (stored in the LSB 96b if res)
// mode2: (14b x 1) x 9 x 8 ==> 14b x 9 x 8, 14b x 9 x 8 ==> 4b x 9 x 8 (stored in res)
module Adder_Tree(
    input               clk,
    input               rst_n,
    input      [1007:0] PSUM, // 14b x 8 x 9(= 1008) 
    input      [1:0]    mode,
    output reg [287:0]   res // 4b x 8 x 9 for mode2
);

// =========== params and variables =========
integer i, j;

// =========== wires and regs ===============
reg  [287:0] res_next;
wire [127:0] adder_out_3_to_1 [0:2];
wire [143:0] adder_out_9_to_1;

// =========== Combinational ================
always @(*) begin
    res_next = 288'b0;
    case (mode)
        2'b00: begin // mode 0
            for (i = 0; i < 8; i = i+1) begin
                res_next[4*i+3 -: 4] = adder_out_9_to_1[18*i+17 -: 4]; // take the MSB 4b of the 14b partial sum
            end
        end
        2'b01: begin // mode 1
            for (i = 0; i < 3; i = i+1) begin
                for (j = 0; j < 8; j = j+1) begin
                    res_next[32*i + 4*j + 3 -: 4] = adder_out_3_to_1[i][16*j+15 -: 4]; // take the MSB of the 16b partial sum
                end
            end
        end
        2'b10: begin // mode 2
            for (i = 0; i < 72; i = i+1) begin
                res_next[4*i+3 -: 4] = PSUM[14*i+13 -: 4]; // take the MSB 4b of the 14b partial sum
            end
        end
        default: begin
            
        end
    endcase
end

// ========== Sequential ====================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        res <= 288'b0;
    end
    else begin
        res <= res_next;
    end
end

// ========== call module ==================
// 3-to-1 adder
Adder_3_to_1 #(.N(14)) adder036(
    .a(PSUM[111:0]),
    .b(PSUM[223:112]),
    .c(PSUM[335:224]),
    .out(adder_out_3_to_1[0])
);

Adder_3_to_1 #(.N(14)) adder147(
    .a(PSUM[447:336]),
    .b(PSUM[559:448]),
    .c(PSUM[671:560]),
    .out(adder_out_3_to_1[1])
);

Adder_3_to_1 #(.N(14)) adder258(
    .a(PSUM[783:672]),
    .b(PSUM[895:784]),
    .c(PSUM[1007:896]),
    .out(adder_out_3_to_1[2])
);

// 9-to-1 adder
Adder_3_to_1 #(.N(16)) adder0to8(
    .a(adder_out_3_to_1[0]),
    .b(adder_out_3_to_1[1]),
    .c(adder_out_3_to_1[2]),
    .out(adder_out_9_to_1)
);

endmodule


// 3-to-1 Adder

module Adder_3_to_1 #(parameter N = 14)(
    input  [8*N-1:0] a, 
    input  [8*N-1:0] b,
    input  [8*N-1:0] c,
    output [8*(N+2)-1:0] out
);

genvar ii;
generate
    for (ii = 0; ii < 8; ii = ii+1) begin
        assign out[(N+2)*ii + (N+1) -: N+2] = a[N*ii + (N-1) -: N] + b[N*ii + (N-1) -: N] + c[N*ii + (N-1) -: N];
    end
endgenerate

endmodule