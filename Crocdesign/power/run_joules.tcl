# ----------------------------------------------------------------------------
#	* File:		/power/run_joules.tcl
#	* Brief:	power estimation flow (pre-layout)
#	* Author:	Vladimir Vakhter (vvvakhter@wpi.edu)
#	* Date:		02/17/2025
# ----------------------------------------------------------------------------

set_db design_process_node 180

#######################################################
# read in the timing libraries (.lib)
######################################################

if {![info exists ::env(TIMINGLIBS)] } {
    puts "Error: missing TIMINGLIBS"
    exit(0)
}
 
read_libs [getenv TIMINGLIBS]

#######################################################
# read in the RTL
#######################################################

if {![info exists ::env(VERILOG)] } {
    puts "Error: missing VERILOG"
    exit(0)
}

# read Verilog (e.g., VERILOG='../rtl/mavg.v')
read_hdl [getenv VERILOG]

# read SystemVerilog (e.g., VERILOG='../rtl/mavg.sv')
#read_hdl -sv [getenv VERILOG]

#######################################################
# set and elaborat the top design level
#######################################################

if {![info exists ::env(BASENAME)] } {
    puts "Error: missing BASENAME"
    exit(0)
}

set top [getenv BASENAME]
elaborate $top

#######################################################
# read the stimulus and the number of frames
#######################################################

if {![info exists ::env(VCD)] } {
    puts "Error: missing VCD"
    exit(0)
}

if {![info exists ::env(FRAME_COUNT)] } {
    puts "Error: missing FRAME_COUNT"
    exit(0)
}

read_stimulus -file [getenv VCD] -dut_instance /tb/dut -frame_count [getenv FRAME_COUNT]

#######################################################
# read in the timing constraints
#######################################################

if {![info exists ::env(SDC)] } {
   puts "Error: missing SDC"
   exit(0)
}

read_sdc [getenv SDC]

#######################################################
# perform the power analysis
#######################################################

power_map
gen_clock_tree
compute_power
report_power -out dut.final.report
compute_power -mode time_based
plot_power_profile -format png  -unit W -out dut.trace.png

exit

