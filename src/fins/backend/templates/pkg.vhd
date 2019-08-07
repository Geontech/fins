--==============================================================================
-- Company:     Geon Technologies, LLC
-- Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this 
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: Auto-generated VHDL package file
-- Generated:   {{ now }}
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Package
package {{ fins['name'] }}_pkg is
{%- if 'params' in fins %}
--------------------------------------------------------------------------------
-- Parameters
--------------------------------------------------------------------------------
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

{%- endif %}{#### if 'params' in fins ####}

{%- if 'properties' in fins %}
--------------------------------------------------------------------------------
-- Properties
--------------------------------------------------------------------------------
-- Records for each individual property
-- Notes: 1. 'read-only-constant' and 'read-write-internal' property types do
--           not have records
--        2. There are two records for each property: an interface record and
--           the top-level record for the property. These records are only
--           different if they are a sequence that is not memory mapped.
--           Otherwise, the top-level record for the property is a subtype of
--           the interface record.
--        3. A sequence property has a 'length' > 0. If the sequence property
--           is memory mapped, then the property does not have an array of
--           records, and instead translates the different items in the
--           sequence using the addresses (wr_addr & rd_addr).

{%- for prop in fins['properties']['properties'] %}
{#### Only create the control record for this property if the register type permits ####}
{%- if (prop['type'] == 'read-only-external') or (prop['type'] == 'read-only-memmap') or (prop['type'] == 'write-only-external') or (prop['type'] == 'write-only-memmap') or (prop['type'] == 'read-write-data') or (prop['type'] == 'read-write-external') or (prop['type'] == 'read-write-memmap') %}
-- {{ prop['name'] }} CONTROL Records
type t_{{ fins['name'] }}_{{ prop['name'] }}_control_interface is record
  {%- if prop['type'] == 'read-only-external' %}
  rd_en    : std_logic;
  {%- elif prop['type'] == 'read-only-memmap' %}
  rd_en    : std_logic;
  rd_addr  : std_logic_vector({% if prop['length'] > 1 %}integer(ceil(log2(real({{ prop['length'] }}))))-1{% else %}0{% endif %} downto 0);
  {%- elif prop['type'] == 'write-only-external' %}
  wr_data  : std_logic_vector({{ prop['width'] }}-1 downto 0);
  wr_en    : std_logic;
  {%- elif prop['type'] == 'write-only-memmap' %}
  wr_data  : std_logic_vector({{ prop['width'] }}-1 downto 0);
  wr_en    : std_logic;
  wr_addr  : std_logic_vector({% if prop['length'] > 1 %}integer(ceil(log2(real({{ prop['length'] }}))))-1{% else %}0{% endif %} downto 0);
  {%- elif prop['type'] == 'read-write-data' %}
  wr_data  : std_logic_vector({{ prop['width'] }}-1 downto 0);
  {%- elif prop['type'] == 'read-write-external' %}
  rd_en    : std_logic;
  wr_data  : std_logic_vector({{ prop['width'] }}-1 downto 0);
  wr_en    : std_logic;
  {%- elif prop['type'] == 'read-write-memmap' %}
  rd_en    : std_logic;
  rd_addr  : std_logic_vector({% if prop['length'] > 1 %}integer(ceil(log2(real({{ prop['length'] }}))))-1{% else %}0{% endif %} downto 0);
  wr_data  : std_logic_vector({{ prop['width'] }}-1 downto 0);
  wr_en    : std_logic;
  wr_addr  : std_logic_vector({% if prop['length'] > 1 %}integer(ceil(log2(real({{ prop['length'] }}))))-1{% else %}0{% endif %} downto 0);
  {%- endif %}
end record t_{{ fins['name'] }}_{{ prop['name'] }}_control_interface;
{%- if (prop['length'] > 1) and (not 'memmap' in prop['type']) %}
type t_{{ fins['name'] }}_{{ prop['name'] }}_control is array (0 to {{ prop['length'] }}-1) of t_{{ fins['name'] }}_{{ prop['name'] }}_control_interface;
{%- else %}
subtype t_{{ fins['name'] }}_{{ prop['name'] }}_control is t_{{ fins['name'] }}_{{ prop['name'] }}_control_interface;
{%- endif %}
{%- endif %}

{#### Only create the status record for this property if the register type permits ####}
{%- if (prop['type'] == 'read-only-data') or (prop['type'] == 'read-only-external') or (prop['type'] == 'read-only-memmap') or (prop['type'] == 'read-write-external') or (prop['type'] == 'read-write-memmap') %}
-- {{ prop['name'] }} STATUS records
type t_{{ fins['name'] }}_{{ prop['name'] }}_status_interface is record
  {%- if prop['type'] == 'read-only-data' %}
  rd_data : std_logic_vector({{ prop['width'] }}-1 downto 0);
  {%- elif prop['type'] == 'read-only-external' %}
  rd_data  : std_logic_vector({{ prop['width'] }}-1 downto 0);
  rd_valid : std_logic;
  {%- elif prop['type'] == 'read-only-memmap' %}
  rd_data  : std_logic_vector({{ prop['width'] }}-1 downto 0);
  rd_valid : std_logic;
  {%- elif prop['type'] == 'read-write-external' %}
  rd_data  : std_logic_vector({{ prop['width'] }}-1 downto 0);
  rd_valid : std_logic;
  {%- elif prop['type'] == 'read-write-memmap' %}
  rd_data  : std_logic_vector({{ prop['width'] }}-1 downto 0);
  rd_valid : std_logic;
  {%- endif %}
end record t_{{ fins['name'] }}_{{ prop['name'] }}_status_interface;
{%- if (prop['length'] > 1) and (not 'memmap' in prop['type']) %}
type t_{{ fins['name'] }}_{{ prop['name'] }}_status is array (0 to {{ prop['length'] }}-1) of t_{{ fins['name'] }}_{{ prop['name'] }}_status_interface;
{%- else %}
subtype t_{{ fins['name'] }}_{{ prop['name'] }}_status is t_{{ fins['name'] }}_{{ prop['name'] }}_status_interface;
{%- endif %}
{%- endif %}

{%- endfor %}{#### for prop in fins['properties']['properties'] ####}

-- Top Level Properties CONTROL Record
type t_{{ fins['name']|lower }}_props_control is record
{%- for prop in fins['properties']['properties'] %}
{%- if (prop['type'] == 'read-only-external') or (prop['type'] == 'read-only-memmap') or (prop['type'] == 'write-only-external') or (prop['type'] == 'write-only-memmap') or (prop['type'] == 'read-write-data') or (prop['type'] == 'read-write-external') or (prop['type'] == 'read-write-memmap') %}
  {{ prop['name'] }} : t_{{ fins['name'] }}_{{ prop['name'] }}_control;
{%- endif %}
{%- endfor %}
end record t_{{ fins['name']|lower }}_props_control;

-- Top Level Properties STATUS Record
type t_{{ fins['name']|lower }}_props_status is record
{%- for prop in fins['properties']['properties'] %}
{%- if (prop['type'] == 'read-only-data') or (prop['type'] == 'read-only-external') or (prop['type'] == 'read-only-memmap') or (prop['type'] == 'read-write-external') or (prop['type'] == 'read-write-memmap') %}
  {{ prop['name'] }} : t_{{ fins['name'] }}_{{ prop['name'] }}_status;
{%- endif %}
{%- endfor %}
end record t_{{ fins['name']|lower }}_props_status;

{%- endif %}{#### if 'properties' in fins ####}

end {{ fins['name'] }}_pkg;
