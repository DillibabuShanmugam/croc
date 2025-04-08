# ----------------------------------------------------------------------------
#	* File:		/power/Makefile
#	* Brief:	(early) RTL power consumption estimation
#	* Author:	Vladimir Vakhter (vvvakhter@wpi.edu)
#	* Date:		03/19/2025
# ----------------------------------------------------------------------------

STD_CELL_LIB=/opt/libraries/TSMCHOME/180_1V8_3V3/LOGIC_GP_LIB/tcb018gbwp7t_290a/Front_End/timing_power_noise/NLDM/tcb018gbwp7t_270a/tcb018gbwp7ttc.lib

power:
	BASENAME=mavg \
	VCD=../sim/trace.vcd \
	FRAME_COUNT=99 \
	TIMINGLIBS='$(STD_CELL_LIB)' \
	VERILOG='../rtl/mavg.v' \
	SDC='../constraints/constraints_clk.sdc' \
	joules -files run_joules.tcl

clean:
	rm -rf *~ *.db *.sdb fv joules_work *.data *.report *.png
