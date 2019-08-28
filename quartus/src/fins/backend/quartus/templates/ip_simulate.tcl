#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Josh Schindehette
# Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: This is a generic TCL script to run an IP simulation
#===============================================================================

# Set the relative path back to the IP root directory
set IP_ROOT_RELATIVE_TO_PROJ "../../.."

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
{%- if presim_script['type']|lower == 'tcl' %}
source ${IP_ROOT_RELATIVE_TO_PROJ}/{{ presim_script['path'] }}
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}
{%- endif %}

source msim_setup.tcl
ld
vsim {{ fins['name'] }}_00.{{ fins['top_sim'] }}
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