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
# Template:    ip_create.tcl
# Backend:     {{ fins['backend'] }}
# Generated:   {{ now }}
# ---------------------------------------------------------
# Description: TCL script for creating an IP compatible with
#              Xilinx Vivado IP Integrator
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

# Create Project
# Note: Default is webpack part
{%- if 'part' in fins %}
create_project {{ fins['name'] }} $PROJECT_VIVADO_DIR -force -part {{ fins['part'] }}
{%- else %}
create_project {{ fins['name'] }} $PROJECT_VIVADO_DIR -force -part xc7z020clg484-1
{%- endif %}

# Set sub-ip paths to be added to the IP Catalog
set SUB_IP_PATHS ""
{%- if 'ip' in fins %}
{%- for ip in fins['ip'] %}
lappend SUB_IP_PATHS "{{ ip['fins_path']|dirname }}"
{%- endfor %}
{%- endif %}
{%- if 'user_ip_catalog' in fins %}
lappend SUB_IP_PATHS "{{ fins['user_ip_catalog'] }}"
{%- endif %}
{%- if 'user_ip_catalog' in fins or 'ip' in fins %}
set_property ip_repo_paths $SUB_IP_PATHS [current_project]
update_ip_catalog
{%- endif %}

{%- if 'filesets' in fins %}
{%- if 'source' in fins['filesets'] %}
# Add Source Files
# Note: Vivado doesn't care about VHDL vs. Verilog when adding files
set SOURCE_FILES [list \
{%- for source_file in fins['filesets']['source'] %}
    {{ source_file['path'] }} \
{%- endfor %}
]
if { [info exists env(DELIVERY) ] } {
    import_files -norecurse $SOURCE_FILES
} else {
    add_files -norecurse $SOURCE_FILES
}
{%- endif %}

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

# Run TCL Scripts that Create Vendor IP
# Note: These scripts can use parameters defined above since they are sourced by this script
{%- if 'scripts' in fins['filesets'] %}
{%- if 'vendor_ip' in fins['filesets']['scripts'] %}
{%- for ip_script in fins['filesets']['scripts']['vendor_ip'] %}
source {{ ip_script['path'] }}
{%- endfor %}
{%- endif %}
{%- endif %}

{%- endif %}{#### if 'filesets' in fins ####}

# Create User IP
{%- for ip in fins['ip'] %}
{%- for instance in ip['instances'] %}
create_ip -name {{ ip['name'] }} -vendor {{ ip['vendor'] }} -library {{ ip['library'] }} -version {{ ip['version'] }} -module_name {{ instance['module_name'] }}
{%- if 'generics' in instance %}
set_property -dict [list \
    {%- for generic in instance['generics'] %}
    CONFIG.{{ generic['name'] }} {{ generic['value'] }} \
    {%- endfor %}
] [get_ips {{ instance['module_name'] }}]
{%- endif %}
{%- endfor %}
{%- endfor %}

# Set the top module
set_property "top" {{ fins['top_source'] }} [get_filesets "sources*"]

# Set the top module for the simulation
set_property "top" {{ fins['top_sim'] }} [get_filesets "sim*"]

# Package the project
ipx::package_project -root_dir $PROJECT_VIVADO_DIR -vendor {{ fins['company_url'] }} -library "{{ fins['library'] }}"
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

# Run Post-Build TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
{%- if 'filesets' in fins %}
{%- if 'scripts' in fins['filesets'] %}
{%- if 'postbuild' in fins['filesets']['scripts'] %}
{%- for postbuild_script in fins['filesets']['scripts']['postbuild'] %}
{%- if postbuild_script['type']|lower == 'tcl' %}
source {{ postbuild_script['path'] }}
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}
{%- endif %}
