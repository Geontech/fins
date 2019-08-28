#===============================================================================
# Company:     Geon Technologies, LLC
# Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Auto-generated Intel HW Component TCL script
# Generated:   {{ now }}
#===============================================================================
package require qsys
package require quartus::device

# Fixed folder paths
set IP_ROOT_RELATIVE_TO_COREGEN "../.."

# Module Properties
{%- if 'description' in fins %}
set_module_property DESCRIPTION  "{{ fins['description'] }}"
{%- endif %}
set_module_property NAME "{{ fins['name'] }}"
set_module_property VERSION "{{ fins['version'] }}"
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "{{ fins['company_url'] }}"
set_module_property DISPLAY_NAME "{{ fins['name'] }}"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_property LOAD_ELABORATION_LIMIT 0
{%- if 'company_logo' in fins %}
set_module_property ICON_PATH "${IP_ROOT_RELATIVE_TO_COREGEN}/{{ fins['company_logo'] }}"
{%- endif %}
set_module_property GROUP "{{ fins['library'] }}"
set_module_property ELABORATION_CALLBACK "{{ fins['name'] }}_create_sub_ip"

# Define Inferred Generics
{%- for generic in fins['generics']['hdl'] %}
add_parameter {{ generic['name'] }} {{ generic['type']|upper }} {{ generic['value'] }}
set_parameter_property {{ generic['name'] }} HDL_PARAMETER true
{%- if 'width' in generic %}
set_parameter_property {{ generic['name'] }} WIDTH {{ generic['width'] }}
{%- endif %}
{%- endfor %}

# Define FINS Parameters
{%- for param in fins['params'] %}
add_parameter {{ param['name'] }}
{%- if param['value'] is iterable and param['value'] is not string %} INTEGER_LIST [list {{ param['value']|join(' ') }}]
{%- elif param['value'] is string %} STRING "{{ param['value'] }}"
{%- elif param['value'] is sameas true or param['value'] is sameas false %} BOOLEAN {{ param['value'] }}
{%- else %} INTEGER {{ param['value'] }}
{%- endif %} {% if 'description' in param %}"{{ param['description'] }}"{% endif %}
{%- endfor %}

# Source Fileset
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL {{ fins['top_source'] }}
{%- for source_file in fins['filesets']['source'] %}
add_fileset_file {{ source_file['path']|basename }} {{ source_file['type']|upper }} PATH ${IP_ROOT_RELATIVE_TO_COREGEN}/{{ source_file['path'] }} {% if source_file['path']|basename|lower=='%s.vhd'|format(fins['top_source']) or source_file['path']|basename|lower=='%s.vhdl'|format(fins['top_source']) or source_file['path']|basename|lower=='%s.v'|format(fins['top_source']) %}TOP_LEVEL_FILE{% endif %}
{%- endfor %}
{%- for constraints_file in fins['filesets']['constraints'] %}
{%- if constraints_file['type']|lower == 'sdc' %}
add_fileset_file {{ constraints_file['path']|basename }} {{ constraints_file['type']|upper }} PATH ${IP_ROOT_RELATIVE_TO_COREGEN}/{{ constraints_file['path'] }}
{%- endif %}
{%- endfor %}

# Simulation Fileset
set SIMULATION_FILESET "SIM_VERILOG"
{%- if 'filesets' in fins %}
{%- if 'sim' in fins['filesets'] %}
{%- for sim_file in fins['filesets']['sim'] %}
{%- if '%s.vhd'|format(fins['top_sim']) in sim_file['path']|lower %}
# Redefine the simulation fileset to VHDL
set SIMULATION_FILESET "SIM_VHDL"
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}
add_fileset $SIMULATION_FILESET $SIMULATION_FILESET "" ""
set_fileset_property $SIMULATION_FILESET TOP_LEVEL {{ fins['top_source'] }}
{%- for source_file in fins['filesets']['source'] %}
add_fileset_file {{ source_file['path']|basename }} {{ source_file['type']|upper }} PATH ${IP_ROOT_RELATIVE_TO_COREGEN}/{{ source_file['path'] }}
{%- endfor %}
{%- for sim_file in fins['filesets']['sim'] %}
add_fileset_file {{ sim_file['path']|basename }} {{ sim_file['type']|upper }} PATH ${IP_ROOT_RELATIVE_TO_COREGEN}/{{ sim_file['path'] }}
{%- endfor %}

# Create Interfaces
{%- for interface in fins['ports']['interfaces'] %}
add_interface {{ interface['name'] }} {{ interface['type'] }} {{ interface['mode'] }}
{%- if 'reset' in interface['type']|lower %}
set_interface_property {{ interface['name'] }} synchronousEdges NONE
{%- endif %}
{%- for hdl_port in interface['hdl_ports'] %}
{%- if ('clk' in hdl_port['interface_signal']|lower or 'reset' in hdl_port['interface_signal']|lower) and (not 'clock' in interface['type']|lower and not 'reset' in interface['type']|lower) %}
set_interface_property {{ interface['name'] }} {% if 'clk' in hdl_port['interface_signal']|lower %}associatedClock{% else %}associatedReset{% endif %} {{ hdl_port['name'] }}
{%- else %}
add_interface_port {{ interface['name'] }} {{ hdl_port['name'] }} {{ hdl_port['interface_signal'] }} {% if hdl_port['direction']|lower == 'in' %}Input{% elif hdl_port['direction']|lower == 'out' %}Output{% else %}Bidir{% endif %} "{{ hdl_port['width'] }}"
{%- endif %}
{%- endfor %}
{%- endfor %}

# Create Conduits for the non-interface ports
{%- for hdl_port in fins['ports']['hdl'] %}
{%- if not 'interface_signal' in hdl_port %}
add_interface {{ hdl_port['name'] }} conduit end
add_interface_port {{ hdl_port['name'] }} {{ hdl_port['name'] }} {{ hdl_port['type'] }} {% if hdl_port['direction']|lower == 'in' %}Input{% elif hdl_port['direction']|lower == 'out' %}Output{% else %}Bidir{% endif %} "{{ hdl_port['width'] }}"
{%- endif %}
{%- endfor %}

# Elaboration Callback
# Note: Used to instantiate sub-ip
proc {{ fins['name'] }}_create_sub_ip {} {
    # Set up filepaths
    set IP_ROOT_RELATIVE_TO_COREGEN "../.."
    # Set up the device details
    {%- if 'part' in fins %}
    set IP_DEVICE "{{ fins['part'] }}"
    {%- else %}
    set IP_DEVICE "10CX220YF780I5G"
    {%- endif %}
    set IP_DEVICE_FAMILY [regsub -all {[\{\}]} [quartus::device::get_part_info -family $IP_DEVICE] ""]
    # Retrieve parameters
    {%- for param in fins['params'] %}
    set {{ param['name'] }} [get_parameter_value "{{ param['name'] }}"]
    {%- endfor %}
    {%- for ip in fins['ip'] %}
    {%- for instance in ip['instances'] %}
    # FINS Path: {{ ip['fins_path'] }}
    # Vendor: {{ ip['vendor'] }}
    # Library: {{ ip['library'] }}
    add_hdl_instance {{ instance['module_name'] }} {{ ip['name'] }} {{ ip['version'] }}
    {%- if 'generics' in instance %}
    {%- for generic in instance['generics'] %}
    set_instance_parameter_value instance['module_name'] {{ generic['name'] }} {{ generic['value'] }}
    {%- endfor %}
    {%- endif %}
    {%- endfor %}
    {%- endfor %}
    # Run TCL Scripts that Create Vendor IP
    # Note: These scripts can use parameters defined above since they are sourced by this script
    {%- if 'scripts' in fins['filesets'] %}
    {%- if 'vendor_ip' in fins['filesets']['scripts'] %}
    {%- for ip_script in fins['filesets']['scripts']['vendor_ip'] %}
    source ${IP_ROOT_RELATIVE_TO_COREGEN}/{{ ip_script['path'] }}
    {%- endfor %}
    {%- endif %}
    {%- endif %}
}