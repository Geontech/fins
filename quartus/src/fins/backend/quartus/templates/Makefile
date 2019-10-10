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
# Make Variables
#-------------------------------------------------------------------------------
# Variable to build and simulate with the GUI modes of the tools
#   * To set this variable on the command line, use the syntax: make UseGui=1
#   * Manually uncomment to always use the GUI for build and simulation
#UseGui = 1

# Inverse of UseGui
UseBatch:=$(if $(UseGui),,1)

# Check if matlab exists
MatlabExists:=$(shell command -v matlab 2> /dev/null)

#-------------------------------------------------------------------------------
# File paths
#-------------------------------------------------------------------------------
# FINS directories
FINS_OUTPUT_DIR:=gen/quartus

# Project directories
PROJECT_DIR:=project
QUARTUS_DIR:=$(PROJECT_DIR)/quartus
QUARTUS_TO_ROOT:=../..

# Modelsim directory
MODELSIM_DIR:=$(QUARTUS_DIR)/mentor
MODELSIM_TO_ROOT:=../../..

# Logging directory
LOGS_DIR:=log

#-------------------------------------------------------------------------------
# File lists
#-------------------------------------------------------------------------------
# Temporary build products and files
TEMP_FILES:=$(PROJECT_DIR) $(LOGS_DIR)
{% if 'filesets' in fins %}
{%- if 'source' in fins['filesets'] %}
# Source files
{%- for source_file in fins['filesets']['source'] %}
SOURCE_FILES+= {{ source_file['path'] }}
{%- endfor %}
{%- endif %}
{% if 'sim' in fins['filesets'] %}
# Simulation files
{%- for sim_file in fins['filesets']['sim'] %}
SIM_FILES+= {{ sim_file['path'] }}
{%- endfor %}
{%- endif %}
{% if 'constraints' in fins['filesets'] %}
# Constraints files
{%- for constraints_file in fins['filesets']['constraints'] %}
CONSTRAINTS_FILES+= {{ constraints_file['path'] }}
{%- endfor %}
{%- endif %}
{%- endif %}

#-------------------------------------------------------------------------------
# Additional variables
#-------------------------------------------------------------------------------
# Search paths of this IP's _hw.tcl and sub-IP
IP_SEARCH_PATHS:=$(QUARTUS_TO_ROOT)/$(FINS_OUTPUT_DIR),
{%- if 'ip' in fins %}
{%- for ip in fins['ip'] %}
IP_SEARCH_PATHS:=$(IP_SEARCH_PATHS)$(QUARTUS_TO_ROOT)/{{ ip['fins_path']|dirname }}/**/*,
{%- endfor %}
{%- endif %}
{%- if 'user_ip_catalog' in fins %}
IP_SEARCH_PATHS:=$(IP_SEARCH_PATHS)$(QUARTUS_TO_ROOT)/{{ fins['user_ip_catalog'] }}/**/*,
{%- endif %}

# Filenames
PROJECT_FILENAME:={{ fins['name'] }}.qpf
QSYS_IP_FILENAME:={{ fins['name'] }}.ip
IP_CREATE_SCRIPT_FILENAME:=ip_create.tcl
IP_CREATE_LOG_FILENAME:=ip_create.log
IP_SIMULATE_SCRIPT_FILENAME:=ip_simulate.tcl
IP_SIMULATE_LOG_FILENAME:=ip_simulate.log

# Paths relative to the IP root
IP_CREATE_LOG_PATH:=$(LOGS_DIR)/$(IP_CREATE_LOG_FILENAME)
IP_SIMULATE_LOG_PATH:=$(LOGS_DIR)/$(IP_SIMULATE_LOG_FILENAME)

# Paths relative to the other paths
QUARTUS_TO_IP_CREATE_SCRIPT_PATH:=$(QUARTUS_TO_ROOT)/$(FINS_OUTPUT_DIR)/$(IP_CREATE_SCRIPT_FILENAME)
QUARTUS_TO_IP_CREATE_LOG_PATH:=$(QUARTUS_TO_ROOT)/$(IP_CREATE_LOG_PATH)
QUARTUS_TO_IP_SIMULATE_LOG_PATH:=$(QUARTUS_TO_ROOT)/$(IP_SIMULATE_LOG_PATH)
MODELSIM_TO_IP_SIMULATE_SCRIPT_PATH:=$(MODELSIM_TO_ROOT)/$(FINS_OUTPUT_DIR)/$(IP_SIMULATE_SCRIPT_FILENAME)
MODELSIM_TO_IP_SIMULATE_LOG_PATH:=$(MODELSIM_TO_ROOT)/$(IP_SIMULATE_LOG_PATH)

# Set the default synthesis language to use
SYNTH_LANGUAGE:=VERILOG
{%- if 'filesets' in fins %}
{%- if 'source' in fins['filesets'] %}
{%- for source_file in fins['filesets']['source'] %}
{%- if '%s.vhd'|format(fins['top_source']) in source_file['path']|lower %}
# Redefine the synthesis language to VHDL
SYNTH_LANGUAGE:=VHDL
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}

# Set the default simulation language to use
SIM_LANGUAGE:=VERILOG
{%- if 'filesets' in fins %}
{%- if 'sim' in fins['filesets'] %}
{%- for sim_file in fins['filesets']['sim'] %}
{%- if '%s.vhd'|format(fins['top_sim']) in sim_file['path']|lower %}
# Redefine the simulation language to VHDL
SIM_LANGUAGE:=VHDL
{%- endif %}
{%- endfor %}
{%- endif %}
{%- endif %}

#-------------------------------------------------------------------------------
# Target specifications
#-------------------------------------------------------------------------------
# Top-level target
IP_TARGET:=$(QUARTUS_DIR)/$(PROJECT_FILENAME)

#-------------------------------------------------------------------------------
# Makefile targets
#-------------------------------------------------------------------------------
.PHONY: all clean clean-all sim

# All phony target to build the Vivado project
all:
	{%- for ip in fins['ip'] %}
	{%- if ip['library'] == "user" %}
	make -C {{ ip['fins_path']|dirname }} all
	{%- endif %}
	{%- endfor %}
	make -C . $(IP_TARGET)

# Clean target that cleans only this IP
clean:
	rm -rf $(TEMP_FILES)

# Clean-all phony target that cleans this IP and all sub-ip
clean-all:
{%- for ip in fins['ip'] %}
{%- if ip['library'] == "user" %}
	make -C {{ ip['fins_path']|dirname }} $@
{%- endif %}
{%- endfor %}
	rm -rf $(TEMP_FILES)

# Vivado project target
$(IP_TARGET) : $(SOURCE_FILES) $(SIM_FILES) $(CONSTRAINTS_FILES)
	$(if $(UseBatch),mkdir -p $(LOGS_DIR))
	rm -rf $(QUARTUS_DIR) && mkdir -p $(QUARTUS_DIR)
	{%- if 'filesets' in fins %}
	{%- if 'scripts' in fins['filesets'] %}
	{%- if 'prebuild' in fins['filesets']['scripts'] %}
	{%- for script in fins['filesets']['scripts']['prebuild'] %}
	{%- if script['type']|lower == 'matlab' %}
ifdef MatlabExists
	matlab $(if $(UseBatch),-nosplash -nodesktop -noFigureWindows) -r "try; run('{{ script['path'] }}'); catch; end; quit" $(if $(UseBatch),>> $(IP_CREATE_LOG_PATH) 2>&1)
else
	octave {{ script['path'] }} $(if $(UseBatch),>> $(IP_CREATE_LOG_PATH) 2>&1)
endif
	{%- elif script['type']|lower == 'octave' %}
	octave {{ script['path'] }} $(if $(UseBatch),>> $(IP_CREATE_LOG_PATH) 2>&1)
	{%- elif script['type']|lower == 'python' %}
	python {{ script['path'] }} $(if $(UseBatch),>> $(IP_CREATE_LOG_PATH) 2>&1)
	{%- endif %}
	{%- endfor %}
	{%- endif %}
	{%- endif %}
	{%- endif %}
	cd $(QUARTUS_DIR) && qsys-script --search-path=$(IP_SEARCH_PATHS)$$ --new-quartus-project=$(PROJECT_FILENAME) --script=$(QUARTUS_TO_IP_CREATE_SCRIPT_PATH) $(if $(UseBatch),>> $(QUARTUS_TO_IP_CREATE_LOG_PATH) 2>&1)
	cd $(QUARTUS_DIR) && qsys-generate --search-path=$(IP_SEARCH_PATHS)$$ --quartus-project=$(PROJECT_FILENAME) --synthesis=$(SYNTH_LANGUAGE) --simulation=$(SIM_LANGUAGE) --ipxact $(QSYS_IP_FILENAME) $(if $(UseBatch),>> $(QUARTUS_TO_IP_CREATE_LOG_PATH) 2>&1)
	{%- if 'filesets' in fins %}
	{%- if 'scripts' in fins['filesets'] %}
	{%- if 'postbuild' in fins['filesets']['scripts'] %}
	{%- for script in fins['filesets']['scripts']['postbuild'] %}
	{%- if script['type']|lower == 'matlab' %}
ifdef MatlabExists
	matlab $(if $(UseBatch),-nosplash -nodesktop -noFigureWindows) -r "try; run('{{ script['path'] }}'); catch; end; quit" $(if $(UseBatch),>> $(IP_CREATE_LOG_PATH) 2>&1)
else
	octave {{ script['path'] }} $(if $(UseBatch),>> $(IP_CREATE_LOG_PATH) 2>&1)
endif
	{%- elif script['type']|lower == 'octave' %}
	octave {{ script['path'] }} $(if $(UseBatch),>> $(IP_CREATE_LOG_PATH) 2>&1)
	{%- elif script['type']|lower == 'python' %}
	python {{ script['path'] }} $(if $(UseBatch),>> $(IP_CREATE_LOG_PATH) 2>&1)
	{%- endif %}
	{%- endfor %}
	{%- endif %}
	{%- endif %}
	{%- endif %}

# Simulation phony target
sim : all
	{%- if 'filesets' in fins %}
	{%- if 'scripts' in fins['filesets'] %}
	{%- if 'presim' in fins['filesets']['scripts'] %}
	{%- for script in fins['filesets']['scripts']['presim'] %}
	{%- if script['type']|lower == 'matlab' %}
ifdef MatlabExists
	matlab $(if $(UseBatch),-nosplash -nodesktop -noFigureWindows) -r "try; run('{{ script['path'] }}'); catch; end; quit" $(if $(UseBatch),>> $(IP_SIMULATE_LOG_PATH) 2>&1)
else
	octave {{ script['path'] }} $(if $(UseBatch),>> $(IP_SIMULATE_LOG_PATH) 2>&1)
endif
	{%- elif script['type']|lower == 'octave' %}
	octave {{ script['path'] }} $(if $(UseBatch),>> $(IP_SIMULATE_LOG_PATH) 2>&1)
	{%- elif script['type']|lower == 'python' %}
	python {{ script['path'] }} $(if $(UseBatch),>> $(IP_SIMULATE_LOG_PATH) 2>&1)
	{%- endif %}
	{%- endfor %}
	{%- endif %}
	{%- endif %}
	{%- endif %}
	cd $(QUARTUS_DIR) && ip-setup-simulation --quartus-project=$(PROJECT_FILENAME) --output-directory=./ --use-relative-paths $(if $(UseBatch),>> $(QUARTUS_TO_IP_SIMULATE_LOG_PATH) 2>&1)
	cd $(MODELSIM_DIR) && vsim $(if $(UseBatch),-batch) -do $(MODELSIM_TO_IP_SIMULATE_SCRIPT_PATH) $(if $(UseBatch),>> $(MODELSIM_TO_IP_SIMULATE_LOG_PATH) 2>&1)
	{%- if 'filesets' in fins %}
	{%- if 'scripts' in fins['filesets'] %}
	{%- if 'postsim' in fins['filesets']['scripts'] %}
	{%- for script in fins['filesets']['scripts']['postsim'] %}
	{%- if script['type']|lower == 'matlab' %}
ifdef MatlabExists
	matlab $(if $(UseBatch),-nosplash -nodesktop -noFigureWindows) -r "try; run('{{ script['path'] }}'); catch; end; quit" $(if $(UseBatch),>> $(IP_SIMULATE_LOG_PATH) 2>&1)
else
	octave {{ script['path'] }} $(if $(UseBatch),>> $(IP_SIMULATE_LOG_PATH) 2>&1)
endif
	{%- elif script['type']|lower == 'octave' %}
	octave {{ script['path'] }} $(if $(UseBatch),>> $(IP_SIMULATE_LOG_PATH) 2>&1)
	{%- elif script['type']|lower == 'python' %}
	python {{ script['path'] }} $(if $(UseBatch),>> $(IP_SIMULATE_LOG_PATH) 2>&1)
	{%- endif %}
	{%- endfor %}
	{%- endif %}
	{%- endif %}
	{%- endif %}
