{#-
 #
 # Copyright (C) 2019, 2026 Geon Technologies, LLC
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
-#}
{%- if 'license_lines' in fins %}
{%-  for line in fins['license_lines'] -%}
# {{ line }}
{%-  endfor %}
{%- endif %}

#===============================================================================
# Firmware IP Node Specification (FINS) Auto-Generated File
# ---------------------------------------------------------
# Template:    ip_simulate.tcl
# Backend:     {{ fins['backend'] }}
# ---------------------------------------------------------
# Description: TCL script for running an IP simulation with
#              Xilinx Vivado Xsim
# Versions:    Tested with:
#              * Xilinx Vivado 2019.1
#===============================================================================

# Default the return code to 0=SUCCESS
set return_code 0

# Batch simulations do not need Vivado's default waveform setup. The generated
# Makefile passes this flag only when UseGui is unset.
set FINS_BATCH_NO_WAVES [expr {
    [lsearch -exact $argv "--batch-no-waves"] >= 0
}]

# Setup paths
set PROJECT_VIVADO_DIR "./project/vivado"

# Parameters
set FINS_BACKEND "{{ fins['backend'] }}"
{%- if 'params' in fins %}
{% for param in fins['params'] -%}
set {{ param['name'] }}
{%- if param['value'] is iterable and param['value'] is not string %} [list {{ param['value']|join(' ') }}]
{% elif param['value'] is string %} "{{ param['value'] }}"
{% else %} {{ param['value'] }}
{% endif -%}
{% endfor %}
{% endif %}

# Try to read a simulation object without exposing simulator-specific commands.
proc fins_try_get_value {object_name result_var} {
    upvar 1 $result_var result
    if {[catch {
        set result [get_value [get_objects $object_name]]
    }]} {
        return 0
    }
    return 1
}

# Check the standard FINS testbench completion signal.
proc fins_check_simulation_done {signal_path} {
    if {![fins_try_get_value $signal_path value]} {
        puts "ERROR: simulation_done signal not found at '$signal_path'"
        return 0
    }
    set value [string toupper [string trim $value]]
    switch -- $value {
        "TRUE"  { puts "***** SIMULATION PASSED *****"; return 1 }
        "FALSE" { puts "***** SIMULATION FAILED *****"; return 0 }
        default { puts "ERROR: simulation_done has unexpected value '$value'"; return 0 }
    }
}

# Run Pre-Sim TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
{%- if 'filesets' in fins %}
{%- if 'scripts' in fins['filesets'] %}
{%- if 'presim' in fins['filesets']['scripts'] %}
{%- for presim_script in fins['filesets']['scripts']['presim'] %}
{%- if presim_script['type']|lower == 'tcl' %}
source {{ presim_script['path'] }}
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}
{%- endif %}

# Open project if not open
if {[current_project -quiet] == ""} {
    open_project $PROJECT_VIVADO_DIR/{{ fins['name'] }}.xpr
}

# Generate each vendor and sub-IP
foreach ip [get_ips] {
    generate_target simulation [get_files [get_property IP_FILE $ip ] ]
}

# Vivado's default XSim startup script adds every top-level object to the wave
# configuration. Besides wasting time and memory in batch mode, that produces
# Wavedata 42-489 warnings for objects wider than the viewer display limit.
# A custom startup script replaces that default only for batch simulations.
set FINS_SIM_FILESET [get_filesets sim_1]
if {$FINS_BATCH_NO_WAVES} {
    set FINS_BATCH_TCL [file normalize [file join \
        [file dirname [info script]] xsim_batch.tcl]]
    set_property xsim.simulate.custom_tcl $FINS_BATCH_TCL $FINS_SIM_FILESET
} else {
    # Clear a value persisted by an earlier batch run so GUI simulations retain
    # Vivado's normal waveform behavior.
    set_property xsim.simulate.custom_tcl {} $FINS_SIM_FILESET
}

# Launch Simulation
launch_sim

# Check that the simulation launched correctly
# Note: By default, Vivado launches the simulation and runs for 1us
if { [current_time] != "1 us" } {
    error "***** SIMULATION FAILED (t<1us) *****"
}

# Run Simulation until there is no more stimulus
run all

# Run Post-Sim TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
{%- if 'filesets' in fins %}
{%- if 'scripts' in fins['filesets'] %}
{%- if 'postsim' in fins['filesets']['scripts'] %}
{%- for postsim_script in fins['filesets']['scripts']['postsim'] %}
{%- if postsim_script['type']|lower == 'tcl' %}
source {{ postsim_script['path'] }}
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}
{%- endif %}

if {![fins_check_simulation_done "/{{ fins['top_sim'] }}/simulation_done"]} {
    set return_code 1
}
exit $return_code
