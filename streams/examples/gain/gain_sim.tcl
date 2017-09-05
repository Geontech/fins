#===============================================================================
#  Company:      Geon Technologies, LLC
#  File:         gain_sim.tcl
#  Description:  This is a script for simulating the gain.vhd module
#  Tool Version: Vivado 2015.4, 2016.2
#
#  Revision History:
#  Date        Author             Revision
#  ----------  -----------------  ----------------------------------------------
#  2017-08-08  Josh Schindehette  Initial Version
#
#===============================================================================

# Create Project
create_project "gain" ./gain -force

# Add Source & Simulation Files
add_files -norecurse gain.vhd
add_files -fileset sim_1 -norecurse ../../hdl/axis_file_reader.vhd
add_files -fileset sim_1 -norecurse ../../hdl/axis_file_writer.vhd
add_files -fileset sim_1 -norecurse gain_tb.vhd

# Set the top module
set_property "top" "gain"    [get_filesets "sources*"]
set_property "top" "gain_tb" [get_filesets "sim*"]

# Launch Simulation
launch_sim

# Run Simulation until there is no more stimulus
run all
