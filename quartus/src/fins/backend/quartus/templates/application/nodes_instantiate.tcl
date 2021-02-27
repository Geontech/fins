{#-
 #
 # Copyright (C) 2020 Geon Technologies, LLC
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
# Template:    nodes_instantiate.tcl
# Backend:     {{ fins['backend'] }}
# Generated:   {{ now }}
# ---------------------------------------------------------
# Description: Intel Quartus Platform Designer Hardware Component
#              Definition TCL Script
# Versions:    Tested with:
#              * Intel Quartus Prime Pro 19.4
#===============================================================================

{#-
# Instantiate all nodes in the Application
-#}
{%  for node in fins['nodes'] %}
{%- if not node['descriptive_node'] %}
# Instantiate node "{{ node['node_name'] }}" as module "{{ node['module_name'] }}"
add_component {{ node['module_name'] }} {{ node['module_name'] }}.ip {{ node['node_name'] }}
load_component {{ node['module_name'] }}
save_component
load_instantiation {{ node['module_name'] }}
save_instantiation
{%  endif %}
{%- endfor %}

{#-
# For each connection, determine the 'type' of each source and destination (port, or other)
# Make connections between ports or signals accordingly, and include '<node>.' as a signal prefix
-#}
{%- for connection in fins['connections'] %}
{%-  for destination in connection['destinations'] %}
{%-   set source = connection['source'] %}
{%-   if source['type'] == 'port' and destination['type'] == 'port' %}
# Connecting port "{{ source['node_name'] }}.{{ source['net'] }}" to port "{{ destination['node_name'] }}.{{ destination['net'] }}"
{%-    for i in range(source['port']['num_instances']) %}
add_connection {{ source['node_name'] }}.{{ source['port']|axisprefix(i) }}/{{ destination['node_name'] }}.{{ destination['port']|axisprefix(i) }}
{%-    endfor %}
{%-   else %}
# Connecting signal "{{ source['node_name'] }}.{{ source['net'] }}" to signal "{{ destination['node_name'] }}.{{ destination['net'] }}"
add_connection {{ source['node_name'] }}.{{ source['net'] }}/{{ destination['node_name'] }}.{{ destination['net'] }}
{%-   endif %}
{%   endfor %}
{%- endfor %}
