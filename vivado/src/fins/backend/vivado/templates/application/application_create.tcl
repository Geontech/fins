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
# Template:    application_create.tcl
# Backend:     {{ fins['backend'] }}
# Generated:   {{ now }}
# ---------------------------------------------------------
# Description: TCL script for creating a Application compatible with
#              Xilinx Vivado IP Integrator
# Versions:    Tested with:
#              * Xilinx Vivado 2019.2
#===============================================================================

# Setup paths
set PROJECT_VIVADO_DIR "./project/vivado"

# Run Pre-Build TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
{%- if 'filesets' in fins %}
{%- if 'scripts' in fins['filesets'] %}
{%- if 'prebuild' in fins['filesets']['scripts'] %}
{%- for prebuild_script in fins['filesets']['scripts']['prebuild'] %}
{%- if prebuild_script['type']|lower == 'tcl' %}
source {{ prebuild_script['path'] }}
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}
{%- endif %}

# TODO: default part should be set in python
{%- if 'part' in fins %}
set APPLICATION_DEVICE {{ fins['part'] }}
{%- else %}
set APPLICATION_DEVICE xc7z020clg484-1
{%- endif %}

# Create the Application Vivado IP Integrator Block Design and set the project properties
create_project {{ fins['name'] }} $PROJECT_VIVADO_DIR -force -part $APPLICATION_DEVICE

set_property target_language VHDL [current_project]

# Create the Block design for the Application
create_bd_design {{ fins['name'] }}_bd

# Set the IP Repository Paths list
{%- for node in fins['nodes'] %}
lappend IP_SEARCH_PATHS {{ node['fins_path']|dirname }}
{%- endfor %}
set_property ip_repo_paths $IP_SEARCH_PATHS [current_project]

update_ip_catalog

{%- if 'filesets' in fins %}
{%- if 'sim' in fins['filesets'] %}
# Add Simulation Files
# Note: Vivado doesn't care about VHDL vs. Verilog when adding files
set SIM_FILES [list \
{%- for sim_file in fins['filesets']['sim'] %}
    {{ sim_file['path'] }} \
{%- endfor %}
]
if {[llength $SIM_FILES] > 0} {
    if { [info exists env(DELIVERY) ] } {
        import_files -fileset sim_1 -norecurse $SIM_FILES
    } else {
        add_files -fileset sim_1 -norecurse $SIM_FILES
    }
}
{%- endif %}

{%- if 'constraints' in fins['filesets'] %}
# Add XDC Constraints Files
# Note: SDC constraints files will be ignored
set CONSTRAINTS_FILES [list \
{%- for constraint_file in fins['filesets']['constraints'] %}
{%- if constraint_file['type']|lower == 'xdc' %}
    {{ constraint_file['path'] }} \
{%- endif %}
{%- endfor %}
]
if {[llength $CONSTRAINTS_FILES] > 0} {
    if { [info exists env(DELIVERY) ] } {
        import_files -fileset constrs_1 -norecurse $CONSTRAINTS_FILES
    } else {
        add_files -fileset constrs_1 -norecurse $CONSTRAINTS_FILES
    }
}
{%- endif %}
{%- endif %}{#### if 'filesets' in fins ####}

# Set the top module for the simulation
set_property "top" {{ fins['top_sim'] }} [get_filesets "sim*"]

{%  for node in fins['nodes'] %}
{%- if not node['descriptive_node'] %}
# set the "vlnv" = Vendor:Library:Name:Version
set vlnv {{ node['node_details']['company_url'] }}:{{ node['node_details']['library'] }}:{{ node['node_details']['name'] }}:{{ node['node_details']['version'] }}
# Instantiate node "{{ node['node_name'] }}" as module "{{ node['module_name'] }}"
create_bd_cell -type ip -vlnv $vlnv {{ node['module_name'] }}
{%  endif %}
{%- endfor %}

# Wiring clock domains
{% for clock in fins['clocks'] %}
# Add "{{ clock['basename'] }}" clock domain: ({{ clock['clock'] }} and {{ clock['resetn'] }})
create_bd_port -dir I -type clk {{ clock['clock'] }}
create_bd_port -dir I -type rst {{ clock['resetn'] }}
set_property -dict [list CONFIG.ASSOCIATED_ASYNC_RESET {{ clock['resetn'] }}] [get_bd_ports {{ clock['clock'] }}]

# Connecting clocks and resets for "{{ clock['base_name'] }}" clock domain
{%-  for net in clock['nets'] %}
{%-   if net['type'] == 'port' %}
{%-    set port = net['port'] %}
{%-    for i in range(port['num_instances']) %}
connect_bd_net [get_bd_ports {{ clock['clock'] }}] [get_bd_pins {{ net['node_name'] }}/{{ port|axisprefix(i) }}_aclk]
connect_bd_net [get_bd_ports {{ clock['resetn'] }}] [get_bd_pins {{ net['node_name'] }}/{{ port|axisprefix(i) }}_aresetn]
{%-    endfor %}
{%-   elif net['type'] == 'hdl' %}
{%-    set port = net['port'] %}
connect_bd_net [get_bd_ports {{ clock['clock'] }}] [get_bd_pins {{ net['node_name'] }}/{{ port['name'] }}]
{%-   elif net['type'] == 'prop_interface' %}
connect_bd_net [get_bd_ports {{ clock['clock'] }}] [get_bd_pins {{ net['node_name'] }}/{{ net['interface']|axi4liteprefix() }}_ACLK]
connect_bd_net [get_bd_ports {{ clock['resetn'] }}] [get_bd_pins {{ net['node_name'] }}/{{ net['interface']|axi4liteprefix() }}_ARESETN]
{%-   endif %}
{%-  endfor %}
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
{%-    if source['instance'] == None and destination['instance'] == None %}
{%-     for i in range(source['port']['num_instances']) %}
connect_bd_intf_net [get_bd_intf_pins {{ source['node_name'] }}/{{ source['port']|axisprefix(i) }}] [get_bd_intf_pins {{ destination['node_name'] }}/{{ destination['port']|axisprefix(i) }}]
{%-     endfor %}
{#-
# Handles the case where the source is a specific instance but the destination is not and num_instances==1 in the destination
-#}
{%-    elif source['instance'] != None and destination['instance'] == None %}
connect_bd_intf_net [get_bd_intf_pins {{ source['node_name'] }}/{{ source['port']|axisprefix(source['instance']) }}] [get_bd_intf_pins {{ destination['node_name'] }}/{{ destination['port']|axisprefix }}]
{#-
# Handles the case where the destination is a specific instance but the source is not and num_instances==1 in the source
-#}
{%-    elif source['instance'] == None and destination['instance'] != None %}
connect_bd_intf_net [get_bd_intf_pins {{ source['node_name'] }}/{{ source['port']|axisprefix }}] [get_bd_intf_pins {{ destination['node_name'] }}/{{ destination['port']|axisprefix(destination['instance']) }}]
{#-
# Handles the case where the source and destination are a specific instance
-#}
{%-    elif source['instance'] != None and destination['instance'] != None %}
connect_bd_intf_net [get_bd_intf_pins {{ source['node_name'] }}/{{ source['port']|axisprefix(source['instance']) }}] [get_bd_intf_pins {{ destination['node_name'] }}/{{ destination['port']|axisprefix(destination['instance']) }}]
{%-    endif %}
{%-   else %}
# Connecting signal "{{ source['node_name'] }}.{{ source['net'] }}" to signal "{{ destination['node_name'] }}.{{ destination['net'] }}"
connect_bd_net [get_bd_pins {{ source['node_name'] }}/{{ source['net'] }}] [get_bd_pins {{ destination['node_name'] }}/{{ destination['net'] }}]
{%-   endif %}
{%   endfor %}
{%- endfor %}

{%- if 'ports' in fins %}
{%-  if 'ports' in fins['ports'] and fins['ports']['ports']|length > 0 %}
# The following ports were exported (made external) from the Application
{%-   for port in fins['ports']['ports'] %}
{%-    set mode = 'Slave' if port['direction']|lower == 'in' else 'Master' %}
{%-    for i in range(port['num_instances']) %}
create_bd_intf_port -mode {{ mode }} -vlnv xilinx.com:interface:axis_rtl:1.0 {{ port|axisprefix(i) }}
connect_bd_intf_net [get_bd_intf_pins {{ port['node_name'] }}/{{ port['node_port']|axisprefix(port['node_instances'][i]) }}] [get_bd_intf_ports {{ port|axisprefix(i) }}]
{%-    endfor %}
{%-   endfor %}
{%-  endif %}
{%-  if 'hdl' in fins['ports'] and fins['ports']['hdl']|length > 0 %}
{%-   for port in fins['ports']['hdl'] %}
{%-    set mode = 'I' if port['direction']|lower == 'in' else 'O' %}
{%-    if port['bit_width'] > 1 %}
create_bd_port -dir {{ mode }} -from {{ port['bit_width']-1 }} -to 0 {{ port['name'] }}_port
{%-    else %}
create_bd_port -dir {{ mode }} {{ port['name'] }}_port
{%-    endif %}
connect_bd_net [get_bd_pins {{ port['node_name'] }}/{{ port['node_port']['name'] }}] [get_bd_ports {{ port['name'] }}_port]
{%-   endfor %}
{%-  endif %}
{%- endif %}

{%- if 'prop_interfaces' in fins %}
# The following property interfaces are exported for this Application
{%-  for node_interfaces in fins['prop_interfaces'] %}
{%-   set node_name = node_interfaces['node_name'] %}
{%-   for interface in node_interfaces['interfaces'] %}
{%-    set external_iface_name = interface|axi4liteprefix(application_external=True) %}
{%-    set internal_iface_name = node_name + '/' + interface|axi4liteprefix() %}
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 {{ external_iface_name }}
set_property -dict [list \
    CONFIG.PROTOCOL              [get_property CONFIG.PROTOCOL              [get_bd_intf_pins {{ internal_iface_name }}]] \
    CONFIG.ADDR_WIDTH            [get_property CONFIG.ADDR_WIDTH            [get_bd_intf_pins {{ internal_iface_name }}]] \
    CONFIG.HAS_BURST             [get_property CONFIG.HAS_BURST             [get_bd_intf_pins {{ internal_iface_name }}]] \
    CONFIG.HAS_LOCK              [get_property CONFIG.HAS_LOCK              [get_bd_intf_pins {{ internal_iface_name }}]] \
    CONFIG.HAS_CACHE             [get_property CONFIG.HAS_CACHE             [get_bd_intf_pins {{ internal_iface_name }}]] \
    CONFIG.HAS_QOS               [get_property CONFIG.HAS_QOS               [get_bd_intf_pins {{ internal_iface_name }}]] \
    CONFIG.HAS_REGION            [get_property CONFIG.HAS_REGION            [get_bd_intf_pins {{ internal_iface_name }}]] \
    CONFIG.SUPPORTS_NARROW_BURST [get_property CONFIG.SUPPORTS_NARROW_BURST [get_bd_intf_pins {{ internal_iface_name }}]] \
    CONFIG.MAX_BURST_LENGTH      [get_property CONFIG.MAX_BURST_LENGTH      [get_bd_intf_pins {{ internal_iface_name }}]] \
] [get_bd_intf_ports {{ external_iface_name }}]

connect_bd_intf_net [get_bd_intf_pins {{ internal_iface_name }}] [get_bd_intf_ports {{ external_iface_name }}]

{%-   endfor %}
{%-  endfor %}
{%- endif %}

validate_bd_design
regenerate_bd_layout
save_bd_design

ipx::package_project -root_dir $PROJECT_VIVADO_DIR -vendor {{ fins['company_url'] }} -library {{ fins['library'] }} -module {{ fins['name'] }}_bd
#

set_property company_url "http://{{ fins['company_url'] }}" [ipx::current_core]

# Set the Name
set_property name "{{ fins['name'] }}" [ipx::current_core]
set_property display_name "{{ fins['name'] }}" [ipx::current_core]

# Set the Version
set_property version "{{ fins['version'] }}" [ipx::current_core]

{%- if 'company_name' in fins %}
# Set Vendor Display Name
set_property vendor_display_name "{{ fins['company_name'] }}" [ipx::current_core]
{%- endif %}

{%- if 'description' in fins %}
# Set IP Description
set_property description "{{ fins['description'] }}" [ipx::current_core]
{%- endif %}

{%- if 'company_logo' in fins %}
# Add company logo to IP Core
# Note: The ../../ is added to logo path since the project is located in ./project/vivado
ipx::add_file_group -type utility {} [ipx::current_core]
ipx::add_file ../../{{ fins['company_logo'] }} [ipx::get_file_groups xilinx_utilityxitfiles -of_objects [ipx::current_core]]
set_property type LOGO [ipx::get_files ../../{{ fins['company_logo'] }} -of_objects [ipx::get_file_groups xilinx_utilityxitfiles -of_objects [ipx::current_core]]]
{%- endif %}

# Save the core
ipx::save_core [ipx::current_core]
