# ----------------------------------------------------------------------------
#	* File:		/sta/Makefile
#	* Brief:	post-synthesis static timing analysis (STA)
#	* Author:	Vladimir Vakhter (vvvakhter@wpi.edu)
#	* Date:		03/19/2025
# ----------------------------------------------------------------------------

STD_CELL_LIB=/opt/libraries/TSMCHOME/180_1V8_3V3/LOGIC_GP_LIB/tcb018gbwp7t_290a/Front_End/timing_power_noise/NLDM/tcb018gbwp7t_270a/tcb018gbwp7ttc.lib

TOP_RTL=mavg

sta:
	TOP_RTL=$(TOP_RTL) \
	SYN_NETLIST=../syn/outputs/$(TOP_RTL)_netlist.v \
	SDC=../syn/outputs/$(TOP_RTL)_constraints.sdc \
	SDF=../syn/outputs/$(TOP_RTL)_delays.sdf \
	TIMINGLIBS='$(STD_CELL_LIB)' \
	tempus -files run_tempus.tcl

stagui:
	TOP_RTL=$(TOP_RTL) \
	SYN_NETLIST=../syn/outputs/$(TOP_RTL)_netlist.v \
	SDC=../syn/outputs/$(TOP_RTL)_constraints.sdc \
	SDF=../syn/outputs/$(TOP_RTL)_delays.sdf \
	TIMINGLIBS='$(STD_CELL_LIB)' \
	tempus

clean:
	rm -f *.rpt *.slk tempus.cmd* tempus.rpt* tempus.log* *~
