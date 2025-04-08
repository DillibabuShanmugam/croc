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
#stdcell_tsmc180 = /opt/libraries/TSMCHOME.1023/tsmc18/digital/Front_End/verilog/tcb018gbwp7t_270a/tcb018gbwp7t.v



SDC=./constraints_clk.sdc
# ----------------------------------------------------------------------------
# Ensure the correct toolchain is used
export PATH := /opt/riscv/bin:$(PATH)

# Automatically determine GCC version and update LD_LIBRARY_PATH
GCC_VERSION := $(shell riscv64-unknown-elf-gcc -dumpversion)
export LD_LIBRARY_PATH := $(LD_LIBRARY_PATH):/opt/riscv/lib/gcc/riscv64-unknown-elf/$(GCC_VERSION)

# Disable use of the linker plugin to avoid the missing liblto_plugin.so error
export LDFLAGS := -fno-use-linker-plugin

############
# Software #
############
SW_HEX := ../sw/bin/helloworld.hex

# Use wildcard to expand file lists so make knows the actual files
SW_C_SRCS := $(wildcard sw/*.c)
SW_H_SRCS := $(wildcard sw/*.h)
SW_S_SRCS := $(wildcard sw/*.S)
SW_LD_SRCS := $(wildcard sw/*.ld)

$(SW_HEX): $(SW_C_SRCS) $(SW_H_SRCS) $(SW_S_SRCS) $(SW_LD_SRCS)
	$(MAKE) -C ../sw/ compile

## Build all top-level programs in sw/
software: $(SW_HEX)
sw: $(SW_HEX)

.PHONY: software sw

##################
# RTL Simulation #
##################
VLOG_ARGS  = -svinputport=compat
VSIM_ARGS  = -t 1ns -voptargs=+acc
VSIM_ARGS += -suppress vsim-3009 -suppress vsim-8683 -suppress vsim-8386

# Use the provided flist file that contains include paths, defines, and RTL files
FLIST = croc.flist

rtl_sim: $(SW_HEX)
	@echo "Compiling RTL sources for simulation using $(FLIST)..."
	rm -rf work
	vlog -sv $(VLOG_ARGS) ../stdcelllib/tcb018gbwp7t.v
	# Compile all RTL sources from the flist plus the testbench
	vlog $(VLOG_ARGS) -f $(FLIST) ../rtl/riscv-dbg/tb/jtag_test_simple.sv ../rtl/tb_croc_soc.sv
	@echo "Launching simulation..."
	vsim +binary="$(realpath $(SW_HEX))" -gui tb_croc_soc $(VSIM_ARGS)




gtl_sim: $(SW_HEX)
	@echo "Compiling gate-level netlist and testbench for simulation..."
	rm -rf work
	vlib work
	#vlog -sv -work work ../rtl/common_verification/clk_rst_gen.sv
	#vlog -sv -work work ../rtl/common_cells/cdc_4phase.sv
	# Compile the TSMC standard cell library in SystemVerilog mode
	vlog -sv $(VLOG_ARGS) -work work ../stdcelllib/tcb018gbwp7t.v
	# Compile io library
	vlog -sv $(VLOG_ARGS) -work work ../stdcelllib/tpz973gv.v
	# Compile the package with proper include directories
	vlog -sv -svinputport=compat -work work -f $(FLIST)
	vlog -sv -svinputport=compat -work work \
		+incdir+../rtl/register_interface \
		+incdir+../rtl/obi \
		../rtl/croc_pkg.sv
	# Compile gate-level netlist and testbench
	vlog -sv $(VLOG_ARGS) -work work \
		../syn/outputs/croc_chip_netlist.v \
		../rtl/tb_croc_soc.sv \
		../rtl/croc_domain.sv \
		../rtl/riscv-dbg/tb/jtag_test_simple.sv
	@echo "Launching gate-level simulation..."
	vsim -c -do ../rtl/dofiles/gtl_sim_vcd.do \
		-voptargs=+acc=lprn \
		-L work work.tb_croc_soc \
		+notimingchecks \
		+bus_conflict_off \
		-sdfnoerror \
		-sdfnowarn \
		-sdfmax /tb_croc_soc/i_croc_soc=../syn/outputs/croc_chip_delays.sdf




clean:
	rm -rf  transcript work outputs reports genus.log* genus.cmd* *~ fv




