`timescale 1ns/1ps
module adder_subtractor(A, B, cntrl, S, Cout, overflow);
	output logic [63:0] S;
	output logic Cout, overflow;
	input logic [63:0] A, B;
	input logic [2:0] cntrl;
	
	logic [63:0] xB;
	logic [64:0] carrys;
	logic nT, sub;
	
	not #0.05 n1 (nT, cntrl[2]);
	and #0.05 a1 (sub, nT, cntrl[1], cntrl[0]);
	
	assign carrys[0] = sub;
	
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : loop1
			xor(xB[i], B[i], sub);
			full_adder fa (.A(A[i]), .B(xB[i]), .Cin(carrys[i]), .S(S[i]), .Cout(carrys[i+1]));
		end
	endgenerate
	
	xor #0.05 x1 (overflow, carrys[64], carrys[63]);
	assign Cout = carrys[64];

endmodule // adder_subtractor
	