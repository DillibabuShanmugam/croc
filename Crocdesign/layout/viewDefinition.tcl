# Brief: the multi-mode multi-corner definition
# Prepared by: Vladimir Vakhter (vvvakhter@wpi.edu)
# Date: 02/20/2025

#######################################################
# read in the timing libraries (.lib)
#######################################################
if {![info exists ::env(TIMINGLIBS)] } {
   puts "Error: missing TIMINGLIBS"
   exit(0)
}
set timinglibs [getenv TIMINGLIBS]

#######################################################
# read in the parasitics of metal lines
#######################################################
if {![info exists ::env(QRC)] } {
    puts "Error: missing QRC"
    exit(0)
}
set qrc [getenv QRC]

# create a library set
create_library_set -name default_libs -timing $timinglibs

# TIMING
create_opcond -name op_cond_default -process 1 -voltage 1 -temperature 125
create_timing_condition -name default_tc -opcond op_cond_default -library_sets default_libs
create_rc_corner -name default_rc -temperature 125 -qrc_tech $qrc

# QRC
create_delay_corner -name default_dc -timing_condition default_tc -rc_corner default_rc
create_constraint_mode -name default_const -sdc_files ../constraints/constraints_clk.sdc
create_analysis_view -name func_default -delay_corner default_dc -constraint_mode default_const
set_analysis_view -setup {func_default} -hold {func_default}


