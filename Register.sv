`timescale 1ns/1ps
module Register (DataOut, DataIn, WriteEnable, clk, reset);
	output logic [63:0] DataOut;
	input logic [63:0] DataIn;
   input logic WriteEnable, clk, reset;
	
	logic [63:0] muxOut;

	genvar i;
   generate
		for (i = 0; i < 64; i = i + 1) begin : loop1	
			mux2_1 m1 (.out(muxOut[i]), .i0(DataOut[i]), .i1(DataIn[i]), .sel(WriteEnable));
			D_FF ff (.q(DataOut[i]), .d(muxOut[i]), .reset(reset), .clk(clk));
      end
	endgenerate
 
endmodule // Registers
