# ----------------------------------------------------------------------------
#	* File:		/layout/Makefile
#	* Brief:	configure tools for PnR for TSMC180nm
#	* Author:	Vladimir Vakhter (vvvakhter@wpi.edu)
#	* Date:		03/12/2025
# ----------------------------------------------------------------------------

###############################################################################
# Conditional execution
###############################################################################

####################
# General settings #
####################

# Generate padframe (0 - no padframe, 1 - padframe)
ADD_PADFRAME=0

###########################
# Genus-specific settings #
###########################

# Enable DEBUG mode: suspends script after large design steps (0 = disabled, 1 = enabled)
DEBUG_GENUS=0

#############################
# Innovus-specific settings #
#############################

DEBUG_INNOVUS=0

# add a sealring (as of 03/14/2025, not implemented, set to 0)
ADD_SEAL_RING=0

# add dummy metal and dummy OD/PO (if you integrate with analog, and they are added there, set to 0 to disable)
ADD_DUMMIES=0

# route ECO (set to 0, if you are unsure; this is a specific ECO flow)
ENABLE_ECO_ROUTE=0

# perform DRC with Calibre (set to 1 to enable; recommended)
ENABLE_CALIBRE_DRC=1

# perform LVS with Calibre (set to 1 to enable; recommended)
ENABLE_CALIBRE_LVS=1

# select the IO/bonding pad library set (exclusive; has an effect in conjunction with ADD_PADFRAME)
IO_BOND_PAIR_018=1
IO_BOND_PAIR_973=0

# Check that only one of the pairs is set to 1
ifeq ($(shell expr $(IO_BOND_PAIR_018) + $(IO_BOND_PAIR_973)), 2)
    $(error Both IO_BOND_PAIR_018 and IO_BOND_PAIR_973 cannot be 1)
endif

# Check if both are 0
ifeq ($(shell expr $(IO_BOND_PAIR_018) + $(IO_BOND_PAIR_973)), 0)
    $(error Both IO_BOND_PAIR_018 and IO_BOND_PAIR_973 cannot be 0)
endif

###############################################################################
# General configuration
###############################################################################
BASENAME=mavg
CHIPNAME=chip
CHIPCLK_NS=1.5

###############################################################################
# Design Verilog
###############################################################################
CORE_RTL=../rtl/mavg.v
PADS_RTL=../chip/padframe/pads.v
CHIP_RTL=../chip/padframe/chip.v

###############################################################################
# Standard cells (LIB - timing (wc or tc for the tapeout), LEF - abstract view)
###############################################################################

################
# tcb018gbwp7t #
################
STD_CELL_LIB=/opt/libraries/TSMCHOME/180_1V8_3V3/LOGIC_GP_LIB/tcb018gbwp7t_290a/Front_End/timing_power_noise/NLDM/tcb018gbwp7t_270a/tcb018gbwp7ttc.lib
STD_CELL_LEF=/opt/libraries/TSMCHOME/180_1V8_3V3/LOGIC_GP_LIB/tcb018gbwp7t_290a/Back_End/lef/tcb018gbwp7t_270a/lef/tcb018gbwp7t_6lm.lef
STD_CELL_GDS=/opt/libraries/TSMCHOME/180_1V8_3V3/LOGIC_GP_LIB/tcb018gbwp7t_290a/Back_End/gds/tcb018gbwp7t_270a/tcb018gbwp7t.gds
STD_CELL_VERILOG=/opt/libraries/TSMCHOME/180_1V8_3V3/LOGIC_GP_LIB/tcb018gbwp7t_290a/Front_End/verilog/tcb018gbwp7t_270a/tcb018gbwp7t.v
STD_CELL_SPICE=/opt/libraries/TSMCHOME/180_1V8_3V3/LOGIC_GP_LIB/tcb018gbwp7t_290a/Back_End/spice/tcb018gbwp7t_270a/tcb018gbwp7t_270a.spi

###############################################################################
# I/O cells  (LIB - timing (wc or tc for the tapeout), LEF - abstract view)
###############################################################################

ifeq ($(IO_BOND_PAIR_018), 1)
	# tpz018nv
	IO_CELL_LIB=/home/gulerlab/tsmc180nm_25/digital/tpz018nv_280c/tpz018nv_280b_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tpz018nv_280b/tpz018nvtc.lib
	IO_CELL_LEF=/home/gulerlab/tsmc180nm_25/digital/tpz018nv_280c/tpz018nv_6lm_mod.lef
	IO_CELL_GDS=/home/gulerlab/tsmc180nm_25/digital/tpz018nv_280c/tpz018nv_280b_gdsu6lm/TSMCHOME/digital/Back_End/gds/tpz018nv_280b/mt_2/6lm/tpz018nv.gds
	IO_CELL_VERILOG=/home/gulerlab/tsmc180nm_25/digital/tpz018nv_280c/tpz018nv_270a_vlg/TSMCHOME/digital/Front_End/verilog/tpz018nv_270a/tpz018nv.v
	IO_CELL_SPICE=/home/gulerlab/tsmc180nm_25/digital/tpz018nv_280c/tpz018nv_280b_spi/TSMCHOME/digital/Back_End/spice/tpz018nv_280b/tpz018nv_1_2.spi
else ifeq ($(IO_BOND_PAIR_973), 1)
	# tpz973gv
	IO_CELL_LIB=/home/gulerlab/tsmc180nm_25/digital/tpz973gv_280a/tpz973gv_280a_nldm/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tpz973gv_280a/tpz973gvtc.lib
	IO_CELL_LEF=/home/gulerlab/tsmc180nm_25/digital/tpz973gv_280a/tpz973gv_6lm_mod.lef
	IO_CELL_GDS=/home/gulerlab/tsmc180nm_25/digital/tpz973gv_280a/tpz973gv_280a_gdsu6lm/TSMCHOME/digital/Back_End/gds/tpz973gv_280a/mt_2/6lm/tpz973gv.gds
	IO_CELL_VERILOG=/home/gulerlab/tsmc180nm_25/digital/tpz973gv_280a/tpz973gv_270a_vlg/TSMCHOME/digital/Front_End/verilog/tpz973gv_270a/tpz973gv.v
	IO_CELL_SPICE=/home/gulerlab/tsmc180nm_25/digital/tpz973gv_280a/tpz973gv_270a_spi/TSMCHOME/digital/Back_End/spice/tpz973gv_270a/tpz973gv_1_2.spi
endif

################################################################################
# Bonding pads (LIB - timing (wc or tc for the tapeout), LEF - abstract view)
################################################################################

ifeq ($(IO_BOND_PAIR_018), 1)
	# tpb018v
	BOND_PAD_LEF=/home/gulerlab/tsmc180nm_25/digital/tpb018v_190a/tpb018v_6lm_mod.lef
	IO_CELL_GDS=/home/gulerlab/tsmc180nm_25/digital/tpb018v_190a/tpb018v_190a_gds/TSMCHOME/digital/Back_End/gds/tpb018v_190a/wb/6lm/tpb018v.gds
else ifeq ($(IO_BOND_PAIR_973), 1)
	# tpb973gv
	BOND_PAD_LEF=/home/gulerlab/tsmc180nm_25/digital/tpb973gv_140a/tpb973gv_6lm_mod.lef
	BOND_PAD_GDS=/home/gulerlab/tsmc180nm_25/digital/tpb973gv_140a/tpb973gv_140a_gdswb6lm/TSMCHOME/digital/Back_End/gds/tpb973gv_140a/wb/6lm/tpb973gv.gds
endif

################################################################################
# Chip I/O cells' placement specifications
################################################################################
CHIPIO_NO_PADFRAME=../chip/no_padframe/chip.io
CHIPIO_PADFRAME=../chip/padframe/chip.io

################################################################################
# QRC
################################################################################
QRC=/opt/libraries/TSMCHOME/180_1V8_3V3/DIGITAL/RC_EXTRACTION/RC_QRC_cm018g_1p6m_4x1u_mim5_40k_typical/qrcTechFile

################################################################################
# Map files (for GDS: https://icaslab.wpi.edu/wiki/doku.php?id=digital_ic_gds)
################################################################################
QUANTUS_LAYERMAP=/home/gulerlab/tsmc180nm_25/digital/quantus_map/tsmc180.layermap
GDS_MAPFILE=/home/gulerlab/tsmc180nm_25/digital/gds2_map/gds2.map

################################################################################
# Calibre rule files (IMPORTANT: check the paths/design names INSIDE each rule file)
# https://icaslab.wpi.edu/wiki/doku.php?id=calibre
################################################################################
ifeq ($(ADD_PADFRAME), 1)
	CALIBRE_DUMMY_RULES=../calibre/padframe/dummy_generation/rule_files
	CALIBRE_DRC_RULES=../calibre/padframe/drc/rule_files
else
	CALIBRE_DUMMY_RULES=../calibre/no_padframe/dummy_generation/rule_files
	CALIBRE_DRC_RULES=../calibre/no_padframe/drc/rule_files
endif

CALIBRE_LVS_RULES=../calibre/lvs

################################################################################
# Padframe configuration
################################################################################
ifeq ($(ADD_PADFRAME), 1)
	# IO assignment/placement
    CHIPIO=$(CHIPIO_PADFRAME)
	# Verilog
	VERILOG=$(CORE_RTL) $(PADS_RTL) $(CHIP_RTL)
	# Abstract views
	LEF=$(STD_CELL_LEF) $(IO_CELL_LEF) $(BOND_PAD_LEF)
	# Timing
	LIB=$(STD_CELL_LIB) $(IO_CELL_LIB)
	# Top-level RTL
	TOP_RTL=$(CHIPNAME)
else
    CHIPIO=$(CHIPIO_NO_PADFRAME)
	VERILOG=$(CORE_RTL)
	LEF=$(STD_CELL_LEF)
	LIB=$(STD_CELL_LIB)
	TOP_RTL=$(BASENAME)
endif

################################################################################
# Commands
################################################################################

info:
	@echo "Targets are"
	@echo "		synthesize design:		make syn"
	@echo "		P&R design:				make layout"
	@echo "		remove produced files:	make clean"

syn:
	DEBUG=$(DEBUG_GENUS) \
	BASENAME=$(BASENAME) \
	CLOCKPERIOD=$(CHIPCLK_NS) \
	VERILOG='$(VERILOG)' \
	TIMINGLIBS='$(LIB)' \
	LEF='$(LEF)' \
	QRC=$(QRC) \
	MMMC='./viewDefinition.tcl' \
	TOP_RTL=$(TOP_RTL) \
	ADD_PADFRAME=$(ADD_PADFRAME) \
	CORENETLIST='../syn/outputs/mavg_netlist.v' \
	genus -f run_genus.tcl

syndebug:
	DEBUG=$(DEBUG_GENUS) \
	BASENAME=$(BASENAME) \
	CLOCKPERIOD=$(CHIPCLK_NS) \
	VERILOG='$(VERILOG)' \
	TIMINGLIBS='$(LIB)' \
	LEF='$(LEF)' \
	QRC=$(QRC) \
	MMMC='./viewDefinition.tcl' \
	TOP_RTL=$(TOP_RTL) \
	ADD_PADFRAME=$(ADD_PADFRAME) \
	CORENETLIST='../syn/outputs/mavg_netlist.v' \
	genus

layout:
	DEBUG=$(DEBUG_INNOVUS) \
	BASENAME=$(BASENAME) \
	MERGEGDS='$(STD_CELL_GDS) $(IO_CELL_GDS) $(BOND_PAD_GDS)' \
	STD_CELL_VERILOG=$(STD_CELL_VERILOG) \
	STD_CELL_SPICE=$(STD_CELL_SPICE) \
	IO_CELL_VERILOG=$(IO_CELL_VERILOG) \
	IO_CELL_SPICE=$(IO_CELL_VERILOG) \
	MAPFILE='$(GDS_MAPFILE)' \
	SCANDEF='syndb/final.scan.def' \
	CHIPIO=$(CHIPIO) \
	LAYERMAP=$(QUANTUS_LAYERMAP) \
	CALIBRE_DUMMY_RULES=$(CALIBRE_DUMMY_RULES) \
	CALIBRE_DRC_RULES=$(CALIBRE_DRC_RULES) \
	CALIBRE_LVS_RULES=$(CALIBRE_LVS_RULES) \
	TOP_RTL=$(TOP_RTL) \
	ADD_PADFRAME=$(ADD_PADFRAME) \
	ADD_SEAL_RING=$(ADD_SEAL_RING) \
	ADD_DUMMIES=$(ADD_DUMMIES) \
	ENABLE_ECO_ROUTE=$(ENABLE_ECO_ROUTE) \
	ENABLE_CALIBRE_DRC=$(ENABLE_CALIBRE_DRC) \
	ENABLE_CALIBRE_LVS=$(ENABLE_CALIBRE_LVS) \
	IO_BOND_PAIR_018=$(IO_BOND_PAIR_018) \
	IO_BOND_PAIR_973=$(IO_BOND_PAIR_973) \
	innovus -stylus -files run_innovus.tcl

layoutdebug:
	DEBUG=$(DEBUG_INNOVUS) \
	BASENAME=$(BASENAME) \
	MERGEGDS='$(STD_CELL_GDS) $(IO_CELL_GDS) $(BOND_PAD_GDS)' \
	STD_CELL_VERILOG=$(STD_CELL_VERILOG) \
	STD_CELL_SPICE=$(STD_CELL_SPICE) \
	IO_CELL_VERILOG=$(IO_CELL_VERILOG) \
	IO_CELL_SPICE=$(IO_CELL_VERILOG) \
	MAPFILE='$(GDS_MAPFILE)' \
	SCANDEF='syndb/final.scan.def' \
	CHIPIO=$(CHIPIO) \
	LAYERMAP=$(QUANTUS_LAYERMAP) \
	CALIBRE_DUMMY_RULES=$(CALIBRE_DUMMY_RULES) \
	CALIBRE_DRC_RULES=$(CALIBRE_DRC_RULES) \
	CALIBRE_LVS_RULES=$(CALIBRE_LVS_RULES) \
	TOP_RTL=$(TOP_RTL) \
	ADD_PADFRAME=$(ADD_PADFRAME) \
	ADD_SEAL_RING=$(ADD_SEAL_RING) \
	ADD_DUMMIES=$(ADD_DUMMIES) \
	ENABLE_ECO_ROUTE=$(ENABLE_ECO_ROUTE) \
	ENABLE_CALIBRE_DRC=$(ENABLE_CALIBRE_DRC) \
	ENABLE_CALIBRE_LVS=$(ENABLE_CALIBRE_LVS) \
	IO_BOND_PAIR_018=$(IO_BOND_PAIR_018) \
	IO_BOND_PAIR_973=$(IO_BOND_PAIR_973) \
	innovus -stylus -no_gui 

clean_syn:
	rm -rf syndb synout synreports fv genus.*
	
clean_pnr:
	rm -rf pnr_steps_db gds innovus.cmd* innovus.log* out reports addRing.log* fp_details.txt *.rpt* rc_model.bin qrc*.log

clean_calibre:
	rm -rf drc lvs* svdb *.rep *.rdb *DENSITY* *density* *ratio.log calibre*.db calibre*.sum

clean:
	$(MAKE) clean_syn
	$(MAKE) clean_pnr
	$(MAKE) clean_calibre
	rm -rf *~ .~