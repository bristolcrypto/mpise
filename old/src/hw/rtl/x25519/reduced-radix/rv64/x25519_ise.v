module x25519_ise (
input  wire [63:0]  rs1,
input  wire [63:0]  rs2,
input  wire [ 5:0]  shamt,

input  wire         op_sraiadd,

output wire [63:0]  rd
);

`define shar64(x,  imm,  l)  ({64{imm[5]}} & {{32{x[63]}},l16``l[63:32]}) | ({64{!imm[5]}} &l16``l[63:0]); \
        wire [63:0] l16``l= ({64{imm[4]}} & {{16{x[63]}}, l8``l[63:16]}) | ({64{!imm[4]}} & l8``l[63:0]); \
        wire [63:0] l8``l = ({64{imm[3]}} & {{ 8{x[63]}}, l4``l[63: 8]}) | ({64{!imm[3]}} & l4``l[63:0]); \
        wire [63:0] l4``l = ({64{imm[2]}} & {{ 4{x[63]}}, l2``l[63: 4]}) | ({64{!imm[2]}} & l2``l[63:0]); \
        wire [63:0] l2``l = ({64{imm[1]}} & {{ 2{x[63]}}, l1``l[63: 2]}) | ({64{!imm[1]}} & l1``l[63:0]); \
        wire [63:0] l1``l = ({64{imm[0]}} & {{ 1{x[63]}}, l0``l[63: 1]}) | ({64{!imm[0]}} & l0``l[63:0]); \
        wire [63:0] l0``l = x  

wire [63:0] wshr= `shar64(rs2, shamt, rs2shr);
wire [63:0] res = rs1 + wshr;

assign      rd  = {64{op_sraiadd}} & res ;
endmodule


