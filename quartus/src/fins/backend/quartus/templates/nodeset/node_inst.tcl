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
# Template:    node_inst.tcl
# Backend:     {{ fins['backend'] }}
# Generated:   {{ now }}
# ---------------------------------------------------------
# Description: Intel Quartus Platform Designer Hardware Component
#              Definition TCL Script
# Versions:    Tested with:
#              * Intel Quartus Prime Pro 19.1
#===============================================================================

#proc {{ fins['name'] }}_add_nodes {} {
    # Instantiate all nodes in nodeset

    {%- for node in fins['nodes'] %}
    {%- if 'descriptive_node' not in node or node['descriptive_node'] in fins %}
    # Instantiate node "{{ node['node_name'] }}" as module "{{ node['module_name'] }}"
    add_component {{ node['module_name'] }} {{ node['module_name'] }}.ip {{ node['node_name'] }}
    load_component {{ node['module_name'] }}
    save_component
    load_instantiation {{ node['module_name'] }}
    save_instantiation
    {%- endif %}
    {%- endfor %}

    {%  if 'connections' in fins %}
    {%- for connection in fins['connections'] %}
    # Connections to "{{ connection['source'] }}"
    {%- for destination in connection['destination'] %}
    {%- if 'signals' in destination %}
    {%- for signal in destination['signals'] %}
    add_connection {{ connection['source'] }}/{{ destination['node'] }}.{{ signal }}
    {%- endfor %}
    {%- endif %}
    {%- endfor %}
    {%- endfor %}
    {%- endif %}

#}

