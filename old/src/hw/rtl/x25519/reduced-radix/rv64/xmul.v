//extended multiplier with 3 operands for multiply accumulation
module xmul ( 
    input clock,
    input reset,
    input         req_valid,
    input         req_bits_dw,
    input  [ 5:0] req_bits_fn,
    input  [ 4:0] req_bits_tag,
    input  [63:0] req_bits_in1,
    input  [63:0] req_bits_in2,
    input  [63:0] req_in3,

    output [63:0] resp_data,
    output [ 4:0] resp_tag
    );
    localparam [5:0] FN_MUL    = 6'd0;  
    localparam [5:0] FN_MULH   = 6'd1;
    localparam [5:0] FN_MULHSU = 6'd2; 
    localparam [5:0] FN_MULHU  = 6'd3;
    localparam [5:0] FN_MADDL  = 6'd50;   //madd51lu = XMUL0
    localparam [5:0] FN_MADDH  = 6'd51;   //madd51hu = XMUL1

    reg         val;
    reg         dw;
    reg  [ 5:0] fn;
    reg  [ 4:0] tag;
    reg  [63:0] in1;
    reg  [63:0] in2;
    reg  [63:0] in3;
    always @(posedge clock) begin
        if (reset) begin
        val <=  1'b0;
        dw  <=  1'b0;
        fn  <=  6'd0;
        tag <=  5'd0;
        in1 <= 64'd0;
        in2 <= 64'd0;
        in3 <= 64'd0;
        end else if (req_valid) begin
        val <=  1'b1;
        dw  <=  req_bits_dw;
        fn  <=  req_bits_fn;
        tag <=  req_bits_tag;
        in1 <=  req_bits_in1;
        in2 <=  req_bits_in2;
        in3 <=  req_in3;
        end else val <= 1'b0;
    end

    //decode
    reg cmdHi, lhsSigned, rhsSigned, acc;

    always @(fn) begin
        case (fn)
        FN_MUL    : {cmdHi, lhsSigned, rhsSigned, acc} <= 4'b0000;
        FN_MULH   : {cmdHi, lhsSigned, rhsSigned, acc} <= 4'b1110;
        FN_MULHU  : {cmdHi, lhsSigned, rhsSigned, acc} <= 4'b1000;
        FN_MULHSU : {cmdHi, lhsSigned, rhsSigned, acc} <= 4'b1100;
        FN_MADDL  : {cmdHi, lhsSigned, rhsSigned, acc} <= 4'b0001;
        FN_MADDH  : {cmdHi, lhsSigned, rhsSigned, acc} <= 4'b1001;
        default   : {cmdHi, lhsSigned, rhsSigned, acc} <= 4'bxxxx;
        endcase
    end

    wire signed [ 64:0]  lhs  = {lhsSigned && in1[63], in1};
    wire signed [ 64:0]  rhs  = {rhsSigned && in2[63], in2};
    wire signed [128:0] prod  = lhs * rhs;

    wire [ 63:0] muxed  = cmdHi? ( acc ? prod[51 +:64] : prod[64 +:64]) : 
                                 ( acc ? {13'd0, prod[ 0 +:51]}       : 
                                  (~dw)? {{32{prod[31]}}, prod[31:0]} : prod[ 63:0]);

    reg          acc_pp;
    reg  [  4:0] tag_pp;
    reg  [ 63:0] pro_pp;
    reg  [ 63:0] in3_pp;   
    always @(posedge clock) begin
        if (reset) begin
        acc_pp <=  1'b0;
        tag_pp <=  5'd0;
        pro_pp <= 64'd0;
        in3_pp <= 64'd0;
        end else if (val) begin
        acc_pp <=   acc;
        tag_pp <=   tag;
        pro_pp <=   muxed;
        in3_pp <=   in3;
        end 
    end

    wire [63:0] out = acc_pp ? (pro_pp + in3_pp): pro_pp;

    assign resp_data = out;
    assign resp_tag  = tag_pp;
endmodule

