
FW_WISHBONE_BRIDGES_RTLDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))


ifneq (1,$(RULES))

ifeq (,$(findstring $(FW_WISHBONE_BRIDGES_RTLDIR),$(MKDV_INCLUDED_DEFS)))
MKDV_INCLUDED_DEFS += $(FW_WISHBONE_BRIDGES_RTLDIR)

include $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/defs_rules.mk
MKDV_VL_SRCS += $(wildcard $(FW_WISHBONE_BRIDGES_RTLDIR)/*.v)
endif

else # Rules

endif
