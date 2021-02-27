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
{%- if 'license_lines' in fins %}
{%-  for line in fins['license_lines'] -%}
-- {{ line }}
{%-  endfor %}
{%- endif %}

--==============================================================================
-- Firmware IP Node Specification (FINS) Auto-Generated File
-- ---------------------------------------------------------
-- Template:    core.vhd
-- Backend:     {{ fins['backend'] }}
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: Core functionality code stub for a FINS IP
-- Reset Type:  Synchronous
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- User Libraries
library work;
use work.{{ fins['name']|lower }}_pkg.all;

-- Entity
entity {{ fins['name']|lower }}_core is
  port (
    {%- if 'properties' in fins %}
    props_control : in  t_{{ fins['name']|lower }}_props_control;
    props_status  : out t_{{ fins['name']|lower }}_props_status{% if 'ports' in fins %};{% endif %}
    {%- endif %}
    {%- if 'ports' in fins %}
    {%- if 'hdl' in fins['ports'] %}
    ports_hdl_in  : in  t_{{ fins['name']|lower }}_ports_hdl_in;
    ports_hdl_out : out t_{{ fins['name']|lower }}_ports_hdl_out{% if 'ports' in fins['ports'] %};{% endif %}
    {%- endif %}
    {%- if 'ports' in fins['ports'] %}
    ports_in      : in  t_{{ fins['name']|lower }}_ports_in;
    ports_out     : out t_{{ fins['name']|lower }}_ports_out
    {%- endif %}
    {%- endif %}
  );
end {{ fins['name']|lower }}_core;

-- Architecture
architecture rtl of {{ fins['name']|lower }}_core is

begin

  --------------------------------------------------------------------------------
  -- User Core Code Goes Here!
  --------------------------------------------------------------------------------
  {%- if 'properties' in fins %}
  -- To use the software-controllable FINS "Properties" interface, use the
  -- fields of the following record signals:
  --
  --   * props_control : t_{{ fins['name']|lower }}_props_control;
  --   * props_status  : t_{{ fins['name']|lower }}_props_status;
  --
  -- The fields of props_control and props_status record signals above are the
  -- property names. A property name field is in turn a record of access signal
  -- records. If a property has a "length" > 1, then its property name field
  -- is an array of access signal records. An access signal record has different
  -- fields depending on the property "type". The access signal record fields are
  -- listed below for each property "type":
  -- 
  --   | type                | props_control Record Fields             | props_status Record Fields |
  --   | ------------------- | ----------------------------------------| -------------------------- |
  --   | read-only-constant  | None                                    | None                       |
  --   | read-only-data      | None                                    | rd_data                    |
  --   | read-only-external  | rd_en                                   | rd_data, rd_valid          |
  --   | read-only-memmap    | rd_en, rd_addr                          | rd_data, rd_valid          |
  --   | write-only-external | wr_en, wr_data                          | None                       |
  --   | write-only-memmap   | wr_en, wr_data, wr_addr                 | None                       |
  --   | read-write-internal | None                                    | None                       |
  --   | read-write-data     | wr_data                                 | None                       |
  --   | read-write-external | rd_en, wr_en, wr_data                   | rd_data, rd_valid          |
  --   | read-write-memmap   | rd_en, rd_addr, wr_en, wr_data, wr_addr | rd_data, rd_valid          |
  --
  -- The only property types that instantiate a physical storage register
  -- inside the {{ fins['name']|lower }}_axilite module are the "read-write-data"
  -- and the "read-write-internal". The most common property type used is
  -- "read-write-data", and its value can be used directly since it doesn't
  -- have any of the other access signals. An example of the usage of a property
  -- with name "gain" and type "read-write-data" is below:
  --
  --   signal_magnitude_out <= signed(props_control.gain.wr_data) * signal_magnitude_in;
  --
  -- All other types assume that the user will handle the storage and retrieval
  -- of data. Below is an example of using a property with name "coefficient"
  -- and type "read-write-external":
  --
  --   s_coefficient_property : process(S_AXI_ACLK)
  --   begin
  --     if (rising_edge(S_AXI_ACLK)) then
  --       if (S_AXI_ARESETN = '0') then
  --         coefficient_register <= (others => '0');
  --       else
  --         if (props_control.coefficient.wr_en = '1') then
  --           coefficient_register <= props_control.coefficient.wr_data;
  --         end if;
  --       end if;
  --     end if;
  --   end process s_coefficient_property;
  --   props_status.coefficient.rd_valid <= props_control.coefficient.rd_en;
  --   props_status.coefficient.rd_data  <= coefficient_register;
  --
  --------------------------------------------------------------------------------
  {%- endif %}
  {%- if 'ports' in fins %}
  {%- if 'ports' in fins['ports'] %}
  -- To use the standardized FINS "Ports" interfaces, use the
  -- fields of the following record signals:
  --
  --   * ports_in  : t_{{ fins['name']|lower }}_ports_in;
  --   * ports_out : t_{{ fins['name']|lower }}_ports_out;
  --
  -- The fields of ports_in and ports_out record signals above are the port names.
  -- When a port has (num_instances > 1), the port name field is an array of
  -- access signal records. Otherwise, the port name field is a single access
  -- signal record. The fields of the port name records are dependent on the port
  -- characteristics and are listed in the table below:
  --
  --   | `direction` | `supports_backpressure` | `data` exists | `metadata` exists | ports_in Record Fields      | ports_out Record Fields     |
  --   | ----------- | ----------------------- | ------------- | ----------------- | --------------------------- | --------------------------- |
  --   | in          | true                    | true          | false             | valid, last, data           | ready                       |
  --   | in          | true                    | false         | true              | valid, last, metadata       | ready                       |
  --   | in          | true                    | true          | true              | valid, last, data, metadata | ready                       |
  --   | in          | false                   | true          | false             | valid, last, data           |                             |
  --   | in          | false                   | false         | true              | valid, last, metadata       |                             |
  --   | in          | false                   | true          | true              | valid, last, data, metadata |                             |
  --   | out         | true                    | true          | false             | ready                       | valid, last, data           |
  --   | out         | true                    | false         | true              | ready                       | valid, last, metadata       |
  --   | out         | true                    | true          | true              | ready                       | valid, last, data, metadata |
  --   | out         | false                   | true          | false             |                             | valid, last, data           |
  --   | out         | false                   | false         | true              |                             | valid, last, metadata       |
  --   | out         | false                   | true          | true              |                             | valid, last, data, metadata |
  --
  -- At the lowest level, the data or metadata values have either signed or
  -- unsigned types (indicated by the "is_signed" field). However, the data field
  -- may itself be a more complex type when:
  --
  --   * (num_channels > 1) AND (num_samples > 1): The data field is a
  --     two-dimensional array of either complex records or signed/unsigned
  --     values. The first index is for channels, and the second is for samples.
  --     Example code for real-only output port "power":
  --         ports_out.power.data(channel)(sample) <= data_i*data_i+data_q*data_q;
  --   * (num_channels > 1) XOR (num_samples > 1): The data field is a
  --     one-dimensional array of either complex records or signed/unsigned
  --     values.
  --   * (is_complex = true): The data field is a complex record with fields
  --     "i" (real) and "q" (imaginary). "i" and "q" are either signed or
  --     unsigned types.
  --
  -- Similar to the data field, the metadata field may also be a more complex
  -- type than just signed or unsigned when:
  --
  --   * (is_complex = true): The metadata field is a complex record with fields
  --     "i" (real) and "q" (imaginary). "i" and "q" are either signed or
  --     unsigned types.
  --
  -- For ease of use, four conversion functions are provided in the pkg file
  -- for each port's data and metadata. These functions convert between the
  -- custom record types and std_logic_vector's, and their naming conventions
  -- are listed below:
  --
  --   * f_serialize_[IP_NAME]_[PORT_NAME]_data()
  --   * f_unserialize_[IP_NAME]_[PORT_NAME]_data()
  --   * f_serialize_[IP_NAME]_[PORT_NAME]_metadata()
  --   * f_unserialize_[IP_NAME]_[PORT_NAME]_metadata()
  --
  -- Example code of a "powconv" module using an input port "adc" and output
  -- port "power" that both have metadata and support backpressure is shown below:
  --
  --   ports_out.power.data     <= (ports_in.adc.i * ports_in.adc.i) + (ports_in.adc.q * ports_in.adc.q);
  --   ports_out.power.metadata <= f_unserialize_powconv_power_metadata(f_serialize_powconv_adc_metadata(ports_in.adc.metadata));
  --   ports_out.power.valid    <= ports_in.adc.valid;
  --   ports_out.power.last     <= ports_in.adc.last;
  --   ports_out.adc.ready      <= ports_in.power.ready;
  --
  -- Notice how the metadata is passed through, using the conversion functions
  -- from the package file to make the assignment with incongruous types.
  --
  --------------------------------------------------------------------------------
  {%- endif %}
  {%- endif %}

end rtl;
