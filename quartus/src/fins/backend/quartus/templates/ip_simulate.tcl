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
# Template:    ip_simulate.tcl
# Backend:     {{ fins['backend'] }}
# Generated:   {{ now }}
# ---------------------------------------------------------
# Description: TCL script to generate a simulation with Intel Quartus
#              and run it with Intel ModelSim
# Versions:    Tested with:
#              * Intel Quartus Prime Pro 19.1
#===============================================================================

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
set UNIT_SIM_LIBRARY [glob -tails -path ../{{ fins['name'] }}/ {{ fins['name'] }}_??]

# Run the simulation
source msim_setup.tcl
ld
vsim ${UNIT_SIM_LIBRARY}.{{ fins['top_sim'] }}
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

quit