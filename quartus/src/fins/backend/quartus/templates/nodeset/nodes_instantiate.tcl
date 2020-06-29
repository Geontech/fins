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
# Template:    nodes_instantiate.tcl
# Backend:     {{ fins['backend'] }}
# Generated:   {{ now }}
# ---------------------------------------------------------
# Description: Intel Quartus Platform Designer Hardware Component
#              Definition TCL Script
# Versions:    Tested with:
#              * Intel Quartus Prime Pro 19.1
#===============================================================================

{#-
# Instantiate all nodes in nodeset
-#}
{%  for node in fins['nodes'] %}
{%- if not node['sub_node'] %}
# Instantiate node "{{ node['node_name'] }}" as module "{{ node['module_name'] }}"
add_component {{ node['module_name'] }} {{ node['module_name'] }}.ip {{ node['node_name'] }}
load_component {{ node['module_name'] }}
save_component
load_instantiation {{ node['module_name'] }}
save_instantiation
{%  endif %}
{%- endfor %}

{#-
# For each connection, determine the 'type' of each source and destination (clock, reset or port)
# Make connections between ports or signals accordingly, and include '<node>.' as a signal prefix
-#}
{%- for connection in fins['connections'] %}
{%- for destination in connection['destinations'] %}

{%- set source = connection['source'] %}

{#-
# Determine whether each connection source and destination is associated with node
-#}
{%- if 'node_name' in source and source['node_name'] is not none %}
    {%- set snode = source['node_name'] + '.' %}
{%- else %}
    {%- set snode = '' %}
{%- endif %}
{%- if 'node_name' in destination and destination['node_name'] is not none %}
    {%- set dnode = destination['node_name'] + '.' %}
{%- else %}
    {%- set dnode = '' %}
{%- endif %}

{%- if source['type'] == 'clock' and destination['type'] == 'port' %}
# Connecting clock signal "{{ snode }}{{ source['net'] }}" to clock(s) on port "{{ dnode }}{{ destination['net'] }}"
{%- for i in range(destination['port']['num_instances']) %}
add_connection {{ snode }}{{ source['net'] }}/{{ dnode }}{{ destination['port']|axisprefix(i) }}_aclk
{%- endfor %}
{%- elif source['type'] == 'reset' and destination['type'] == 'port' %}
# Connecting reset signal "{{ source['net'] }}" to reset(s) on port "{{ destination['net'] }}"
{%- for i in range(destination['port']['num_instances']) %}
add_connection {{ snode }}{{ source['net'] }}/{{ dnode }}{{ destination['port']|axisprefix(i) }}_aresetn
{%- endfor %}
{%- elif source['type'] == 'port' and destination['type'] == 'port' %}
# Connecting port "{{ source['net'] }}" to port "{{ destination['net'] }}"
{%- for i in range(source['port']['num_instances']) %}
add_connection {{ snode }}{{ source['port']|axisprefix(i) }}/{{ dnode }}{{ destination['port']|axisprefix(i) }}
{%- endfor %}
{%- else %}
# Connecting signal "{{ source['net'] }}" to signal "{{ destination['net'] }}"
add_connection {{ snode }}{{ source['net'] }}/{{ dnode }}{{ destination['net'] }}
{%- endif %}
{%  endfor %}
{%- endfor %}
