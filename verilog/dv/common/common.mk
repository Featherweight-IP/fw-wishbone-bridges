
COMMON_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
PACKAGES_DIR := $(abspath $(COMMON_DIR)/../../packages)

ifeq (1,$(RULES))

INCDIRS += $(PACKAGES_DIR)/fwprotocol-defs/src/sv

PYTHONPATH := $(COMMON_DIR)/python:$(PYTHONPATH)
export PYTHONPATH

PYBFMS_MODULES += wishbone_bfms


else # Rules

endif
