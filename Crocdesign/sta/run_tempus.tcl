# ----------------------------------------------------------------------------
#	* File:		/sta/run_tempus.tcl
#	* Brief:	static timing analysis (STA) flow
#	* Author:	Vladimir Vakhter (vvvakhter@wpi.edu)
#	* Date:		02/17/2025
# ----------------------------------------------------------------------------

set_multi_cpu_usage -localCpu 16
set_db design_process_node 180

#######################################################
# read in the timing libraries (.lib)
#######################################################

if {![info exists ::env(TIMINGLIBS)] } {
    puts "Error: missing TIMINGLIBS"
    exit(0)
}

read_lib [getenv TIMINGLIBS]

#######################################################
# read in the RTL design files
#######################################################
if {![info exists ::env(TOP_RTL)] } {
    puts "Error: missing TOP_RTL"
    exit(0)
}

if {![info exists ::env(SYN_NETLIST)]} {
    puts "Error: missing SYN_NETLIST"
    exit(0)
}

read_verilog [getenv SYN_NETLIST]
set_top_module [getenv TOP_RTL]

######################################################
# read in the timing constraints
######################################################

if {![info exists ::env(SDC)] } {
    puts "Error: missing SDC"
    exit(0)
}

read_sdc [getenv SDC]

######################################################
# read in the delays
######################################################

if {![info exists ::env(SDF)] } {
   puts "Error: missing SDF"
   exit(0)
}

read_sdf [getenv SDF]

#######################################################
# write out the reports
#######################################################

report_timing -late -max_paths 3 > late.rpt
report_timing -early -max_paths 3 > early.rpt

report_timing  -from [all_inputs] -to [all_outputs] -max_paths 12 -path_type summary  > allpaths.rpt
report_timing  -from [all_inputs] -to [all_registers] -max_paths 12 -path_type summary  >> allpaths.rpt
report_timing  -from [all_registers] -to [all_registers] -max_paths 12 -path_type summary >> allpaths.rpt
report_timing  -from [all_registers] -to [all_outputs] -max_paths 12 -path_type summary >> allpaths.rpt

exit

