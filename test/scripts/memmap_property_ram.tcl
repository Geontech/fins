# BRAM for verifying "memmap" properties
# NOTE: The TCL variables used here are available since the parameters were
#       defined in ip_create.tcl before this script was sourced
if { $USE_XILINX } {
    create_ip -name blk_mem_gen -vendor xilinx.com -library ip -module_name xilinx_memmap_property_ram
    set_property -dict [list \
        CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
        CONFIG.Write_Width_A $PROPS_DATA_WIDTH \
        CONFIG.Write_Depth_A $TEST_RAM_DEPTH \
        CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
        CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
    ] [get_ips xilinx_memmap_property_ram]
} else {
    set RAM_MODULE_NAME "intel_memmap_property_ram"
    add_hdl_instance $RAM_MODULE_NAME ram_2port 19.1
    set_instance_parameter_value $RAM_MODULE_NAME "DEVICE_FAMILY" $IP_DEVICE_FAMILY
    set_instance_parameter_value $RAM_MODULE_NAME "GUI_MODE" 0
    set_instance_parameter_value $RAM_MODULE_NAME "GUI_MEMSIZE_WORDS" $TEST_RAM_DEPTH
    set_instance_parameter_value $RAM_MODULE_NAME "GUI_DATAA_WIDTH" $PROPS_DATA_WIDTH
    set_instance_parameter_value $RAM_MODULE_NAME "GUI_QB_WIDTH" $PROPS_DATA_WIDTH
}
