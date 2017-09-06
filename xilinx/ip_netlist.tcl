#===============================================================================
#  Company:      Geon Technologies, LLC
#  File:         ip_netlist.tcl
#  Description:  This is a generic script for synthesizing and generating an
#                EDIF netlist from an IP project
#  Tool Version: Vivado 2015.4, 2016.2
#
#  Revision History:
#  Date        Author             Revision
#  ----------  -----------------  ----------------------------------------------
#  2017-07-21  Josh Schindehette  Initial Version
#
#===============================================================================

# Import the name of the project
source ip_params.tcl

# Assign the netlist project name
set IP_NETLIST "${IP_NAME}_netlist"

# Create Project
if {[info exists "IP_PART"]} {
    create_project $IP_NETLIST ./$IP_NETLIST -force -part $IP_PART
} else {
    create_project $IP_NETLIST ./$IP_NETLIST -force -part xc7z020clg484-1
}

# Look for an IP repository in this IP's folder
set_property ip_repo_paths . [current_project]
update_ip_catalog

# Create the IP within the project
if {[info exists "IP_COMPANY_URL"]} {
    create_ip -name $IP_NAME -vendor $IP_COMPANY_URL -library user -version 1.0 -module_name $IP_NETLIST
} else {
    create_ip -name $IP_NAME -vendor user.org -library user -version 1.0 -module_name $IP_NETLIST
}

# Generate all the stuffs
generate_target all [get_files "${IP_NETLIST}.xci"]

# Create the IP synthesis run
set IP_SYNTH_RUN [create_ip_run [get_files "${IP_NETLIST}.xci"]]

# Launch and Open the synthesis run
launch_run -jobs 2 $IP_SYNTH_RUN
wait_on_run $IP_SYNTH_RUN
open_run $IP_SYNTH_RUN

# Write the netlists
write_edif ${IP_NETLIST}.edif
write_verilog ${IP_NETLIST}.v
write_vhdl ${IP_NETLIST}.vhd
