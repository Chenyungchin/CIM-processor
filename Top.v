module Top(
    input              clk,
    input              rst_n,
    input      [2:0]   state, // operation
    input      [11:0]  A, // address. row adress: A[11:7], col adress: A[6:0]
    input      [31:0]  D, // input data
    output reg         out_valid,
    output reg [31:0]  Q // output data
);

// ========== parameter =====================
parameter NOP       = 3'd0; // No operation 
parameter GAM       = 3'd1; // Serial in D[31:0] to global activation memory
parameter GWM       = 3'd2; // Serial in D[31:0] to global weight memory
parameter GIM       = 3'd3; // Serial in D[31:0] to global instruction memory
parameter STD_WRITE = 3'd4; // CIM standard write
parameter STD_READ  = 3'd5; // CIM standard read
parameter PIP       = 3'd6; // Pipeline datapath and control
parameter RGA       = 3'd7; // serial out Q[31:0] from global activation memory

// parameter WEIGHT_BUFFER_NUM = 7'd72;
// parameter ACT_BUFFER_NUM    = 5'd24;
parameter INST_LEN  = 16;

// ========== wire and reg ==================
reg   [5:0]    PC; // PC[5:1]: row in inst_mem, PC[0]: left or right

wire           out_valid_ns;
wire  [31:0]   Q_ns;
// RAM
wire  [4:0]    A_row;
wire  [6:0]    A_col;
// the SRAM is enabled when web == 0
reg            web_inst_mem, web_act_mem_top, web_act_mem_bottom, web_weight_mem;
reg     [4:0]  A_inst_mem, A_act_mem_row_top, A_act_mem_col_top, A_act_mem_row_bottom, A_act_mem_col_bottom; // A_weight_mem;
reg     [4:0]  A_weight_mem_row;
reg     [6:0]  A_weight_mem_col;
reg    [31:0]  D_inst_mem;
reg   [255:0]  D_act_mem;
reg    [31:0]  D_weight_mem;
wire   [31:0]  Q_inst_mem;
wire  [767:0]  Q_act_mem_top, Q_act_mem_bottom;
wire [2303:0]  Q_weight_mem;

// instruction
reg  [15:0] instruction; // delay 1 cycle from inst_mem output
wire [4:0]  act_in_A;
wire [6:0]  act_wb_A_ns_3d;
wire        sel_top; // read from top
wire        CIM_Core_A_ns_1d;
wire        slide_en_ns_1d;
wire        WB_en_ns_3d;
// instruction delay to fit pipeline
reg  [6:0] act_wb_A_ns_2d, act_wb_A_ns_1d, act_wb_A;
reg        CIM_Core_A;
reg        slide_en;
reg        WB_en_ns_2d, WB_en_ns_1d, WB_en;

// STD 
wire [5:0] STD_A;


// -- CIM input --
reg   [255:0] act_in1, act_in2, act_in3;

// -- CIM_Unit output --
wire [2303:0] weight_out;
wire [1151:0] PSUM;

// -- NMC output --
wire [255:0]  relu_out;

// ========== assignments ===================
// adress for accessing RAM
assign A_row = A[11:7];
assign A_col = A[6:0];

// instruction
assign act_in_A             = instruction[15: 11];
assign act_wb_A_ns_3d       = instruction[10: 4]; // need to delay 3 cycle
assign sel_top              = instruction[3];
assign CIM_Core_A_ns_1d     = instruction[2];
assign slide_en_ns_1d       = instruction[1];
assign WB_en_ns_3d          = instruction[0];

// STD_A
assign STD_A = (state == STD_READ || state == STD_WRITE) ? A[5:0] : 6'b0;

// output
assign out_valid_ns = (state == RGA) ? 1'b1     : 1'b0;
assign Q_ns         = (state != RGA) ? 32'b0: 
                      (A[5] == 1)    ? Q_act_mem_top : Q_act_mem_bottom; // A[5] indicate top/bottom of AM
// ========== Combinational =================
// SRAM web, D
always @(*) begin
    // web
    web_inst_mem   = 1'b1;
    web_act_mem_top    = 1'b1;
    web_act_mem_bottom = 1'b1;
    web_weight_mem = 1'b1;
    D_inst_mem     = 32'b0;
    D_act_mem      = 256'b0;
    D_weight_mem   = 32'b0;
    A_inst_mem     = 5'b0;
    A_act_mem_row_top  = 5'b0;
    A_act_mem_row_bottom = 5'b0;
    A_act_mem_col_top  = 5'b0;
    A_act_mem_col_bottom = 5'b0;
    A_weight_mem_row     = 5'b0;
    A_weight_mem_col     = 7'b0;
    // D mem
    case (state)
        // NOP: begin
        // end
        GAM: begin // enable act web
            if (A[5]) web_act_mem_top    = 1'b0;
            else      web_act_mem_bottom = 1'b0;
            D_act_mem      = {224'b0, D}; // pad to 256'b
            A_act_mem_row_top    = A_row;
            A_act_mem_row_bottom = A_row;
            A_act_mem_col_top    = A_col[4:0];
            A_act_mem_col_bottom = A_col[4:0];
        end
        GWM: begin // enable weight web
            web_weight_mem    = 1'b0;
            A_weight_mem_row  = A_row;
            A_weight_mem_col  = A_col;
            D_weight_mem      = D;
        end
        GIM: begin // enable inst web
            web_inst_mem   = 1'b0;
            A_inst_mem     = A_row;
            D_inst_mem     = D;
        end
        STD_WRITE: begin
            A_weight_mem_row  = A_row;
        end
        PIP: begin 
            A_inst_mem     = PC[5:1];
            if (sel_top) begin // read top => write bottom
                // read top
                A_act_mem_row_top = act_in_A;
                // write bottom
                A_act_mem_row_bottom = act_wb_A[6:2]; // write back address for row
                A_act_mem_col_bottom = {3'b0, act_wb_A[1:0]}; // write back address for col (pad 3'b0)
                web_act_mem_bottom   = !WB_en; // write back enable
            end
            else begin
                // read bottom
                A_act_mem_row_bottom = act_in_A;
                // write bottom
                A_act_mem_row_top = act_wb_A[6:2]; // write back address for row
                A_act_mem_col_top = {3'b0, act_wb_A[1:0]}; // write back address for col (pad 3'b0)
                web_act_mem_top   = !WB_en; // write back enable
            end
            D_act_mem      = relu_out; // relu out
        end
        // RGA: begin 
        // end
        default: begin 

        end
    endcase
end

// =========== Sequential ====================
// PC
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)           PC <= 6'b0;
    else if (PC == 6'd63) PC <= 6'b0;
    else                  PC <= PC + 6'b1;
end
// instruction
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)     instruction  <= 16'b0;
    else if (PC[0]) instruction  <= Q_inst_mem[31: 16];
    else            instruction  <= Q_inst_mem[15: 0];
end

// instruction delay to fit pipeline
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        act_wb_A_ns_2d <= 7'b0;
        act_wb_A_ns_1d <= 7'b0;
        act_wb_A       <= 7'b0;
        CIM_Core_A     <= 1'b0;
        slide_en       <= 1'b0;
        WB_en_ns_2d    <= 1'b0;
        WB_en_ns_1d    <= 1'b0;
        WB_en          <= 1'b0;
    end
    else begin
        act_wb_A_ns_2d <= act_wb_A_ns_3d;
        act_wb_A_ns_1d <= act_wb_A_ns_2d;
        act_wb_A       <= act_wb_A_ns_1d;
        CIM_Core_A     <= CIM_Core_A_ns_1d;
        slide_en       <= slide_en_ns_1d;
        WB_en_ns_2d    <= WB_en_ns_3d;
        WB_en_ns_1d    <= WB_en_ns_2d;
        WB_en          <= WB_en_ns_1d;
    end
end

// activation (CIM input)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        act_in1 <= 256'b0;
        act_in2 <= 256'b0;
        act_in3 <= 256'b0;
    end
    else begin
        if (sel_top) begin
            act_in1 <= Q_act_mem_top[255: 0];
            act_in2 <= Q_act_mem_top[511: 256];
            act_in3 <= Q_act_mem_top[767: 512];
        end
        else begin
            act_in1 <= Q_act_mem_bottom[255: 0];
            act_in2 <= Q_act_mem_bottom[511: 256];
            act_in3 <= Q_act_mem_bottom[767: 512];
        end
    end
end

// output
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 1'b0;
        Q         <= 32'b0;
    end
    else begin
        out_valid <= out_valid_ns;
        Q         <= Q_ns;
    end
end

// =========== Module Instantiation ==========
// RAM
Instruction_sram_32X32 inst_mem(
	.clk(clk),
	.ceb(1'b0),
	.web(web_inst_mem),
	.A(A_inst_mem),
	.D(D_inst_mem),
	.Q(Q_inst_mem)
);

Activation_sram_32X768 act_mem_top(
	.clk(clk),
	.ceb(1'b0),
	.web(web_act_mem_top),
    .WB_from_PIP((state != GAM)),
	.A_row(A_act_mem_row_top),
    .A_col(A_act_mem_col_top),
	.D(D_act_mem),
	.Q(Q_act_mem_top)
);

Activation_sram_32X768 act_mem_bottom(
	.clk(clk),
	.ceb(1'b0),
	.web(web_act_mem_bottom),
    .WB_from_PIP((state != GAM)),
	.A_row(A_act_mem_row_bottom),
    .A_col(A_act_mem_col_bottom),
	.D(D_act_mem),
	.Q(Q_act_mem_bottom)
);

Weight_sram_32X2304 weight_mem(
	.clk(clk),
	.ceb(1'b0),
	.web(web_weight_mem),
	.A_row(A_weight_mem_row),
    .A_col(A_weight_mem_col),
	.D(D_weight_mem),
	.Q(Q_weight_mem)
);

// IF
// IF if0(
//     .clk(clk),
//     .rst_n(rst_n),
//     .instruction(),
//     .address(),
//     .data(),// D
//     // ===== for LD (2nd pipelined stage: 1 delay) ===========
//     .weight_in_A(weight_in_A),
//     .act_in_A(act_in_A),
//     // ===== for CIM Unit (3rd pipelined stage: 2 delay) =====
//     // STD
//     .STDW((state == STD_WRITE)),
//     .STDR((state == STD_READ)),
//     .STD_A(A[5:0]), // A[11:7] is for accessing weight SRAM, A[5:0] is for assigning the CIM row
//     // CIM
//     .CIM_Core_A(CIM_Core_A),
//     .CIM_en(CIM_en),
//     .slide_en(slide_en),
//     // ===== for NMC (4th pipelined stage: 3 delay) ==========
//     .relu_out_en(relu_out_en),
//     // ===== for WB (5th pipelined stage: 4 delay) ===========
//     .WB_A(WB_A)
// );

// // LD
// LD ld0(
//     // input
//     .clk(clk),
//     .rst_n(rst_n),
//     .act_in_A(act_in_A),
//     .weight_in_A(weight_in_A)
//     // output
//     // .act_in1(act_in1),
//     // .act_in2(act_in2),
//     // .act_in3(act_in3),
//     // .weight_in(weight_in)
// );

// CIM
CIM_Unit cim0(
    // input
    .clk(clk),
    .rst_n(rst_n),
    .CIM_Core_A(CIM_Core_A),
    .CIM_en((state == PIP)),
    .STDW((state == STD_WRITE)),
    .STDR((state == STD_READ)),
    .STD_A(STD_A),
    .weight_in(Q_weight_mem),
    .act_in1(act_in1),
    .act_in2(act_in2),
    .act_in3(act_in3),
    .slide_en(slide_en),
    // output
    .weight_out(weight_out),
    .PSUM(PSUM)
);

// NMC
NMC nmc0(
    .clk(clk),
    .rst_n(rst_n),
    .relu_out_en(WB_en),
    .aggre_in(PSUM),
    .relu_out(relu_out)
);

// // WB
// WB wb0(
//     .clk(clk),
//     .rst_n(rst_n),
//     .relu_out(relu_out),
//     .WB_A(WB_A)
// );

endmodule