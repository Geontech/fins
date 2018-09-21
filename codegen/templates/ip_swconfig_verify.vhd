--==============================================================================
-- Company:     Geon Technologies, LLC
-- Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this 
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: Auto-generated Software Configuration verification procedure
-- Generated:   {{ now }}
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
package {{ fins['name'] }}_swconfig_verify is

  ------------------------------------------------------------------------------
  -- Register Address Constants
  ------------------------------------------------------------------------------
  {%- for reg in fins['swconfig']['regs'] %}
  {%- for n in range(reg['length']) %}
  constant REG_{{ reg['name'] | upper }}_OFFSET{{ n }} : natural := {{ reg['offset'] + n }};
  {%- endfor %}
  {%- endfor %}

  ------------------------------------------------------------------------------
  -- Procedures
  ------------------------------------------------------------------------------
  procedure write_reg (
    reg_wr_address              : natural;
    reg_wr_data                 : std_logic_vector;
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector;
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector;
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector
  );

  procedure read_reg (
    reg_rd_address              : natural;
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector;
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector;
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector
  );

  procedure verify_swconfig (
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector;
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector;
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector
  );

end {{ fins['name'] }}_swconfig_verify;

package body {{ fins['name'] }}_swconfig_verify is

  -- Procedure to write a register through the Software Configuration Bus
  procedure write_reg (
    reg_wr_address              : natural;
    reg_wr_data                 : std_logic_vector;
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector;
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector;
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector
  ) is
  begin
    wait until falling_edge(s_swconfig_clk);
    s_swconfig_wr_data   <= reg_wr_data;
    s_swconfig_address   <= std_logic_vector(to_unsigned(reg_wr_address, s_swconfig_address'length));
    s_swconfig_wr_enable <= '1';
    wait until falling_edge(s_swconfig_clk);
    s_swconfig_wr_data   <= (others => '0');
    s_swconfig_address   <= (others => '1');
    s_swconfig_wr_enable <= '0';
  end write_reg;

  -- Procedure to read a register through the Software Configuration Bus
  procedure read_reg (
    reg_rd_address              : natural;
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector;
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector;
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector
  ) is
  begin
    wait until falling_edge(s_swconfig_clk);
    s_swconfig_address <= std_logic_vector(to_unsigned(reg_rd_address, s_swconfig_address'length));
    s_swconfig_rd_enable <= '1';
    wait until falling_edge(s_swconfig_clk);
    s_swconfig_rd_enable <= '0';
    if (s_swconfig_rd_valid = '0') then
      wait until (s_swconfig_rd_valid = '1');
    end if;
    s_swconfig_address <= (others => '1');
  end read_reg;

  -- Procedure to verify all registers in the Software Configuration Bus
  procedure verify_swconfig (
    signal s_swconfig_clk       : in  std_logic;
    signal s_swconfig_reset     : in  std_logic;
    signal s_swconfig_address   : out std_logic_vector;
    signal s_swconfig_wr_enable : out std_logic;
    signal s_swconfig_wr_data   : out std_logic_vector;
    signal s_swconfig_rd_enable : out std_logic;
    signal s_swconfig_rd_valid  : in  std_logic;
    signal s_swconfig_rd_data   : in  std_logic_vector
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
    {%- for reg in fins['swconfig']['regs'] %}
    --*********************************************
    -- Register: {{ reg['name'] }}
    --*********************************************
    {%- if reg['is_readable'] %}
    -- Verify default values
    {%- for n in range(reg['length']) %}
    read_reg(
      REG_{{ reg['name'] | upper }}_OFFSET{{ n }},
      s_swconfig_clk       ,
      s_swconfig_reset     ,
      s_swconfig_address   ,
      s_swconfig_wr_enable ,
      s_swconfig_wr_data   ,
      s_swconfig_rd_enable ,
      s_swconfig_rd_valid  ,
      s_swconfig_rd_data   
    );
    {%- if reg['is_signed'] %}
    assert ({{ reg['default_values'][n] }} = to_integer(signed(s_swconfig_rd_data({{ reg['width'] }}-1 downto 0))))
      report "ERROR: Incorrect default value for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correct default value for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"));
    writeline(output, my_line);
    {%- else %}
    assert ({{ reg['default_values'][n] }} = to_integer(unsigned(s_swconfig_rd_data({{ reg['width'] }}-1 downto 0))))
      report "ERROR: Incorrect default value for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correct default value for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"));
    writeline(output, my_line);
    {%- endif %}
    {%- endfor %}
    {%- if reg['is_writable'] and reg['is_read_from_write'] %}
    -- Verify write width by writing all 1s and reading back correct width
    {%- for n in range(reg['length']) %}
    write_reg(
      REG_{{ reg['name'] | upper }}_OFFSET{{ n }},
      x"FFFFFFFF"          ,
      s_swconfig_clk       ,
      s_swconfig_reset     ,
      s_swconfig_address   ,
      s_swconfig_wr_enable ,
      s_swconfig_wr_data   ,
      s_swconfig_rd_enable ,
      s_swconfig_rd_valid  ,
      s_swconfig_rd_data   
    );
    read_reg(
      REG_{{ reg['name'] | upper }}_OFFSET{{ n }},
      s_swconfig_clk       ,
      s_swconfig_reset     ,
      s_swconfig_address   ,
      s_swconfig_wr_enable ,
      s_swconfig_wr_data   ,
      s_swconfig_rd_enable ,
      s_swconfig_rd_valid  ,
      s_swconfig_rd_data   
    );
    {%- if reg['width'] == 32 %}
    assert (x"FFFFFFFF" = s_swconfig_rd_data)
    {%- else %}
    assert ({{ 2**reg['width']-1 }} = to_integer(unsigned(s_swconfig_rd_data)))
    {%- endif %}
      report "ERROR: Incorrect write width for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correct write width for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"));
    writeline(output, my_line);
    {%- endfor %}
    -- Write back to default value
    {%- for n in range(reg['length']) %}
    write_reg(
      REG_{{ reg['name'] | upper }}_OFFSET{{ n }},
      x"{{ '%08X' | format(reg['default_values'][n]) }}",
      s_swconfig_clk       ,
      s_swconfig_reset     ,
      s_swconfig_address   ,
      s_swconfig_wr_enable ,
      s_swconfig_wr_data   ,
      s_swconfig_rd_enable ,
      s_swconfig_rd_valid  ,
      s_swconfig_rd_data   
    );
    read_reg(
      REG_{{ reg['name'] | upper }}_OFFSET{{ n }},
      s_swconfig_clk       ,
      s_swconfig_reset     ,
      s_swconfig_address   ,
      s_swconfig_wr_enable ,
      s_swconfig_wr_data   ,
      s_swconfig_rd_enable ,
      s_swconfig_rd_valid  ,
      s_swconfig_rd_data   
    );
    {%- if reg['is_signed'] %}
    assert ({{ reg['default_values'][n] }} = to_integer(signed(s_swconfig_rd_data({{ reg['width'] }}-1 downto 0))))
      report "ERROR: Write to default value failed for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correctly written back to default value for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"));
    writeline(output, my_line);
    {%- else %}
    assert ({{ reg['default_values'][n] }} = to_integer(unsigned(s_swconfig_rd_data({{ reg['width'] }}-1 downto 0))))
      report "ERROR: Write to default value failed for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset']) }}"
      severity failure;
    write(my_line, string'("PASS: Correctly written back to default value for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"));
    writeline(output, my_line);
    {%- endif %}
    {%- endfor %}
    {%- endif %}
    {%- else %}
    -- Register cannot be verified here since it is not readable
    {%- endif %}
    {%- endfor %}
    --*********************************************
    -- Verify Error Code
    --*********************************************
    {%- set last_reg = fins['swconfig']['regs'] | last %}
    read_reg(
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
    assert (x"BADADD00" = s_swconfig_rd_data)
      report "ERROR: Incorrect Software Configuration Read Error Code"
      severity failure;
    write(my_line, string'("PASS: Correct Software Configuration Read Error Code"));
    writeline(output, my_line);

  end verify_swconfig;

end {{ fins['name'] }}_swconfig_verify;
