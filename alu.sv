`timescale 1ns/1ps
module alu (A, B, cntrl, result, negative, zero, overflow, carry_out);
	output logic [63:0] result;
	output logic negative, zero, overflow, carry_out;
	input logic [63:0] A, B;
	input logic [2:0] cntrl;
	
	// 0 = b, 1 = 0, 2 = add, 3 = sub, 4 = and, 5 = or, 6 = xor, 7 = 0
	logic [63:0] Operations [0:7];
	adder_subtractor as (.A(A), .B(B), .cntrl(cntrl), .S(Operations[2]), .Cout(carry_out), .overflow(overflow));
	logic_gates lg (.A(A), .B(B), .and_output(Operations[4]), .or_output(Operations[5]), .xor_output(Operations[6]));
	
	assign Operations[0] = B;
	assign Operations[3] = Operations[2];
	assign Operations[1] = 64'b0;
	assign Operations[7] = 64'b0;

	MultiplexerALU m (.out(result), .in(Operations), .sel(cntrl));
	assign negative = result[63];
	nor #0.05 nr1 (zero, result[0], result[1], result[2], result[3], result[4], result[5], result[6],
								result[7], result[8], result[9], result[10], result[11], result[12], result[13], 
								result[14], result[15], result[16], result[17], result[18], result[19], result[20], 
								result[21], result[22], result[23], result[24], result[25], result[26], result[27], 
								result[28], result[29], result[30], result[31], result[32], result[33], result[34],
								result[35], result[36], result[37], result[38], result[39], result[40], result[41],
								result[42], result[43], result[44], result[45], result[46], result[47], result[48], 
								result[49], result[50], result[51], result[52], result[53], result[54], result[55],
								result[56], result[57], result[58], result[59], result[60], result[61], result[62], result[63]);

endmodule // regfile