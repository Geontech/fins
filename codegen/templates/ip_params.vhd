--==============================================================================
-- Company:     Geon Technologies, LLC
-- File:        {{ fins['name'] }}_params.vhd
-- Description: Auto-generated from Jinja2 VHDL package template
-- Generated:   {{ now }}
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- User Libraries
{% if 'packages' in fins -%}
library work;
{% for pkg in fins['packages'] -%}
use work.{{ pkg }}.all;
{% endfor %}
{% endif %}

-- Package
package {{ fins['name'] }}_params is

-- Parameters
{% for param in fins['params'] -%}
{%- if 'range' in param and 'sub_type' in parm %}
type {{ param['hdl_type'] }} is array ({{ param['range'][0] }} to {{ param['range'][1] }}) of {{ param['sub_type'] }};
{% end if -%}
constant {{ param['name'] }} :
{%- if param['value'] is iterable and param['value'] is not string %} {{ param['hdl_type'] }} := ({{ param['value']|join(', ') }});
{% elif 'hdl_type' in param %} {{ param['hdl_type'] }} := {{ param['value'] }};
{% elif param['value'] is string %} string := "{{ param['value'] }}";
{% elif param['value'] is sameas true or param['value'] is sameas false %} boolean := {{ param['value']|lower }};
{% else %} integer := {{ param['value'] }};
{% endif -%}
{% endfor %}

end {{ fins['name'] }}_params;
