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
-- Template:    avalonst_tdm_to_parallel.vhd
-- Backend:     core (Nodeset)
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: Converts FINS Port from Avalon-ST time-division multiplexed
--              bus (Big Endian) to AXI4-Stream fully parallel bus
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

-- Entity
entity {{ fins['name']|lower }}_avalonst_tdm_to_parallel is
  generic (
    G_SAMPLE_COUNTER_WIDTH : natural := 16; -- This value MUST be >= ceil(log2(MAX_SAMPLES_IN_PACKET))
    G_TDM_WORD_WIDTH       : natural := 32  -- LIMITATION: This value MUST be >= fins['data']['bit_width']
  );
  port (
    -- AXI4-Stream Parallel Bus
    m_axis_aclk       : in  std_logic;
    m_axis_aresetn    : in  std_logic;
    {%- if fins['supports_backpressure'] %}
    m_axis_tready     : in  std_logic;
    {%- endif %}
    m_axis_tdata      : out std_logic_vector({{ fins['data']['bit_width']*fins['data']['num_samples']*fins['data']['num_channels'] }}-1 downto 0);
    {%- if 'metadata' in fins %}
    m_axis_tuser      : out std_logic_vector({{ fins['metadata']|sum(attribute='bit_width') }}-1 downto 0);
    {%- endif %}
    m_axis_tvalid     : out std_logic;
    m_axis_tlast      : out std_logic;
    -- Avalon-ST Time-Division Multiplexed Bus (Big Endian)
    asi_clock         : in  std_logic;
    asi_reset         : in  std_logic;
    asi_ready         : out std_logic;
    asi_data          : in  std_logic_vector(G_TDM_WORD_WIDTH-1 downto 0);
    asi_valid         : in  std_logic;
    asi_startofpacket : in  std_logic;
    asi_endofpacket   : in  std_logic
  );
end {{ fins['name']|lower }}_avalonst_tdm_to_parallel;

-- Architecture
architecture rtl of {{ fins['name']|lower }}_avalonst_tdm_to_parallel is

  --------------------------------------------------------------------------------
  -- Constants
  --------------------------------------------------------------------------------
  {%- if 'metadata' in fins %}
  constant TOTAL_METADATA_WIDTH : natural := {{ fins['metadata']|sum(attribute='bit_width') }};
  constant NUM_METADATA_WORDS : natural := integer(ceil(real(TOTAL_METADATA_WIDTH) / real(G_TDM_WORD_WIDTH)));
  constant METADATA_REMAINDER_BITS : natural := (NUM_METADATA_WORDS*G_TDM_WORD_WIDTH) - TOTAL_METADATA_WIDTH;
  {%- endif %}
  constant TOTAL_DATA_WIDTH : natural := {{ fins['data']['bit_width']*fins['data']['num_samples']*fins['data']['num_channels'] }};

  --------------------------------------------------------------------------------
  -- Types
  --------------------------------------------------------------------------------
  {%- if 'metadata' in fins %}
  type t_metadata_array is array (0 to NUM_METADATA_WORDS-1) of std_logic_vector(G_TDM_WORD_WIDTH-1 downto 0);
  {%- endif %}

  --------------------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------------------
  -- Internal signals
  signal internal_m_axis_tvalid : std_logic;
  signal internal_asi_ready : std_logic;
  signal internal_asi_data : std_logic_vector(G_TDM_WORD_WIDTH-1 downto 0);
  {%- if 'metadata' in fins %}
  -- Signals for demuxing the metadata
  signal tdm_word_counter       : unsigned(G_SAMPLE_COUNTER_WIDTH-1 downto 0);
  signal metadata_array         : t_metadata_array;
  {%- endif  %}

begin

  {%- if 'metadata' in fins %}
  --------------------------------------------------------------------------------
  -- Metadata
  --------------------------------------------------------------------------------
  -- Synchronous process for serialized word counting and capturing metadata
  s_capture_metadata : process (asi_clock)
  begin
    if (rising_edge(asi_clock)) then
      if (asi_reset = '1') then
        tdm_word_counter  <= (others => '0');
      else
        if ((asi_valid = '1') AND (internal_asi_ready = '1')) then
          -- Count the word index
          if (asi_endofpacket = '1') then
            tdm_word_counter <= (others => '0');
          else
            tdm_word_counter <= tdm_word_counter + 1;
          end if;
          -- Capture the metadata
          if (tdm_word_counter < NUM_METADATA_WORDS) then
            metadata_array(to_integer(tdm_word_counter)) <= internal_asi_data;
          end if;
        end if;
      end if;
    end if;
  end process s_capture_metadata;

  -- Remap the metadata
  c_remap_metadata : process (metadata_array)
  begin
    for n in 0 to NUM_METADATA_WORDS-1 loop
      if ((n = NUM_METADATA_WORDS-1) AND (METADATA_REMAINDER_BITS > 0)) then
        m_axis_tuser((n+1)*G_TDM_WORD_WIDTH-METADATA_REMAINDER_BITS-1 downto n*G_TDM_WORD_WIDTH) <= metadata_array(n)(G_TDM_WORD_WIDTH-METADATA_REMAINDER_BITS-1 downto 0);
      else
        m_axis_tuser((n+1)*G_TDM_WORD_WIDTH-1 downto n*G_TDM_WORD_WIDTH) <= metadata_array(n);
      end if;
    end loop;
  end process c_remap_metadata;

  {%- endif %}{#### if 'metadata' in fins ####}

  --------------------------------------------------------------------------------
  -- Data and control signals
  --------------------------------------------------------------------------------
  {%- if 'metadata' in fins %}
  -- Combinatorial process to assign data TVALID
  c_data_tvalid : process (asi_valid, tdm_word_counter)
  begin
    -- Set defaults
    internal_m_axis_tvalid <= '0';
    -- Assign value
    if (asi_valid = '1') then
      if (tdm_word_counter > NUM_METADATA_WORDS-1) then
        internal_m_axis_tvalid <= '1';
      end if;
    end if;
  end process c_data_tvalid;
  {%- else %}
  -- TVALID is passed through directly
  internal_m_axis_tvalid <= asi_valid;
  {%- endif %}

  -- Combinatorial process to convert the input data to Little Endian
  c_convert_data_to_little_endian : process (asi_data)
  begin
    -- Set defaults
    internal_asi_data <= (others => '0');

    -- Convert from Big Endian to Little Endian
    for n in 0 to G_TDM_WORD_WIDTH/8-1 loop
      internal_asi_data((n+1)*8-1 downto n*8) <= asi_data(G_TDM_WORD_WIDTH-1-n*8 downto G_TDM_WORD_WIDTH-(n+1)*8);
    end loop;
  end process c_convert_data_to_little_endian;

  -- Concurrent signal assignments to set outputs and signals
  m_axis_tdata  <= internal_asi_data(TOTAL_DATA_WIDTH-1 downto 0);
  m_axis_tlast  <= asi_endofpacket;
  {%- if fins['supports_backpressure'] %}
  internal_asi_ready <= m_axis_tready;
  {%- else %}
  internal_asi_ready <= '1';
  {%- endif %}

  -- Assign control signal outputs
  asi_ready <= internal_asi_ready;
  m_axis_tvalid <= internal_m_axis_tvalid;

end rtl;
