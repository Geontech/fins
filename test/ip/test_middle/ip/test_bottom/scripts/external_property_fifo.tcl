# FWFT FIFO for verifying "external" properties
# NOTE: The TCL variables used here are available since the parameters were
#       defined in ip_create.tcl before this script was sourced
create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name external_property_fifo
set_property -dict [list \
    CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM} \
    CONFIG.Performance_Options {First_Word_Fall_Through} \
    CONFIG.Input_Data_Width $PROPS_DATA_WIDTH \
    CONFIG.Input_Depth $TEST_FIFO_DEPTH \
] [get_ips external_property_fifo]
