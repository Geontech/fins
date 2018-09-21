#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Josh Schindehette
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: This is a generic TCL script for creating and packaging IP
#===============================================================================

# Source the Parameters Script
source ip_params.tcl

# Create Project
if {[info exists "IP_PART"]} {
    create_project $IP_PROJECT_NAME . -force -part $IP_PART
} else {
    create_project $IP_PROJECT_NAME . -force -part xc7z020clg484-1
}

# Check if there is a directory where sub-ip could be located
if {[info exists "IP_USER_IP_CATALOG"]} {
    set_property ip_repo_paths $IP_USER_IP_CATALOG [current_project]
    update_ip_catalog
}

# Add Source Files
add_files -norecurse $SOURCE_FILES

# Add Simulation Files
if {[llength $SIM_FILES] > 0} {
    add_files -fileset sim_1 -norecurse $SIM_FILES
}

# Add Constraints Files
if {[llength $CONSTRAINTS_FILES] > 0} {
    add_files -fileset constrs_1 -norecurse $CONSTRAINTS_FILES
}

# Add IP that will be used in this project if the file exists
if {[file exists ip_import.tcl]} {
    source ip_import.tcl
}

# Add User IP that will be used in this project if the file exists
if {[file exists ip_import_user.tcl]} {
    source ip_import_user.tcl
}

# Set the top module
if {[info exists "IP_TOP"]} {
    set_property "top" $IP_TOP [get_filesets "sources*"]
} else {
    set_property "top" $IP_NAME [get_filesets "sources*"]
}

# Set the top module for the simulation
if {[info exists "IP_TESTBENCH"]} {
    set_property "top" $IP_TESTBENCH [get_filesets "sim*"]
} else {
    set_property "top" ${IP_NAME}_tb [get_filesets "sim*"]
}

# Package the project
if {[info exists "IP_COMPANY_URL"]} {
    ipx::package_project -root_dir . -vendor $IP_COMPANY_URL -library user
    set_property company_url "http://$IP_COMPANY_URL" [ipx::current_core]
} else {
    ipx::package_project -root_dir . -library user
}

# Set the Name
set_property name $IP_PROJECT_NAME [ipx::current_core]
set_property display_name $IP_PROJECT_NAME [ipx::current_core]

# Set the Version
if {[info exists "IP_VERSION"]} {
    set_property version $IP_VERSION [ipx::current_core]
}

# Set Vendor Display Name
if {[info exists "IP_COMPANY_NAME"]} {
    set_property vendor_display_name $IP_COMPANY_NAME [ipx::current_core]
}

# Set IP Description
if {[info exists "IP_DESCRIPTION"]} {
    set_property description $IP_DESCRIPTION [ipx::current_core]
}

# Add company logo to IP Core
if {[info exists "IP_COMPANY_LOGO"]} {
  ipx::add_file_group -type utility {} [ipx::current_core]
  ipx::add_file $IP_COMPANY_LOGO [ipx::get_file_groups xilinx_utilityxitfiles -of_objects [ipx::current_core]]
  set_property type LOGO  [ipx::get_files $IP_COMPANY_LOGO -of_objects [ipx::get_file_groups xilinx_utilityxitfiles -of_objects [ipx::current_core]]]
}

# Save the core
ipx::save_core [ipx::current_core]
