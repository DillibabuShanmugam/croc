# ----------------------------------------------------------------------------
#	* File:		/glsta/Makefile
#	* Brief:	Gate-level (post-layout) STA
#	* Author:	Vladimir Vakhter (vvvakhter@wpi.edu)
#	* Date:		03/19/2025
# ----------------------------------------------------------------------------

STD_CELL_LIB=/opt/libraries/TSMCHOME/180_1V8_3V3/LOGIC_GP_LIB/tcb018gbwp7t_290a/Front_End/timing_power_noise/NLDM/tcb018gbwp7t_270a/tcb018gbwp7ttc.lib
IO_CELL_LIB=/home/gulerlab/tsmc180nm_25/digital/tpz973gv_280a/tpz973gv_280a_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tpz973gv_280a/tpz973gvtc.lib

TOP_RTL=chip
CORE_RTL=mavg

sta:
	TOP_RTL=$(TOP_RTL) \
	LAYOUT_NETLIST=../layout/out/design.v \
	TIMINGLIBS='$(STD_CELL_LIB) $(IO_CELL_LIB)' \
	SDC=../layout/synout/$(CORE_RTL)_constraints.sdc \
	SDF=../layout/synout/$(CORE_RTL)_delays.sdf \
	SPEF=../layout/out/design_default_rc.spef \
	tempus -files run_tempus.tcl

stagui:
	TOP_RTL=$(TOP_RTL) \
	LAYOUT_NETLIST=../layout/out/design.v \
	TIMINGLIBS='$(STD_CELL_LIB) $(IO_CELL_LIB)' \
	SDC=../layout/synout/$(CORE_RTL)_constraints.sdc \
	SDF=../layout/synout/$(CORE_RTL)_delays.sdf \
	SPEF=../layout/out/design_default_rc.spef \
	tempus

clean:
	rm -f *.rpt *.slk tempus.cmd* tempus.rpt* tempus.log* *~ *.logv *.cmd
