# ----------------------------------------------------------------------------
#	* File:		/glsta/run_tempus.tcl
#	* Brief:	gate-level static timing analysis (STA) flow
#	* Author:	Vladimir Vakhter (vvvakhter@wpi.edu)
#	* Date:		02/19/2025
# ----------------------------------------------------------------------------

set_db design_process_node 180

# read in the timing libraries (.lib)
if {![info exists ::env(TIMINGLIBS)] } {
    puts "Error: missing TIMINGLIBS"
    exit(0)
}
read_lib [getenv TIMINGLIBS]


# read in the RTL design files
if {![info exists ::env(LAYOUT_NETLIST)]} {
   puts "Error: missing LAYOUT_NETLIST"
   exit(0)
}
set layoutnetlist [getenv LAYOUT_NETLIST]

if {![info exists ::env(TOP_RTL)] } {
   puts "Error: missing TOP_RTL"
   exit(0)
}
set top_rtl [getenv TOP_RTL]

read_verilog $layoutnetlist
set_top_module $top_rtl

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

# write out the reports
report_timing -late -max_paths 3 > late.rpt
report_timing -early -max_paths 3 > early.rpt

report_timing  -from [all_inputs] -to [all_outputs] -max_paths 16 -path_type summary  > allpaths.rpt
report_timing  -from [all_inputs] -to [all_registers] -max_paths 16 -path_type summary  >> allpaths.rpt
report_timing  -from [all_registers] -to [all_registers] -max_paths 16 -path_type summary >> allpaths.rpt
report_timing  -from [all_registers] -to [all_outputs] -max_paths 16 -path_type summary >> allpaths.rpt

#suspend

exit
