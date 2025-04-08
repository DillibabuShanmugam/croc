# ----------------------------------------------------------------------------
#	* File:		/syn/run_genus.tcl
#	* Brief:	simplified synthesis flow (single corner)
#	* Author:	Vladimir Vakhter (vvvakhter@wpi.edu)
#	* Date:		02/17/2025
# ----------------------------------------------------------------------------

set_db design_process_node 180

#######################################################
# read in the technology timing libraries (.lib)
######################################################
if {![info exists ::env(TIMINGLIBS)] } {
     puts "Error: missing TIMINGLIBS" 
     exit(0)
} 
read_libs [getenv TIMINGLIBS]

if {![info exists ::env(LEF)]} {
    puts "Error: missing LEF"
    exit 0
}
set lefList [getenv LEF]

if {![info exists ::env(QRC)]} {
    puts "Error: missing QRC"
    exit 0
}
set qrc [getenv QRC]

read_physical -lef $lefList

#set_db init_hdl_search_path ../rtl/
#read_hdl -language sv [getenv VERILOG]
set_db init_hdl_search_path ../rtl/
read_hdl -language sv -f croc.flist

#---------------------Edit
if {![info exists ::env(BASENAME)] } {
  set basename "default"
} else {
    set basename [getenv BASENAME]
}
#---------------
#read_hdl [getenv VERILOG]
elaborate $basename
# check for any unresolved references
check_design -unresolved

#######################################################
# read in and set the timing and design constraints
#######################################################
if {![info exists ::env(SDC)] } {
    puts "Error: missing SDC" 
    exit(0)
} 
read_sdc [getenv SDC]
#read_sdc ../constraints/constraints_clk.sdc

# check the constraints consistency
#check_timing_intent -verbose
#######################################################
# do synthesis
#######################################################

# generic gate optimization
set_db syn_generic_effort low

# mapping to the supplied technology cells
set_db syn_map_effort low

# incremental optimization (improves timing, area,
# and fix DRC violations)
set_db syn_opt_effort low

#set_db dft_scan_style muxed_scan
#set_db dft_prefix dft_
#define_shift_enable scan_enable -active high
#define_test_signal  scan_mode -active high -function test_mode
#define_test_signal  rst_n -active low -function async_set_reset


#check_dft_rules
#fix_dft_violations -async_set -async_reset -async_control scan_mode -test_control scan_mode
#check_dft_rules -max_print_violations 100 >reports/dft_violations.txt
#set_db simplify_hdl_types true

syn_generic
syn_map
ungroup -flatten -all
syn_opt

# Flatten the design hierarchy
#ungroup -flatten -all
# at this point, the synthesis is complete

#######################################################
# analyze and write out the reports
#######################################################
#if {![info exists ::env(BASENAME)] } {
#  set basename "default"
#} else {
#    set basename [getenv BASENAME]
#}
#------------------Edit
#check_dft_rules
#set_db design:${basename} .dft_min_number_of_scan_chains 1
# define_scan_chain -name top_chain -sdi scan_in -sdo scan_out -create_ports
#define_scan_chain -name top_chain -sdi test_si -sdo test_so -create_ports
#connect_scan_chains -auto_create_chains
#syn_opt -incr

#report_scan_chains
#write_dft_atpg -library /opt/cadence/libraries/gsclib045_all_v4.7/gsclib045/verilog/slow_vdd1v0_basicCells.v
#-----------------Edit

# a timing repor
report_timing > reports/${basename}_report_timing.rpt

# a power repor
report_power  > reports/${basename}_report_power.rpt

# an exhaustive hierarchical area report
report_area   > reports/${basename}_report_area.rpt

# a quality-of-results report
report_qor    > reports/${basename}_report_qor.rpt

# other reports include:
# report_dp (Prints a datapath resources report (to be done before syn_map))
# report_design_rules (Prints design rule violations)
# report_gates (Reports libcells used, total area, and instance count summary)
# report_hierarchy (Prints a hierarchy report)
# report_instance (Generates a report on the specified instance)
# report_memory (Prints a memory usage report)
# report_messages (Prints a summary of the error messages that have been issued)
# report_summary (Prints an area, timing, and design rules report)

#######################################################
# generate and write out netlist, constraints, delays
#######################################################
set outputnetlist     outputs/${basename}_netlist.v
set outputconstraints outputs/${basename}_constraints.sdc
set outputdelays      outputs/${basename}_delays.sdf
set outputdb	      outputs/db/${basename}
write_hdl > $outputnetlist
write_sdc > $outputconstraints
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge  -setuphold split > $outputdelays
#write_scandef >outputs/${basename}.scandef
write_design \
    -base_name $outputdb \
    -innovus \
    -db
#write_db -common $outputdb
exit
 
