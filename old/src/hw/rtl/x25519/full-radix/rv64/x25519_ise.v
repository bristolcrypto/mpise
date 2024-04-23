module x25519_ise (
input  wire [63:0]  rs1,
input  wire [63:0]  rs2,
//input  wire [63:0]  rs3,

input  wire         op_maddlu,
input  wire         op_maddhu,

output wire [63:0]  rd
);

assign rd = 0;
endmodule


