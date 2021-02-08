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
-- Template:    props_control_cdc.vhd
-- Backend:     {{ fins['backend'] }}
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: Clock Domain Crossings for FINS Control Properties
--              (a.k.a. software control of firmware)
-- Reset Type:  Synchronous
-- Limitations: This module only implements Clock Domain Crossings for
--              Properties with type "read-write-data"
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
entity {{ fins['name']|lower }}_props_control_cdc is
  port (
    clk : in  std_logic;
    {%- for prop in fins['properties']['properties'] %}
    {%- if (prop['type'] == 'read-write-data') %}
    {{ prop['name'] }} : out std_logic_vector({{ prop['length']*prop['width'] }}-1 downto 0);
    {%- endif %}
    {%- endfor %}{#### for prop in fins['properties']['properties'] ####}
    props_control : in  t_{{ fins['name']|lower }}_props_control
  );
end {{ fins['name']|lower }}_props_control_cdc;

-- Architecture
architecture rtl of {{ fins['name']|lower }}_props_control_cdc is

  -- Signals for mapping property records to std_logic_vectors
  {%- for prop in fins['properties']['properties'] %}
  {%- if (prop['type'] == 'read-write-data') %}
  signal cdc_{{ prop['name'] }}  : std_logic_vector({{ prop['length']*prop['width'] }}-1 downto 0);
  {%- endif %}
  {%- endfor %}{#### for prop in fins['properties']['properties'] ####}

  -- Double registers for metastability protection across clock domains
  {%- for prop in fins['properties']['properties'] %}
  {%- if (prop['type'] == 'read-write-data') %}
  signal cdc_{{ prop['name'] }}_q  : std_logic_vector({{ prop['length']*prop['width'] }}-1 downto 0);
  signal cdc_{{ prop['name'] }}_qq : std_logic_vector({{ prop['length']*prop['width'] }}-1 downto 0);
  {%- endif %}
  {%- endfor %}{#### for prop in fins['properties']['properties'] ####}

  -- Apply attribute to indicate that these registers are capable of receiving asynchronous data
  -- NOTE: This attribute applies to Xilinx synthesis only
  attribute async_reg : boolean;
  {%- for prop in fins['properties']['properties'] %}
  {%- if (prop['type'] == 'read-write-data') %}
  attribute async_reg of cdc_{{ prop['name'] }}_q  : signal is true;
  attribute async_reg of cdc_{{ prop['name'] }}_qq : signal is true;
  {%- endif %}
  {%- endfor %}{#### for prop in fins['properties']['properties'] ####}

begin

  -- Map Property Records to std_logic_vector
  {%- for prop in fins['properties']['properties'] %}
  {%- if (prop['type'] == 'read-write-data') %}
  {%- if (prop['length'] > 1) %}
  {%- for prop_index in range(prop['length']) %}
  cdc_{{ prop['name'] }}({{ (prop_index+1)*prop['width'] }}-1 downto {{ prop_index*prop['width'] }}) <= props_control.{{ prop['name'] }}({{ prop_index }}).wr_data;
  {%- endfor %}{#### for prop_index in range(prop['length']) ####}
  {%- else %}
  cdc_{{ prop['name'] }} <= props_control.{{ prop['name'] }}.wr_data;
  {%- endif %}
  {%- endif %}
  {%- endfor %}{#### for prop in fins['properties']['properties'] ####}

  -- Double Register for metastability protection across clock domains
  s_cdc : process (clk)
  begin
    if (rising_edge(clk)) then
      {%- for prop in fins['properties']['properties'] %}
      {%- if (prop['type'] == 'read-write-data') %}
      cdc_{{ prop['name'] }}_q  <= cdc_{{ prop['name'] }};
      cdc_{{ prop['name'] }}_qq <= cdc_{{ prop['name'] }}_q;
      {%- endif %}
      {%- endfor %}{#### for prop in fins['properties']['properties'] ####}
    end if;
  end process s_cdc;

  -- Assign Outputs
  {%- for prop in fins['properties']['properties'] %}
  {%- if (prop['type'] == 'read-write-data') %}
  {{ prop['name'] }} <= cdc_{{ prop['name'] }}_qq;
  {%- endif %}
  {%- endfor %}{#### for prop in fins['properties']['properties'] ####}

end rtl;
