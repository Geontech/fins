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
# Description: TCL script to generate a simulation with Intel Quartus
#              and run it with Intel ModelSim
# Versions:    Tested with:
#              * Intel Quartus Prime Pro 19.1
#===============================================================================

# Default the return code to 0=SUCCESS
set return_code 0

# Set the relative path back to the IP root directory
set IP_ROOT_RELATIVE_TO_PROJ "../../.."

# Parameters
set FINS_BACKEND "{{ fins['backend'] }}"
{% if 'params' in fins %}
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
        set result [examine $object_name]
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
source ${IP_ROOT_RELATIVE_TO_PROJ}/{{ presim_script['path'] }}
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}
{%- endif %}

# Find the Quartus-generated library name
set wrapper_dir [file normalize ../{{ fins['name'] }}_wrapper]
set unit_sim_libraries [glob \
    -nocomplain \
    -types d \
    -tails \
    -directory $wrapper_dir \
    {{ fins['name'] }}_*]

if {[llength $unit_sim_libraries] != 1} {
    error "Expected exactly one generated simulation library in $wrapper_dir, found: $unit_sim_libraries"
}
set UNIT_SIM_LIBRARY [lindex $unit_sim_libraries 0]


# Run the simulation
set TOP_LEVEL_NAME "${UNIT_SIM_LIBRARY}.{{ fins['top_sim'] }}"
set USER_DEFINED_ELAB_OPTIONS "-t 1ps"
source msim_setup.tcl

if {[llength [info commands ld]] == 0} {
    puts stderr "ERROR: msim_setup.tcl does not define the required ld command"
    exit -code 1
}
if {[catch {ld} message]} {
    puts stderr "ERROR: Quartus simulation compilation/elaboration failed: $message"
    exit -code 1
}
run -all

# Run Post-Sim TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
{%- if 'filesets' in fins %}
{%- if 'scripts' in fins['filesets'] %}
{%- if 'postsim' in fins['filesets']['scripts'] %}
{%- for postsim_script in fins['filesets']['scripts']['postsim'] %}
{%- if postsim_script['type']|lower == 'tcl' %}
source ${IP_ROOT_RELATIVE_TO_PROJ}/{{ postsim_script['path'] }}
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}
{%- endif %}

if {![fins_check_simulation_done "/{{ fins['top_sim'] }}/simulation_done"]} {
    set return_code 1
}

exit -code $return_code
