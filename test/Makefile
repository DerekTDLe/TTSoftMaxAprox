# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
FST ?= -fst # Use more efficient FST format
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES ?= project.v
TB_FILE ?= tb.v
TOPLEVEL ?= tb
COCOTB_TEST_MODULES ?= test

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else

# Gate level simulation:
SIM_BUILD				= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# this gets copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Allow sharing configuration between design and testbench via `include`:
COMPILE_ARGS 		+= -I$(SRC_DIR)

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/$(TB_FILE)

.PHONY: test-max4 test-norm-sub4 test-recip-nr test-exp-pwl-lane test-exp-pwl4

test-max4:
	$(MAKE) SIM_BUILD="sim_build/max4" PROJECT_SOURCES="max4_signed8.v" TB_FILE="tb/tb_max4_signed8.v" TOPLEVEL="tb_max4_signed8" COCOTB_TEST_MODULES="test_max4_signed8" sim

test-norm-sub4:
	$(MAKE) SIM_BUILD="sim_build/norm_sub4" PROJECT_SOURCES="nom_sub4.v" TB_FILE="tb/tb_norm_sub4.v" TOPLEVEL="tb_norm_sub4" COCOTB_TEST_MODULES="test_norm_sub4" sim

test-recip-nr:
	$(MAKE) SIM_BUILD="sim_build/recip_nr" PROJECT_SOURCES="recip_nr.v" TB_FILE="tb/tb_recip_nr.v" TOPLEVEL="tb_recip_nr" COCOTB_TEST_MODULES="test_recip_nr" sim

test-exp-pwl-lane:
	$(MAKE) SIM_BUILD="sim_build/exp_pwl_lane" PROJECT_SOURCES="exp_pwl_lane.v" TB_FILE="tb/tb_exp_pwl_lane.v" TOPLEVEL="tb_exp_pwl_lane" COCOTB_TEST_MODULES="test_exp_pwl_lane" sim

test-exp-pwl4:
	$(MAKE) SIM_BUILD="sim_build/exp_pwl4" PROJECT_SOURCES="exp_pwl_lane.v exp_pwl4.v" TB_FILE="tb/tb_exp_pwl4.v" TOPLEVEL="tb_exp_pwl4" COCOTB_TEST_MODULES="test_exp_pwl4" sim

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
