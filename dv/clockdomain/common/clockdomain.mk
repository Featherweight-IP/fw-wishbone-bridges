CLOCKDOMAIN_COMMON_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
PACKAGES_DIR := $(abspath $(CLOCKDOMAIN_COMMON_DIR)/../../../packages)
GL_DIR := $(abspath $(CLOCKDOMAIN_COMMON_DIR)/../../../verilog/gl)
RTL_DIR := $(abspath $(CLOCKDOMAIN_COMMON_DIR)/../../../verilog/rtl)
DV_MK_DIR := $(PACKAGES_DIR)/sim-mk

ifeq (1,$(RULES))

SIMTYPE ?= functional

PYTHONPATH := $(CLOCKDOMAIN_COMMON_DIR)/python:$(PYTHONPATH)
export PYTHONPATH

PYBFMS_MODULES += wishbone_bfms
INCDIRS += $(PACKAGES_DIR)/fwprotocol-defs/src/sv

ifeq (gate,$(SIMTYPE))
SRCS += $(GL_DIR)/wb_clockdomain_bridge.v
SRCS += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/verilog/sky130_fd_io.v
SRCS += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/verilog/sky130_ef_io.v
SRCS += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
SRCS += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
SRCS += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hvl/verilog/primitives.v
SRCS += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hvl/verilog/sky130_fd_sc_hvl.v
DEFINES += USE_POWER_PINS FUNCTIONAL UNIT_DELAY='\#1'
else
SRCS += $(RTL_DIR)/wb_clockdomain_bridge.v
endif

include $(DV_MK_DIR)/mkfiles/dv.mk
else # Rules

include $(DV_MK_DIR)/mkfiles/dv.mk
endif
