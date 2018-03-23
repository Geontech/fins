#===============================================================================
# Company:     Geon Technologies, LLC
# File:        ip.mk
# Description: Auto-generated from Jinja2 IP Parameters Makefile Template
# Generated:   {{ now }}
#===============================================================================

# File Lists
FINS_FILES        := ip_params.tcl ip_import_user.tcl ip_params.m fins_edit.json {{ fins['name'] }}_params.vhd {{ fins['name'] }}_streams.vhd {{ fins['name'] }}_regs.vhd 
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
	{% if 'tools' in fins and 'sim' in fins['tools'] and 'matlab' in fins['tools']['sim'] -%}
	matlab -nosplash -nodesktop -r "sim_setup;exit" >> ip_simulate.log 2>&1
	{%- else -%}
	octave sim_setup.m >> ip_simulate.log 2>&1
	{%- endif %}
	vivado -mode batch -source ./fins/xilinx/ip_simulate.tcl >> ip_simulate.log 2>&1
	{% if 'tools' in fins and 'sim' in fins['tools'] and 'matlab' in fins['tools']['sim'] -%}
	matlab -nosplash -nodesktop -r "sim_verify;exit" >> ip_simulate.log 2>&1
	{%- else -%}
	octave sim_verify.m >> ip_simulate.log 2>&1
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
