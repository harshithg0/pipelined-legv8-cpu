`timescale 1ns/1ps
module full_adder(A, B, Cin, S, Cout);
	output logic S, Cout;
	input logic A, B, Cin;
	
	logic xab, aab, aabc;
	
	// XORs all A, B, Cin for S
	xor #0.05 x1 (xab, A, B);
	xor #0.05 x2 (S, xab, Cin);
	
	// OR the AND of AB and AND Cin XOR(A,B)
	and #0.05 a1 (aab, A, B);
	and #0.05 a2 (aabc, xab, Cin);
	or #0.05 o1 (Cout, aab, aabc);
	
endmodule // full_adder
	
	
	