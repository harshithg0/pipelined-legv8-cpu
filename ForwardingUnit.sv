`timescale 1ns/1ps
module ForwardingUnit (forwarda, forwardb, ex_rn, ex_rm, exmem_rd, exmem_regwrite, memwb_rd, memwb_regwrite);
	
	input logic [4:0] ex_rn, ex_rm, exmem_rd, memwb_rd;
	input logic exmem_regwrite, memwb_regwrite;
	output logic [1:0] forwarda, forwardb;
	
	always_comb begin
		// A
		if (exmem_regwrite && exmem_rd != 5'b11111 && exmem_rd == ex_rn) begin
			forwarda = 2'b10; // EX/MEM
		end else if (memwb_regwrite && memwb_rd != 5'b11111 && memwb_rd == ex_rn) begin
			forwarda = 2'b01; // MEM/WB
		end else begin
			forwarda = 2'b00;
		end
		
		// B
		if (exmem_regwrite && exmem_rd != 5'b11111 && exmem_rd == ex_rm) begin
			forwardb = 2'b10; // EX/MEM
		end else if (memwb_regwrite && memwb_rd != 5'b11111 && memwb_rd == ex_rm) begin
			forwardb = 2'b01; // MEM/WB
		end else begin
			forwardb = 2'b00;
		end
	end
endmodule // ForwardingUnit
	