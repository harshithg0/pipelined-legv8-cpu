`timescale 1ns/1ps
module ALUControl(ALUOp, opcode_I, ALUCtrl);

	input logic [1:0] ALUOp;
	input logic [10:0] opcode_I;
	output logic [2:0] ALUCtrl;
	
	always_comb begin
		ALUCtrl = 3'b010;
		if (ALUOp == 2'b10) begin
			if (opcode_I == 11'b11101011000)
				ALUCtrl = 3'b011;
			else 
				ALUCtrl = 3'b010;
		end else if (ALUOp == 2'b01) begin
			ALUCtrl = 3'b011;
		end
	end
	
endmodule // ALUControl
	
	