`timescale 1ns/1ps
module sign_extend(imm_I, imm_D, imm_B, imm_CB, ImmOp, immOut);

	input logic [11:0] imm_I;
	input logic [8:0] imm_D;
	input logic [25:0] imm_B;
	input logic [18:0] imm_CB;
	input logic [1:0] ImmOp;
	output logic [63:0] immOut;

	logic [63:0] ext_I, ext_D, ext_B, ext_CB, sel1, sel2;
	assign ext_I = {52'b0, imm_I};
	assign ext_D = {{55{imm_D[8]}}, imm_D};
	assign ext_B = {{36{imm_B[25]}}, imm_B, 2'b00};
	assign ext_CB = {{43{imm_CB[18]}}, imm_CB, 2'b00};
	
	mux2_64 m1 (.out(sel1), .i0(ext_I), .i1(ext_D), .sel(ImmOp[0]));
	mux2_64 m2 (.out(sel2), .i0(ext_B), .i1(ext_CB), .sel(ImmOp[0]));
	
	mux2_64 m3 (.out(immOut), .i0(sel1), .i1(sel2), .sel(ImmOp[1]));

endmodule // sign_extend
