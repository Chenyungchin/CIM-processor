// instruction fetch
module IF(
    input     clk,
    input     rst_n,
    input []  instruction,
    input []  address,
    input []  data,// D
    // ===== for LD (2nd pipelined stage: 1 delay) ===========
    output [] weight_in_A,
    output [] act_in1_A,
    output [] act_in2_A,
    output [] act_in3_A,
    // ===== for CIM Unit (3rd pipelined stage: 2 delay) =====
    // STD
    output [] STDW,
    output [] STDR,
    output [] STD_A,
    // CIM
    output [] CIM_Core_A,
    output [] CIM_en,
    output [] slide_en,
    // ===== for NMC (4th pipelined stage: 3 delay) ==========
    output    relu_out_en,
    // ===== for WB (5th pipelined stage: 4 delay) ===========
    output [] WB_A
);


endmodule