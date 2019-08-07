#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Josh Schindehette
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: This is a generic TCL script to run an IP simulation
#===============================================================================

# Setup paths
set PROJECT_VIVADO_DIR "./project/vivado"

# Parameters
{% for param in fins['params'] -%}
set {{ param['name'] }}
{%- if param['value'] is iterable and param['value'] is not string %} [list {{ param['value']|join(' ') }}]
{% elif param['value'] is string %} "{{ param['value'] }}"
{% else %} {{ param['value'] }}
{% endif -%}
{% endfor %}

# Run Pre-Sim TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
{%- if 'filesets' in fins %}
{%- if 'scripts' in fins['filesets'] %}
{%- if 'presim' in fins['filesets']['scripts'] %}
{%- for presim_script in fins['filesets']['scripts']['presim'] %}
{%- if 'tcl' in presim_script['type']|lower %}
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
{%- if 'tcl' in postsim_script['type']|lower %}
source {{ postsim_script['path'] }}
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}
{%- endif %}
