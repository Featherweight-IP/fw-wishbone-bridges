set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) wb_clockdomain_bridge

set vlog_files ""
lappend vlog_files $script_dir/../../verilog/rtl/wb_clockdomain_bridge.v

set vlog_incdirs ""
lappend vlog_incdirs $script_dir/../../packages/fwprotocol-defs/src/sv

set ::env(VERILOG_FILES) $vlog_files
set ::env(VERILOG_INCLUDE_DIRS) $vlog_incdirs

set ::env(CLOCK_PORT) "i_clock"
#set ::env(CLOCK_NET) "u_payload.clock"
set ::env(CLOCK_PERIOD) "4"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 200 200"
set ::env(DESIGN_IS_CORE) 0

#set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

#set ::env(PL_BASIC_PLACEMENT) 1
#set ::env(PL_TARGET_DENSITY) 0.32
set ::env(PL_TARGET_DENSITY) 0.50

#set ::env(DIODE_INSERTION_STRATEGY) 1
#set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 4

set ::env(ROUTING_CORES) 10
# Removed
#set ::env(GLB_RT_MAXLAYER) 4

