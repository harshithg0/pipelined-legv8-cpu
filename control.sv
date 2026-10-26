`timescale 1ns/1ps
module control (opcode_RD, opcode_I, opcode_B, opcode_CB, RegWrite, ALUSrc,
					 MemWrite, MemRead, Mem2Reg, Reg2Loc, Branch, CBranch, CBZSel, 
					 UnCondBr, BRBranch, BLInstr, FlagWrite, ALUOp, ImmOp);

	input logic [10:0] opcode_RD;
	input logic [9:0] opcode_I;
	input logic [5:0] opcode_B;
	input logic [7:0] opcode_CB;
	output logic RegWrite, ALUSrc, MemWrite, MemRead, Mem2Reg, Reg2Loc, 
					 Branch, CBranch, CBZSel, UnCondBr, BRBranch, BLInstr, FlagWrite;
	output logic [1:0] ALUOp, ImmOp;
	
	always_comb begin
		RegWrite = 1'b0;
		ALUSrc = 1'b0;
		MemWrite = 1'b0;
		MemRead = 1'b0;
		Mem2Reg = 1'b0;
		Reg2Loc = 1'b0;
		Branch = 1'b0;
		CBranch = 1'b0;
		CBZSel = 1'b0;
		UnCondBr = 1'b0;
		BRBranch = 1'b0;
		BLInstr = 1'b0;
		FlagWrite = 1'b0;
		ALUOp = 2'b00;
		ImmOp = 2'b00;
		if (opcode_I == 10'b1001000100) begin // ADDI
			ALUSrc = 1'b1;
			RegWrite = 1'b1;
			
		end else if (opcode_RD == 11'b10101011000 || opcode_RD == 11'b11101011000) begin // ADDS/SUBS
			RegWrite = 1'b1;
			ALUOp = 2'b10;
			FlagWrite = 1'b1;
			
		end else if (opcode_B == 6'b000101) begin // B
			UnCondBr = 1'b1;
			ImmOp = 2'b10;
			
		end else if (opcode_CB == 8'b01010100) begin // B.cond
			CBranch = 1'b1;
			ALUOp = 2'b01;
			ImmOp = 2'b11;
			
		end else if (opcode_B == 6'b100101) begin // BL
			UnCondBr = 1'b1;
			BLInstr = 1'b1;
			RegWrite = 1'b1;
			ImmOp = 2'b10;
		
		end else if (opcode_RD == 11'b11010110000) begin // BR
			BRBranch = 1'b1;
		
		end else if (opcode_CB == 8'b10110100) begin // CBZ
			CBZSel = 1'b1;
			Branch = 1'b1;
			ALUOp = 2'b01;
			ImmOp = 2'b11;
		
		end else if (opcode_RD == 11'b11111000010) begin // LDUR
			RegWrite = 1'b1;
			ALUSrc = 1'b1;
			MemRead = 1'b1;
			Mem2Reg = 1'b1;
			ImmOp = 2'b01;
		
		end else if (opcode_RD == 11'b11111000000) begin // STUR
			Reg2Loc = 1'b1;
			ALUSrc = 1'b1;
			MemWrite = 1'b1;
			ImmOp = 2'b01;
		
		end
	end
endmodule // control
			
		
		
		