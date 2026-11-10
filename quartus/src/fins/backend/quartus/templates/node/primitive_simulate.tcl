# FINS-generated direct ModelSim run script for a primitive HDL node.
set return_code 0
set FINS_BACKEND "{{ fins['backend'] }}"
{%- if 'params' in fins %}
{% for param in fins['params'] -%}
set {{ param['name'] }}{% if param['value'] is iterable and param['value'] is not string %} [list {{ param['value']|join(' ') }}]{% elif param['value'] is string %} "{{ param['value'] }}"{% else %} {{ param['value'] }}{% endif %}
{% endfor %}
{% endif %}
{%- for script in fins.get('filesets', {}).get('scripts', {}).get('presim', []) %}
{%- if script['type']|lower == 'tcl' %}
source ../../../{{ script['path'] }}
{%- endif %}
{%- endfor %}

# Suppress NUMERIC_STD metavalue warnings only while time-zero delta
# cycles initialize the primitive's internal pipelines.
set NumericStdNoWarnings 1
run 0 ns
set NumericStdNoWarnings 0

run -all

{%- for script in fins.get('filesets', {}).get('scripts', {}).get('postsim', []) %}
{%- if script['type']|lower == 'tcl' %}
source ../../../{{ script['path'] }}
{%- endif %}
{%- endfor %}

if {[catch {examine /{{ fins['top_sim'] }}/simulation_done} value]} {
    puts "ERROR: simulation_done signal not found"
    set return_code 1
} elseif {![string equal -nocase [string trim $value] "TRUE"]} {
    puts "***** SIMULATION FAILED *****"
    set return_code 1
} else {
    puts "***** SIMULATION PASSED *****"
}
exit -code $return_code
