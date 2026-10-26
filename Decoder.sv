`timescale 1ns/1ps
module Decoder(decoderOut, WriteRegister, RegWrite);
	output logic [31:0] decoderOut;
	input logic [4:0] WriteRegister;
	input logic RegWrite;
	
	logic [3:0] decEnable;
	
	decoder2_4 d24(.out(decEnable), .sel(WriteRegister[4:3]), .enable(RegWrite));
	
	decoder3_8 d1(.out(decoderOut[7:0]), .sel(WriteRegister[2:0]), .enable(decEnable[0]));
	decoder3_8 d2(.out(decoderOut[15:8]), .sel(WriteRegister[2:0]), .enable(decEnable[1]));
	decoder3_8 d3(.out(decoderOut[23:16]), .sel(WriteRegister[2:0]), .enable(decEnable[2]));
	decoder3_8 d4(.out(decoderOut[31:24]), .sel(WriteRegister[2:0]), .enable(decEnable[3]));
	
endmodule // Decoder


module decoder3_8(out, sel, enable);
	output logic [7:0] out;
	input logic [2:0] sel;
	input logic enable;
	
	logic nenable, na, nb;
	
	not #0.05 n1 (nenable, sel[2]);
	and #0.05 a1 (na, nenable, enable);
	and #0.05 a2 (nb, sel[2], enable);
	
	decoder2_4 d1(.out(out[3:0]), .sel(sel[1:0]), .enable(na));
	decoder2_4 d2(.out(out[7:4]), .sel(sel[1:0]), .enable(nb));


endmodule // decoder3_8


module decoder2_4(out, sel, enable);
	output logic [3:0] out;
	input logic [1:0] sel;
	input logic enable;
	
	logic na, nb;
	
	not #0.05 n1 (na, sel[0]);
	not #0.05 n2 (nb, sel[1]);
	
	and #0.05 a1 (out[0], na, nb, enable);
	and #0.05 a2 (out[1], nb, sel[0], enable);
	and #0.05 a3 (out[2], na, sel[1], enable);
	and #0.05 a4 (out[3], sel[0], sel[1], enable);

endmodule // decoder2_4