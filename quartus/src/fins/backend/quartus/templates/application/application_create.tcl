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
#===============================================================================
# Firmware IP Node Specification (FINS) Auto-Generated File
# ---------------------------------------------------------
# Template:    application_create.tcl
# Backend:     {{ fins['backend'] }}
# Generated:   {{ now }}
# ---------------------------------------------------------
# Description: TCL script for creating a Application compatible with
#              Intel Quartus Platform Designer
# Versions:    Tested with:
#              * Intel Quartus Prime Pro 19.4
#===============================================================================

package require qsys

# Set the fixed filepaths
set QUARTUS_TO_ROOT "../.."
set FINS_OUTPUT_DIR "gen/quartus"


# Run Pre-Build TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
{%- if 'filesets' in fins %}
{%- if 'scripts' in fins['filesets'] %}
{%- if 'prebuild' in fins['filesets']['scripts'] %}
{%- for prebuild_script in fins['filesets']['scripts']['prebuild'] %}
{%- if prebuild_script['type']|lower == 'tcl' %}
source ${QUARTUS_TO_ROOT}/{{ prebuild_script['path'] }}
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}
{%- endif %}

# Create the Application Quartus system and set the project properties
create_system {{ fins['name'] }}
{%- if 'part' in fins %}
set APPLICATION_DEVICE {{ fins['part'] }}
{%- else %}
set APPLICATION_DEVICE 10CX220YF780I5G
{%- endif %}
set_project_property DEVICE $APPLICATION_DEVICE
set_project_property HIDE_FROM_IP_CATALOG {false}
set_use_testbench_naming_pattern 0 {}

{% for clock in fins['clocks'] %}
{%- set clock_bridge_name = clock['base_name'] + '_clock_bridge' %}
{%- set reset_bridge_name = clock['base_name'] + '_reset_bridge' %}
# Add "{{ clock_bridge_name }}" clock bridge
add_component {{ clock_bridge_name }} ip/{{ fins['name'] }}/{{ clock_bridge_name }}_clock_in.ip altera_clock_bridge clock_in 19.1
load_component {{ clock_bridge_name }}

set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
set_component_project_property HIDE_FROM_IP_CATALOG {false}
save_component
load_instantiation {{ clock_bridge_name }}
#remove_instantiation_interfaces_and_ports
add_instantiation_interface in_clk clock INPUT
#set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
add_instantiation_interface out_clk clock OUTPUT
set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
#set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
save_instantiation

# Add reset bridge
{#
# TODO do I need version here for add_component?
#}
add_component {{ reset_bridge_name }} ip/{{ fins['name'] }}/{{ reset_bridge_name }}_reset_in.ip altera_reset_bridge reset_in 19.1
load_component {{ reset_bridge_name }}
set_component_parameter_value ACTIVE_LOW_RESET {1}
set_component_parameter_value NUM_RESET_OUTPUTS {1}
set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
set_component_parameter_value SYNC_RESET {0}
set_component_parameter_value USE_RESET_REQUEST {0}
#set_component_project_property HIDE_FROM_IP_CATALOG {false}
save_component
load_instantiation {{ reset_bridge_name }}
#remove_instantiation_interfaces_and_ports
add_instantiation_interface clk clock INPUT
#set_instantiation_interface_parameter_value clk ptfSchematicName {}
add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
add_instantiation_interface in_reset reset INPUT
set_instantiation_interface_parameter_value in_reset associatedClock {clk}
set_instantiation_interface_parameter_value in_reset synchronousEdges {DEASSERT}
add_instantiation_interface_port in_reset in_reset_n reset_n 1 STD_LOGIC Input
add_instantiation_interface out_reset reset OUTPUT
set_instantiation_interface_parameter_value out_reset associatedClock {clk}
set_instantiation_interface_parameter_value out_reset associatedDirectReset {in_reset}
set_instantiation_interface_parameter_value out_reset associatedResetSinks {in_reset}
set_instantiation_interface_parameter_value out_reset synchronousEdges {DEASSERT}
add_instantiation_interface_port out_reset out_reset_n reset_n 1 STD_LOGIC Output
save_instantiation

add_connection {{ clock_bridge_name }}.out_clk/{{ reset_bridge_name }}.clk

# Export clocks
set_interface_property {{ clock['clock'] }} EXPORT_OF {{ clock_bridge_name }}.in_clk
set_interface_port_property {{ clock['clock'] }} {{ clock['clock'] }}_clk NAME {{ clock['clock'] }}
set_interface_property {{ clock['resetn'] }} EXPORT_OF {{ reset_bridge_name }}.in_reset
set_interface_port_property {{ clock['resetn'] }} {{ clock['resetn'] }}_reset_n NAME {{ clock['resetn'] }}
{%- endfor %}{#### for clock in fins['clocks'] ####}

# Source FINS Application Tcl to instantiate FINS nodes and make connections to/between them
source ../../gen/quartus/nodes_instantiate.tcl

{%- if 'ports' in fins %}
{%-  if 'ports' in fins['ports'] and fins['ports']['ports']|length > 0 %}
# The following ports were exported (made external) from the Application
{%-   for port in fins['ports']['ports'] %}
{%-    for i in range(port['num_instances']) %}
set_interface_property {{ port|axisprefix(i) }} EXPORT_OF {{ port['node_name'] }}.{{ port['node_port']|axisprefix(i) }}
{%-    endfor %}
{%-   endfor %}
{%-  endif %}
{%-  if 'hdl' in fins['ports'] and fins['ports']['hdl']|length > 0 %}
{%-   for port in fins['ports']['hdl'] %}
set_interface_property {{ port['name'] }} EXPORT_OF {{ port['node_name'] }}.{{ port['node_port']['name'] }}
{%-   endfor %}
{%-  endif %}
{%- endif %}

{%- if 'prop_interfaces' in fins %}
# The following property interfaces are exported for this Application
{%-  for node_interfaces in fins['prop_interfaces'] %}
{%-   set node_name = node_interfaces['node_name'] %}
{%-   for interface in node_interfaces['interfaces'] %}
{%-    set external_iface_name = interface|axi4liteprefix(application_external=True) %}
{%-    set internal_iface_name = node_name + '.' + interface|axi4liteprefix() %}
add_interface {{ external_iface_name }} conduit end
set_interface_property {{ external_iface_name }} EXPORT_OF {{ internal_iface_name }}
{%-   endfor %}
{%-  endfor %}
{%- endif %}

# Wiring clock domains
{%- for clock in fins['clocks'] %}
# Connecting clocks and resets for "{{ clock['base_name'] }}" clock domain
{%-  set clock_name = clock['clock'] %}
{%-  set reset_name = clock['resetn'] %}
{%-  set clock_bridge_name = clock['base_name'] + '_clock_bridge' %}
{%-  set reset_bridge_name = clock['base_name'] + '_reset_bridge' %}
{%-  for net in clock['nets'] %}
{%-   if net['type'] == 'port' %}
{%-    set port = net['port'] %}
{%-    for i in range(port['num_instances']) %}
add_connection {{ clock_bridge_name }}.out_clk/{{ net['node_name'] }}.{{ port|axisprefix(i) }}_aclk
add_connection {{ reset_bridge_name }}.out_reset/{{ net['node_name'] }}.{{ port|axisprefix(i) }}_aresetn
{%-    endfor %}
{%-   elif net['type'] == 'hdl' %}
{%-    set port = net['port'] %}
add_connection {{ clock_bridge_name }}.out_clk/{{ net['node_name'] }}.{{ port['name'] }}
{%-   elif net['type'] == 'prop_interface' %}
add_connection {{ clock_bridge_name }}.out_clk/{{ net['node_name'] }}.{{ net['interface']|axi4liteprefix() }}_ACLK
add_connection {{ reset_bridge_name }}.out_reset/{{ net['node_name'] }}.{{ net['interface']|axi4liteprefix() }}_ARESETN
{%-   endif %}
{%-  endfor %}
{%- endfor %}

# save the system
sync_sysinfo_parameters
save_system {{ fins['name'] }}
