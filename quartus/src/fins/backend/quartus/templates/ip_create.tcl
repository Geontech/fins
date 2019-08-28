#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Josh Schindehette
# Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: This is an auto-generated TCL script for creating an IP
#              that is compatible with Quartus Platform Designer
# Generated:   {{ now }}
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

# Create the IP and set the project properties
create_ip {{ fins['name'] }} {{ fins['name'] }}
{%- if 'part' in fins %}
set IP_DEVICE {{ fins['part'] }}
{%- else %}
set IP_DEVICE 10CX220YF780I5G
{%- endif %}
set_project_property DEVICE $IP_DEVICE
set_project_property HIDE_FROM_IP_CATALOG {false}
set_module_property FILE {{ fins['name'] }}.ip
set_module_property GENERATION_ID {0x00000000}
set_module_property NAME {{ fins['name'] }}

# Run Post-Build TCL Scripts
# Note: These scripts can use parameters defined above since they are sourced by this script
{%- if 'filesets' in fins %}
{%- if 'scripts' in fins['filesets'] %}
{%- if 'postbuild' in fins['filesets']['scripts'] %}
{%- for postbuild_script in fins['filesets']['scripts']['postbuild'] %}
{%- if postbuild_script['type']|lower == 'tcl' %}
source ${IP_ROOT_RELATIVE_TO_PROJ}/{{ postbuild_script['path'] }}
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}
{%- endif %}

# Save the system
sync_sysinfo_parameters
save_system {{ fins['name'] }}
