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
-- Template:    swconfig_verify.vhd
-- Backend:     {{ fins['backend'] }}
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: File I/O Software Configuration bus test component for FINS
--              ports
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;
library std;
use std.textio.all;

-- Package
package {{ fins['name']|lower }}_swconfig_verify is

  ------------------------------------------------------------------------------
  -- Property Address Constants
  ------------------------------------------------------------------------------
  {%- for prop in fins['properties']['properties'] %}
  {%- for n in range(prop['length']) %}
  constant {{ fins['name']|upper }}_PROP_{{ prop['name']|upper }}_OFFSET{{ n }} : natural := {{ prop['offset'] + n }};
  {%- endfor %}
  {%- endfor %}

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type t_{{ fins['name']|lower }}_reg_array is array (natural range <>) of integer;

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- The maximum software configuration data width
  constant {{ fins['name']|upper }}_MAX_DATA_WIDTH : natural := 128;

  -- Error code when address does not correspond to a property
  constant {{ fins['name']|upper }}_ERROR_CODE : std_logic_vector({{ fins['name']|upper }}_MAX_DATA_WIDTH-1 downto 0) := x"BADADD03BADADD02BADADD01BADADD00";

  -- The maximum data value
  constant {{ fins['name']|upper }}_MAX_DATA_VALUE : std_logic_vector({{ fins['name']|upper }}_MAX_DATA_WIDTH-1 downto 0) := x"FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF";

  ------------------------------------------------------------------------------
  -- Procedures
  ------------------------------------------------------------------------------
  procedure {{ fins['name']|lower }}_write_reg (
    reg_wr_address              : natural;
    reg_wr_data                 : std_logic_vector;
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0)
  );

  procedure {{ fins['name']|lower }}_read_reg (
    reg_rd_address              : natural;
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0)
  );

  procedure {{ fins['name']|lower }}_write_regs (
    reg_wr_address              : natural;
    reg_wr_data                 : t_{{ fins['name']|lower }}_reg_array;
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0)
  );

  procedure {{ fins['name']|lower }}_verify_regs (
    reg_rd_address              : natural;
    reg_rd_data                 : t_{{ fins['name']|lower }}_reg_array;
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0)
  );

  procedure {{ fins['name']|lower }}_swconfig_verify (
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0)
  );

end {{ fins['name']|lower }}_swconfig_verify;

package body {{ fins['name']|lower }}_swconfig_verify is

  -- Procedure to write a property through the Software Configuration Bus
  procedure {{ fins['name']|lower }}_write_reg (
    reg_wr_address              : natural;
    reg_wr_data                 : std_logic_vector;
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0)
  ) is
  begin
    wait until falling_edge(s_swconfig_clk);
    s_swconfig_wr_data   <= reg_wr_data;
    {%- if fins['properties']['is_addr_byte_indexed'] %}
    s_swconfig_address <= std_logic_vector(to_unsigned(reg_wr_address*(s_swconfig_wr_data'length/8), s_swconfig_address'length));
    {%- else %}
    s_swconfig_address <= std_logic_vector(to_unsigned(reg_wr_address, s_swconfig_address'length));
    {%- endif %}
    s_swconfig_wr_enable <= '1';
    wait until falling_edge(s_swconfig_clk);
    s_swconfig_wr_data   <= (others => '0');
    s_swconfig_address   <= (others => '1');
    s_swconfig_wr_enable <= '0';
  end {{ fins['name']|lower }}_write_reg;

  -- Procedure to read a property through the Software Configuration Bus
  procedure {{ fins['name']|lower }}_read_reg (
    reg_rd_address              : natural;
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0)
  ) is
  begin
    wait until falling_edge(s_swconfig_clk);
    {%- if fins['properties']['is_addr_byte_indexed'] %}
    s_swconfig_address <= std_logic_vector(to_unsigned(reg_rd_address*(s_swconfig_rd_data'length/8), s_swconfig_address'length));
    {%- else %}
    s_swconfig_address <= std_logic_vector(to_unsigned(reg_rd_address, s_swconfig_address'length));
    {%- endif %}
    s_swconfig_rd_enable <= '1';
    wait until falling_edge(s_swconfig_clk);
    s_swconfig_rd_enable <= '0';
    if (s_swconfig_rd_valid = '0') then
      wait until (s_swconfig_rd_valid = '1');
    end if;
    s_swconfig_address <= (others => '1');
  end {{ fins['name']|lower }}_read_reg;

  -- Procedure to load a contiguous set of registers through the Software Configuration Bus
  procedure {{ fins['name']|lower }}_write_regs (
    reg_wr_address              : natural;
    reg_wr_data                 : t_{{ fins['name']|lower }}_reg_array;
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0)
  ) is
  begin
    for n in reg_wr_data'low to reg_wr_data'high loop
      {{ fins['name']|lower }}_write_reg(
        reg_wr_address + (n - reg_wr_data'low),
        std_logic_vector(to_unsigned(reg_wr_data(n), s_swconfig_wr_data'length)),
        s_swconfig_clk,
        s_swconfig_reset,
        s_swconfig_address,
        s_swconfig_wr_enable,
        s_swconfig_wr_data,
        s_swconfig_rd_enable,
        s_swconfig_rd_valid,
        s_swconfig_rd_data
      );
    end loop;
  end {{ fins['name']|lower }}_write_regs;

  -- Procedure to verify a contiguous set of registers through the Software Configuration Bus
  procedure {{ fins['name']|lower }}_verify_regs (
    reg_rd_address              : natural;
    reg_rd_data                 : t_{{ fins['name']|lower }}_reg_array;
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0)
  ) is
    variable my_line : line;
  begin
    for n in reg_rd_data'low to reg_rd_data'high loop
      {{ fins['name']|lower }}_read_reg(
        reg_rd_address + (n - reg_rd_data'low),
        s_swconfig_clk,
        s_swconfig_reset,
        s_swconfig_address,
        s_swconfig_wr_enable,
        s_swconfig_wr_data,
        s_swconfig_rd_enable,
        s_swconfig_rd_valid,
        s_swconfig_rd_data
      );
      -- TODO: Support signed comparison
      assert (reg_rd_data(n) = to_integer(unsigned(s_swconfig_rd_data)))
        report "ERROR: Incorrect value in property at address " & integer'image(reg_rd_address + n)
        severity failure;
    end loop;
    write(my_line, string'("PASS: Correct values for registers with starting offset ") & integer'image(reg_rd_address));
    writeline(output, my_line);
  end {{ fins['name']|lower }}_verify_regs;

  -- Procedure to verify all registers in the Software Configuration Bus
  procedure {{ fins['name']|lower }}_swconfig_verify (
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0)
  ) is
    variable my_line : line;
  begin

    --*********************************************
    -- Initialize Outputs
    --*********************************************
    s_swconfig_address   <= (others => '1');
    s_swconfig_wr_enable <= '0';
    s_swconfig_wr_data   <= (others => '0');
    s_swconfig_rd_enable <= '0';
    {%- for prop in fins['properties']['properties'] %}
    --*********************************************
    -- Property: {{ prop['name'] }}
    --*********************************************
    {%- if prop['is_readable'] %}
    -- Verify default values
    {%- for n in range(prop['length']) %}
    {{ fins['name']|lower }}_read_reg(
      {{ fins['name']|upper }}_PROP_{{ prop['name'] | upper }}_OFFSET{{ n }},
      s_swconfig_clk       ,
      s_swconfig_reset     ,
      s_swconfig_address   ,
      s_swconfig_wr_enable ,
      s_swconfig_wr_data   ,
      s_swconfig_rd_enable ,
      s_swconfig_rd_valid  ,
      s_swconfig_rd_data   
    );
    {%- if prop['is_signed'] %}
    assert ({{ prop['default_values'][n] }} = to_integer(signed(s_swconfig_rd_data({{ prop['width'] }}-1 downto 0))))
      report "ERROR: Incorrect default value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correct default value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"));
    writeline(output, my_line);
    {%- else %}
    assert ({{ prop['default_values'][n] }} = to_integer(unsigned(s_swconfig_rd_data({{ prop['width'] }}-1 downto 0))))
      report "ERROR: Incorrect default value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correct default value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"));
    writeline(output, my_line);
    {%- endif %}
    {%- endfor %}
    {%- if prop['is_writable'] %}
    -- Verify write width by writing all 1s and reading back correct width
    {%- for n in range(prop['length']) %}
    {{ fins['name']|lower }}_write_reg(
      {{ fins['name']|upper }}_PROP_{{ prop['name'] | upper }}_OFFSET{{ n }},
      {{ fins['name']|upper }}_MAX_DATA_VALUE(s_swconfig_wr_data'length-1 downto 0),
      s_swconfig_clk       ,
      s_swconfig_reset     ,
      s_swconfig_address   ,
      s_swconfig_wr_enable ,
      s_swconfig_wr_data   ,
      s_swconfig_rd_enable ,
      s_swconfig_rd_valid  ,
      s_swconfig_rd_data   
    );
    {{ fins['name']|lower }}_read_reg(
      {{ fins['name']|upper }}_PROP_{{ prop['name'] | upper }}_OFFSET{{ n }},
      s_swconfig_clk       ,
      s_swconfig_reset     ,
      s_swconfig_address   ,
      s_swconfig_wr_enable ,
      s_swconfig_wr_data   ,
      s_swconfig_rd_enable ,
      s_swconfig_rd_valid  ,
      s_swconfig_rd_data   
    );
    {# maximum value for prop['width'] sized slv, front-padded with 0s to fit fins['properties']['data_width'] #}
    assert ({{ ("x\"{:0" ~ fins['properties']['data_width']//4 ~ "x}\"").format(2**prop['width']-1) }} = s_swconfig_rd_data)
      report "ERROR: Incorrect write width for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correct write width for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"));
    writeline(output, my_line);
    {%- endfor %}
    -- Write back to default value
    {%- for n in range(prop['length']) %}
    {{ fins['name']|lower }}_write_reg(
      {{ fins['name']|upper }}_PROP_{{ prop['name'] | upper }}_OFFSET{{ n }},
      std_logic_vector(to_unsigned({{ prop['default_values'][n] }}, s_swconfig_wr_data'length)),
      s_swconfig_clk       ,
      s_swconfig_reset     ,
      s_swconfig_address   ,
      s_swconfig_wr_enable ,
      s_swconfig_wr_data   ,
      s_swconfig_rd_enable ,
      s_swconfig_rd_valid  ,
      s_swconfig_rd_data   
    );
    {{ fins['name']|lower }}_read_reg(
      {{ fins['name']|upper }}_PROP_{{ prop['name'] | upper }}_OFFSET{{ n }},
      s_swconfig_clk       ,
      s_swconfig_reset     ,
      s_swconfig_address   ,
      s_swconfig_wr_enable ,
      s_swconfig_wr_data   ,
      s_swconfig_rd_enable ,
      s_swconfig_rd_valid  ,
      s_swconfig_rd_data   
    );
    {%- if prop['is_signed'] %}
    assert ({{ prop['default_values'][n] }} = to_integer(signed(s_swconfig_rd_data({{ prop['width'] }}-1 downto 0))))
      report "ERROR: Write to default value failed for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correctly written back to default value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"));
    writeline(output, my_line);
    {%- else %}
    assert ({{ prop['default_values'][n] }} = to_integer(unsigned(s_swconfig_rd_data({{ prop['width'] }}-1 downto 0))))
      report "ERROR: Write to default value failed for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset']) }}"
      severity failure;
    write(my_line, string'("PASS: Correctly written back to default value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"));
    writeline(output, my_line);
    {%- endif %}
    {%- endfor %}
    {%- endif %}
    {%- else %}
    -- Property cannot be verified here since it is either not readable or it is a RAM
    {%- endif %}
    {%- endfor %}
    --*********************************************
    -- Verify Error Code
    --*********************************************
    {%- set last_reg = fins['properties']['properties'] | last %}
    {{ fins['name']|lower }}_read_reg(
      {{ last_reg['offset'] + last_reg['length'] }},
      s_swconfig_clk       ,
      s_swconfig_reset     ,
      s_swconfig_address   ,
      s_swconfig_wr_enable ,
      s_swconfig_wr_data   ,
      s_swconfig_rd_enable ,
      s_swconfig_rd_valid  ,
      s_swconfig_rd_data   
    );
    assert ({{ fins['name']|upper }}_ERROR_CODE(s_swconfig_rd_data'length-1 downto 0) = s_swconfig_rd_data)
      report "ERROR: Incorrect Software Configuration Read Error Code"
      severity failure;
    write(my_line, string'("PASS: Correct Software Configuration Read Error Code"));
    writeline(output, my_line);

  end {{ fins['name']|lower }}_swconfig_verify;

end {{ fins['name']|lower }}_swconfig_verify;
