#===============================================================================
# Company:     Geon Technologies, LLC
# File:        ip.mk
# Description: Auto-generated from Jinja2 IP Parameters Makefile Template
# Generated:   {{ now }}
#===============================================================================

# Variables
IP_NAME := {{ fins['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}

# File Lists
FINS_FILES        := ip_params.tcl ip_params.m fins_edit.json $(IP_NAME)_params.vhd $(IP_NAME)_streams.vhd $(IP_NAME)_regs.vhd 
TEMP_FILES        := {{ fins['filesets']['temp']|join(' ') }}
SOURCE_FILES      := {{ fins['filesets']['source']|join(' ') }}
SIM_FILES         := {{ fins['filesets']['sim']|join(' ') }}
CONSTRAINTS_FILES := {{ fins['filesets']['constraints']|join(' ') }}
USER_IP_TARGETS   := {% for ip in fins['ip'] %}{% if ip['library'] == "user" %}{{ ip['repo_name'] }}/{{ ip['name'] }}.xpr {% endif -%}{% endfor %}
IP_TARGET         := $(IP_NAME).xpr
SIM_TARGET        := sim_results.txt
NETLIST_TARGET    := $(IP_NAME)_netlist.edif

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
	octave sim_setup.m >> ip_simulate.log 2>&1
	vivado -mode batch -source ./fins/xilinx/ip_simulate.tcl >> ip_simulate.log 2>&1
	octave sim_verify.m >> ip_simulate.log 2>&1

$(NETLIST_TARGET) : $(IP_TARGET)
	vivado -mode batch -source ./fins/xilinx/ip_netlist.tcl >> ip_netlist.log 2>&1
	rm -rf $(IP_NAME)_netlist
	find . -name "*.edif" ! -name "$@" -delete
	find . -name "*.edn" ! -name "$@" -delete

{% for ip in fins['ip'] %}
{% if ip['library'] == "user" %}
{{ ip['repo_name'] }}/{{ ip['name'] }}.xpr :
	make -C {{ ip['repo_name'] }} all
{% endif -%}
{% endfor %}
