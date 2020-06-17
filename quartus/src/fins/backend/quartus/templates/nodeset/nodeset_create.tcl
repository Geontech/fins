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
# Template:    nodeset_create.tcl
# Backend:     {{ fins['backend'] }}
# Generated:   {{ now }}
# ---------------------------------------------------------
# Description: TCL script for creating a nodeset compatible with
#              Intel Quartus Platform Designer
# Versions:    Tested with:
#              * Intel Quartus Prime Pro 19.1
#===============================================================================

package require qsys

# Set the fixed filepaths
set IP_ROOT_RELATIVE_TO_PROJ "../.."

# Run Pre-Build TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
{%- if 'filesets' in fins %}
{%- if 'scripts' in fins['filesets'] %}
{%- if 'prebuild' in fins['filesets']['scripts'] %}
{%- for prebuild_script in fins['filesets']['scripts']['prebuild'] %}
{%- if prebuild_script['type']|lower == 'tcl' %}
source ${IP_ROOT_RELATIVE_TO_PROJ}/{{ prebuild_script['path'] }}
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}
{%- endif %}

# Create the nodeset system and set the project properties
create_system {{ fins['name'] }}
{%- if 'part' in fins %}
set NODESET_DEVICE {{ fins['part'] }}
{%- else %}
set NODESET_DEVICE 10CX220YF780I5G
{%- endif %}
set_project_property DEVICE $NODESET_DEVICE
#set_project_property DEVICE_FAMILY {Cyclone 10 GX}
set_project_property HIDE_FROM_IP_CATALOG {false}
set_use_testbench_naming_pattern 0 {}

# Add the components

# Add clock bridge
# TODO do I need version here for add_component?
add_component clock_in ip/{{ fins['name'] }}/{{ fins['name'] }}_clock_in.ip altera_clock_bridge clock_in 19.1
load_component clock_in
# TODO clock rate?
set_component_parameter_value EXPLICIT_CLOCK_RATE {50000000.0}
set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
set_component_project_property HIDE_FROM_IP_CATALOG {false}
save_component
load_instantiation clock_in
#remove_instantiation_interfaces_and_ports
add_instantiation_interface in_clk clock INPUT
set_instantiation_interface_parameter_value in_clk clockRate {0}
set_instantiation_interface_parameter_value in_clk externallyDriven {false}
set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
add_instantiation_interface out_clk clock OUTPUT
set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
set_instantiation_interface_parameter_value out_clk clockRate {50000000}
set_instantiation_interface_parameter_value out_clk clockRateKnown {true}
set_instantiation_interface_parameter_value out_clk externallyDriven {false}
set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
set_instantiation_interface_sysinfo_parameter_value out_clk clock_rate {50000000}
add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
save_instantiation

# Add reset bridge
# TODO do I need version here for add_component?
add_component reset_in ip/{{ fins['name'] }}/{{ fins['name'] }}_reset_in.ip altera_reset_bridge reset_in 19.1
load_component reset_in
set_component_parameter_value ACTIVE_LOW_RESET {1}
set_component_parameter_value NUM_RESET_OUTPUTS {1}
set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
set_component_parameter_value SYNC_RESET {0}
set_component_parameter_value USE_RESET_REQUEST {0}
set_component_project_property HIDE_FROM_IP_CATALOG {false}
save_component
load_instantiation reset_in
#remove_instantiation_interfaces_and_ports
add_instantiation_interface clk clock INPUT
set_instantiation_interface_parameter_value clk clockRate {0}
set_instantiation_interface_parameter_value clk externallyDriven {false}
set_instantiation_interface_parameter_value clk ptfSchematicName {}
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

add_connection clock_in.out_clk/reset_in.clk

# Source FINS nodeset Tcl to instantiate FINS nodes and make connections to/between them
source ../../gen/quartus/node_inst.tcl

# add the exports
set_interface_property clk EXPORT_OF clock_in.in_clk
#set_exported_interface_sysinfo_parameter_value clk clock_domain {-1}
#set_exported_interface_sysinfo_parameter_value clk clock_rate {-1}
#set_exported_interface_sysinfo_parameter_value clk reset_domain {-1}
set_interface_property reset EXPORT_OF reset_in.in_reset

{%- if 'ports' in fins %}
{%-  if 'ports' in fins['ports'] %}
# The following ports were exported (made external) from the nodeset
{%-   for port in fins['ports']['ports'] %}
{%-    for i in range(port['num_instances']) %}
#set_interface_property {{ port|axisprefix(i) }}_aclk EXPORT_OF {{ port['node_name'] }}.{{ port['node_port']|axisprefix(i) }}_aclk
#set_interface_property {{ port|axisprefix(i) }}_aresetn EXPORT_OF {{ port['node_name'] }}.{{ port['node_port']|axisprefix(i) }}_aresetn
set_interface_property {{ port|axisprefix(i) }} EXPORT_OF {{ port['node_name'] }}.{{ port['node_port']|axisprefix(i) }}
{%-    endfor %}
{%-   endfor %}
{%-  endif %}
{%- endif %}

{%- if 'prop_interfaces' in fins %}
# The following property interfaces are exported for this nodeset
{%-  for node_interfaces in fins['prop_interfaces'] %}
{%-   set node_name = node_interfaces['node_name'] %}
{%-   for interface in node_interfaces['interfaces'] %}
{%-    set external_iface_name = (node_name + '_' + interface)|axi4liteprefix() %}
{%-    set internal_iface_name = node_name + '.' + interface|axi4liteprefix(node_interfaces['top']) %}
set_interface_property {{ external_iface_name }}_ACLK    EXPORT_OF {{ internal_iface_name }}_ACLK
set_interface_property {{ external_iface_name }}_ARESETN EXPORT_OF {{ internal_iface_name }}_ARESETN
set_interface_property {{ external_iface_name }}         EXPORT_OF {{ internal_iface_name }}
{%-   endfor %}
{%-  endfor %}
{%- endif %}

# save the system
sync_sysinfo_parameters
save_system {{ fins['name'] }}
