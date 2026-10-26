# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./alu.sv"
vlog "./full_adder.sv"
vlog "./adder_subtractor.sv"
vlog "./logic_gates.sv"
vlog "./regfile.sv"
vlog "./D_FF.sv"
vlog "./Multiplexer.sv"
vlog "./Decoder.sv"
vlog "./Register.sv"
vlog "./adder_subtractor.sv"
vlog "./instructmem.sv"
vlog "./datamem.sv"
vlog "./math.sv"
vlog "./pipeline_cpu.sv"
vlog "./control.sv"
vlog "./ALUControl.sv"
vlog "./sign_extend.sv"
vlog "./HazardDetectionUnit.sv"
vlog "./ForwardingUnit.sv"
vlog "./PipelineReg.sv"
vlog "./pipeline_cpu_tb.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work pipeline_cpu_tb

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do pipeline_cpu_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
