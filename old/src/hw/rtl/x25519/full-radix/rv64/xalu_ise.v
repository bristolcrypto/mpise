//Ascon Instruction Set Extension
module xalu_ise (
    ise_clk,
    ise_rst,
    ise_fn,
    ise_imm,   
    ise_in1,   
    ise_in2,  
//    ise_in3,
    ise_val,
    ise_oval,         
    ise_out    );
input           ise_clk, ise_rst;
input  [ 5:0]   ise_fn;
input  [ 6:0]   ise_imm;
input  [63:0]   ise_in1;
input  [63:0]   ise_in2;
//input  [63:0]   ise_in3;
input           ise_val;
output          ise_oval;
output [63:0]   ise_out; 

parameter [1:0] ISE_V  = 2'b01;

localparam [1:0] CUSTOM_0 = 2'b00;
localparam [1:0] CUSTOM_1 = 2'b01;
localparam [1:0] CUSTOM_2 = 2'b10;
localparam [1:0] CUSTOM_3 = 2'b11; 

wire [6:0] funct    = ise_imm;

//decode x25519_ise
wire        x25519_ise_sel;
wire [63:0] x25519_ise_rd;  
generate 
    if (ISE_V[1] == 1'b1) begin : X25519_ISE_IMP
wire   op_maddlu       = (funct[1:0] == 2'b00) && (ise_fn[1:0] == CUSTOM_3);
wire   op_maddhu       = (funct[1:0] == 2'b01) && (ise_fn[1:0] == CUSTOM_3);

assign x25519_ise_sel  = op_maddlu || op_maddhu;


x25519_ise x25519_ise_ins2(
    .rs1(      ise_in1      ),
    .rs2(      ise_in2      ),
    .rd (      x25519_ise_rd ),

    .op_maddlu( op_maddlu   ),
    .op_maddhu( op_maddhu   )
);
end else begin            : No_X25519_ISE
assign  x25519_ise_sel =  1'b0;
assign  x25519_ise_rd  = 64'd0;  
    end
endgenerate

wire [63:0] dout = {64{ x25519_ise_sel }} & x25519_ise_rd ;

assign  ise_oval = ise_val && x25519_ise_sel;
assign  ise_out  = dout;

endmodule

