# ----------------------------------------------------------------------------
#	* File:		/layout/run_innovus.tcl
#	* Brief:	PnR for TSMC180nm
#	* Author:	Vladimir Vakhter (vvvakhter@wpi.edu)
#	* Date:		03/12/2025
# ----------------------------------------------------------------------------

# NOTE 1: 	to reload your design database, execute "read_db out/final_route.db"
# NOTE 2: 	you need to modify your Calibre rule files to match the name of your top-level design;
#			more details are here: https://icaslab.wpi.edu/wiki/doku.php?id=calibre

##################################################################################################################
# Define functions
##################################################################################################################
proc printDesignStage {msg} {
	puts "\n###################################################################################################"
	puts ">>> $msg <<<"
	puts "###################################################################################################\n"
}

##################################################################################################################
printDesignStage "Design initialization"
##################################################################################################################
if {![info exists ::env(DEBUG)] } {
	puts "Error: missing DEBUG"
	exit(0)
} else {
    set enable_debug [getenv DEBUG]
	if {$enable_debug} { 
		printDesignStage "Debug mode of run_innovus.tcl"
		gui_show
		suspend
	}
}

if {![info exists ::env(ADD_SEAL_RING)] } {
	puts "Error: missing ADD_SEAL_RING"
	exit(0)
} else {
    set generate_sealring [getenv ADD_SEAL_RING]
}

if {![info exists ::env(ADD_DUMMIES)] } {
	puts "Error: missing ADD_DUMMIES"
	exit(0)
} else {
    set generate_dummies [getenv ADD_DUMMIES]
}

if {![info exists ::env(ENABLE_ECO_ROUTE)] } {
	puts "Error: missing ENABLE_ECO_ROUTE"
	exit(0)
} else {
    set enable_route_eco [getenv ENABLE_ECO_ROUTE]
}

if {![info exists ::env(ENABLE_CALIBRE_DRC)] } {
	puts "Error: missing ENABLE_CALIBRE_DRC"
	exit(0)
} else {
    set enable_calibre_drc [getenv ENABLE_CALIBRE_DRC]
}

if {![info exists ::env(ENABLE_CALIBRE_LVS)] } {
	puts "Error: missing ENABLE_CALIBRE_LVS"
	exit(0)
} else {
    set enable_calibre_lvs [getenv ENABLE_CALIBRE_LVS]
}

if {![info exists ::env(IO_BOND_PAIR_973)] } {
	puts "Error: missing IO_BOND_PAIR_973"
	exit(0)
} else {
    set io_bond_pair_tpz973gv_tpb973gv [getenv IO_BOND_PAIR_973]
}

if {![info exists ::env(IO_BOND_PAIR_018)] } {
	puts "Error: missing IO_BOND_PAIR_018"
	exit(0)
} else {
    set io_bond_pair_tpz018nv_tpb018v [getenv IO_BOND_PAIR_018]
}

set_db design_process_node 180
source ./syndb/final.invs_setup.tcl

# read out and set the IO assignment
if {![info exists ::env(CHIPIO)] } {
   puts "Error: missing CHIPIO"
   exit(0)
}
set chip_io_specs [getenv CHIPIO]
read_io_file $chip_io_specs -no_die_size_adjust 

# define whether to add a padframe or not
if {![info exists ::env(ADD_PADFRAME)] } {
	puts "Error: missing ADD_PADFRAME"
	exit(0)
} else {
    set add_padframe [getenv ADD_PADFRAME]
}

if {![info exists ::env(TOP_RTL)] } {
   puts "Error: missing TOP_RTL"
   exit(0)
}
set top_rtl [getenv TOP_RTL]

# make a directory for intermediate P&R database snippets
file mkdir ./pnr_steps_db
set pnr_steps_db "./pnr_steps_db"

# make a directory to save the layout files (GDSII)
file mkdir ./gds
file mkdir ./gds/CalibreDMY

# make a directory to save the Calibre DRC reports
file mkdir ./drc

# make a directory to save the Calibre LVS reports
file mkdir ./lvs

printDesignStage "End design initialization"

###################################################################################################################
printDesignStage "Floorplanning"
###################################################################################################################
if {$enable_debug} { suspend }

###################################
printDesignStage "create floorplan"
###################################
# core aspect ratio (H/W), core utilization, core edge spacings (L/B/R/T) [um] (more options: TCRcom.pdf, p.806)

if {$add_padframe} {
	create_floorplan \
		-stdcell_density_size 1 0.7 40 40 40 40 \
		-flip f \
		-floorplan_origin llcorner \
		-core_margins_by io
} else {
	create_floorplan \
		-stdcell_density_size 1 0.7 10 10 10 10 \
		-flip f \
		-floorplan_origin llcorner \
		-core_margins_by io
}
	
check_floorplan -out_file fp_details.txt -report_density

#############################################
printDesignStage "add global net connections"
#############################################

# You do not need this attributes settings if they are activated in your Genus script already
#set_db init_ground_nets {VSS}
#set_db init_power_nets {VDD}

connect_global_net VDD -type tie_hi -verbose
connect_global_net VSS -type tie_lo -verbose
connect_global_net VDD -type pg_pin -pin_base_name VDD -all -verbose
connect_global_net VSS -type pg_pin -pin_base_name VSS -all -verbose

######################################
printDesignStage "add IO filler cells"
######################################
# should be run after the connect_global_net command (TCRcom.pdf, p.783)
if {$add_padframe} {
	set io_filler_cells {PFILLER20 PFILLER10 PFILLER5 PFILLER1 PFILLER05}
	add_io_fillers -cells $io_filler_cells -prefix IOFILLER
}

#####################################
printDesignStage "create power rings"
#####################################
# on layer selection, check: https://icaslab.wpi.edu/wiki/doku.php?id=mixed_ic_design_considerations
set_db add_rings_detailed_log true
set_db add_rings_avoid_short true
add_rings -around user_defined -type core_rings -user_class power_ring_class \
    -nets {VSS VDD} \
    -center 1 -offset 0 \
    -width 2 \
    -spacing 2 \
    -layer {bottom METAL2 top METAL2 right METAL3 left METAL3}

#gui_deselect -all
#delete_routes -shapes ring
#OR delete_routes -sub_class power_ring_class

#####################################################
#printDesignStage "create power stripes"
#(optional, for larger chips)
#####################################################
#add_stripes \
#	-user_class power_stripe_class
#	-layer METAL2 \
#	-direction horizontal \
#	-width 0.46 \
#	-spacing 0.4 \
#	-start_offset 7 \
#	-set_to_set_distance 10 \
#	-nets {VSS VDD}
#add_stripes \
#	-user_class power_stripe_class
#	-layer METAL3 \
#	-direction vertical \
#	-width 0.46 \
#	-spacing 0.4 \
#	-start_offset 7 \
#	-set_to_set_distance 10 \
#	-nets {VSS VDD}

# save the design database (saves all routing information in DEF)
# you can further "read_def" to restore a clean database for routing
write_db ${pnr_steps_db}/pre_route_special.db

#################################################
printDesignStage "route the power infrastructure"
#################################################
route_special \
	-delete_existing_routes \
	-connect {core_pin pad_pin} \
	-core_pin_target {first_after_row_end} \
	-pad_pin_target {nearest_target} \
	-nets {VDD VSS} \
	-allow_layer_change 1 \
	-pad_pin_layer_range {METAL1(2) METAL6(6)} 

#route_special \
#	-delete_existing_routes \
#	-connect {core_pin pad_pin} \
#	-core_pin_target {first_after_row_end} \
#	-pad_pin_target {nearest_target} \
#	-allow_jogging 1 \
#	-allow_layer_change 1 \
#	-pad_pin_layer_range {METAL1(2) METAL6(6)} \
#	-layer_change_range {METAL1(2) METAL6(6)} \
#	-crossover_via_layer_range {METAL1(2) METAL6(6)} \
#	-target_via_layer_range { METAL1(2) METAL6(6)} \
#	-nets {VDD VSS}

# save the design database
write_db ${pnr_steps_db}/post_route_special.db

#####################################
printDesignStage "place bonding pads"
#####################################

# NOTE: MIT (Kyungmi) used the "addbonding.pl" script by TSMC.
# As of 03/13/2025, I did not locate it at `/opt/libraries` on `cadence-uguler`

if {$add_padframe} {
	# categorize pads
	set port_dict [dict create \
		vss {thepads/vss1 thepads/vss2 thepads/vss3 thepads/vss4} \
		vdd {thepads/vdd1 thepads/vdd2 thepads/vdd3 thepads/vdd4} \
		ctrl {thepads/resetpad thepads/clkpad} \
		signals_in {thepads/x0pad thepads/x1pad thepads/x2pad thepads/x3pad} \
		signals_out {thepads/y0pad thepads/y1pad thepads/y2pad thepads/y3pad} \
	]

	# assign the pad name
	if {$io_bond_pair_tpz973gv_tpb973gv} {
		set pad_name "PAD70N"
	} elseif {$io_bond_pair_tpz018nv_tpb018v} {
		set pad_name "PAD80L"
	}

	# iterate over each category and its pads
	foreach {category pads} [dict get $port_dict] {
		puts "Category: $category"
		foreach port_name $pads {
			place_bond_pad -bond_pad $pad_name -position inner -io_inst $port_name -pin PAD
		}
	}

	# save the design database
	write_db ${pnr_steps_db}/post_place_bond_pad.db
}

########################################
printDesignStage "insert well tap cells"
########################################
# INFO: after the macro placement and power rail creation
# INFO: https://icaslab.wpi.edu/wiki/doku.php?id=well_tap_cells
# INFO: the offset [um] is design-dependent
# INFO: the max. distance b/w the same-row cells of 54 [um] is from Prof.Schaumont's lab

# Next, the tap-cells should be pre-placed every 60um (for example), and on every
# other row. A single tap-cell at the proper distance can bias the n- or p-well for two
# flipped rows of standard cells, since wells are shared between rows. The top and
# bottom rows should also contain tap-cells, as should the edges of a design.
# The tap-cells are preferably placed in vertical columns for easy routing with
# vertical metal layers that connect to VBB/VPP. If no connection to VBB/VPP is
# required (no back-bias), then the tap-cells can be placed randomly. However, the
# maximum effective distance must be honored.

# place tap cells on every row in the design
set well_tap_cell "TAPCELLBWP7T"
add_well_taps -cell $well_tap_cell -prefix WELLTAP -cell_interval 54 -in_row_offset 0

# remove the added well-tap cells (in case you want to re-route)
#delete_filler -prefix WELLTAP

# place tap cells in a checkered pattern
#add_well_taps -cell TAPCELLBWP7T -prefix wtap_odd -cell_interval 54 -skip_row 1
#add_well_taps -cell TAPCELLBWP7T -prefix wtap_even -cell_interval 54 -skip_row 1 \
#	-start_row 2 -in_row_offset 54

# remove the added well-tap cells
#delete_filler -prefix wtap_odd
#delete_filler -prefix wtap_even

# verify placement/mark violations/create a violation report
check_well_taps -max_distance 54 -cells {TAPCELLBWP7T}

# save the design database
write_db ${pnr_steps_db}/post_add_well_taps.db

#############################################
printDesignStage "pre-placement timing check"
#############################################
check_timing -verbose
time_design -pre_place -report_prefix preplace -report_dir reports/STA

printDesignStage "End floorplanning"

###################################################################################################################
printDesignStage "Placement and pre-CTS timing optimization"
###################################################################################################################
if {$enable_debug} { suspend }

#####################################
printDesignStage "place and optimize"
#####################################
place_opt_design -report_dir reports/STA

###############################
printDesignStage "add tie-offs"
###############################
# Tie-offs are extra VDD/VSS connections in std. cells for meeting power requirements (particularly, in long rows)
# use this command after placing the standard cells in the flow (TCRcom.pdf, p.432)
add_tieoffs -lib_cell "TIEHBWP7T TIELBWP7T" -prefix tieOff

###################################
printDesignStage "add Core fillers"
###################################
# Filler cells provide continuity for the power and ground rails, as well as for n-wells
# in most cases, use this command after placement and before detailed routing (TCRcom.pdf, p.2450);
# if the design is routed, this command also does DRC checks of the filler cells added versus the wires in the design
set core_filler_cells {FILL64BWP7T FILL32BWP7T FILL16BWP7T FILL8BWP7T FILL4BWP7T FILL2BWP7T FILL1BWP7T}
set_db add_fillers_cells $core_filler_cells
# this command can be used multiple times
add_fillers -prefix COREFILLER
#delete_filler

# remove the Verilog "assign" statements (needed to avoid LVS errors) - execute after placement
delete_assigns -add_buffer

# save the design database
write_db ${pnr_steps_db}/placement_pre_cts_opt.db

##########################################
printDesignStage "pre-CTS timing analysis"
##########################################
time_design -pre_cts -report_dir reports/STA

printDesignStage "End placement and pre-CTS timing optimization"

###################################################################################################################
printDesignStage "Clock-tree synthesis (CTS)"
###################################################################################################################
if {$enable_debug} { suspend }

##############################
printDesignStage "perform CTS"
##############################
set_db cts_inverter_cells {CKND0BWP7T CKND10BWP7T CKND12BWP7T}
set_db cts_buffer_cells {CKBD0BWP7T CKBD10BWP7T CKBD12BWP7T}
set_db cts_update_clock_latency false
clock_design

report_clock_trees -summary -out_file reports/report_clock_trees.rpt
report_skew_groups  -summary -out_file reports/report_ccopt_skew_groups.rpt

# save the design database
write_db ${pnr_steps_db}/clock_design.db

########################################################
printDesignStage "post-CTS setup- and hold-optimization"
########################################################

# enter the interactive constraint mode
set_interactive_constraint_modes [all_constraint_modes -active]
get_interactive_constraint_modes
reset_clock_tree_latency [all_clocks]
set_propagated_clock [all_clocks]

# exit the interactive constraint mode
set_interactive_constraint_modes []

opt_design -post_cts        -report_dir reports/STA
time_design -post_cts       -report_dir reports/STA

# save the design database
write_db ${pnr_steps_db}/post_cts_opt.db

opt_design -post_cts -hold -report_dir reports/STA
time_design -post_cts -hold -report_dir reports/STA

# save the design database
write_db ${pnr_steps_db}/post_cts_hold_opt.db

printDesignStage "End CTS"

###################################################################################################################
printDesignStage "Global and detail routing"
###################################################################################################################
if {$enable_debug} { suspend }

##########################
printDesignStage "routing"
##########################
assign_io_pins
route_design

# save the design database
write_db ${pnr_steps_db}/route_design.db

##########################################################
printDesignStage "post-route setup- and hold-optimization"
##########################################################
set_db extract_rc_engine post_route
set_db extract_rc_effort_level medium

# enable signal integrity analysis
set_db delaycal_enable_si true
set_db timing_analysis_type ocv

opt_design -post_route -setup -hold -report_dir reports/STA
# INFO: re-run multiple times if there are any timing viol-s

# NOTE: if your technology supports, and you use ECO (Engineering Change Order) gate array cells,
# launch "route_eco" at the end of global and detail routing, after placing fillers, and do "check_drc" afterwards
if {$enable_route_eco} { route_eco }

# save the design database
write_db ${pnr_steps_db}/post_route_opt.db

printDesignStage "End global and detail routing"

###################################################################################################################
printDesignStage "Signoff (physical verification, logical equivalent checking and timing analysis)"
###################################################################################################################
if {$enable_debug} { suspend }

################################################
printDesignStage "check DRC and LVS at Innnovus"
################################################

# NOTE: Innovus cannot consume the foundry's runset files. Innovus uses and knows only the rules as defined in the techLef.
# Therefore, one must run DRC and LVS with Calibre.

check_drc           -out_file reports/check_drc.rpt
check_connectivity  -out_file reports/check_connectivity.rpt

# TODO: 
	#check_design -type "all" -out_file reports/check_design.rpt

# TODO: for fillers, check TCRcom.pdf, p.2450
	#verify_drc
	#add_fillers -fix_drc

#####################################
printDesignStage "signoff extraction"
#####################################

# Select QRC extraction to be in signoff mode
set_db extract_rc_engine post_route
set_db extract_rc_effort_level signoff
set_db extract_rc_coupled true

#set_db extract_rc_lef_tech_file_map tsmc180.layermap

if {![info exists ::env(LAYERMAP)] } {
   puts "Error: missing LAYERMAP"
   exit(0)
}
set quntusLayerMap [getenv LAYERMAP]
set_db extract_rc_lef_tech_file_map $quntusLayerMap

extract_rc

# generate RC spefs  for WC_rc & BC_rc corners
write_parasitics -rc_corner default_rc -spef_file out/design_default_rc.spef

# generate delays (SDF)
write_sdf out/design_delays.sdf

#########################################################
printDesignStage "generate and save a gate-level netlist"
#########################################################
write_netlist out/design.v

######################################################
printDesignStage "save the final design database file"
######################################################
write_db out/final_route.db

#########################################################
printDesignStage "stream out the die 'layout' GDSII file"
#########################################################

if {![info exists ::env(MERGEGDS)] } {
   puts "Error: missing MERGEGDS"
   exit(0)
}
set mergegds [getenv MERGEGDS]

if {![info exists ::env(MAPFILE)] } {
   puts "Error: missing MAPFILE"
   exit(0)
}
set mapfile [getenv MAPFILE]

# NOTE: the "unit" value needs further investigation. In the dummy insertion Calibre rule files, there are settings:
# {PRECISION: 1000, RESOLUTION: 5}. However, I was not sure they are related with these ones. 
set gds_file ./gds/${top_rtl}.gds
set gds_stream_report ./gds/${top_rtl}_gds_stream.rpt ; # outputs cell name changed to the file

#set_db write_stream_cell_name_prefix ${top_rtl} ; # this setting is useful when you need to merge multiple blocks; but it caused an LVS extraction error
set_db write_stream_text_size 7.0

write_stream $gds_file \
	-report_file $gds_stream_report \
	-format stream \
	-merge $mergegds \
	-mode NOFILL \
	-map_file $mapfile \
	-lib_name DesignLib \
	-unit 1000

if {$generate_sealring} {
	# NOTE: NOT IMPLEMENTED, IGNORE
	
	####################################################
	printDesignStage "generate seal-ring GDSII"
	####################################################

	# IMPORTANT: always ask the foundry in advance, who is in charge of providing the seal ring. Sometimes, foundries
	# refuse to provide seal ring, because it is connected to VSS and therefore electrical properties of the design might change.

	# As of 03/12/2025, I have not find a way to generate a seal ring in Innovus. It is possible there to place bumps
	# (in the case of wedge wirebonding, bonding pads) with the -edge_offset -bump_to_edge flags, but not to produce
	# a GDSII for a guard ring (at least, with a dedicated command). I think the way to produce a seal ring is to create
	# a custom area/ring at a given distance from the bonding pads, e.g. by using the place_spare_modules command.
	# https://support.cadence.com/apex/ArticleAttachmentPortal?id=a1Od0000000nUVKEA2&pageName=ArticleContent

	# The cells to use are the following ones from the TSMC sealring library:
	# tsmc_c018_seal_ring_edge_1p6m, tsmc_c018_sealring_corner_1p6m

	# The seal ring can be simply produced in Cadence Virtuoso by abutting the above cells.
	# See for details: https://icaslab.wpi.edu/wiki/lib/exe/detail.php?id=ic_padframe_structure&media=ex_sealring.png

	# Cadence Integrity System Planner seems to be capable of generating a seal ring (it may be an out-dated tool).
	# Search for "Adding a Seal Ring or Scribe Line to a Die Device" on Cadence Online Support for more information.

	# Potentially, it is also possible to generate a seal ring GDS file using the GDSFactory Python-to-CAD converter
	# (https://gdsfactory.github.io/gdsfactory/index.html#) and using the following cells 

	# Another option is using klayout:
	# https://www.klayout.de/forum/discussion/637/pcell-instantiating-and-accessing-other-cells-for-things-like-guard-rings
	
	##########################################################################
	printDesignStage "merge die and sealring GDSII files"
	##########################################################################

	# At this step, merge the netlist GDS with the seal GDS.
	# Use the Python script ../sealring/merge_gds.py by Patric Schaumont (as of 03/12/2025, not tested by ICAS)
	# Check this resource to get an idea about the script: https://www.klayout.de/doc/programming/python.html
	
	# NOTE: output the merge result to `../sealring/${top_rtl}_w_sealring.gds`
}

if {$generate_dummies} {
	# NOTE: If you integrate your digital design layout with an analog
	# layout and plan to insert the dummies there, omit this step.

	########################################################
	printDesignStage "dummy metal fill and OD/PO generation"
	########################################################

	if {![info exists ::env(CALIBRE_DUMMY_RULES)] } {
	   puts "Error: missing CALIBRE_DUMMY_RULES"
	   exit(0)
	}
	set calibre_dummy_rules [getenv CALIBRE_DUMMY_RULES]

	# Dummy metal fill (note: your rule file changes depending on whether you have a sealring or not)
	calibre -drc -hier -turbo 40 $calibre_dummy_rules/Dummy_Metal_Calibre_0.18um.214a

	# Dummy OD/PO fill
	calibre -drc -hier -turbo 40 $calibre_dummy_rules/Dummy_OD_PO_Calibre_0.18um.210a

	# For the padframe only (no padframe worked):
		# NOTE1: as of 03/13/2025, both worked but the tool said the following cells were referenced but not
		# defined: PDO04CDG, PVSS2DGZ, PVSS1DGZ, PVDD2POC, PVDD2DGZ, PVDD1DGZ, PCORNER, and PDIDGZ
		# NOTE2: as of 03/13/2025, the report files were not generated (because the tool exited abnormally)
	
	########################################################################################
	printDesignStage "merge all the GDSII files (design+sealring, dummy metal, dummy OD/PO)"
	########################################################################################
	
	if {$generate_sealring} {
		# NOTE: as of 03/13/2025, untested since had no sealring and the dummy generation exited abnormally
		calibredrv \
			-a layout filemerge -append \
			-topcell ${top_rtl} \
			-in ../sealring/${top_rtl}_w_sealring.gds \
			-in ./gds/CalibreDMY/DM.gds \
			-in ./gds/CalibreDMY/DOD.gds \
			-out ./gds/final.gds
	}
}

if {$enable_calibre_drc} {
	# NOTE: if you use a merged GDS (see above), you need to change the `LAYOUT PATH`
	# variable inside the rule files to `./gds/final.gds`.
	# See here: https://icaslab.wpi.edu/wiki/doku.php?id=calibre

	#############################################
	printDesignStage "run final DRC with Calibre"
	#############################################
	if {$enable_debug} { suspend }

	# INFO: in a mixed flow, if metal/poly-fill cells show a few DRC errors, correct it in Virtuoso.
	if {![info exists ::env(CALIBRE_DRC_RULES)] } {
	   puts "Error: missing CALIBRE_DRC_RULES"
	   exit(0)
	}
	set calibre_drc_rules [getenv CALIBRE_DRC_RULES]
	
	# TODO: configure runset files for all drc and lvs steps (the issue: DRC and LVS outputs too many temporary files in the /layout)
	#		To do so:
	#			1. do `file mkdir drc/main`, `file mkdir drc/ant`, etc.
	#			2. execute `calibre -gui`, select DRC or LVS.
	#			3. setup all the paths to the desired Calibre launch dir, etc.
	#			4. save the runset files
	#			5. then, you can do `set main_drc_runfile "path_to_runset"`, etc.
	#			6. now, you can launch "calibre -gui -drc -runset ${main_drc_runfile}"
	
	# main DRC check (file revision: CLM18_LM16_LM152_6M.215_5a)
	calibre -drc -hier -turbo 40 ${calibre_drc_rules}/main.drc
	calibre -rve ./drc/MAIN_DRC_RES.db ; #show the result (the path should match the one in the Calibre rule file)

	# antenna DRC check (file revision: CLM18_LM16_LM152_6M_ANT.215_5a)
	calibre -drc -hier -turbo 40 $calibre_drc_rules/ant.drc
	calibre -rve ./drc/ANT_DRC_RES.db

	# wire-bonding DRC check (file revision: C18_WIRE_BOND_6M.19_1a1)
	calibre -drc -hier -turbo 40 $calibre_drc_rules/wb.drc
	calibre -rve ./drc/WB_DRC_RES.db	
	
	# For the padframe only (no padframe worked):
		# NOTE1: as of 03/13/2025, both worked but the tool said the following cells were referenced but not
		# defined: PDO04CDG, PVSS2DGZ, PVSS1DGZ, PVDD2POC, PVDD2DGZ, PVDD1DGZ, PCORNER, and PDIDGZ
		# NOTE2: as of 03/13/2025, the report files were not generated (because the tool exited abnormally)
			
}

############################################################################
# Insert antenna diodes (only if there is a DRC violation) (not implemented)
############################################################################

if {$add_padframe} {

	# NOTE: as of 03/14/2025, untested since I will be working in the mixed-signal flow,
	# and the diodes will be added in the analog part after integration
	
	set antenna_diode "ANTENNABWP7T"

	# Example Synopsys command: set the attribute is_diode for the specific antenna pin (named “I”) of the antenna standard cell (ANTENNABWP7T) in the design
	# set_attribute [get_lib_pins -quiet -of_objects [get_lib_cells */ANTENNABWP7T/design] -filter “name == I”] is_diode

	# Example script for Innovus: https://support.cadence.com/apex/ArticleAttachmentPortal?id=a1O3w000009lsx2EAA&pageName=ArticleContent
	# TCRcom.pdf (p.2484): route_design_antenna_cell_name, route_design_antenna_diode_insertion
	# TCRcom.pdf (p.1711)

	# Based on the STD Cells AN, we need to connect it between VSS and I pin
	#set drc_port_list [list thepads/x3pad thepads/y0pad]
	#foreach port_name $drc_port_list {
	#  create_diode -diode_cell ANTENNABWP7T -pin $port_name I -prefix antenna
	#}

	# NOTE: you need to re-route your design after placing the diodes
}

if {$enable_calibre_lvs} {
	#############################################
	printDesignStage "run final LVS with Calibre"
	#############################################
	if {$enable_debug} { suspend }

	#########################################################
	# set paths to the Verilog and SPICE of the used macros #
	#########################################################
	
	# INFO: if you used any external hard macros or compiled memories like SRAM,
	# you will need to provide a Verilog/Spice file pair for them as well.
	# For SRAM specifically, the SPICE file may have an extension like ".cir" vs ".spi"
	
	if {![info exists ::env(CALIBRE_LVS_RULES)] } {
	   puts "Error: missing CALIBRE_LVS_RULES"
	   exit(0)
	}
	set calibre_lvs_rules [getenv CALIBRE_LVS_RULES]
	
	if {![info exists ::env(STD_CELL_VERILOG)] } {
	   puts "Error: missing STD_CELL_VERILOG"
	   exit(0)
	}
	set std_cell_verilog [getenv STD_CELL_VERILOG]
	
	if {![info exists ::env(STD_CELL_SPICE)] } {
	   puts "Error: missing STD_CELL_SPICE"
	   exit(0)
	}
	set std_cell_spice [getenv STD_CELL_SPICE]
	
	if {![info exists ::env(IO_CELL_VERILOG)] } {
	   puts "Error: missing IO_CELL_VERILOG"
	   exit(0)
	}
	set io_cell_verilog [getenv IO_CELL_VERILOG]
	
	if {![info exists ::env(IO_CELL_SPICE)] } {
	   puts "Error: missing IO_CELL_SPICE"
	   exit(0)
	}
	set io_cell_spice [getenv IO_CELL_SPICE]

	#################################################################
	# prepare the verilog netlist without the "physical only" cells #
	# (which have no CDL .SUBCKT in its Spice library)				#
	#################################################################
	
	# NOTE: this source suggested not to exclude well taps;
	# https://youtu.be/soaMWQZzEW0?list=PLZU5hLL_713xp5sDexQMVdOM86l_wP5w8&t=739
	# However, their tech files might have the well-tap .subckt, and that was why
	
	# create a list of excluded cells for LVS
	set exclude_lvs_list [list]  ; # initialize an empty list
	# exclude core fillers, well taps
	set exclude_lvs_list [concat $exclude_lvs_list $core_filler_cells $well_tap_cell]
	if {$add_padframe} {
		# in addition, exclude: IO fillers, bonding pads, corner cells, antenna diodes
		set corner_cell PCORNER
		set exclude_lvs_list [concat $exclude_lvs_list $io_filler_cells $pad_name $corner_cell $antenna_diode]
	}
	
	# save the netlist
	# 	-phys: write out global power nets
	# 	-flatten_bus: connect independent signals and not buses
	# 	-exclude_insts_of_cells: exclude the "physical only"
	set lvs_source_verilog_netlist "./lvs/lvs_source_netlist.v"
	write_netlist $lvs_source_verilog_netlist \
		-phys -flatten_bus \
		-exclude_insts_of_cells $exclude_lvs_list

	#################################################################
	# translate the Verilog "source" netlist into LVS SPICE netlist #
	#################################################################
	set v2lvs_log_file "./lvs/v2lvs.log"
	set lvs_source_spice_netlist "./lvs/lvs_source_netlist.spi"
		
	# -v: the Verilog design netlist file
	# -l: a verilog library file
	# -s: include (does not read) the path to a provided Spice into the final Spice file (-o)
	# -s0: default global ground
	# -s1: default global power
	# -so: instance/module specific power/ground overrides' file
	# -o: the resulting Spice netlist to be used in the LVS
	# -sn: connect default power and ground nets to globals
		
	if {$add_padframe} {
		v2lvs -sn \
			-log $v2lvs_log_file \
			-v $lvs_source_verilog_netlist \
			-l $std_cell_verilog -s $std_cell_spice \
			-l $io_cell_verilog -s $io_cell_spice \
			-s0 VSS -s1 VDD \
			-o $lvs_source_spice_netlist
	} else {
		v2lvs -sn \
			-log $v2lvs_log_file \
			-v $lvs_source_verilog_netlist \
			-l $std_cell_verilog -s $std_cell_spice \
			-s0 VSS -s1 VDD \
			-o $lvs_source_spice_netlist
	}
	
	##########################################################################################################
	# extract the LVS-ready "layout" SPICE netlist from GDSII and compare it with the SPICE "source" netlist #
	##########################################################################################################
	calibre -lvs -hier -turbo 40 $calibre_lvs_rules/main.lvs
	
	######################################################################################
	# open the LVS results database (extraction and comparison results) from Calibre RVE #
	######################################################################################
	calibre -rve svdb/
	# NOTE1: to get connectivity to layout, open if from the Virtuoso plugin (Virtuoso: Calibre/Start RVE...)
	# NOTE2: Calibre will also perform ERC on the layout during extraction
}

printDesignStage "End signoff"
if {$enable_debug} { suspend }
printDesignStage "End of run_innovus.tcl script. Exiting..."

exit