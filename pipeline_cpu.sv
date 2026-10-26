`timescale 1ns/1ps
module pipeline_cpu (clk, reset);

	input logic clk, reset;
	
	// IF Stage
	// PC
	logic hz_WriteEnable, IF_Flush;
	logic [63:0] PC, updatePC, PC_4;
	Register regPC (.DataOut(PC), .DataIn(updatePC), .WriteEnable(hz_WriteEnable), .clk(clk), .reset(reset));
	adder_subtractor pc4 (.A(PC), .B(64'd4), .cntrl(3'b010), .S(PC_4), .Cout(), .overflow());
	
	// Instructions
	logic [31:0] Instruct;
	instructmem im (.address(PC), .instruction(Instruct), .clk(clk));
	
	
	// IF/ID Stage
	// Pipeline Register
	logic [63:0] Instruct64_D, PC_D;
	logic [31:0] Instruct_D;
	
	PipelineReg if_id_instruct (.DataOut(Instruct64_D), .DataIn({32'b0, Instruct}), .WriteEnable(hz_WriteEnable),
	.Flush(IF_Flush), .clk(clk), .reset(reset));
	PipelineReg if_id_pc (.DataOut(PC_D), .DataIn(PC), .WriteEnable(hz_WriteEnable), .Flush(IF_Flush),
	.clk(clk), .reset(reset));
	assign Instruct_D = Instruct64_D[31:0];
	
	
	// ID Stage
	// Control					  
	logic RegWrite, ALUSrc, MemWrite, MemRead, Mem2Reg, Reg2Loc, 
			Branch, CBranch, CBZSel, UnCondBr, BRBranch, BLInstr, FlagWrite;
	logic [1:0] ALUOp, ImmOp;
	control ctrl (.opcode_RD(Instruct_D[31:21]), .opcode_I(Instruct_D[31:22]), .opcode_B(Instruct_D[31:26]),
					  .opcode_CB(Instruct_D[31:24]), .RegWrite(RegWrite), .ALUSrc(ALUSrc), .MemWrite(MemWrite),
					  .MemRead(MemRead), .Mem2Reg(Mem2Reg), .Reg2Loc(Reg2Loc), .Branch(Branch), .CBranch(CBranch),
					  .CBZSel(CBZSel), .UnCondBr(UnCondBr), .BRBranch(BRBranch), .BLInstr(BLInstr), .FlagWrite(FlagWrite),
					  .ALUOp(ALUOp), .ImmOp(ImmOp));
	
	
	// ALU Control
	logic [2:0] ALUCtrl;
	ALUControl aluc (.ALUOp(ALUOp), .opcode_I(Instruct_D[31:21]), .ALUCtrl(ALUCtrl));
	
	//Sign Extender
	logic [63:0] immOut;
	sign_extend se (.imm_I(Instruct_D[21:10]), .imm_D(Instruct_D[20:12]), .imm_B(Instruct_D[25:0]),
						 .imm_CB(Instruct_D[23:5]), .ImmOp(ImmOp), .immOut(immOut));
						 
	
	// Register
	logic RegWrite_W, Mem2Reg_W, BLInstr_W;
	logic [4:0] WriteRegister_W;
	logic [63:0] ReadData1, ReadData2, WriteData;
	logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	logic [4:0] Rm, Rn, Rd;
	logic isZero;
	
	assign Rm = Instruct_D[20:16];
	assign Rn = Instruct_D[9:5];
	assign Rd = Instruct_D[4:0];
	
	logic reg1sel;
	or #(0.05) o3 (reg1sel, BRBranch, CBZSel);
	mux2_5 cbzm (.out(ReadRegister1), .i0(Rn), .i1(Rd), .sel(reg1sel));
	mux2_5 sturm (.out(ReadRegister2), .i0(Rm), .i1(Rd), .sel(Reg2Loc));
	mux2_5 blm (.out(WriteRegister), .i0(Rd), .i1(5'd30), .sel(BLInstr));
	
	regfile rf (.ReadData1(ReadData1), .ReadData2(ReadData2), .WriteData(WriteData),
					.ReadRegister1(ReadRegister1), .ReadRegister2(ReadRegister2),
					.WriteRegister(WriteRegister_W), .RegWrite(RegWrite_W), .clk(clk));
	
	logic RegWrite_M, Mem2Reg_M, BLInstr_M, MemRead_M, MemWrite_M;
	logic [4:0] WriteRegister_M;
	logic [63:0] ALUOut_M, StoreData_M, PC_4_M, WriteRegister64_M;
	
	logic RegWrite_E, MemWrite_E, MemRead_E, Mem2Reg_E, BLInstr_E, ALUSrc_E, FlagWrite_E;
	logic [2:0] ALUCtrl_E;
	logic [4:0] WriteRegister_E, Rn_E, Rm_E;
	logic [63:0] ALUOut;
	logic ALUneg, ALUzero, ALUof, ALUco;
	
	logic [1:0] forwarda_br, forwardb_br;
	ForwardingUnit fu_br (.forwarda(forwarda_br), .forwardb(forwardb_br), .ex_rn(ReadRegister1), .ex_rm(ReadRegister2),
						  .exmem_rd(WriteRegister_M), .exmem_regwrite(RegWrite_M),
						  .memwb_rd(WriteRegister_W), .memwb_regwrite(RegWrite_W));
	
	logic [4:0] eqE;
	genvar j;
	generate
		for (j = 0; j < 5; j = j + 1) begin : loop_eqE
			xnor #0.05 xnE (eqE[j], WriteRegister_E[j], ReadRegister1[j]);
		end
	endgenerate
	
	logic regEqE, not31E, exNow_match;
	and  #0.05 aeE (regEqE, eqE[0], eqE[1], eqE[2], eqE[3], eqE[4]);
	nand #0.05 n31E (not31E, WriteRegister_E[0], WriteRegister_E[1], WriteRegister_E[2], WriteRegister_E[3], WriteRegister_E[4]);
	and  #0.05 aExNow (exNow_match, RegWrite_E, regEqE, not31E);
	
	logic [1:0] forwarda_br_final;
	mux2_1 fbf1 (.out(forwarda_br_final[1]), .i0(forwarda_br[1]), .i1(1'b1), .sel(exNow_match));
	mux2_1 fbf0 (.out(forwarda_br_final[0]), .i0(forwarda_br[0]), .i1(1'b1), .sel(exNow_match));
	
	logic [63:0] fwdBranch_in [0:3];
	logic [63:0] ReadData1_fwd;
	assign fwdBranch_in[0] = ReadData1;
	assign fwdBranch_in[1] = WriteData;
	assign fwdBranch_in[2] = ALUOut_M;
	assign fwdBranch_in[3] = ALUOut;
	mux4_64 branchFwdMux (.out(ReadData1_fwd), .in(fwdBranch_in), .sel(forwarda_br_final));
					
	assign isZero = (ReadData1_fwd == 64'b0);
	
	logic [63:0] targetbranch, PC_4_D;
	adder_subtractor badd (.A(PC_D), .B(immOut), .cntrl(3'b010), .S(targetbranch), .Cout(), .overflow());
	adder_subtractor pc4_d_adder (.A(PC_D), .B(64'd4), .cntrl(3'b010), .S(PC_4_D), .Cout(), .overflow());
	
	logic Negative, Zero, Overflow, Carryout;
	logic TakeBranch;
	logic [63:0] PCtemp;
	
	logic Negative_fwd, Overflow_fwd;
	mux2_1 m_neg (.out(Negative_fwd), .i0(Negative), .i1(ALUneg), .sel(FlagWrite_E));
	mux2_1 m_ovf (.out(Overflow_fwd), .i0(Overflow), .i1(ALUof), .sel(FlagWrite_E));
	
	logic cbz_branch, blt_false, blt_branch, cond_branch;
	
	and #(0.05) a1 (cbz_branch, Branch, isZero);
	xor #(0.05) x1 (blt_false, Negative_fwd, Overflow_fwd);
	and #(0.05) a2 (blt_branch, CBranch, blt_false);
	or #(0.05) o1 (cond_branch, cbz_branch, blt_branch);
	or #(0.05) o2 (TakeBranch, cond_branch, UnCondBr);
	
	mux2_64 pcm1 (.out(PCtemp), .i0(PC_4), .i1(targetbranch), .sel(TakeBranch));
	mux2_64 pcm2 (.out(updatePC), .i0(PCtemp), .i1(ReadData1_fwd), .sel(BRBranch));
	
	assign IF_Flush = 1'b0;
	
	logic id_ex_muxsel;
	HazardDetectionUnit hdu (.WriteEnable(hz_WriteEnable), .id_ex_muxsel(id_ex_muxsel), .id_ex_memread(MemRead_E),
							  .id_ex_rd(WriteRegister_E), .if_id_rn(ReadRegister1), .if_id_rm(ReadRegister2));
	
	logic RegWrite_bub, MemWrite_bub, MemRead_bub, Mem2Reg_bub, BLInstr_bub, ALUSrc_bub, FlagWrite_bub;
	and #0.05 bg1 (RegWrite_bub, RegWrite, id_ex_muxsel);
	and #0.05 bg2 (MemWrite_bub, MemWrite, id_ex_muxsel);
	and #0.05 bg3 (MemRead_bub, MemRead, id_ex_muxsel);
	and #0.05 bg4 (Mem2Reg_bub, Mem2Reg, id_ex_muxsel);
	and #0.05 bg5 (BLInstr_bub, BLInstr, id_ex_muxsel);
	and #0.05 bg6 (ALUSrc_bub, ALUSrc, id_ex_muxsel);
	and #0.05 bg7 (FlagWrite_bub, FlagWrite, id_ex_muxsel);
	
	
	// ID/EX
	logic [63:0] RegWrite64_E, MemWrite64_E, MemRead64_E, Mem2Reg64_E, BLInstr64_E, ALUSrc64_E, FlagWrite64_E, ALUCtrl64_E;
	logic [63:0] ReadData1_E, ReadData2_E, immOut_E, PC_4_E;
	logic [63:0] WriteRegister64_E, Rn64_E, Rm64_E;
	
	Register idex_rw (.DataOut(RegWrite64_E), .DataIn({63'b0, RegWrite_bub}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_mw (.DataOut(MemWrite64_E), .DataIn({63'b0, MemWrite_bub}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_mr (.DataOut(MemRead64_E), .DataIn({63'b0, MemRead_bub}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_m2r (.DataOut(Mem2Reg64_E), .DataIn({63'b0, Mem2Reg_bub}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_bl (.DataOut(BLInstr64_E), .DataIn({63'b0, BLInstr_bub}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_as (.DataOut(ALUSrc64_E), .DataIn({63'b0, ALUSrc_bub}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_fw (.DataOut(FlagWrite64_E), .DataIn({63'b0, FlagWrite_bub}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_ac (.DataOut(ALUCtrl64_E), .DataIn({61'b0, ALUCtrl}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_d1 (.DataOut(ReadData1_E), .DataIn(ReadData1), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_d2 (.DataOut(ReadData2_E), .DataIn(ReadData2), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_imm (.DataOut(immOut_E), .DataIn(immOut), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_pc4 (.DataOut(PC_4_E), .DataIn(PC_4_D), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_wreg (.DataOut(WriteRegister64_E), .DataIn({59'b0, WriteRegister}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_rn (.DataOut(Rn64_E), .DataIn({59'b0, ReadRegister1}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register idex_rm (.DataOut(Rm64_E), .DataIn({59'b0, ReadRegister2}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	
	assign RegWrite_E = RegWrite64_E[0];
	assign MemWrite_E = MemWrite64_E[0];
	assign MemRead_E = MemRead64_E[0];
	assign Mem2Reg_E = Mem2Reg64_E[0];
	assign BLInstr_E = BLInstr64_E[0];
	assign ALUSrc_E = ALUSrc64_E[0];
	assign FlagWrite_E = FlagWrite64_E[0];
	assign ALUCtrl_E = ALUCtrl64_E[2:0];
	assign WriteRegister_E = WriteRegister64_E[4:0];
	assign Rn_E = Rn64_E[4:0];
	assign Rm_E = Rm64_E[4:0];
	
	
	// ALU
	logic [1:0] forwarda, forwardb;
	ForwardingUnit fu (.forwarda(forwarda), .forwardb(forwardb), .ex_rn(Rn_E), .ex_rm(Rm_E),
					   .exmem_rd(WriteRegister_M), .exmem_regwrite(RegWrite_M),
					   .memwb_rd(WriteRegister_W), .memwb_regwrite(RegWrite_W));
	
	logic [63:0] fwdA_in [0:3];
	logic [63:0] fwdB_in [0:3];
	logic [63:0] fwdA, fwdB;
	assign fwdA_in[0] = ReadData1_E;
	assign fwdA_in[1] = WriteData;
	assign fwdA_in[2] = ALUOut_M;
	assign fwdA_in[3] = 64'b0;
	
	assign fwdB_in[0] = ReadData2_E;
	assign fwdB_in[1] = WriteData; 
	assign fwdB_in[2] = ALUOut_M;
	assign fwdB_in[3] = 64'b0;
	
	mux4_64 fwdAmux (.out(fwdA), .in(fwdA_in), .sel(forwarda));
	mux4_64 fwdBmux (.out(fwdB), .in(fwdB_in), .sel(forwardb));
	
	logic [63:0] B;
	mux2_64 alum (.out(B), .i0(fwdB), .i1(immOut_E), .sel(ALUSrc_E));
	alu al (.A(fwdA), .B(B), .cntrl(ALUCtrl_E), .result(ALUOut), .negative(ALUneg), .zero(ALUzero),
			.overflow(ALUof), .carry_out(ALUco));
	
	logic [63:0] FlagsIn, FlagsOut;
	assign FlagsIn = {60'b0, ALUneg, ALUzero, ALUof, ALUco};
	Register flagsreg (.DataOut(FlagsOut), .DataIn(FlagsIn), .WriteEnable(FlagWrite_E), .clk(clk), .reset(reset));
	assign {Negative, Zero, Overflow, Carryout} = FlagsOut[3:0];
	
	
	// EX/MEM
	logic [63:0] RegWrite64_M, Mem2Reg64_M, BLInstr64_M, MemRead64_M, MemWrite64_M;
	
	Register exmem_rw (.DataOut(RegWrite64_M), .DataIn({63'b0, RegWrite_E}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register exmem_m2r (.DataOut(Mem2Reg64_M), .DataIn({63'b0, Mem2Reg_E}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register exmem_bl (.DataOut(BLInstr64_M), .DataIn({63'b0, BLInstr_E}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register exmem_mr (.DataOut(MemRead64_M), .DataIn({63'b0, MemRead_E}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register exmem_mw (.DataOut(MemWrite64_M), .DataIn({63'b0, MemWrite_E}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register exmem_alu (.DataOut(ALUOut_M), .DataIn(ALUOut), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register exmem_sd (.DataOut(StoreData_M), .DataIn(fwdB), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register exmem_pc4 (.DataOut(PC_4_M), .DataIn(PC_4_E), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register exmem_wreg (.DataOut(WriteRegister64_M), .DataIn({59'b0, WriteRegister_E}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	
	assign RegWrite_M = RegWrite64_M[0];
	assign Mem2Reg_M = Mem2Reg64_M[0];
	assign BLInstr_M = BLInstr64_M[0];
	assign MemRead_M = MemRead64_M[0];
	assign MemWrite_M = MemWrite64_M[0];
	assign WriteRegister_M = WriteRegister64_M[4:0];
	
	
	// Data Memory
	logic [63:0] dataMem;
	datamem dm (.address(ALUOut_M), .write_data(StoreData_M), .read_enable(MemRead_M),
				.write_enable(MemWrite_M), .xfer_size(4'd8), .read_data(dataMem), .clk(clk));
	
	
	// MEM/WB
	logic [63:0] RegWrite64_W, Mem2Reg64_W, BLInstr64_W;
	logic [63:0] ALUOut_W, dataMem_W, PC_4_W, WriteRegister64_W;
	
	Register memwb_rw (.DataOut(RegWrite64_W), .DataIn({63'b0, RegWrite_M}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register memwb_m2r (.DataOut(Mem2Reg64_W), .DataIn({63'b0, Mem2Reg_M}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register memwb_bl (.DataOut(BLInstr64_W), .DataIn({63'b0, BLInstr_M}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register memwb_alu (.DataOut(ALUOut_W), .DataIn(ALUOut_M), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register memwb_mem (.DataOut(dataMem_W), .DataIn(dataMem), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register memwb_pc4 (.DataOut(PC_4_W), .DataIn(PC_4_M), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	Register memwb_wreg (.DataOut(WriteRegister64_W), .DataIn({59'b0, WriteRegister_M}), .WriteEnable(1'b1), .clk(clk), .reset(reset));
	
	assign RegWrite_W = RegWrite64_W[0];
	assign Mem2Reg_W = Mem2Reg64_W[0];
	assign BLInstr_W = BLInstr64_W[0];
	assign WriteRegister_W = WriteRegister64_W[4:0];
	
	logic [63:0] wbTemp;
	mux2_64 m1 (.out(wbTemp), .i0(ALUOut_W), .i1(dataMem_W), .sel(Mem2Reg_W));
	mux2_64 m2 (.out(WriteData), .i0(wbTemp), .i1(PC_4_W), .sel(BLInstr_W));
	
endmodule // pipeline_cpu