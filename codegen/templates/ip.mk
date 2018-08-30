#===============================================================================
# Company:     Geon Technologies, LLC
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Auto-generated IP generation Makefile
# Generated:   {{ now }}
#===============================================================================

# File Lists
FINS_FILES        := ip_params.tcl ip_import_user.tcl ip_params.m fins_edit.json fins_swconfig_register_map.json fins_axilite_register_map.json {{ fins['name'] }}_params.vhd {{ fins['name'] }}_streams.vhd {{ fins['name'] }}_swconfig.vhd {{ fins['name'] }}_swconfig.md {{ fins['name'] }}_swconfig_verify.vhd {{ fins['name'] }}_axilite.md {{ fins['name'] }}_axilite.vhd
TEMP_FILES        := {{ fins['filesets']['temp']|join(' ') }}
SOURCE_FILES      := {{ fins['filesets']['source']|join(' ') }}
SIM_FILES         := {{ fins['filesets']['sim']|join(' ') }}
CONSTRAINTS_FILES := {{ fins['filesets']['constraints']|join(' ') }}
USER_IP_TARGETS   := {% for ip in fins['ip'] %}{% if ip['library'] == "user" %}{{ ip['repo_name'] }}/{{ ip['name'] }}.xpr {% endif -%}{% endfor %}
IP_TARGET         := {{ fins['name'] }}.xpr
SIM_TARGET        := sim_results.txt
NETLIST_TARGET    := {{ fins['name'] }}_netlist.edif

.PHONY: all clean clean-all sim

all: $(IP_TARGET)

clean:
	rm -rf $(TEMP_FILES) $(FINS_FILES)

clean-all:
{% for ip in fins['ip'] -%}
{% if ip['library'] == "user" %}	make -C {{ ip['repo_name'] }} $@
{% endif -%}
{% endfor %}	rm -rf $(TEMP_FILES) $(FINS_FILES)

sim: $(SIM_TARGET)

netlist: $(NETLIST_TARGET)

$(IP_TARGET) : $(SOURCE_FILES) $(SIM_FILES) $(CONSTRAINTS_FILES) $(USER_IP_TARGETS)
	vivado -mode batch -source ./fins/xilinx/ip_create.tcl >> ip_create.log 2>&1

$(SIM_TARGET) : $(IP_TARGET)
	{% if 'modeling_tool' in fins -%}
	{% if 'matlab' in fins['modeling_tool'] -%}
	matlab -nosplash -nodesktop -r "sim_setup;exit" >> ip_simulate.log 2>&1
	{%- else -%}
	octave sim_setup.m >> ip_simulate.log 2>&1
	{%- endif %}
	{%- endif %}
	vivado -mode batch -source ./fins/xilinx/ip_simulate.tcl >> ip_simulate.log 2>&1
	{% if 'modeling_tool' in fins -%}
	{% if 'matlab' in fins['modeling_tool'] -%}
	matlab -nosplash -nodesktop -r "sim_verify;exit" >> ip_simulate.log 2>&1
	{%- else -%}
	octave sim_verify.m >> ip_simulate.log 2>&1
	{%- endif %}
	{%- endif %}

$(NETLIST_TARGET) : $(IP_TARGET)
	vivado -mode batch -source ./fins/xilinx/ip_netlist.tcl >> ip_netlist.log 2>&1
	rm -rf {{ fins['name'] }}_netlist
	find . -name "*.edif" ! -name "$@" -delete
	find . -name "*.edn" ! -name "$@" -delete

{% for ip in fins['ip'] %}
{% if ip['library'] == "user" %}
{{ ip['repo_name'] }}/{{ ip['name'] }}.xpr :
	make -C {{ ip['repo_name'] }} all
{% endif -%}
{% endfor %}
