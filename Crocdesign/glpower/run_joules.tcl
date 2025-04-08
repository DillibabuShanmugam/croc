# ----------------------------------------------------------------------------
#	* File:		/glpower/run_joules.tcl
#	* Brief:	gate-level power estimation flow
#	* Author:	Vladimir Vakhter (vvvakhter@wpi.edu)
#	* Date:		02/19/2025
# ----------------------------------------------------------------------------

set_db design_process_node 180

# read in the timing libraries (.lib)
if {![info exists ::env(TIMINGLIBS)] } {
   puts "Error: missing TIMINGLIBS"
   exit(0)
}
read_libs [getenv TIMINGLIBS]

# read in the RTL
if {![info exists ::env(VERILOG)] } {
    puts "Error: missing VERILOG"
    exit(0)
}
read_netlist [getenv VERILOG]

# read in the timing constraints
if {![info exists ::env(SDC)] } {
    puts "Error: missing SDC"
    exit(0)
}
read_sdc [getenv SDC]

# read in the delays
if {![info exists ::env(SDF)] } {
   puts "Error: missing SDF"
   exit(0)
}
read_sdf [getenv SDF]

# read in the parasitics based on the actual wiring
if {![info exists ::env(SPEF)] } {
   puts "Error: missing SPEF"
   exit(0)
}
read_spef [getenv SPEF]

# read the stimulus and the number of frames
if {![info exists ::env(VCD)] } {
    puts "Error: missing VCD"
    exit(0)
}
if {![info exists ::env(FRAME_COUNT)] } {
    puts "Error: missing FRAME_COUNT"
    exit(0)
}
read_stimulus -file [getenv VCD] -dut_instance /tb/dut -frame_count [getenv FRAME_COUNT]

# perform the power analysis
power_map
gen_clock_tree
compute_power
report_power -out dut.final.report
compute_power -mode time_based
plot_power_profile -format png  -unit W -out dut.trace.png

exit

