if { $USE_XILINX } {
    # Make sure the simulation_done signal is True
    if { [get_value [get_objects "simulation_done"]] == "FALSE" } {
        error "***** SIMULATION FAILED (simulation_done=false) *****"
    }
} else {
    # Make sure the simulation_done signal is True
    if { [examine "simulation_done"] == "FALSE" } {
        error "***** SIMULATION FAILED (simulation_done=false) *****"
    }
}
