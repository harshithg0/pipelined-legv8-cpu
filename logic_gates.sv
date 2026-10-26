`timescale 1ns/1ps
module logic_gates(A, B, and_output, or_output, xor_output);
	output logic [63:0] and_output, or_output, xor_output;
	input logic [63:0] A, B;
	
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : loop1
			and #0.05 a1 (and_output[i], A[i], B[i]);
			or #0.05 o1 (or_output[i], A[i], B[i]);
			xor #0.05 x1 (xor_output[i], A[i], B[i]);
		end
	endgenerate
	
endmodule // logic_gates