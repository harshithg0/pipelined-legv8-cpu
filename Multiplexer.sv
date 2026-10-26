`timescale 1ns/1ps
module Multiplexer(ReadData, Registers, ReadRegister);
	output logic [63:0] ReadData;
	input logic [63:0] Registers [0:31];
	input logic [4:0] ReadRegister;
	
	genvar i, j;
	generate
		for (i = 0; i < 64; i = i + 1) begin : loop1
			logic [31:0] bits;
			for (j = 0; j < 32; j = j + 1) begin : loop2
				assign bits[j] = Registers[j][i];
			end
			mux32_1 m1(.out(ReadData[i]), .in(bits), .sel(ReadRegister));
		end
	endgenerate
	
endmodule // Multiplexer


module MultiplexerALU(out, in, sel);
	output logic [63:0] out;
	input logic [63:0] in [0:7];
	input logic [2:0] sel;
	
	genvar i, j;
	generate
		for (i = 0; i < 64; i = i + 1) begin : loop1
			logic [7:0] bits;
			for (j = 0; j < 8; j = j + 1) begin : loop2
				assign bits[j] = in[j][i];
			end
			mux8_1 m1(.out(out[i]), .in(bits), .sel(sel));
		end
	endgenerate
	
endmodule // MultiplexerALU


module mux4_64(out, in, sel);
	output logic [63:0] out;
	input logic [63:0] in [0:3];
	input logic [1:0] sel;
	
	genvar i, j;
	generate
		for (i = 0; i < 64; i = i + 1) begin : loop1
			logic [3:0] bits;
			for (j = 0; j < 4; j = j + 1) begin : loop2
				assign bits[j] = in[j][i];
			end
			mux4_1 m1(.out(out[i]), .in(bits), .sel(sel));
		end
	endgenerate
	
endmodule // mux4_64


module mux2_64(out, i0, i1, sel);
	output logic [63:0] out;
	input logic [63:0] i0, i1;
	input logic sel;
	
	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin : loop1
			mux2_1 m1 (.out(out[i]), .i0(i0[i]), .i1(i1[i]), .sel(sel));
		end
	endgenerate
	
endmodule // mux2_64


module mux2_5(out, i0, i1, sel);
	output logic [4:0] out;
	input logic [4:0] i0, i1;
	input logic sel;
	
	genvar i;
	generate
		for (i = 0; i < 5; i = i + 1) begin : loop1
			mux2_1 m1 (.out(out[i]), .i0(i0[i]), .i1(i1[i]), .sel(sel));
		end
	endgenerate
	
endmodule // mux2_64


module mux32_1(out, in, sel);
	output logic out;
	input logic [31:0] in;
	input logic [4:0] sel;
	
	logic [15:0] l1;
	logic [7:0] l2;
	logic [3:0] l3;
	logic [1:0] l4;
	
	genvar i;
	generate
		for (i = 0; i < 16; i = i + 1) begin : level1
			mux2_1 m1 (.out(l1[i]), .i0(in[i*2]), .i1(in[i*2+1]), .sel(sel[0]));
		end
		
		for (i = 0; i < 8; i = i + 1) begin : level2
			mux2_1 m2 (.out(l2[i]), .i0(l1[i*2]), .i1(l1[i*2+1]), .sel(sel[1]));
		end
		
		for (i = 0; i < 4; i = i + 1) begin : level3
			mux2_1 m3 (.out(l3[i]), .i0(l2[i*2]), .i1(l2[i*2+1]), .sel(sel[2]));
		end
		
		for (i = 0; i < 2; i = i + 1) begin : level4
			mux2_1 m4 (.out(l4[i]), .i0(l3[i*2]), .i1(l3[i*2+1]), .sel(sel[3]));
		end
	endgenerate
	
	mux2_1 m5 (.out(out), .i0(l4[0]), .i1(l4[1]), .sel(sel[4]));

endmodule // mux32_1


module mux8_1(out, in, sel);
	output logic out;
	input logic [7:0] in;
	input logic [2:0] sel;
	
	logic [3:0] l1;
	logic [1:0] l2;
	
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin : level1
			mux2_1 m1 (.out(l1[i]), .i0(in[i*2]), .i1(in[i*2+1]), .sel(sel[0]));
		end
		
		for (i = 0; i < 2; i = i + 1) begin : level2
			mux2_1 m2 (.out(l2[i]), .i0(l1[i*2]), .i1(l1[i*2+1]), .sel(sel[1]));
		end
	endgenerate
	
	mux2_1 m3 (.out(out), .i0(l2[0]), .i1(l2[1]), .sel(sel[2]));

endmodule // mux8_1


module mux4_1(out, in, sel);
	output logic out;
	input logic [3:0] in;
	input logic [1:0] sel;
	
	logic [1:0] l1;
	
	genvar i;
	generate
		for (i = 0; i < 2; i = i + 1) begin : level1
			mux2_1 m1 (.out(l1[i]), .i0(in[i*2]), .i1(in[i*2+1]), .sel(sel[0]));
		end
	endgenerate
	
	mux2_1 m2 (.out(out), .i0(l1[0]), .i1(l1[1]), .sel(sel[1]));
 
endmodule // mux4_1
	

module mux2_1(out, i0, i1, sel);
	output logic out;
	input logic i0, i1, sel;
	
	logic a, b, nsel;

	not #0.05 n1 (nsel, sel);
	and #0.05 a1 (a, i0, nsel);
	and #0.05 b1 (b, i1, sel);
	or #0.05 o1 (out, a, b);
	
endmodule //mux2_1