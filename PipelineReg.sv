`timescale 1ns/1ps
module PipelineReg (DataOut, DataIn, WriteEnable, Flush, clk, reset);
	output logic [63:0] DataOut;
	input logic [63:0] DataIn;
	input logic WriteEnable, Flush, clk, reset;
	
	logic clear;
	or #0.05 o1 (clear, reset, Flush);
	
	Register reg1 (.DataOut(DataOut), .DataIn(DataIn), .WriteEnable(WriteEnable), .clk(clk), .reset(clear));
	
endmodule // PipelineReg