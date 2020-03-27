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
# Template:    Makefile
# Backend:     {{ fins['backend'] }}
# Generated:   {{ now }}
# ---------------------------------------------------------
# Description: Makefile to build and simulate the FINS "quartus" backend
# Versions:    Tested with:
#              * Intel Quartus Prime Pro 19.1
#===============================================================================

#-------------------------------------------------------------------------------
# File paths
#-------------------------------------------------------------------------------
# Logging directory
LOGS_DIR:=log

TEMP_FILES:=$(LOGS_DIR)

#-------------------------------------------------------------------------------
# Makefile targets
#-------------------------------------------------------------------------------
.PHONY: all clean clean-nodes clean-all

# All phony target to build the Vivado project
all:
	{%- for node in fins['nodes'] %}
	$(MAKE) -C {{ node['fins_dir'] }} all
	{%- endfor %}

# Clean phony target that cleans only this nodeset
clean:
	rm -rf $(TEMP_FILES)

# Clean-nodes phony target that cleans all nodes
clean-nodes:
{%- for node in fins['nodes'] %}
	$(MAKE) -C {{ node['fins_dir'] }} clean-all
{%- endfor %}

# Clean-all phony target that cleans this nodeset and all nodes
clean-all: clean-nodes clean

