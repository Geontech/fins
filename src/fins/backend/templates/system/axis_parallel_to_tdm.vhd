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
-- Template:    axis_parallel_to_tdm.vhd
-- Backend:     core (Application)
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: Converts FINS Port from AXI4-Stream fully parallel to
--              AXI4-Stream time-division multiplexed
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
use work.{{ fins['name']|lower }}_axis_parallel_to_tdm_pkg.all;

-- Entity
entity {{ fins['name']|lower }}_axis_parallel_to_tdm is
  generic (
    G_TDM_WORD_WIDTH : natural := 32  -- LIMITATION: This value MUST be >= fins['data']['bit_width']
  );
  port (
    -- Parallel Bus
    s_axis_aclk    : in  std_logic;
    s_axis_aresetn : in  std_logic;
    {%- if fins['supports_backpressure'] %}
    s_axis_tready  : out std_logic;
    {%- endif %}
    {%- if fins['supports_byte_enable'] %}
    s_axis_tkeep   : in  std_logic_vector({{ fins['data']['byte_width'] }}-1 downto 0);
    {%- endif %}
    s_axis_tdata   : in  std_logic_vector({{ fins['data']['bit_width']*fins['data']['num_samples']*fins['data']['num_channels'] }}-1 downto 0);
    {%- if 'metadata' in fins %}
    s_axis_tuser   : in  std_logic_vector({{ fins['metadata']|sum(attribute='bit_width') }}-1 downto 0);
    {%- endif %}
    s_axis_tvalid  : in  std_logic;
    s_axis_tlast   : in  std_logic;
    -- Time-Division Multiplexed Bus
    m_axis_aclk    : in  std_logic;
    m_axis_aresetn : in  std_logic;
    m_axis_tready  : in  std_logic;
    m_axis_tdata   : out std_logic_vector(G_TDM_WORD_WIDTH-1 downto 0);
    m_axis_tvalid  : out std_logic;
    {%- if fins['supports_byte_enable'] %}
    m_axis_tkeep   : out std_logic_vector({{ fins['data']['byte_width'] }}-1 downto 0);
    {%- endif %}
    m_axis_tlast   : out std_logic
  );
end {{ fins['name']|lower }}_axis_parallel_to_tdm;

-- Architecture
architecture rtl of {{ fins['name']|lower }}_axis_parallel_to_tdm is

  --------------------------------------------------------------------------------
  -- Constants
  --------------------------------------------------------------------------------
  constant G_DATA_WIDTH : natural := {{ fins['data']['bit_width']*fins['data']['num_samples']*fins['data']['num_channels'] }};
  {%- if 'metadata' in fins %}
  constant G_METADATA_WIDTH : natural := {{ fins['metadata']|sum(attribute='bit_width') }};
  constant NUM_METADATA_WORDS : natural := integer(ceil(real(G_METADATA_WIDTH) / real(G_TDM_WORD_WIDTH)));
  constant NUM_METADATA_WORDS_LOG2 : natural := integer(ceil(log2(real(NUM_METADATA_WORDS))));
  {%- endif %}
  {%- if fins['supports_byte_enable'] %}
  constant G_BYTE_WIDTH : natural := {{ fins['data']['byte_width'] }};
  {%- endif %}
  constant FIFO_WIDTH : natural := G_DATA_WIDTH {%- if 'metadata' in fins %}+ G_METADATA_WIDTH {%- endif %}{%- if fins['supports_byte_enable'] %}+ G_BYTE_WIDTH {%- endif %}+ 1; -- +1 for tlast

  --------------------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------------------
  -- Xilinx IP created by TCL script
  -- NOTE: +1 is for TLAST
  component xilinx_parallel_word_fifo
    port (
      clk   : in  std_logic;
      srst  : in  std_logic;
      din   : in  std_logic_vector(FIFO_WIDTH-1 downto 0);
      wr_en : in  std_logic;
      rd_en : in  std_logic;
      dout  : out std_logic_vector(FIFO_WIDTH-1 downto 0);
      full  : out std_logic;
      empty : out std_logic
    );
  end component;

  -- Intel IP created by TCL script
  -- NOTE: +1 is for TLAST
  component intel_parallel_word_fifo is
    port (
      data  : in  std_logic_vector(FIFO_WIDTH-1 downto 0);
      wrreq : in  std_logic;
      rdreq : in  std_logic;
      clock : in  std_logic;
      q     : out std_logic_vector(FIFO_WIDTH-1 downto 0);
      full  : out std_logic;
      empty : out std_logic
    );
  end component;

  --------------------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------------------
  -- FIFO signals
  signal fifo_din   : std_logic_vector(FIFO_WIDTH-1 downto 0);
  signal fifo_dout  : std_logic_vector(FIFO_WIDTH-1 downto 0);
  signal fifo_rd_en : std_logic;
  signal fifo_wr_en : std_logic;
  signal fifo_full  : std_logic;
  signal fifo_empty : std_logic;

  {%- if 'metadata' in fins %}
  -- Metadata signals
  signal send_metadata : std_logic;
  signal metadata_mux_counter : unsigned(NUM_METADATA_WORDS_LOG2-1 downto 0);
  signal metadata : std_logic_vector(NUM_METADATA_WORDS*G_TDM_WORD_WIDTH-1 downto 0);
  {%- endif %}

begin

  -----------------------------------------------------------------------------
  -- Input Buffer
  -----------------------------------------------------------------------------
  -- Write the input directly into FIFO
  fifo_din   <= s_axis_tlast & s_axis_tdata{%- if 'metadata' in fins %} & s_axis_tuser{%- endif %} {%- if fins['supports_byte_enable'] %} & s_axis_tkeep{%- endif %};
  fifo_wr_en <= s_axis_tvalid; -- Since tready is always high
  {%- if fins['supports_backpressure'] %}
  -- Only ready when the FIFO has space
  s_axis_tready <= NOT fifo_full;
  {%- endif %}

  -- FWFT FIFO instantitation for buffering data while metadata is captured and then multiplexed out
  u_gen_xilinx_parallel_word_fifo : if (FINS_BACKEND = "vivado") generate
    u_parallel_word_fifo : xilinx_parallel_word_fifo
      port map (
        clk   => s_axis_aclk,
        srst  => '0',
        din   => fifo_din,
        wr_en => fifo_wr_en,
        rd_en => fifo_rd_en,
        dout  => fifo_dout,
        full  => fifo_full,
        empty => fifo_empty
      );
  end generate u_gen_xilinx_parallel_word_fifo;
  u_gen_intel_parallel_word_fifo : if (FINS_BACKEND = "quartus") generate
    u_parallel_word_fifo : intel_parallel_word_fifo
      port map (
        clock   => s_axis_aclk,
        data    => fifo_din,
        wrreq   => fifo_wr_en,
        rdreq   => fifo_rd_en,
        q       => fifo_dout,
        full    => fifo_full,
        empty   => fifo_empty
      );
  end generate u_gen_intel_parallel_word_fifo;

  -----------------------------------------------------------------------------
  -- Output control
  -----------------------------------------------------------------------------
  {%- if 'metadata' in fins %}{###############################################}

  -- Synchronous process for controlling metadata mode and output mux
  s_metadata : process (s_axis_aclk)
  begin
    if (rising_edge(s_axis_aclk)) then
      --**************************
      -- Control registers
      --**************************
      if (s_axis_aresetn = '0') then
        send_metadata <= '1';
        metadata_mux_counter <= (others => '0');
      else
        -- Take action when there is a transaction
        if ((m_axis_tready = '1') AND (fifo_empty = '0')) then
          -- Set send_metadata back to high when we detect tlast
          if (fifo_dout(FIFO_WIDTH-1) = '1') then
            send_metadata <= '1';
          end if;
          -- Count the number of metadata words and then reset send_metadata
          if (send_metadata = '1') then
            -- Mux the output with the counter
            if (metadata_mux_counter >= NUM_METADATA_WORDS-1) then
              metadata_mux_counter <= (others => '0');
              send_metadata <= '0';
            else
              metadata_mux_counter <= metadata_mux_counter + 1;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process s_metadata;

  -- Combinatorial process to multiplex the TDM output
  c_output : process (send_metadata, m_axis_tready, fifo_empty, fifo_dout, metadata_mux_counter, metadata)
  begin
    -- Set defaults
    fifo_rd_en    <= m_axis_tready AND (NOT fifo_empty) AND (NOT send_metadata);
    metadata      <= (others => '0');
    m_axis_tdata  <= (others => '0');
    m_axis_tvalid <= (NOT fifo_empty);
    m_axis_tlast  <= fifo_dout(FIFO_WIDTH-1) AND (NOT send_metadata);
    {%- if fins['supports_byte_enable'] %}
    m_axis_tkeep  <= fifo_dout({{ fins['data']['byte_width'] }}-1 downto 0);
    {%- endif %}

    -- Zero pad the metadata
    metadata(G_METADATA_WIDTH-1 downto 0) <= fifo_dout(G_METADATA_WIDTH{%- if fins['supports_byte_enable'] %}+G_BYTE_WIDTH{%- endif %}-1 downto 0{%- if fins['supports_byte_enable'] %}+G_BYTE_WIDTH{%- endif %});

    -- Determine the tdata output
    if (send_metadata = '1') then
      -- Mux the metadata
      for n in 0 to NUM_METADATA_WORDS-1 loop
        if (n = metadata_mux_counter) then
          m_axis_tdata <= metadata((n+1)*G_TDM_WORD_WIDTH-1 downto n*G_TDM_WORD_WIDTH);
        end if;
      end loop;
    else
      -- Assign the data
      m_axis_tdata(G_DATA_WIDTH-1 downto 0) <= fifo_dout(G_METADATA_WIDTH+G_DATA_WIDTH{%- if fins['supports_byte_enable'] %}+G_BYTE_WIDTH{%- endif %}-1 downto G_METADATA_WIDTH{%- if fins['supports_byte_enable'] %}+G_BYTE_WIDTH{%- endif %});
    end if;
  end process c_output;

  {%- else %}{# if 'metadata' in fins ########################################}

  -- Combinatorial process to set the TDM output
  c_output : process (m_axis_tready, fifo_empty, fifo_dout)
  begin
    -- Set defaults
    fifo_rd_en    <= m_axis_tready;
    m_axis_tvalid <= NOT fifo_empty;
    m_axis_tlast  <= fifo_dout(FIFO_WIDTH-1);
    {%- if fins['supports_byte_enable'] %}
    m_axis_tkeep  <= fifo_dout({{ fins['data']['byte_width'] }}-1 downto 0);
    {%- endif %}
    m_axis_tdata  <= (others => '0');

    -- Zero-pad tdata if applicable
    m_axis_tdata(G_DATA_WIDTH-1 downto 0) <= fifo_dout(G_DATA_WIDTH{%- if fins['supports_byte_enable'] %}+G_BYTE_WIDTH{%- endif %}-1 downto 0{%- if fins['supports_byte_enable'] %}+G_BYTE_WIDTH{%- endif %});
  end process c_output;

  {%- endif %}{# if 'metadata' in fins #######################################}

end rtl;
