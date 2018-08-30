#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Josh Schindehette
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: This is a generic TCL script to run an IP simulation
#===============================================================================

# Import the name of the project
source ip_params.tcl

# Open project if not open
if {[current_project -quiet] == ""} {
    open_project "$IP_NAME.xpr"
}

# Launch Simulation
launch_sim

# Check that the simulation launched correctly
if { [current_time] != "1 us" } {
    error "***** SIMULATION FAILED (t<1us) *****"
}

# Run Simulation until there is no more stimulus
run all

# Check that the simulation_done signal is True
if { [get_value [get_objects "simulation_done"]] == "FALSE" } {
    error "***** SIMULATION FAILED *****"
} else {
    puts "***** SIMULATION PASSED *****"
}
