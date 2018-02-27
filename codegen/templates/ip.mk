#===============================================================================
# Company:     Geon Technologies, LLC
# File:        ip.mk
# Description: Auto-generated from Jinja2 IP Parameters Makefile Template
# Generated:   {{ now }}
#===============================================================================

# File Lists
PARAM_FILES       := ip_params.tcl ip_params.m ip_override.json {{ json_params['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}_pkg.vhd {{ json_params['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}_streams.vhd
TEMP_FILES        := {{ json_params['filesets']['temp']|join(' ') }}
SOURCE_FILES      := {{ json_params['filesets']['source']|join(' ') }}
SIM_FILES         := {{ json_params['filesets']['sim']|join(' ') }}
CONSTRAINTS_FILES := {{ json_params['filesets']['constraints']|join(' ') }}
USER_IP_TARGETS   := {% for ip in json_params['ip'] %}{% if ip['library'] == "user" %}{{ ip['repo_name'] }}/{{ ip['name'] }}.xpr {% endif -%}{% endfor %}
IP_TARGET         := {{ json_params['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}.xpr
SIM_TARGET        := sim_results.txt
NETLIST_TARGET    := {{ json_params['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}_netlist.edif

.PHONY: all clean clean-ip sim

all: $(IP_TARGET)

clean:
	rm -rf $(TEMP_FILES) $(PARAM_FILES)

clean-ip: clean
{% for ip in json_params['ip'] -%}
{% if ip['library'] == "user" %}	make -C {{ ip['repo_name'] }} $@
{% endif -%}
{% endfor %}

sim: $(SIM_TARGET)

netlist: $(NETLIST_TARGET)

$(IP_TARGET) : $(SOURCE_FILES) $(SIM_FILES) $(CONSTRAINTS_FILES) $(USER_IP_TARGETS)
	vivado -mode batch -source ./repos/fins/xilinx/ip_create.tcl >> ip_create.log 2>&1

$(SIM_TARGET) : $(IP_TARGET)
	octave sim_setup.m >> ip_simulate.log 2>&1
	vivado -mode batch -source ./repos/fins/xilinx/ip_simulate.tcl >> ip_simulate.log 2>&1
	octave sim_verify.m >> ip_simulate.log 2>&1

$(NETLIST_TARGET) : $(IP_TARGET)
	vivado -mode batch -source ./repos/fins/xilinx/ip_netlist.tcl >> ip_netlist.log 2>&1
	rm -rf {{ json_params['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}_netlist
	find . -name "*.edif" ! -name "$@" -delete
	find . -name "*.edn" ! -name "$@" -delete

{% for ip in json_params['ip'] %}
{% if ip['library'] == "user" %}
{{ ip['repo_name'] }}/{{ ip['name'] }}.xpr :
	make -C {{ ip['repo_name'] }} all
{% endif -%}
{% endfor %}
