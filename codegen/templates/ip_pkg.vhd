--==============================================================================
-- Company:     Geon Technologies, LLC
-- File:        {{ json_params['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}_pkg.vhd
-- Description: Auto-generated from Jinja2 VHDL package template
-- Generated:   {{ now }}
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Package
package {{ json_params['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}_pkg is

-- Parameters
{% for param in json_params['params'] -%}
{% if "hdl" in param['used_in'] -%}
{% if param['type'] == "code" -%} {{ param['value'] }}
{% else -%} constant {{ param['name'] }} : {{ param['type'] }} :=
{%- if param['value'] is iterable and param['value'] is not string %} ({{ param['value']|join(', ') }});
{% elif param['type'] == "string" %} "{{ param['value'] }}";
{% else %} {{ param['value'] }};
{% endif -%}
{% endif -%}
{% endif -%}
{% endfor %}

end {{ json_params['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}_pkg;
