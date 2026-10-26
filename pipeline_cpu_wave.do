onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock / Control}
add wave -noupdate /pipeline_cpu_tb/dut/clk
add wave -noupdate /pipeline_cpu_tb/dut/reset
add wave -noupdate -divider {IF Stage}
add wave -noupdate /pipeline_cpu_tb/dut/PC
add wave -noupdate /pipeline_cpu_tb/dut/PC_4
add wave -noupdate /pipeline_cpu_tb/dut/updatePC
add wave -noupdate /pipeline_cpu_tb/dut/Instruct
add wave -noupdate -divider IF/ID
add wave -noupdate /pipeline_cpu_tb/dut/hz_WriteEnable
add wave -noupdate /pipeline_cpu_tb/dut/IF_Flush
add wave -noupdate /pipeline_cpu_tb/dut/Instruct_D
add wave -noupdate /pipeline_cpu_tb/dut/PC_D
add wave -noupdate -divider {ID Stage}
add wave -noupdate /pipeline_cpu_tb/dut/RegWrite
add wave -noupdate /pipeline_cpu_tb/dut/MemRead
add wave -noupdate /pipeline_cpu_tb/dut/MemWrite
add wave -noupdate /pipeline_cpu_tb/dut/Reg2Loc
add wave -noupdate /pipeline_cpu_tb/dut/BLInstr
add wave -noupdate /pipeline_cpu_tb/dut/ReadRegister1
add wave -noupdate /pipeline_cpu_tb/dut/ReadRegister2
add wave -noupdate /pipeline_cpu_tb/dut/WriteRegister
add wave -noupdate /pipeline_cpu_tb/dut/ReadData1
add wave -noupdate /pipeline_cpu_tb/dut/ReadData2
add wave -noupdate /pipeline_cpu_tb/dut/isZero
add wave -noupdate /pipeline_cpu_tb/dut/Branch
add wave -noupdate /pipeline_cpu_tb/dut/CBranch
add wave -noupdate /pipeline_cpu_tb/dut/UnCondBr
add wave -noupdate /pipeline_cpu_tb/dut/BRBranch
add wave -noupdate /pipeline_cpu_tb/dut/TakeBranch
add wave -noupdate /pipeline_cpu_tb/dut/targetbranch
add wave -noupdate /pipeline_cpu_tb/dut/id_ex_muxsel
add wave -noupdate -divider {ID/EX + EX Stage}
add wave -noupdate /pipeline_cpu_tb/dut/RegWrite_E
add wave -noupdate /pipeline_cpu_tb/dut/MemRead_E
add wave -noupdate /pipeline_cpu_tb/dut/MemWrite_E
add wave -noupdate /pipeline_cpu_tb/dut/WriteRegister_E
add wave -noupdate /pipeline_cpu_tb/dut/Rn_E
add wave -noupdate /pipeline_cpu_tb/dut/Rm_E
add wave -noupdate /pipeline_cpu_tb/dut/forwarda
add wave -noupdate /pipeline_cpu_tb/dut/forwardb
add wave -noupdate /pipeline_cpu_tb/dut/fwdA
add wave -noupdate /pipeline_cpu_tb/dut/fwdB
add wave -noupdate /pipeline_cpu_tb/dut/B
add wave -noupdate /pipeline_cpu_tb/dut/ALUOut
add wave -noupdate /pipeline_cpu_tb/dut/Negative
add wave -noupdate /pipeline_cpu_tb/dut/Zero
add wave -noupdate /pipeline_cpu_tb/dut/Overflow
add wave -noupdate /pipeline_cpu_tb/dut/Carryout
add wave -noupdate -divider {EX/MEM + MEM Stage}
add wave -noupdate /pipeline_cpu_tb/dut/RegWrite_M
add wave -noupdate /pipeline_cpu_tb/dut/MemRead_M
add wave -noupdate /pipeline_cpu_tb/dut/MemWrite_M
add wave -noupdate /pipeline_cpu_tb/dut/WriteRegister_M
add wave -noupdate /pipeline_cpu_tb/dut/ALUOut_M
add wave -noupdate /pipeline_cpu_tb/dut/StoreData_M
add wave -noupdate /pipeline_cpu_tb/dut/dataMem
add wave -noupdate -divider {MEM/WB + WB Stage}
add wave -noupdate /pipeline_cpu_tb/dut/RegWrite_W
add wave -noupdate /pipeline_cpu_tb/dut/WriteRegister_W
add wave -noupdate /pipeline_cpu_tb/dut/ALUOut_W
add wave -noupdate /pipeline_cpu_tb/dut/dataMem_W
add wave -noupdate /pipeline_cpu_tb/dut/WriteData
add wave -noupdate -divider {Register File}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[0]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[1]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[2]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[3]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[4]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[5]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[6]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[7]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[8]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[9]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[10]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[11]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[12]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[13]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[14]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[15]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[16]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[17]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[18]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[19]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[20]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[21]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[22]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[23]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[24]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[25]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[26]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[27]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[28]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[29]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[30]}
add wave -noupdate -radix decimal {/pipeline_cpu_tb/dut/rf/Registers[31]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 200
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 100
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {507499104 ps} {507500048 ps}
