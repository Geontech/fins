# BRAM for verifying "memmap" properties
# NOTE: The TCL variables used here are available since the parameters were
#       defined in ip_create.tcl before this script was sourced
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -module_name memmap_property_ram
set_property -dict [list \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Write_Width_A $PROPS_DATA_WIDTH \
    CONFIG.Write_Depth_A $TEST_RAM_DEPTH \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
] [get_ips memmap_property_ram]
