`timescale 1ns/10ps
module pipeline_cpu_tb();
	parameter ClockDelay = 5000;
	parameter NumCycles = 5000;
	logic clk, reset;
	integer i;
	
	pipeline_cpu dut (.clk, .reset);
	initial $timeformat(-9, 2, " ns", 10);
	initial begin
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	initial begin
		reset <= 1;
		@(posedge clk);
		@(posedge clk);
		reset <= 0;
		for (i = 0; i < NumCycles; i = i + 1) begin
			@(posedge clk);
			$display("%t PC=%0d Instruction=%h", $time, dut.PC, dut.Instruct);
		end
		// test01_AddiB.arm
//		$display("%t test01_AddiB.arm", $time);
//		assert (dut.rf.Registers[0] == 64'd0);
//		assert (dut.rf.Registers[1] == 64'd1);
//		assert (dut.rf.Registers[2] == 64'd2);
//		assert (dut.rf.Registers[3] == 64'd3);
//		assert (dut.rf.Registers[4] == 64'd4);
		
		// test02_AddsSubs.arm
//		$display("%t test02_AddsSubs.arm", $time);
//		assert ($signed(dut.rf.Registers[0]) ==  1);
//		assert ($signed(dut.rf.Registers[1]) == -1);
//		assert ($signed(dut.rf.Registers[2]) ==  2);
//		assert ($signed(dut.rf.Registers[3]) == -3);
//		assert ($signed(dut.rf.Registers[4]) == -2);
//		assert ($signed(dut.rf.Registers[5]) == -5);
//		assert ($signed(dut.rf.Registers[6]) ==  0);
//		assert ($signed(dut.rf.Registers[7]) == -6);
//		assert (dut.Negative == 1'b1);
//		assert (dut.Carryout == 1'b1);
//		assert (dut.Overflow == 1'b0);
//		assert (dut.Zero == 1'b0);

		// test03_CbzB.arm
//		$display("%t test03_CbzB.arm", $time);
//		assert (dut.rf.Registers[0] == 64'd1);
//		assert (dut.rf.Registers[1] == 64'd0);
//		assert (dut.rf.Registers[2] == 64'd4);
//		assert (dut.rf.Registers[3] == 64'd1);
//		assert (dut.rf.Registers[4] == 64'd31);
//		assert (dut.rf.Registers[5] == 64'd0);

		// test04_LdurStur.arm
//		$display("%t test04_LdurStur.arm", $time);
//		assert (dut.rf.Registers[0] == 64'd1);
//		assert (dut.rf.Registers[1] == 64'd2);
//		assert (dut.rf.Registers[2] == 64'd3);
//		assert (dut.rf.Registers[3] == 64'd8);
//		assert (dut.rf.Registers[4] == 64'd11);
//		assert (dut.rf.Registers[5] == 64'd1);
//		assert (dut.rf.Registers[6] == 64'd2);
//		assert (dut.rf.Registers[7] == 64'd3);
//		assert ({dut.dm.mem[7],dut.dm.mem[6],dut.dm.mem[5],dut.dm.mem[4],dut.dm.mem[3],dut.dm.mem[2],dut.dm.mem[1],dut.dm.mem[0]} == 64'd1);
//		assert ({dut.dm.mem[15],dut.dm.mem[14],dut.dm.mem[13],dut.dm.mem[12],dut.dm.mem[11],dut.dm.mem[10],dut.dm.mem[9],dut.dm.mem[8]} == 64'd2);
//		assert ({dut.dm.mem[23],dut.dm.mem[22],dut.dm.mem[21],dut.dm.mem[20],dut.dm.mem[19],dut.dm.mem[18],dut.dm.mem[17],dut.dm.mem[16]} == 64'd3);

		// test05_Blt.arm
//		$display("%t test05_Blt.arm", $time);
//		assert (dut.rf.Registers[0] == 64'd1);
//		assert (dut.rf.Registers[1] == 64'd1);

		// test06_BlBr.arm
//		$display("%t test06_BlBr.arm", $time);
//		assert (dut.rf.Registers[0]  == 64'd1);
//		assert (dut.rf.Registers[1]  == 64'd0);
//		assert (dut.rf.Registers[2]  == 64'd0);
//		assert (dut.rf.Registers[3]  == 64'd1);
//		assert (dut.rf.Registers[4]  == 64'd52);
//		assert (dut.rf.Registers[5]  == 64'd64);
//		assert (dut.rf.Registers[29] == 64'd20);
//		assert (dut.rf.Registers[30] == 64'd68);

		// test10_forwarding.arm
//		$display("%t test10_forwarding.arm", $time);
//		assert (dut.rf.Registers[0]  == 64'd0);
//		assert (dut.rf.Registers[1]  == 64'd8);
//		assert (dut.rf.Registers[2]  == 64'd4);
//		assert (dut.rf.Registers[3]  == 64'd5);
//		assert (dut.rf.Registers[4]  == 64'd7);
//		assert (dut.rf.Registers[5]  == 64'd2);
//		assert ($signed(dut.rf.Registers[6]) == -2);
//		assert ($signed(dut.rf.Registers[7]) == -2);
//		assert (dut.rf.Registers[8]  == 64'd0);
//		assert (dut.rf.Registers[9]  == 64'd1);
//		assert ($signed(dut.rf.Registers[10]) == -4);
//		assert (dut.rf.Registers[14] == 64'd5);
//		assert (dut.rf.Registers[15] == 64'd8);
//		assert (dut.rf.Registers[16] == 64'd9);
//		assert (dut.rf.Registers[17] == 64'd1);
//		assert (dut.rf.Registers[18] == 64'd99);
//		assert ({dut.dm.mem[7],dut.dm.mem[6],dut.dm.mem[5],dut.dm.mem[4],dut.dm.mem[3],dut.dm.mem[2],dut.dm.mem[1],dut.dm.mem[0]} == 64'd8);
//		assert ({dut.dm.mem[15],dut.dm.mem[14],dut.dm.mem[13],dut.dm.mem[12],dut.dm.mem[11],dut.dm.mem[10],dut.dm.mem[9],dut.dm.mem[8]} == 64'd5);

		// test11_Sort.arm
//		$display("%t test11_Sort.arm", $time);
//		assert (dut.rf.Registers[11] == 64'd1);
//		assert (dut.rf.Registers[12] == 64'd2);
//		assert (dut.rf.Registers[13] == 64'd3);
//		assert (dut.rf.Registers[14] == 64'd4);
//		assert (dut.rf.Registers[15] == 64'd5);
//		assert (dut.rf.Registers[16] == 64'd6);
//		assert (dut.rf.Registers[17] == 64'd7);
//		assert (dut.rf.Registers[18] == 64'd8);
//		assert (dut.rf.Registers[19] == 64'd9);
//		assert (dut.rf.Registers[20] == 64'd10);

		// test12_Fibonacci.arm
		$display("%t test12_Fibonacci.arm", $time);
		assert (dut.rf.Registers[0]  == 64'd6);
		assert (dut.rf.Registers[1]  == 64'd8);
		assert (dut.rf.Registers[28] == 64'd8);
		assert (dut.rf.Registers[30] == 64'd196);
		$stop;
	end
endmodule // pipeline_cpu_tb