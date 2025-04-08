# ----------------------------------------------------------------------------
#	* File:		/layout/run_genus.tcl
#	* Brief:	pre-PnR synthesis (MMMC) for TSMC180nm
#	* Author:	Vladimir Vakhter (vvvakhter@wpi.edu)
#	* Date:		02/18/2025
# ----------------------------------------------------------------------------

##################################################################################################################
# Define functions
##################################################################################################################
proc printDesignStage {msg} {
	puts "\n###################################################################################################"
	puts ">>> $msg <<<"
	puts "###################################################################################################\n"
}

##################################################################################################################
printDesignStage "preliminary configuration"
##################################################################################################################
if {![info exists ::env(DEBUG)] } {
	puts "Error: missing DEBUG"
	exit(0)
} else {
    set enable_debug [getenv DEBUG]
	if {$enable_debug} {
		printDesignStage "Debug mode of run_genus.tcl" 
		suspend
	}
}

set_db design_process_node 180
file delete -force synthDb
set_db max_cpus_per_server 8 

#########################################
# define whether to add a padframe or not
#########################################
if {![info exists ::env(ADD_PADFRAME)] } {
	puts "Error: missing ADD_PADFRAME"
	exit(0)
} else {
    set add_padframe [getenv ADD_PADFRAME]
}

############################
# set the project's basename
############################
if {![info exists ::env(BASENAME)] } {
    set basename "default"
} else {
    set basename [getenv BASENAME]
}

##########################
# set the RTL design files
##########################
if {![info exists ::env(VERILOG)] } {
   puts "Error: missing VERILOG"
   exit(0)
}
set vfileset [getenv VERILOG]

if {![info exists ::env(TOP_RTL)] } {
   puts "Error: missing TOP_RTL"
   exit(0)
}
set top_rtl [getenv TOP_RTL]

if {![info exists ::env(CORENETLIST)] } {
	puts "Error: missing CORENETLIST"
	exit(0)
}
set corenetlist [getenv CORENETLIST]

#######################################
# set the abstract views of cells (LEF)
#######################################
if {![info exists ::env(LEF)] } {
   puts "Error: missing LEF"
   exit(0)
}
set lef [getenv LEF]

############################
# set init power/ground nets
############################
set_db init_power_nets "VDD"
set_db init_ground_nets "VSS"

set_db hdl_resolve_instance_with_libcell true
set_db hdl_unconnected_value 0

################################################
# read in the multi-mode multi-corner definition
################################################
read_mmmc [getenv MMMC]

#######################################
# read in abstract views of cells (LEF)
#######################################
read_physical -lef $lef

printDesignStage "end preliminary configuration"
if {$enable_debug} { suspend }

##################################################################################################################
printDesignStage "read in and elaborate the RTL design files"
##################################################################################################################
set_db gen_module_prefix $basename; # add a unique prefix to the internally generated module names (for LVS, to avoid name conflicts)
if {$add_padframe} {read_hdl -netlist $corenetlist}

# our core netlist is from the front-end synth phase,
# i.e. it had no padframe information yet, therefore
# we read in the below additional RTL files
read_hdl $vfileset

elaborate $top_rtl

###############
# preserve pads
###############
if {$add_padframe} {
	set_db inst:chip/thepads/vss1 .preserve true
	set_db inst:chip/thepads/vss2 .preserve true
	set_db inst:chip/thepads/vss3 .preserve true
	set_db inst:chip/thepads/vss4 .preserve true
	set_db inst:chip/thepads/vdd1 .preserve true
	set_db inst:chip/thepads/vdd2 .preserve true
	set_db inst:chip/thepads/vdd3 .preserve true
	set_db inst:chip/thepads/vdd4 .preserve true
	set_db inst:chip/thepads/ul   .preserve true
	set_db inst:chip/thepads/ur   .preserve true
	set_db inst:chip/thepads/ll   .preserve true
	set_db inst:chip/thepads/lr   .preserve true
}

printDesignStage "end reading/elaborating RTL"
if {$enable_debug} { suspend }

##################################################################################################################
printDesignStage "populate default corner/view, bind default mode to it"
##################################################################################################################

# replace the Verilog "assign" statements with buffers or inverters in the netlist (needed to avoid LVS errors)
set_db remove_assigns true

# initialize the database (required for MMMC)
init_design

# prohibit ungroupping of user hierarchies
set_db auto_ungroup none

printDesignStage "end MMMC configuration"
if {$enable_debug} { suspend }

##################################################################################################################
printDesignStage "do synthesis"
##################################################################################################################

# optimization efforts: low, moderate, or high
set_db syn_generic_effort high
set_db syn_map_effort high
set_db syn_opt_effort high

syn_generic
syn_map
syn_opt

printDesignStage "end synthesis"
if {$enable_debug} { suspend }

##################################################################################################################
printDesignStage "write out the results"
##################################################################################################################

# final database (including final.v - netlist)
file delete -force syndb
file mkdir syndb
set finalDb ./syndb/final
file mkdir $finalDb
write_design -encounter -basename $finalDb

# timing constraints (SDC) and delays (SDF)
file mkdir synout
set synout synout
set outputconstraints ${synout}/${basename}_constraints.sdc
set outputdelays      ${synout}/${basename}_delays.sdf
write_sdc -view func_default > $outputconstraints
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > $outputdelays

printDesignStage "end writing out the results"
if {$enable_debug} { suspend }

##################################################################################################################
printDesignStage "write out the reports"
##################################################################################################################
file mkdir synreports
set syn_reports "synreports"

report_timing > ${syn_reports}/${basename}_report_timing.rpt
report_power  > ${syn_reports}/${basename}_report_power.rpt
report_area   > ${syn_reports}/${basename}_report_area.rpt
report_qor    > ${syn_reports}/${basename}_report_qor.rpt

printDesignStage "end writing out the reports"
if {$enable_debug} { suspend }

exit
