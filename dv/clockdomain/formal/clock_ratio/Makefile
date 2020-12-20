TEST_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PROJECT := clockdomain

TOOL ?= sby
TOP_MODULE = clock_ratio_tb

include $(TEST_DIR)/../../common/$(PROJECT).mk


#SRCS += $($(PROJECT)_COMMON_DIR)/
SRCS += $(TEST_DIR)/clock_ratio_tb.sv
DEFINES += FW_RESET_ASYNC
#INCDIRS += 

RULES := 1


include $(TEST_DIR)/../../common/$(PROJECT).mk


