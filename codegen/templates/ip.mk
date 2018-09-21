#===============================================================================
# Company:     Geon Technologies, LLC
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Auto-generated IP generation Makefile
# Generated:   {{ now }}
#===============================================================================

#-------------------------------------------------------------------------------
# File lists
#-------------------------------------------------------------------------------
# All the temporary files that could be generated
FINS_FILES += ip_params.tcl
FINS_FILES += ip_import_user.tcl
FINS_FILES += ip_params.m
FINS_FILES += fins_edit.json
FINS_FILES += fins_swconfig_register_map.json
FINS_FILES += fins_axilite_register_map.json
FINS_FILES += {{ fins['name'] }}_params.vhd
FINS_FILES += {{ fins['name'] }}_streams.vhd
FINS_FILES += {{ fins['name'] }}_swconfig.vhd
FINS_FILES += {{ fins['name'] }}_swconfig.md
FINS_FILES += {{ fins['name'] }}_swconfig_verify.vhd
FINS_FILES += {{ fins['name'] }}_axilite.md
FINS_FILES += {{ fins['name'] }}_axilite.vhd

# Temporary build products
{%- if 'temp' in fins['filesets'] %}
TEMP_FILES := {{ fins['filesets']['temp']|join(' ') }}
{%- else %}
TEMP_FILES += *.cache
TEMP_FILES += *.data
TEMP_FILES += *.xpr
TEMP_FILES += *.log
TEMP_FILES += vivado_*.str
TEMP_FILES += vivado_*.zip
TEMP_FILES += component.xml
TEMP_FILES += *.jou
TEMP_FILES += xgui
TEMP_FILES += *.ip_user_files
TEMP_FILES += *.srcs
TEMP_FILES += *.runs
TEMP_FILES += *.hw
TEMP_FILES += *.sim
TEMP_FILES += *.txt
TEMP_FILES += *.mat
TEMP_FILES += .Xil
TEMP_FILES += *.coe
TEMP_FILES += *.edn
TEMP_FILES += *.edif
TEMP_FILES += *_netlist.v
TEMP_FILES += *_netlist.vhd
{%- endif %}

# Source files
{%- if 'params' in fins %}
SOURCE_FILES += {{ fins['name'] }}_params.vhd
{%- endif %}
{%- if 'swconfig' in fins %}
SOURCE_FILES += {{ fins['name'] }}_swconfig.vhd
{%- endif %}
{%- if 'axilite' in fins %}
SOURCE_FILES += {{ fins['name'] }}_axilite.vhd
{%- endif %}
SOURCE_FILES += {{ fins['filesets']['source']|join(' ') }}

# Simulation files
{%- if 'streams' in fins %}
SIM_FILES += ./fins/streams/hdl/axis_file_reader.vhd
SIM_FILES += ./fins/streams/hdl/axis_file_writer.vhd
SIM_FILES += {{ fins['name'] }}_streams.vhd
{%- endif %}
{%- if 'swconfig' in fins %}
SIM_FILES += {{ fins['name'] }}_swconfig_verify.vhd
{%- endif %}
SIM_FILES += {{ fins['filesets']['sim']|join(' ') }}

# Constraints files
CONSTRAINTS_FILES := {{ fins['filesets']['constraints']|join(' ') }}

#-------------------------------------------------------------------------------
# Target specifications
#-------------------------------------------------------------------------------
# Sub-IP targets
{%- for ip in fins['ip'] %}
{%- if ip['library'] == "user" %}
USER_IP_TARGETS += {{ ip['repo_name'] }}/{{ ip['name'] }}.xpr
{%- endif %}
{%- endfor %}

# Top-level targets
IP_TARGET      := {{ fins['project_name'] }}.xpr
SIM_TARGET     := sim_results.txt
NETLIST_TARGET := {{ fins['project_name'] }}_netlist.edif

#-------------------------------------------------------------------------------
# Makefile targets
#-------------------------------------------------------------------------------
.PHONY: all clean clean-all sim

all: $(IP_TARGET)

clean:
	rm -rf $(TEMP_FILES) $(FINS_FILES)

clean-all:
{%- for ip in fins['ip'] %}
{%- if ip['library'] == "user" %}
	make -C {{ ip['repo_name'] }} $@
{%- endif %}
{%- endfor %}
	rm -rf $(TEMP_FILES) $(FINS_FILES)

sim: $(SIM_TARGET)

netlist: $(NETLIST_TARGET)

$(IP_TARGET) : $(SOURCE_FILES) $(SIM_FILES) $(CONSTRAINTS_FILES) $(USER_IP_TARGETS)
	vivado -mode batch -source ./fins/xilinx/ip_create.tcl >> ip_create.log 2>&1

$(SIM_TARGET) : $(IP_TARGET)
	{%- if 'modeling_tool' in fins %}
	{%- if 'matlab' in fins['modeling_tool'] %}
	matlab -nosplash -nodesktop -r "sim_setup;exit" >> ip_simulate.log 2>&1
	{%- else %}
	octave sim_setup.m >> ip_simulate.log 2>&1
	{%- endif %}
	{%- endif %}
	vivado -mode batch -source ./fins/xilinx/ip_simulate.tcl >> ip_simulate.log 2>&1
	{%- if 'modeling_tool' in fins %}
	{%- if 'matlab' in fins['modeling_tool'] %}
	matlab -nosplash -nodesktop -r "sim_verify;exit" >> ip_simulate.log 2>&1
	{%- else %}
	octave sim_verify.m >> ip_simulate.log 2>&1
	{%- endif %}
	{%- endif %}

$(NETLIST_TARGET) : $(IP_TARGET)
	vivado -mode batch -source ./fins/xilinx/ip_netlist.tcl >> ip_netlist.log 2>&1
	rm -rf {{ fins['project_name'] }}_netlist
	find . -name "*.edif" ! -name "$@" -delete
	find . -name "*.edn" ! -name "$@" -delete

{% for ip in fins['ip'] %}
{% if ip['library'] == "user" %}
{{ ip['repo_name'] }}/{{ ip['name'] }}.xpr :
	make -C {{ ip['repo_name'] }} all
{%- endif %}
{%- endfor %}
