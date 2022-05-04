// NMC is in charge of the operation of aggregation and relu
module NMC #(
    parameter AGGRE_IN_PRECISION = 18,
    parameter AGGRE_OUT_PRECISION = 21,
    parameter RELU_OUT_PRECISION = 4,
    parameter DIM = 64
)(
    input                                    clk,
    input                                    rst_n,
    input                                    relu_out_en,
    input      [AGGRE_IN_PRECISION*DIM-1:0]  aggre_in,
    output reg [RELU_OUT_PRECISION*DIM-1: 0] relu_out
    // output WB_A (write back address)
);

// =============== wire and reg =======================
wire [RELU_OUT_PRECISION*DIM-1: 0] relu_out_w;
reg                                clear; // "clear" is a cycle delay of relu_out_en

// ============== assignments =========================

// =============== Sequential ==========================
// relu_out
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) relu_out <= 0;
    else        relu_out <= relu_out_w;
end
// clear
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) clear <= 0;
    else        clear <= relu_out_en;
end

// ============== module instantiation ==================
Aggregator #(
    .IN_PRECISION(AGGRE_IN_PRECISION),
    .OUT_PRECISION(AGGRE_OUT_PRECISION),
    .DIM(DIM)
) aggre0(
    .clk(clk),
    .rst_n(rst_n),
    .clear(clear),
    .aggre_in(aggre_in),
    .aggre_out(aggre_out)
);

ReLU #(
    .IN_PRECISION(AGGRE_OUT_PRECISION),
    .OUT_PRECISION(RELU_OUT_PRECISION)
) relu0(
    .clk(clk),
    .rst_n(rst_n),
    .relu_in(aggre_out),
    .relu_out(relu_out_w)
);

endmodule 