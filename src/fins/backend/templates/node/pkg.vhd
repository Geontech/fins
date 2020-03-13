{#-
--
-- Copyright (C) 2019 Geon Technologies, LLC
--
-- This file is part of FINS.
--
-- FINS is free software: you can redistribute it and/or modify it under the
-- terms of the GNU Lesser General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option)
-- any later version.
--
-- FINS is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
-- more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see http://www.gnu.org/licenses/.
--
-#}
--==============================================================================
-- Firmware IP Node Specification (FINS) Auto-Generated File
-- ---------------------------------------------------------
-- Template:    pkg.vhd
-- Backend:     {{ fins['backend'] }}
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: VHDL package file for definition of FINS parameters, ports,
--              and properties
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Package
package {{ fins['name']|lower }}_pkg is

--------------------------------------------------------------------------------
-- Parameters
--------------------------------------------------------------------------------
constant FINS_BACKEND : string := "{{ fins['backend'] }}";
{% if 'params' in fins %}
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
{% endif %}

{%- if 'properties' in fins %}
--------------------------------------------------------------------------------
-- Properties
--------------------------------------------------------------------------------
-- Notes:
-- 1. 'read-only-constant' and 'read-write-internal' property types do not have
--    records
-- 2. There are two records for each property: an interface record and the
--    top-level record for the property. These records are only different if
--    they are a sequence that is not memory mapped. Otherwise, the top-level
--    record for the property is a subtype of the interface record.
-- 3. A sequence property has a 'length' > 0. If the sequence property is
--    memory mapped, then the property does not have an array of records, and
--    instead translates the different items in the sequence using the
--    addresses (wr_addr & rd_addr).

{%- for prop in fins['properties']['properties'] %}
{#### Only create the control record for this property if the register type permits ####}
{%- if (prop['type'] == 'read-only-external') or (prop['type'] == 'read-only-memmap') or (prop['type'] == 'write-only-external') or (prop['type'] == 'write-only-memmap') or (prop['type'] == 'read-write-data') or (prop['type'] == 'read-write-external') or (prop['type'] == 'read-write-memmap') %}
-- {{ prop['name'] }} CONTROL Records
type t_{{ fins['name']|lower }}_{{ prop['name'] }}_control_interface is record
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
end record t_{{ fins['name']|lower }}_{{ prop['name'] }}_control_interface;
{%- if (prop['length'] > 1) and (not 'memmap' in prop['type']) %}
type t_{{ fins['name']|lower }}_{{ prop['name'] }}_control is array (0 to {{ prop['length'] }}-1) of t_{{ fins['name']|lower }}_{{ prop['name'] }}_control_interface;
{%- else %}
subtype t_{{ fins['name']|lower }}_{{ prop['name'] }}_control is t_{{ fins['name']|lower }}_{{ prop['name'] }}_control_interface;
{%- endif %}
{%- endif %}

{#### Only create the status record for this property if the register type permits ####}
{%- if (prop['type'] == 'read-only-data') or (prop['type'] == 'read-only-external') or (prop['type'] == 'read-only-memmap') or (prop['type'] == 'read-write-external') or (prop['type'] == 'read-write-memmap') %}
-- {{ prop['name'] }} STATUS records
type t_{{ fins['name']|lower }}_{{ prop['name'] }}_status_interface is record
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
end record t_{{ fins['name']|lower }}_{{ prop['name'] }}_status_interface;
{%- if (prop['length'] > 1) and (not 'memmap' in prop['type']) %}
type t_{{ fins['name']|lower }}_{{ prop['name'] }}_status is array (0 to {{ prop['length'] }}-1) of t_{{ fins['name']|lower }}_{{ prop['name'] }}_status_interface;
{%- else %}
subtype t_{{ fins['name']|lower }}_{{ prop['name'] }}_status is t_{{ fins['name']|lower }}_{{ prop['name'] }}_status_interface;
{%- endif %}
{%- endif %}

{%- endfor %}{#### for prop in fins['properties']['properties'] ####}

-- Top Level Properties CONTROL Record
type t_{{ fins['name']|lower }}_props_control is record
  clk    : std_logic;
  resetn : std_logic;
{%- for prop in fins['properties']['properties'] %}
{%- if (prop['type'] == 'read-only-external') or
       (prop['type'] == 'read-only-memmap') or
       (prop['type'] == 'write-only-external') or
       (prop['type'] == 'write-only-memmap') or
       (prop['type'] == 'read-write-data') or
       (prop['type'] == 'read-write-external') or
       (prop['type'] == 'read-write-memmap') %}
  {{ prop['name'] }} : t_{{ fins['name']|lower }}_{{ prop['name'] }}_control;
{%- else %}
  {{ prop['name'] }} : boolean; -- Null placeholder
{%- endif %}
{%- endfor %}
end record t_{{ fins['name']|lower }}_props_control;

-- Top Level Properties STATUS Record
type t_{{ fins['name']|lower }}_props_status is record
{%- for prop in fins['properties']['properties'] %}
{%- if (prop['type'] == 'read-only-data') or
       (prop['type'] == 'read-only-external') or
       (prop['type'] == 'read-only-memmap') or
       (prop['type'] == 'read-write-external') or
       (prop['type'] == 'read-write-memmap') %}
  {{ prop['name'] }} : t_{{ fins['name']|lower }}_{{ prop['name'] }}_status;
{%- else %}
  {{ prop['name'] }} : boolean; -- Null placeholder
{%- endif %}
{%- endfor %}
end record t_{{ fins['name']|lower }}_props_status;

{%- endif %}{#### if 'properties' in fins ####}

{%- if 'ports' in fins %}
--------------------------------------------------------------------------------
-- Ports
--------------------------------------------------------------------------------
{%- if 'ports' in fins['ports'] %}
{%- for port in fins['ports']['ports'] %}
-- {{ port['name']|lower }} DATA Records/Functions
{%- if port['data']['is_complex'] %}
type t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data_interface is record
  i : {% if port['data']['is_signed'] %}signed{% else %}unsigned{% endif %}({{ port['data']['bit_width']//2 }}-1 downto 0);
  q : {% if port['data']['is_signed'] %}signed{% else %}unsigned{% endif %}({{ port['data']['bit_width']//2 }}-1 downto 0);
end record t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data_interface;
{%- else %}
subtype t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data_interface is {% if port['data']['is_signed'] %}signed{% else %}unsigned{% endif %}({{ port['data']['bit_width'] }}-1 downto 0);
{%- endif %}
{%- if port['data']['num_samples'] > 1 %}
type t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data_samples is array (0 to {{ port['data']['num_samples'] }}-1) of t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data_interface;
{%- else %}
subtype t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data_samples is t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data_interface;
{%- endif %}
{%- if port['data']['num_channels'] > 1 %}
type t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data is array (0 to {{ port['data']['num_channels'] }}-1) of t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data_samples;
{%- else %}
subtype t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data is t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data_samples;
{%- endif %}
function f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data (data : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data) return std_logic_vector;
function f_unserialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data (data : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0)) return t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data;
{%- if 'metadata' in port %}
-- {{ port['name']|lower }} METADATA Records/Functions
{%- for metafield in port['metadata'] %}
{%- if metafield['is_complex'] %}
type t_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata_{{ metafield['name'] }} is record
  i : {% if metafield['is_signed'] %}signed{% else %}unsigned{% endif %}({{ metafield['bit_width']//2 }}-1 downto 0);
  q : {% if metafield['is_signed'] %}signed{% else %}unsigned{% endif %}({{ metafield['bit_width']//2 }}-1 downto 0);
end record t_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata_{{ metafield['name'] }};
{%- else %}
subtype t_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata_{{ metafield['name'] }} is {% if metafield['is_signed'] %}signed{% else %}unsigned{% endif %}({{ metafield['bit_width'] }}-1 downto 0);
{%- endif %}
{%- endfor %}
type t_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata is record
  {%- for metafield in port['metadata'] %}
  {{ metafield['name'] }} : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata_{{ metafield['name'] }};
  {%- endfor %}
end record t_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata;
function f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata (metadata : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata) return std_logic_vector;
function f_unserialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata (metadata : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0)) return t_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata;
{%- endif %}
-- {{ port['name']|lower }} Records
type t_{{ fins['name']|lower }}_{{ port['name']|lower }}_forward_unit is record
  {%- if port['direction']|lower == 'in' %}
  clk      : std_logic;
  resetn   : std_logic;
  {%- endif %}
  data     : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data;
  {%- if 'metadata' in port %}
  metadata : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata;
  {%- endif %}
  valid    : std_logic;
  last     : std_logic;
end record t_{{ fins['name']|lower }}_{{ port['name']|lower }}_forward_unit;
{%- if port['supports_backpressure'] or (port['direction']|lower == 'out') %}
type t_{{ fins['name']|lower }}_{{ port['name']|lower }}_backward_unit is record
  {%- if port['direction']|lower == 'out' %}
  clk    : std_logic;
  resetn : std_logic;
  {%- endif %}
  {%- if port['supports_backpressure'] %}
  ready  : std_logic;
  {%- endif %}
end record t_{{ fins['name']|lower }}_{{ port['name']|lower }}_backward_unit;
{%- endif %}
{%- if port['num_instances'] > 1 %}
type t_{{ fins['name']|lower }}_{{ port['name']|lower }}_forward is array(0 to {{ port['num_instances'] }}-1) of t_{{ fins['name']|lower }}_{{ port['name']|lower }}_forward_unit;
{%- if port['supports_backpressure'] or (port['direction']|lower == 'out') %}
type t_{{ fins['name']|lower }}_{{ port['name']|lower }}_backward is array(0 to {{ port['num_instances'] }}-1) of t_{{ fins['name']|lower }}_{{ port['name']|lower }}_backward_unit;
{%- endif %}
{%- else %}
subtype t_{{ fins['name']|lower }}_{{ port['name']|lower }}_forward is t_{{ fins['name']|lower }}_{{ port['name']|lower }}_forward_unit;
{%- if port['supports_backpressure'] or (port['direction']|lower == 'out') %}
subtype t_{{ fins['name']|lower }}_{{ port['name']|lower }}_backward is t_{{ fins['name']|lower }}_{{ port['name']|lower }}_backward_unit;
{%- endif %}
{%- endif %}

{%- endfor %}{#### for port in fins['ports']['ports'] ####}

-- Top Level Ports PORTS_IN Record
type t_{{ fins['name']|lower }}_ports_in is record
  {%- for port in fins['ports']['ports'] %}
  {%- if port['direction']|lower == 'in' %}
  {{ port['name']|lower }} : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_forward;
  {%- else %}
  {{ port['name']|lower }} : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_backward;
  {%- endif %}
  {%- endfor %}
end record t_{{ fins['name']|lower }}_ports_in;

-- Top Level Ports PORTS_OUT Record
type t_{{ fins['name']|lower }}_ports_out is record
  {%- for port in fins['ports']['ports'] %}
  {%- if port['direction']|lower == 'out' %}
  {{ port['name']|lower }} : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_forward;
  {%- elif port['supports_backpressure'] %}
  {{ port['name']|lower }} : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_backward;
  {%- else %}
  {{ port['name']|lower }} : boolean; -- Null placeholder
  {%- endif %}
  {%- endfor %}
end record t_{{ fins['name']|lower }}_ports_out;

{%- endif %}{#### if 'ports' in fins['ports'] ####}

{%- if 'hdl' in fins['ports'] %}
-- Top Level Ports PORTS_HDL_IN Record
type t_{{ fins['name']|lower }}_ports_hdl_in is record
  {%- for port_hdl in fins['ports']['hdl'] %}
  {%- if port_hdl['direction']|lower == 'in' %}
  {{ port_hdl['name']|lower }} : std_logic{% if port_hdl['bit_width'] > 1 %}_vector({{ port_hdl['bit_width'] }}-1 downto 0){% endif %};
  {%- else %}
  {{ port_hdl['name']|lower }} : boolean; -- Null placeholder
  {%- endif %}
  {%- endfor %}
end record t_{{ fins['name']|lower }}_ports_hdl_in;

-- Top Level Ports PORTS_HDL_OUT Record
type t_{{ fins['name']|lower }}_ports_hdl_out is record
  {%- for port_hdl in fins['ports']['hdl'] %}
  {%- if port_hdl['direction']|lower == 'out' %}
  {{ port_hdl['name']|lower }} : std_logic{% if port_hdl['bit_width'] > 1 %}_vector({{ port_hdl['bit_width'] }}-1 downto 0){% endif %};
  {%- else %}
  {{ port_hdl['name']|lower }} : boolean; -- Null placeholder
  {%- endif %}
  {%- endfor %}
end record t_{{ fins['name']|lower }}_ports_hdl_out;
{%- endif %}{#### if 'hdl' in fins['ports'] ####}

{%- endif %}{#### if 'ports' in fins ####}

end {{ fins['name']|lower }}_pkg;

package body {{ fins['name']|lower }}_pkg is

  {%- if 'ports' in fins %}
  {%- if 'ports' in fins['ports'] %}
  {%- for port in fins['ports']['ports'] %}
  -- {{ port['name']|lower }} DATA Functions
  function f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data (
    data : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data
  ) return std_logic_vector is
  begin
    {%- if (port['data']['num_channels'] > 1) and (port['data']['num_samples'] > 1) %}
    return
      {%- for channel in range(port['data']['num_channels']-1,-1,-1) %}
      {%- set outer_loop = loop %}
      {%- for sample in range(port['data']['num_samples']-1,-1,-1) %}
      {%- if port['data']['is_complex'] %}
      std_logic_vector(data({{ channel }})({{ sample }}).q) &
      std_logic_vector(data({{ channel }})({{ sample }}).i){% if loop.last and outer_loop.last %};{% else %} &{% endif %}
      {%- else %}
      std_logic_vector(data({{ channel }})({{ sample }})){% if loop.last and outer_loop.last %};{% else %} &{% endif %}
      {%- endif %}
      {%- endfor %}
      {%- endfor %}
    {%- elif (port['data']['num_channels'] > 1) %}
    return
      {%- for channel in range(port['data']['num_channels']-1,-1,-1) %}
      {%- if port['data']['is_complex'] %}
      std_logic_vector(data({{ channel }}).q) &
      std_logic_vector(data({{ channel }}).i){% if loop.last %};{% else %} &{% endif %}
      {%- else %}
      std_logic_vector(data({{ channel }})){% if loop.last %};{% else %} &{% endif %}
      {%- endif %}
      {%- endfor %}
    {%- elif (port['data']['num_samples'] > 1) %}
    return
      {%- for sample in range(port['data']['num_samples']-1,-1,-1) %}
      {%- if port['data']['is_complex'] %}
      std_logic_vector(data({{ sample }}).q) &
      std_logic_vector(data({{ sample }}).i){% if loop.last %};{% else %} &{% endif %}
      {%- else %}
      std_logic_vector(data({{ sample }})){% if loop.last %};{% else %} &{% endif %}
      {%- endif %}
      {%- endfor %}
    {%- else %}
    return
      {%- if port['data']['is_complex'] %}
      std_logic_vector(data.q) &
      std_logic_vector(data.i);
      {%- else %}
      std_logic_vector(data);
      {%- endif %}
    {%- endif %}
  end function f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data;
  function f_unserialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data (
    data : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0)
  ) return t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data is
    variable result : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_data;
  begin
    {%- if (port['data']['num_channels'] > 1) and (port['data']['num_samples'] > 1) %}
      {%- for channel in range(port['data']['num_channels']) %}
      {%- set outer_loop = loop %}
      {%- for sample in range(port['data']['num_samples']) %}
      {%- if port['data']['is_complex'] %}
      {%- if port['data']['is_signed'] %}
      result({{ channel }})({{ sample }}).i :=   signed(data({{ (channel*port['data']['num_samples']+sample)*port['data']['bit_width']+port['data']['bit_width']//2-1 }} downto {{ (channel*port['data']['num_samples']+sample)*port['data']['bit_width'] }}));
      result({{ channel }})({{ sample }}).q :=   signed(data({{ (channel*port['data']['num_samples']+sample)*port['data']['bit_width']+port['data']['bit_width']   -1 }} downto {{ (channel*port['data']['num_samples']+sample)*port['data']['bit_width']+port['data']['bit_width']//2 }}));
      {%- else %}
      result({{ channel }})({{ sample }}).i := unsigned(data({{ (channel*port['data']['num_samples']+sample)*port['data']['bit_width']+port['data']['bit_width']//2-1 }} downto {{ (channel*port['data']['num_samples']+sample)*port['data']['bit_width'] }}));
      result({{ channel }})({{ sample }}).q := unsigned(data({{ (channel*port['data']['num_samples']+sample)*port['data']['bit_width']+port['data']['bit_width']   -1 }} downto {{ (channel*port['data']['num_samples']+sample)*port['data']['bit_width']+port['data']['bit_width']//2 }}));
      {%- endif %}
      {%- else %}
      {%- if port['data']['is_signed'] %}
      result({{ channel }})({{ sample }}) :=   signed(data({{ (channel*port['data']['num_samples']+sample+1)*port['data']['bit_width']-1 }} downto {{ (channel*port['data']['num_samples']+sample)*port['data']['bit_width'] }}));
      {%- else %}
      result({{ channel }})({{ sample }}) := unsigned(data({{ (channel*port['data']['num_samples']+sample+1)*port['data']['bit_width']-1 }} downto {{ (channel*port['data']['num_samples']+sample)*port['data']['bit_width'] }}));
      {%- endif %}
      {%- endif %}
      {%- endfor %}
      {%- endfor %}
    {%- elif (port['data']['num_channels'] > 1) %}
      {%- for channel in range(port['data']['num_channels']) %}
      {%- if port['data']['is_complex'] %}
      {%- if port['data']['is_signed'] %}
      result({{ channel }}).i :=   signed(data({{ (channel*port['data']['bit_width'])+port['data']['bit_width']//2-1 }} downto {{ (channel*port['data']['bit_width']) }}));
      result({{ channel }}).q :=   signed(data({{ (channel*port['data']['bit_width'])+port['data']['bit_width']   -1 }} downto {{ (channel*port['data']['bit_width'])+port['data']['bit_width']//2 }}));
      {%- else %}
      result({{ channel }}).i := unsigned(data({{ (channel*port['data']['bit_width'])+port['data']['bit_width']//2-1 }} downto {{ (channel*port['data']['bit_width']) }}));
      result({{ channel }}).q := unsigned(data({{ (channel*port['data']['bit_width'])+port['data']['bit_width']   -1 }} downto {{ (channel*port['data']['bit_width'])+port['data']['bit_width']//2 }}));
      {%- endif %}
      {%- else %}
      {%- if port['data']['is_signed'] %}
      result({{ channel }}) :=   signed(data({{ (channel+1)*port['data']['bit_width']-1 }} downto {{ channel*port['data']['bit_width'] }}));
      {%- else %}
      result({{ channel }}) := unsigned(data({{ (channel+1)*port['data']['bit_width']-1 }} downto {{ channel*port['data']['bit_width'] }}));
      {%- endif %}
      {%- endif %}
      {%- endfor %}
    {%- elif (port['data']['num_samples'] > 1) %}
      {%- for sample in range(port['data']['num_samples']) %}
      {%- if port['data']['is_complex'] %}
      {%- if port['data']['is_signed'] %}
      result({{ sample }}).i :=   signed(data({{ (sample*port['data']['bit_width'])+port['data']['bit_width']//2-1 }} downto {{ (sample*port['data']['bit_width']) }}));
      result({{ sample }}).q :=   signed(data({{ (sample*port['data']['bit_width'])+port['data']['bit_width']   -1 }} downto {{ (sample*port['data']['bit_width'])+port['data']['bit_width']//2 }}));
      {%- else %}
      result({{ sample }}).i := unsigned(data({{ (sample*port['data']['bit_width'])+port['data']['bit_width']//2-1 }} downto {{ (sample*port['data']['bit_width']) }}));
      result({{ sample }}).q := unsigned(data({{ (sample*port['data']['bit_width'])+port['data']['bit_width']   -1 }} downto {{ (sample*port['data']['bit_width'])+port['data']['bit_width']//2 }}));
      {%- endif %}
      {%- else %}
      {%- if port['data']['is_signed'] %}
      result({{ sample }}) :=   signed(data({{ (sample+1)*port['data']['bit_width']-1 }} downto {{ sample*port['data']['bit_width'] }}));
      {%- else %}
      result({{ sample }}) := unsigned(data({{ (sample+1)*port['data']['bit_width']-1 }} downto {{ sample*port['data']['bit_width'] }}));
      {%- endif %}
      {%- endif %}
      {%- endfor %}
    {%- else %}
      {%- if port['data']['is_complex'] %}
      {%- if port['data']['is_signed'] %}
      result.i :=   signed(data({{ port['data']['bit_width']//2-1 }} downto 0));
      result.q :=   signed(data({{ port['data']['bit_width']   -1 }} downto {{ port['data']['bit_width']//2 }}));
      {%- else %}
      result.i := unsigned(data({{ port['data']['bit_width']//2-1 }} downto 0));
      result.q := unsigned(data({{ port['data']['bit_width']   -1 }} downto {{ port['data']['bit_width']//2 }}));
      {%- endif %}
      {%- else %}
      {%- if port['data']['is_signed'] %}
      result :=   signed(data);
      {%- else %}
      result := unsigned(data);
      {%- endif %}
      {%- endif %}
    {%- endif %}
    return result;
  end function f_unserialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data;
  {%- if 'metadata' in port %}
  -- {{ port['name']|lower }} METADATA Functions
  function f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata (
    metadata : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata
  ) return std_logic_vector is
  begin
    return
      {%- for metafield in port['metadata']|reverse %}
      {%- if metafield['is_complex'] %}
      std_logic_vector(metadata.{{ metafield['name'] }}.q) &
      std_logic_vector(metadata.{{ metafield['name'] }}.i){% if loop.last %};{% else %} &{% endif %}
      {%- else %}
      std_logic_vector(metadata.{{ metafield['name'] }}){% if loop.last %};{% else %} &{% endif %}
      {%- endif %}
      {%- endfor %}
  end function f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata;
  function f_unserialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata (
    metadata : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0)
  ) return t_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata is
    variable result : t_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata;
  begin
    {%- for metafield in port['metadata'] %}
    {%- if metafield['is_complex'] %}
    {%- if metafield['is_signed'] %}
    result.{{ metafield['name'] }}.i :=   signed(metadata({{ metafield['offset']+metafield['bit_width']//2-1 }} downto {{ metafield['offset'] }});
    result.{{ metafield['name'] }}.q :=   signed(metadata({{ metafield['offset']+metafield['bit_width']   -1 }} downto {{ metafield['offset']+metafield['bit_width']//2 }});
    {%- else %}
    result.{{ metafield['name'] }}.i := unsigned(metadata({{ metafield['offset']+metafield['bit_width']//2-1 }} downto {{ metafield['offset'] }});
    result.{{ metafield['name'] }}.q := unsigned(metadata({{ metafield['offset']+metafield['bit_width']   -1 }} downto {{ metafield['offset']+metafield['bit_width']//2 }});
    {%- endif %}
    {%- else %}
    {%- if metafield['is_signed'] %}
    result.{{ metafield['name'] }} :=   signed(metadata({{ metafield['offset']+metafield['bit_width']-1 }} downto {{ metafield['offset'] }}));
    {%- else %}
    result.{{ metafield['name'] }} := unsigned(metadata({{ metafield['offset']+metafield['bit_width']-1 }} downto {{ metafield['offset'] }}));
    {%- endif %}
    {%- endif %}
    {%- endfor %}
    return result;
  end function f_unserialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata;
  {%- endif %}
  {%- endfor %}{#### for port in fins['ports']['ports'] ####}
  {%- endif %}{#### if 'ports' in fins['ports'] ####}
  {%- endif %}{#### if 'ports' in fins ####}

end package body {{ fins['name']|lower }}_pkg;
