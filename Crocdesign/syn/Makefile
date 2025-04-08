# ----------------------------------------------------------------------------
#	* File:		/syn/Makefile
#	* Brief:	run RTL synthesis
# ----------------------------------------------------------------------------

PROJECTNAME=croc_chip
CHIPCLK_NS=50
#RTLPATH=../rtl/precompiled/

#RAM_LIB=../rtl/sram2k8b/compout/views/aspulsgfs1p2048x8cm16sw0/Worst/aspulsgfs1p2048x8cm16sw0.lib
STD_CELL_LIB=/opt/libraries/TSMCHOME.1023/tsmc18/digital/Front_End/timing_power_noise/NLDM/tcb018gbwp7t_270a/tcb018gbwp7twc.lib
PAD_LIB=/opt/libraries/TSMCHOME.1023/tsmc18/digital/Front_End/timing_power_noise/NLDM/tpz973gv_280a/tpz973gvwc.lib
#PAD_LIB=/opt/libraries/TSMCHOME.1023/tsmc18/digital/Front_End/timing_power_noise/NLDM/tpz018nv_280b/tpz018nvwc.lib

# LEF Files for physical design (for layout and common DB creation)
CELL_LEF   = /opt/libraries/TSMCHOME.1023/tsmc18/digital/Back_End/lef/tcb018gbwp7t_270a/lef/tcb018gbwp7t_6lm.lef
PAD_LEF    = ./iopads.lef
#BOND_LEF   = ../chip/bondpads.lef

# GDS Files for layout
CELL_GDS   = /opt/libraries/TSMCHOME.1023/tsmc18/digital/Back_End/gds/tcb018gbwp7t_270a/tcb018gbwp7t.gds
PAD_GDS    = /opt/libraries/TSMCHOME.1023/tsmc18/digital/Back_End/gds/tpz973gv_280a/mt_2/6lm/tpz973gv.gds
#PAD_GDS    = /opt/libraries/TSMCHOME.1023/tsmc18/digital/Back_End/gds/tpz018nv_280b/mt_2/6lm/tpz018nv.gds
BOND_GDS   = /opt/libraries/TSMCHOME.1023/tsmc18/digital/Back_End/gds/tpb973gv_140a/wb/6lm/tpb973gv.gds
#BOND_GDS  = /opt/libraries/TSMCHOME.1023/tsmc18/digital/Back_End/gds/tpb018v_190a/wb/6lm/tpb018v.gds

# QRC file for extraction (used in synthesis if needed)
QRC        = /opt/libraries/TSMCHOME.1023/tsmc18/Cadence/RC_extraction/cm018g_1p6m_4x1u_mim5_40k_typical/qrcTechFile

#stdcell verilog files
stdcell_tsmc180 = /opt/libraries/TSMCHOME.1023/tsmc18/digital/Front_End/verilog/tcb018gbwp7t_270a/tcb018gbwp7t.v



SDC=./constraints_clk.sdc

all: syn

syn:
	BASENAME=$(PROJECTNAME) \
	CLOCKPERIOD=$(CHIPCLK_NS) \
	TIMINGLIBS='$(STD_CELL_LIB) $(PAD_LIB)' \
	SDC=$(SDC) \
        LEF='$(CELL_LEF) $(PAD_LEF)' \
        QRC=$(QRC) \
	genus -f run_genus.tcl


syndebug:
	BASENAME=$(PROJECTNAME) \
	CLOCKPERIOD=$(CHIPCLK_NS) \
	TIMINGLIBS='$(STD_CELL_LIB)' \
	VERILOG='$(RTLPATH)/read_hdl_list.v' \
	SDC=$(SDC) \
	genus



clean:
	rm -rf  transcript work outputs reports wave.do genus.log* genus.cmd* *.vcd *.wlf *~ fv




