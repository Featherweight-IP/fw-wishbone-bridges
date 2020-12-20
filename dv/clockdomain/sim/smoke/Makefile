TEST_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PACKAGES_DIR := $(abspath $(TEST_DIR)/../../packages)
RTL_DIR := $(abspath $(TEST_DIR)/../../verilog/rtl)

DV_TOOL ?= icarus

TOP_MODULE = wb_clockdomain_bridge_tb
SRCS += $(TEST_DIR)/../../common/sv/wb_clockdomain_bridge_tb.sv

include $(TEST_DIR)/../../common/clockdomain.mk

#********************************************************************
#* cocotb testbench setup
#********************************************************************
MODULE=wishbone_bridge_tests.clockdomain_bridge_smoke
export MODULE

VLSIM_OPTIONS += -Wno-fatal --autoflush
VLSIM_CLKSPEC += clock=10ns

RULES := 1

#all : run

include $(TEST_DIR)/../../common/clockdomain.mk

