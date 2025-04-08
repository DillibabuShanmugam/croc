# ----------------------------------------------------------------------------
#	* File:		/glpower/Makefile
#	* Brief:	Gate-level (post-layout) power estimation
#	* Author:	Vladimir Vakhter (vvvakhter@wpi.edu)
#	* Date:		03/19/2025
# ----------------------------------------------------------------------------

STD_CELL_LIB=/opt/libraries/TSMCHOME/180_1V8_3V3/LOGIC_GP_LIB/tcb018gbwp7t_290a/Front_End/timing_power_noise/NLDM/tcb018gbwp7t_270a/tcb018gbwp7ttc.lib
IO_CELL_LIB=/home/gulerlab/tsmc180nm_25/digital/tpz973gv_280a/tpz973gv_280a_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tpz973gv_280a/tpz973gvtc.lib

CORE_RTL=mavg

power:
	VCD=../glsim/trace.vcd \
	FRAME_COUNT=99 \
	TIMINGLIBS='$(STD_CELL_LIB) $(IO_CELL_LIB)' \
	VERILOG='../layout/out/design.v' \
	SPEF='../layout/out/design_default_rc.spef' \
	SDF='../layout/synout/$(CORE_RTL)_delays.sdf' \
	SDC='../layout/synout/$(CORE_RTL)_constraints.sdc' \
	joules -files run_joules.tcl

powerdebug:
	VCD=../glsim/trace.vcd \
	FRAME_COUNT=99 \
	TIMINGLIBS='$(STD_CELL_LIB) $(IO_CELL_LIB)' \
	VERILOG='../layout/out/design.v' \
	SPEF='../layout/out/design_default_rc.spef' \
	SDF='../layout/synout/$(CORE_RTL)_delays.sdf' \
	SDC='../layout/synout/$(CORE_RTL)_constraints.sdc' \
	joules

clean:
	rm -rf *~ *.db *.sdb fv joules_work *.data *.report *.png
