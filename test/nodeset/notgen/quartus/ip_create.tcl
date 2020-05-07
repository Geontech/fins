#===============================================================================
# Firmware IP Node Specification (FINS) Auto-Generated File
# ---------------------------------------------------------
# Template:    ip_create.tcl
# Backend:     quartus
# Generated:   2020-03-30 18:09:51.467181
# ---------------------------------------------------------
# Description: TCL script for creating an IP compatible with
#              Intel Quartus Platform Designer
# Versions:    Tested with:
#              * Intel Quartus Prime Pro 19.1
#===============================================================================

package require qsys

# Set the fixed filepaths
set IP_ROOT_RELATIVE_TO_PROJ "../.."

# Run Pre-Build TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
source ${IP_ROOT_RELATIVE_TO_PROJ}/scripts/print.tcl

# Load the system
#load_system qsys_top.qsys

# Create the IP and set the project properties
#add_component nodeset_qsys_test nodeset_test.qsys nodeset_test
#load_component nodeset_test
#save_component
#load_instantiation nodeset_test
#save_instantiation
#
#
create_ip nodeset_test nodeset_test
set IP_DEVICE 10CX220YF780I5G
set_project_property DEVICE $IP_DEVICE
set_project_property HIDE_FROM_IP_CATALOG {false}
set_module_property FILE nodeset_test.ip
set_module_property GENERATION_ID {0x00000000}
set_module_property NAME nodeset_test
#
# Run Post-Build TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
source ${IP_ROOT_RELATIVE_TO_PROJ}/scripts/print.tcl

# Save the system
sync_sysinfo_parameters
save_system fins_nodeset_test
