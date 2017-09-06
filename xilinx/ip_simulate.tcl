#===============================================================================
#  Company:      Geon Technologies, LLC
#  File:         ip_simulate.tcl
#  Description:  This is a generic script to run an IP simulation
#  Tool Version: Vivado 2016.2
#
#  Revision History:
#  Date        Author             Revision
#  ----------  -----------------  ----------------------------------------------
#  2017-05-04  Josh Schindehette  Initial Version
#
#===============================================================================

# Import the name of the project
source ip_params.tcl

# Open project if not open
if {[current_project -quiet] == ""} {
    open_project "$IP_NAME.xpr"
}

# Launch Simulation
launch_sim

# Run Simulation until there is no more stimulus
run all
