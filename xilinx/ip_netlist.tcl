#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Josh Schindehette
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: This is a TCL generic script for synthesizing and generating an
#              EDIF netlist from an IP project
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
