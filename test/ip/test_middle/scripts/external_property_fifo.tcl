# FWFT FIFO for verifying "external" properties
# NOTE: The TCL variables used here are available since the parameters were
#       defined in ip_create.tcl before this script was sourced
if { $USE_XILINX } {
    create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name xilinx_external_property_fifo
    set_property -dict [list \
        CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM} \
        CONFIG.Performance_Options {First_Word_Fall_Through} \
        CONFIG.Input_Data_Width $PROPS_DATA_WIDTH \
        CONFIG.Input_Depth $TEST_FIFO_DEPTH \
    ] [get_ips xilinx_external_property_fifo]
} else {
    set FIFO_MODULE_NAME "intel_external_property_fifo"
    set FIFO_MODE_NORMAL 1
    set FIFO_MODE_SHOW_AHEAD 0
    set FIFO_USED_WORDS_COUNT_DISABLED 0
    set FIFO_USED_WORDS_COUNT_ENABLED 1
    add_hdl_instance $FIFO_MODULE_NAME fifo 19.1
    set_instance_parameter_value $FIFO_MODULE_NAME "GUI_LegacyRREQ" $FIFO_MODE_SHOW_AHEAD
    set_instance_parameter_value $FIFO_MODULE_NAME "GUI_Width" $PROPS_DATA_WIDTH
    set_instance_parameter_value $FIFO_MODULE_NAME "GUI_Depth" $TEST_FIFO_DEPTH
    set_instance_parameter_value $FIFO_MODULE_NAME "GUI_UsedW" $FIFO_USED_WORDS_COUNT_DISABLED
}
