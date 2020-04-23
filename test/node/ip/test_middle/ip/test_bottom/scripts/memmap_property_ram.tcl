#
# Copyright (C) 2019 Geon Technologies, LLC
#
# This file is part of FINS.
#
# FINS is free software: you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# FINS is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
# more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.
#

# BRAM for verifying "memmap" properties
# NOTE: The TCL variables used here are available since the parameters were
#       defined in ip_create.tcl before this script was sourced
if { $FINS_BACKEND == "vivado" } {
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
    if { $::env(QUARTUS_VERSION) == "19.1" } {
        set ram_2port_version 19.1
    } else {
        # elseif $qsys_version == "19.4"
        set ram_2port_version 20.0
    }
    puts "Quartus version '$::env(QUARTUS_VERSION)' has 'ram_2port' IP verson: $ram_2port_version"
    add_hdl_instance $RAM_MODULE_NAME ram_2port $ram_2port_version
    set_instance_parameter_value $RAM_MODULE_NAME "DEVICE_FAMILY" $IP_DEVICE_FAMILY
    set_instance_parameter_value $RAM_MODULE_NAME "GUI_MODE" 0
    set_instance_parameter_value $RAM_MODULE_NAME "GUI_MEMSIZE_WORDS" $TEST_RAM_DEPTH
    set_instance_parameter_value $RAM_MODULE_NAME "GUI_DATAA_WIDTH" $PROPS_DATA_WIDTH
    set_instance_parameter_value $RAM_MODULE_NAME "GUI_QB_WIDTH" $PROPS_DATA_WIDTH
}
