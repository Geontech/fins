{#-
 #
 # Copyright (C) 2019 Geon Technologies, LLC
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
#===============================================================================
# Firmware IP Node Specification (FINS) Auto-Generated File
# ---------------------------------------------------------
# Template:    application_simulate.tcl
# Backend:     {{ fins['backend'] }}
# ---------------------------------------------------------
# Description: TCL script for running an Application simulation with
#              Xilinx Vivado Xsim
# Versions:    Tested with:
#              * Xilinx Vivado 2019.1
#===============================================================================

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

make_wrapper -files [get_files $PROJECT_VIVADO_DIR/{{ fins['name'] }}.srcs/sources_1/bd/{{ fins['name'] }}_bd/{{ fins['name'] }}_bd.bd] -top -fileset sim_1

set gendir $PROJECT_VIVADO_DIR/{{ fins['name'] }}.srcs/sources_1/bd/{{ fins['name'] }}_bd/hdl
# Try the old (pre-2020) generated HDL path first (*.srcs/....../hdl/),
# if that directory doesn't exist, use the new (post-2020) one (*.gen/......./hdl/)
if { ![file exist $gendir] || ![file isdirectory $gendir] } {
    set gendir $PROJECT_VIVADO_DIR/{{ fins['name'] }}.gen/sources_1/bd/{{ fins['name'] }}_bd/hdl
}

# Replace all instances of <name>_bd_wrapper with <name>
set orig_filename $gendir/{{ fins['name'] }}_bd_wrapper.vhd
set orig_fp [open $orig_filename r+]
set orig_string [read $orig_fp]
close $orig_fp
# replace string and place results in "new_string"
regsub -all {{ fins['name'] }}_bd_wrapper $orig_string {{ fins['name'] }} new_string
# split into an array with newline as the delimiter
set new_lines [split $new_string "\n"]

set new_filename $gendir/{{ fins['name'] }}.vhd
set new_fp [open $new_filename w]
# Write the new_string to the file line-by-line because the string is too long for Tcl all at once
foreach line $new_lines {
  puts $new_fp $line
}
close $new_fp

# Add the wrapper file to the simulation fileset
add_files -fileset sim_1 -norecurse $new_filename

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
