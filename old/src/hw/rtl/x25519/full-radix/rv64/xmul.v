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
    localparam [5:0] FN_MADDL  = 6'd50;   //XMUL0
    localparam [5:0] FN_MADDH  = 6'd51;   //XMUL1
    localparam [5:0] FN_CADD   = 6'd52;   //XMUL2

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
    reg cmdHi, lhsSigned, rhsSigned, acc, add;

    always @(fn) begin
        case (fn)
        FN_MUL    : {cmdHi, lhsSigned, rhsSigned, acc, add} <= 5'b00000;
        FN_MULH   : {cmdHi, lhsSigned, rhsSigned, acc, add} <= 5'b11100;
        FN_MULHU  : {cmdHi, lhsSigned, rhsSigned, acc, add} <= 5'b10000;
        FN_MULHSU : {cmdHi, lhsSigned, rhsSigned, acc, add} <= 5'b11000;
        FN_MADDL  : {cmdHi, lhsSigned, rhsSigned, acc, add} <= 5'b00010;
        FN_MADDH  : {cmdHi, lhsSigned, rhsSigned, acc, add} <= 5'b10010;
        FN_CADD   : {cmdHi, lhsSigned, rhsSigned, acc, add} <= 5'b00001;
        default   : {cmdHi, lhsSigned, rhsSigned, acc, add} <= 5'bxxxxx;
        endcase
    end

    wire signed [ 64:0]  lhs  = {lhsSigned && in1[63], in1};
    wire signed [ 64:0]  rhs  = {rhsSigned && in2[63], in2};
    wire signed [128:0] prod  = lhs * rhs;
    wire signed [128:0] add2  = lhs + rhs;

    wire signed [128:0] padd  = in3 + prod;
    wire signed [ 64:0] cadd  = in3 + {{63{1'b0}}, add2[64]};

    wire [127:0] proadd = acc ? padd[127:0] : prod[127:0];
    wire [ 63:0] muxed  = add ? cadd[ 63:0] : (cmdHi? proadd[127:64] : ((~dw)? {{32{proadd[31]}}, proadd[31:0]} : proadd[ 63:0]));

    reg  [  4:0] tag_pp;
    reg  [128:0] pro_pp;
    always @(posedge clock) begin
        if (reset) begin
        tag_pp <=  5'd0;
        pro_pp <= 64'd0;
        end else if (val) begin
        tag_pp <=   tag;
        pro_pp <=   muxed;
        end 
    end

    assign resp_data = pro_pp;
    assign resp_tag  = tag_pp;
endmodule

