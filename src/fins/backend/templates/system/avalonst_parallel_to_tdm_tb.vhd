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
-- Template:    avalonst_parallel_to_tdm_tb.vhd
-- Backend:     core (Application)
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: Converts FINS Port from AXI4-Stream fully parallel bus to
--              Avalon-ST time-division multiplexed bus (Big Endian)
-- Reset Type:  Synchronous
-- Clocks:      Although there are two different input clocks, they are assumed
--              to be on the same clock domain
-- Limitations: Use of this module is subject to the following requirements:
--              * G_TDM_WORD_WIDTH >= fins['data']['bit_width']
--              * fins['data']['num_channels'] == 1
--              * fins['data']['num_samples'] == 1
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- User Libraries
library work;
use work.{{ fins['name']|lower }}_avalonst_parallel_to_tdm_pkg.all;

-- Entity
entity {{ fins['name']|lower }}_avalonst_parallel_to_tdm_tb is

end {{ fins['name']|lower }}_avalonst_parallel_to_tdm_tb;

-- Architecture
architecture behav of {{ fins['name']|lower }}_avalonst_parallel_to_tdm_tb is
  --------------------------------------------------------------------------------
  -- Constants
  --------------------------------------------------------------------------------
  constant G_TDM_WORD_WIDTH   : integer := 32;
  constant G_BIG_ENDIAN       : boolean := true;  
  constant CLOCK_PERIOD       : time := 5 ns;

  signal clock    : std_logic := '0';
  signal resetn   : std_logic := '1';

  -- AXI4-Stream Parallel Bus
  signal s_axis_aclk       : std_logic;
  signal s_axis_aresetn    : std_logic;
  {%- if fins['supports_backpressure'] %}
  signal s_axis_tready     : std_logic;
  {%- endif %}
  {%- if fins['supports_byte_enable'] %}
  signal s_axis_tkeep      : std_logic_vector({{ fins['data']['byte_width'] }}-1 downto 0);
  {%- endif %}
  signal s_axis_tdata      : std_logic_vector({{ fins['data']['bit_width']*fins['data']['num_samples']*fins['data']['num_channels'] }}-1 downto 0);
  {%- if 'metadata' in fins %}
  signal s_axis_tuser      : std_logic_vector({{ fins['metadata']|sum(attribute='bit_width') }}-1 downto 0);
  {%- endif %}
  signal s_axis_tvalid     : std_logic;
  signal s_axis_tlast      : std_logic;
  -- Avalon-ST Time-Division Multiplexed Bus (Big Endian)
  signal aso_clock         : std_logic;
  signal aso_reset         : std_logic;
  signal aso_ready         : std_logic;
  signal aso_data          : std_logic_vector(G_TDM_WORD_WIDTH-1 downto 0);
  signal aso_valid         : std_logic;
  signal aso_startofpacket : std_logic;
  {%- if fins['supports_byte_enable'] %}
  signal aso_empty         : std_logic_vector({{ fins['data']['empty_width'] }}-1 downto 0);
  {%- endif %}
  signal aso_endofpacket   : std_logic;

  signal simulation_done   : boolean := false;

  function f_rearrange_aso_data(data : std_logic_vector(G_TDM_WORD_WIDTH-1 downto 0) := (others => '0')) return std_logic_vector is
      variable reformat_data: std_logic_vector(G_TDM_WORD_WIDTH-1 downto 0) := (others => '0');
      variable i_up : natural := 0;
      variable i_down : natural := (G_TDM_WORD_WIDTH/8);
      variable num_bytes : natural := G_TDM_WORD_WIDTH/8;
    begin
      for i in 0 to num_bytes-1 loop
        reformat_data((i_down*8)-1 downto (i_down-1)*8) := data(((i_up+1)*8)-1 downto i_up*8);
        i_up := i_up + 1;
        i_down := i_down - 1;
      end loop;
      return reformat_data;
    end function;

begin
  u_uut : entity work.{{ fins['name']|lower }}_avalonst_parallel_to_tdm
    generic map (
      G_TDM_WORD_WIDTH => G_TDM_WORD_WIDTH,
      G_BIG_ENDIAN     => G_BIG_ENDIAN
    )
    port map(
      -- AXI4-Stream Parallel Bus
      s_axis_aclk        => s_axis_aclk,
      s_axis_aresetn     => s_axis_aresetn,
{%- if fins['supports_backpressure'] %}
      s_axis_tready      => s_axis_tready,
{%- endif %}
{%- if fins['supports_byte_enable'] %}
      s_axis_tkeep       => s_axis_tkeep,
{%- endif %}
      s_axis_tdata       => s_axis_tdata,
      s_axis_tuser       => s_axis_tuser,
      s_axis_tvalid      => s_axis_tvalid,
      s_axis_tlast       => s_axis_tlast,
      -- Avalon-ST Time-Division Multiplexed Bus (Big Endian)
      aso_clock          => aso_clock,
      aso_reset          => aso_reset,
      aso_ready          => aso_ready,
      aso_data           => aso_data,
      aso_valid          => aso_valid,
      aso_startofpacket  => aso_startofpacket,
{%- if fins['supports_byte_enable'] %}
      aso_empty          => aso_empty,
{%- endif %}
      aso_endofpacket    => aso_endofpacket
    );

  --------------------------------------------------------------------------------
  -- Clocks and Resets
  --------------------------------------------------------------------------------
  -- Waveform process to generate a clock
  w_clock : process
  begin
    if (simulation_done = false) then
      clock <= '0';
      wait for CLOCK_PERIOD/2;
      clock <= '1';
      wait for CLOCK_PERIOD/2;
    else
      wait;
    end if;
  end process w_clock;

  s_axis_aclk <= clock;
  s_axis_aresetn <= resetn;

  aso_clock   <= clock;
  aso_reset   <= resetn;


end behav;
