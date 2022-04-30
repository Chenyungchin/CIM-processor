module PE (
    // input              IN_valid, 
    input              CIM_en,
    input              STDW, // == 1 if standard write mode (weight updating)
    input              STDR, // == 1 if standard read mode
    input        [5:0] STD_A, // address for determining which row (1 out of 64) to read/write
    input        [3:0] weight_in, // update 4b weight when STDW
    // input              CIM_A,
    input      [255:0] act_in, // 4b x 64
    output reg   [3:0] weight_out, // read out 4b weight when STDR
    output reg  [13:0] PSUM // 14b output
);

// regs and wires
// reg  [7:0] mult_res [0:63];
reg  [3:0] weight   [0:63];

integer i;


always@(*) begin
    weight_out = 4'b0;
    PSUM = 14'b0;
    if (STDW) begin // weight update
        weight[STD_A] = weight_in;
    end
    else if (STDR) begin // read out weight
        weight_out = weight[STD_A];
    end
    else begin // normal CIM operation
        if (CIM_en) begin
            for (i = 0; i < 64; i = i+1) begin
                PSUM = PSUM + weight[i] * act_in[4*i+3 -: 4]; // 4b input activation
            end
        end
    end
end

    
endmodule