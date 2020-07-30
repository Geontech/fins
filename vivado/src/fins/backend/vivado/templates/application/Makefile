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
# Template:    Makefile
# Backend:     {{ fins['backend'] }}
# Generated:   {{ now }}
# ---------------------------------------------------------
# Description: Makefile to build and simulate the FINS "vivado" backend
# Versions:    Tested with:
#              * Xilinx Vivado 2019.2
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
# FINS-generated scripts directory for Vivado
FINS_VIVADO_DIR:=gen/vivado

# Project directory
PROJECT_DIR:=project

# Vivado Project directory
PROJECT_VIVADO_DIR:=$(PROJECT_DIR)/vivado

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

# Filenames
PROJECT_FILENAME:={{ fins['name'] }}.qpf
BD_APPLICATION_FILENAME:={{ fins['name'] }}.qsys
APPLICATION_CREATE_SCRIPT_FILENAME:=application_create.tcl
APPLICATION_CREATE_LOG_FILENAME:=application_create.log
APPLICATION_SIMULATE_SCRIPT_FILENAME:=application_simulate.tcl
APPLICATION_SIMULATE_LOG_FILENAME:=application_simulate.log

# Paths relative to the IP root
APPLICATION_CREATE_SCRIPT_PATH:=$(FINS_VIVADO_DIR)/$(APPLICATION_CREATE_SCRIPT_FILENAME)
APPLICATION_CREATE_LOG_PATH:=$(LOGS_DIR)/$(APPLICATION_CREATE_LOG_FILENAME)
APPLICATION_SIMULATE_SCRIPT_PATH:=$(FINS_VIVADO_DIR)/$(APPLICATION_SIMULATE_SCRIPT_FILENAME)
APPLICATION_SIMULATE_LOG_PATH:=$(LOGS_DIR)/$(APPLICATION_SIMULATE_LOG_FILENAME)

#-------------------------------------------------------------------------------
# Target specifications
#-------------------------------------------------------------------------------
# Top-level target
APPLICATION_TARGET:=$(PROJECT_VIVADO_DIR)/{{ fins['name'] }}.xpr

#-------------------------------------------------------------------------------
# Makefile targets
#-------------------------------------------------------------------------------
.PHONY: all clean clean-nodes clean-all {% if 'filesets' in fins %}{% if 'sim' in fins['filesets'] %}sim{% endif %}{% endif %}

# All phony target to build the {{ fins['backend'] }} project
all:
	{%- for node in fins['nodes'] %}
	$(MAKE) -C {{ node['fins_dir'] }} all
	{%- endfor %}
	make -C . $(APPLICATION_TARGET)

# Clean phony target that cleans only this Application
clean:
	rm -rf $(TEMP_FILES)

# Clean-nodes phony target that cleans all nodes
clean-nodes:
{%- for node in fins['nodes'] %}
	$(MAKE) -C {{ node['fins_dir'] }} clean-all
{%- endfor %}

# Clean-all phony target that cleans this Application and all nodes
clean-all: clean-nodes clean

# {{ fins['backend'] }} project target
$(APPLICATION_TARGET) : $(SOURCE_FILES) $(SIM_FILES) $(CONSTRAINTS_FILES)
	$(if $(UseBatch),mkdir -p $(LOGS_DIR))
	rm -rf $(PROJECT_VIVADO_DIR) && mkdir -p $(PROJECT_VIVADO_DIR)
	{%- if 'filesets' in fins %}
	{%- if 'scripts' in fins['filesets'] %}
	{%- if 'prebuild' in fins['filesets']['scripts'] %}
	{%- for script in fins['filesets']['scripts']['prebuild'] %}
	{%- if script['type']|lower == 'matlab' %}
ifdef MatlabExists
	matlab $(if $(UseBatch),-nosplash -nodesktop -noFigureWindows) -r "try; run('{{ script['path'] }}'); catch; end; quit" $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
else
	octave {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
endif
	{%- elif script['type']|lower == 'octave' %}
	octave {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
	{%- elif script['type']|lower == 'python' %}
	python {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
	{%- elif script['type']|lower == 'python3' %}
	python3 {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
	{%- elif script['type']|lower == 'cmdline' %}
	./{{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
	{%- endif %}
	{%- endfor %}
	{%- endif %}
	{%- endif %}
	{%- endif %}
	vivado $(if $(UseBatch),-mode batch) -source $(APPLICATION_CREATE_SCRIPT_PATH) $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
	{%- if 'filesets' in fins %}
	{%- if 'scripts' in fins['filesets'] %}
	{%- if 'postbuild' in fins['filesets']['scripts'] %}
	{%- for script in fins['filesets']['scripts']['postbuild'] %}
	{%- if script['type']|lower == 'matlab' %}
ifdef MatlabExists
	matlab $(if $(UseBatch),-nosplash -nodesktop -noFigureWindows) -r "try; run('{{ script['path'] }}'); catch; end; quit" $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
else
	octave {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
endif
	{%- elif script['type']|lower == 'octave' %}
	octave {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
	{%- elif script['type']|lower == 'python' %}
	python {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
	{%- elif script['type']|lower == 'python3' %}
	python3 {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
	{%- elif script['type']|lower == 'cmdline' %}
	./{{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_CREATE_LOG_PATH) 2>&1)
	{%- endif %}
	{%- endfor %}
	{%- endif %}
	{%- endif %}
	{%- endif %}

{%- if 'filesets' in fins %}
{%- if 'sim' in fins['filesets'] %}

# Simulation phony target
#sim : all $(APPLICATION_TARGET)
#	{%- if 'filesets' in fins %}
#	{%- if 'scripts' in fins['filesets'] %}
#	{%- if 'presim' in fins['filesets']['scripts'] %}
#	{%- for script in fins['filesets']['scripts']['presim'] %}
#	{%- if script['type']|lower == 'matlab' %}
#ifdef MatlabExists
#	matlab $(if $(UseBatch),-nosplash -nodesktop -noFigureWindows) -r "try; run('{{ script['path'] }}'); catch; end; quit" $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_PATH) 2>&1)
#else
#	octave {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_PATH) 2>&1)
#endif
#	{%- elif script['type']|lower == 'octave' %}
#	octave {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_PATH) 2>&1)
#	{%- elif script['type']|lower == 'python' %}
#	python {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_PATH) 2>&1)
#	{%- elif script['type']|lower == 'python3' %}
#	python3 {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_PATH) 2>&1)
#	{%- elif script['type']|lower == 'cmdline' %}
#	./{{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_PATH) 2>&1)
#	{%- endif %}
#	{%- endfor %}
#	{%- endif %}
#	{%- endif %}
#	{%- endif %}
#	vivado $(if $(UseBatch),-mode batch) -source $(APPLICATION_SIMULATE_SCRIPT_FILENAME) $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_FILENAME) 2>&1)
#	{%- if 'filesets' in fins %}
#	{%- if 'scripts' in fins['filesets'] %}
#	{%- if 'postsim' in fins['filesets']['scripts'] %}
#	{%- for script in fins['filesets']['scripts']['postsim'] %}
#	{%- if script['type']|lower == 'matlab' %}
#ifdef MatlabExists
#	matlab $(if $(UseBatch),-nosplash -nodesktop -noFigureWindows) -r "try; run('{{ script['path'] }}'); catch; end; quit" $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_PATH) 2>&1)
#else
#	octave {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_PATH) 2>&1)
#endif
#	{%- elif script['type']|lower == 'octave' %}
#	octave {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_PATH) 2>&1)
#	{%- elif script['type']|lower == 'python' %}
#	python {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_PATH) 2>&1)
#	{%- elif script['type']|lower == 'python3' %}
#	python3 {{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_PATH) 2>&1)
#	{%- elif script['type']|lower == 'cmdline' %}
#	./{{ script['path'] }} $(if $(UseBatch),>> $(APPLICATION_SIMULATE_LOG_PATH) 2>&1)
#	{%- endif %}
#	{%- endfor %}
#	{%- endif %}
#	{%- endif %}
#	{%- endif %}
{%- endif %}
{%- endif %}
