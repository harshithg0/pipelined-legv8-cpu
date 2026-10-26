`timescale 1ns/1ps
module HazardDetectionUnit (WriteEnable, id_ex_muxsel, id_ex_memread, id_ex_rd, if_id_rn, if_id_rm);

	input logic id_ex_memread;
	input logic [4:0] id_ex_rd, if_id_rn, if_id_rm;
	output logic WriteEnable, id_ex_muxsel;
	
	always_comb begin
		WriteEnable = 1'b1;
		id_ex_muxsel = 1'b1;
		if (id_ex_memread && id_ex_rd != 5'b11111 && (id_ex_rd == if_id_rn || id_ex_rd == if_id_rm)) begin
			WriteEnable = 1'b0;
			id_ex_muxsel = 1'b0;
		end
	end
endmodule // HazardDetectionUnit