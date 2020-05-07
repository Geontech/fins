#===============================================================================
# Firmware IP Node Specification (FINS) Auto-Generated File
# ---------------------------------------------------------
# Template:    ip_simulate.tcl
# Backend:     quartus
# Generated:   2020-03-30 18:09:51.544578
# ---------------------------------------------------------
# Description: TCL script to generate a simulation with Intel Quartus
#              and run it with Intel ModelSim
# Versions:    Tested with:
#              * Intel Quartus Prime Pro 19.1
#===============================================================================

# Set the relative path back to the IP root directory
set IP_ROOT_RELATIVE_TO_PROJ "../../.."

# Parameters
set FINS_BACKEND "quartus"

#set TEST_PARAM_BOOLEAN True
#set TEST_PARAM_INTEGER 4
#set TEST_PARAM_STRING "my_string"
#set TEST_PARAM_INTEGER_LIST [list 0 1 2 3]
#set TEST_FIFO_DEPTH 16
#set TEST_RAM_DEPTH 16
#set PORTS_WIDTH 16
#set PORTS_IS_COMPLEX False
#set PORTS_IS_SIGNED False
#set PORTS_PACKET_SIZE 8
#set PROPS_DATA_WIDTH 32
#set PROPS_ADDR_WIDTH 16
#set PROPS_IS_ADDR_BYTE_INDEXED True



# Run Pre-Sim TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
source ${IP_ROOT_RELATIVE_TO_PROJ}/./scripts/print.tcl

# Find the Quartus-generated library name
set UNIT_SIM_LIBRARY nodeset_test
set QSYS_SIMDIR ../

source msim_setup.tcl

com

vcom -work nodeset_test ../../../hdl/nodeset_test_tb.vhd
# Run the simulation
set TOP_LEVEL_NAME "${UNIT_SIM_LIBRARY}.nodeset_test_tb"

elab
run -a
puts "===============================HEREERERRERER"

# Run Post-Sim TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
source ${IP_ROOT_RELATIVE_TO_PROJ}/scripts/simulation_done.tcl

quit
