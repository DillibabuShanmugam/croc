

# ----------------------------------------------------------------------------
# Toolchain Setup
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
	rm -rf vsim/work
	vlog -sv $(VLOG_ARGS) /opt/libraries/TSMCHOME.1023/tsmc18/digital/Front_End/verilog/tcb018gbwp7t_270a/tcb018gbwp7t.v
	vlog $(VLOG_ARGS) -f $(FLIST) ../rtl/riscv-dbg/tb/jtag_test_simple.sv ../rtl/tb_croc_soc.sv
	@echo "Launching simulation..."
	vsim -gui +binary="$(realpath $(SW_HEX))" tb_croc_soc $(VSIM_ARGS)



clean:
	rm -rf  transcript work outputs reports genus.log* genus.cmd* *.vcd *.wlf *~ fv




