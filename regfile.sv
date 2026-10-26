`timescale 1ns/1ps
module regfile (ReadData1, ReadData2, WriteData,
				 ReadRegister1, ReadRegister2, WriteRegister,
				 RegWrite, clk);

	output logic [63:0] ReadData1, ReadData2;
	input logic [63:0] WriteData;
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic RegWrite, clk;
	
	// Variables
	logic reset;
	logic [31:0] decoderOut;
	logic [63:0] Registers [0:31];
	
	
	// Decoder
	Decoder dec (.decoderOut(decoderOut), .WriteRegister(WriteRegister), .RegWrite(RegWrite));
	
	// Sets 0-30 Registers and 31th Register to 0
	genvar i;
	generate
		for (i = 0; i < 31; i = i + 1) begin : loop1
			Register regi (.DataOut(Registers[i]), .DataIn(WriteData),
							 .WriteEnable(decoderOut[i]), .clk(clk), .reset(reset));
		end
	endgenerate
	
	assign Registers[31] = 64'b0;
	
	
	// Multiplexers
	logic [63:0] rawReadData1, rawReadData2;
	Multiplexer mux1 (.ReadData(rawReadData1), .Registers(Registers), .ReadRegister(ReadRegister1));
	Multiplexer mux2 (.ReadData(rawReadData2), .Registers(Registers), .ReadRegister(ReadRegister2));

	logic [4:0] eq1, eq2;
	generate
		for (i = 0; i < 5; i = i + 1) begin : loop_eq
			xnor #0.05 xn1 (eq1[i], WriteRegister[i], ReadRegister1[i]);
			xnor #0.05 xn2 (eq2[i], WriteRegister[i], ReadRegister2[i]);
		end
	endgenerate
	
	logic regEq1, regEq2, not31, bypass1, bypass2;
	and  #0.05 ae1 (regEq1, eq1[0], eq1[1], eq1[2], eq1[3], eq1[4]);
	and  #0.05 ae2 (regEq2, eq2[0], eq2[1], eq2[2], eq2[3], eq2[4]);
	nand #0.05 n31 (not31, WriteRegister[0], WriteRegister[1], WriteRegister[2], WriteRegister[3], WriteRegister[4]);
	
	and #0.05 ab1 (bypass1, RegWrite, regEq1, not31);
	and #0.05 ab2 (bypass2, RegWrite, regEq2, not31);
	
	mux2_64 bp1 (.out(ReadData1), .i0(rawReadData1), .i1(WriteData), .sel(bypass1));
	mux2_64 bp2 (.out(ReadData2), .i0(rawReadData2), .i1(WriteData), .sel(bypass2));

endmodule // regfile