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
# Template:    ip_project.tcl
# Backend:     {{ fins['backend'] }}
# ---------------------------------------------------------
# Description: TCL script for creating an IP project compatible with
#              Intel Quartus Platform Designer
# Versions:    Tested with:
#              * Intel Quartus Prime Pro 19.4
#===============================================================================

# Quartus project Tcl package
package require ::quartus::project

# Create project
project_new -revision {{ fins['name'] }} {{ fins['name'] }}

# Path variables
set QUARTUS_TO_ROOT "../../"
set FINS_OUTPUT_DIR "gen/quartus/"

# Add known IP locations to the search path
set IP_SEARCH_PATHS "$QUARTUS_TO_ROOT/$FINS_OUTPUT_DIR"
{%- if 'ip' in fins %}
{%- for ip in fins['ip'] %}
set IP_SEARCH_PATHS "$IP_SEARCH_PATHS;$QUARTUS_TO_ROOT/{{ ip['fins_path']|dirname }}/**/*"
{%- endfor %}
{%- endif %}
{%- if 'user_ip_catalog' in fins %}
set IP_SEARCH_PATHS "$IP_SEARCH_PATHS;$QUARTUS_TO_ROOT/{{ fins['user_ip_catalog'] }}/**/*"
{%- endif %}
set_global_assignment -name IP_SEARCH_PATHS "$IP_SEARCH_PATHS;"

# Commit assignments and close project
export_assignments
project_close
