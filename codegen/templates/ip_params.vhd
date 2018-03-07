--==============================================================================
-- Company:     Geon Technologies, LLC
-- File:        {{ fins['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}_params.vhd
-- Description: Auto-generated from Jinja2 VHDL package template
-- Generated:   {{ now }}
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- User Libraries
library work;
{% for param in fins['params'] -%}
{% if "hdl" in param['used_in'] -%}
{% if param['type'] == "package" -%}
use work.{{ param['value'] }}.all;
{% endif -%}
{% endif -%}
{% endfor %}

-- Package
package {{ fins['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}_params is

-- Parameters
{% for param in fins['params'] -%}
{% if "hdl" in param['used_in'] -%}
{% if param['type'] != "package" -%}
{% if param['type'] == "code" -%} {{ param['value'] }}
{% else -%} constant {{ param['name'] }} : {{ param['type'] }} :=
{%- if param['value'] is iterable and param['value'] is not string %} ({{ param['value']|join(', ') }});
{% elif param['value'] is string %} "{{ param['value'] }}";
{% else %} {{ param['value']|lower }};
{% endif -%}
{% endif -%}
{% endif -%}
{% endif -%}
{% endfor %}

end {{ fins['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}_params;
