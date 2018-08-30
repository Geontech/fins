--==============================================================================
-- Company:     Geon Technologies, LLC
-- Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this 
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: Auto-generated parameter package file
-- Generated:   {{ now }}
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Package
package {{ fins['name'] }}_params is

-- Parameters
{% for param in fins['params'] -%}
{%- if param['value'] is iterable and param['value'] is not string and not 'hdl_type' in param %}
type t_{{ param['name'] }} is array (0 to {{ param['value']|length-1 }}) of integer;
{% endif -%}
constant {{ param['name'] }} :
{%- if param['value'] is iterable and param['value'] is not string %} t_{{ param['name'] }} := ({{ param['value']|join(', ') }});
{% elif 'hdl_type' in param %} {{ param['hdl_type'] }} := {{ param['value'] }};
{% elif param['value'] is string %} string := "{{ param['value'] }}";
{% elif param['value'] is sameas true or param['value'] is sameas false %} boolean := {{ param['value']|lower }};
{% else %} integer := {{ param['value'] }};
{% endif -%}
{% endfor %}

end {{ fins['name'] }}_params;
