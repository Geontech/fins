{#-
--
-- Copyright (C) 2020 Geon Technologies, LLC
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
--=============================================================================
-- Firmware IP Node Specification (FINS) Auto-Generated File
-- ---------------------------------------------------------
-- Template:    props_status_cdc.vhd
-- Backend:     {{ fins['backend'] }}
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: Clock Domain Crossings for FINS Status Properties
--              (a.k.a. firmware status registers available to software)
-- Reset Type:  Synchronous
-- Limitations: This module only implements Clock Domain Crossings for
--              Properties with type "read-only-data"
--=============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- User Libraries
library work;
use work.{{ fins['name']|lower }}_pkg.all;

-- Entity
entity {{ fins['name']|lower }}_props_status_cdc is
  port (
    {%- for prop in fins['properties']['properties'] %}
    {%- if (prop['type'] == 'read-only-data') %}
    {{ prop['name'] }}_clk : in  std_logic;
    {{ prop['name'] }}     : in  std_logic_vector({{ prop['length']*prop['width'] }}-1 downto 0);
    {%- endif %}
    {%- endfor %}{#### for prop in fins['properties']['properties'] ####}
    {%- for prop in fins['properties']['properties'] %}
    {%- if (prop['type'] == 'read-only-data') %}
    props_status_{{ prop['name'] }} : out t_{{ fins['name']|lower }}_{{ prop['name'] }}_status;
    {%- endif %}
    {%- endfor %}{#### for prop in fins['properties']['properties'] ####}
    props_control : in  t_{{ fins['name']|lower }}_props_control
  );
end {{ fins['name']|lower }}_props_status_cdc;

-- Architecture
architecture rtl of {{ fins['name']|lower }}_props_status_cdc is

  -- Signals for registering in sending clock domain before crossing clock domains
  {%- for prop in fins['properties']['properties'] %}
  {%- if (prop['type'] == 'read-only-data') %}
  signal cdc_{{ prop['name'] }}  : std_logic_vector({{ prop['length']*prop['width'] }}-1 downto 0);
  {%- endif %}
  {%- endfor %}{#### for prop in fins['properties']['properties'] ####}

  -- Double registers for metastability protection across clock domains
  {%- for prop in fins['properties']['properties'] %}
  {%- if (prop['type'] == 'read-only-data') %}
  signal cdc_{{ prop['name'] }}_q  : std_logic_vector({{ prop['length']*prop['width'] }}-1 downto 0);
  signal cdc_{{ prop['name'] }}_qq : std_logic_vector({{ prop['length']*prop['width'] }}-1 downto 0);
  {%- endif %}
  {%- endfor %}{#### for prop in fins['properties']['properties'] ####}

  -- Apply attribute to indicate that these registers are capable of receiving asynchronous data
  -- NOTE: This attribute applies to Xilinx synthesis only
  attribute async_reg : boolean;
  {%- for prop in fins['properties']['properties'] %}
  {%- if (prop['type'] == 'read-only-data') %}
  attribute async_reg of cdc_{{ prop['name'] }}_q  : signal is true;
  attribute async_reg of cdc_{{ prop['name'] }}_qq : signal is true;
  {%- endif %}
  {%- endfor %}{#### for prop in fins['properties']['properties'] ####}

begin
  {%- for prop in fins['properties']['properties'] %}
  {%- if (prop['type'] == 'read-only-data') %}

  -- Register in sending clock domain before crossing clock domains
  s_register_{{ prop['name'] }}_sender : process ({{ prop['name'] }}_clk)
  begin
    if (rising_edge({{ prop['name'] }}_clk)) then
      cdc_{{ prop['name'] }} <= {{ prop['name'] }};
    end if;
  end process s_register_{{ prop['name'] }}_sender;
  {%- endif %}
  {%- endfor %}{#### for prop in fins['properties']['properties'] ####}

  -- Double Register for metastability protection across clock domains
  s_cdc : process (props_control.clk)
  begin
    if (rising_edge(props_control.clk)) then
      {%- for prop in fins['properties']['properties'] %}
      {%- if (prop['type'] == 'read-only-data') %}
      cdc_{{ prop['name'] }}_q  <= cdc_{{ prop['name'] }};
      cdc_{{ prop['name'] }}_qq <= cdc_{{ prop['name'] }}_q;
      {%- endif %}
      {%- endfor %}{#### for prop in fins['properties']['properties'] ####}
    end if;
  end process s_cdc;

  -- Remap std_logic_vector to Property Record outputs
  {%- for prop in fins['properties']['properties'] %}
  {%- if (prop['type'] == 'read-only-data') %}
  {%- if (prop['length'] > 1) %}
  {%- for prop_index in range(prop['length']) %}
  props_status_{{ prop['name'] }}({{ prop_index }}).rd_data <= cdc_{{ prop['name'] }}_qq({{ (prop_index+1)*prop['width'] }}-1 downto {{ prop_index*prop['width'] }});
  {%- endfor %}{#### for prop_index in range(prop['length']) ####}
  {%- else %}
  props_status_{{ prop['name'] }}.rd_data <= cdc_{{ prop['name'] }}_qq;
  {%- endif %}
  {%- endif %}
  {%- endfor %}{#### for prop in fins['properties']['properties'] ####}

end rtl;
