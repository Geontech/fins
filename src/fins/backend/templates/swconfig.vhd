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
-- Template:    swconfig.vhd
-- Backend:     {{ fins['backend'] }}
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: Software Configuration bus register decode for FINS properties
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
entity {{ fins['name']|lower }}_swconfig is
  generic (
    G_BYTE_INDEXED : boolean := {{ fins['properties']['is_addr_byte_indexed']|lower }};
    G_ADDR_WIDTH   : natural := {{ fins['properties']['addr_width'] }};
    G_DATA_WIDTH   : natural := {{ fins['properties']['data_width'] }}
  );
  port (
    s_swconfig_clk       : in  std_logic;
    s_swconfig_reset     : in  std_logic;
    s_swconfig_address   : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    s_swconfig_wr_enable : in  std_logic;
    s_swconfig_wr_data   : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    s_swconfig_rd_enable : in  std_logic;
    s_swconfig_rd_valid  : out std_logic;
    s_swconfig_rd_data   : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    props_control        : out t_{{ fins['name']|lower }}_props_control;
    props_status         : in  t_{{ fins['name']|lower }}_props_status
  );
end {{ fins['name']|lower }}_swconfig;

-- Architecture
architecture rtl of {{ fins['name']|lower }}_swconfig is

  ------------------------------------------------------------------------------
  -- Attributes
  ------------------------------------------------------------------------------
  -- Create Xilinx Interface Information attribute
  attribute X_INTERFACE_INFO : string;

  -- Infer swconfig bus on slave interface
  attribute X_INTERFACE_INFO of s_swconfig_clk       : signal is "geontech.com:user:swconfig:1.0 S_SWCONFIG CLK";
  attribute X_INTERFACE_INFO of s_swconfig_reset     : signal is "geontech.com:user:swconfig:1.0 S_SWCONFIG RESET";
  attribute X_INTERFACE_INFO of s_swconfig_address   : signal is "geontech.com:user:swconfig:1.0 S_SWCONFIG ADDRESS";
  attribute X_INTERFACE_INFO of s_swconfig_wr_enable : signal is "geontech.com:user:swconfig:1.0 S_SWCONFIG WR_ENABLE";
  attribute X_INTERFACE_INFO of s_swconfig_wr_data   : signal is "geontech.com:user:swconfig:1.0 S_SWCONFIG WR_DATA";
  attribute X_INTERFACE_INFO of s_swconfig_rd_enable : signal is "geontech.com:user:swconfig:1.0 S_SWCONFIG RD_ENABLE";
  attribute X_INTERFACE_INFO of s_swconfig_rd_valid  : signal is "geontech.com:user:swconfig:1.0 S_SWCONFIG RD_VALID";
  attribute X_INTERFACE_INFO of s_swconfig_rd_data   : signal is "geontech.com:user:swconfig:1.0 S_SWCONFIG RD_DATA";

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- The maximum Software Configuration data width
  constant MAX_DATA_WIDTH : natural := 128;

  -- Error code when address does not correspond to a register
  constant ERROR_CODE : std_logic_vector(MAX_DATA_WIDTH-1 downto 0) := x"BADADD03BADADD02BADADD01BADADD00";

  -- The number of LSBs that are unused if Software Configuration address is byte indexed
  constant ADDR_LSB : natural := integer(ceil(log2(real(G_DATA_WIDTH/8))));

  -- The total number of physical addresses of all properties
  constant NUM_ADDRESSES : natural := {{ fins['properties']['properties']|sum(attribute='length') }};

  -- The total number of properties
  constant NUM_PROPERTIES : natural := {{ fins['properties']['properties']|length }};

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type t_reg_array is array (integer range <>) of std_logic_vector(G_DATA_WIDTH-1 downto 0);
  type t_addr_array is array (integer range <>) of std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  type t_address_to_property_map is array (0 to NUM_ADDRESSES-1) of natural;
  type t_properties_offsets is array (0 to NUM_PROPERTIES-1) of unsigned(G_ADDR_WIDTH-1 downto 0);

  ------------------------------------------------------------------------------
  -- Custom-typed Constants
  ------------------------------------------------------------------------------
  -- Constant array of the lengths of each property
  constant ADDRESS_TO_PROPERTY_MAP : t_address_to_property_map := (
    {%- for prop in fins['properties']['properties']|list %}
    {%- set outer_loop = loop %}
    {%- for n in range(prop['length']) %}
    {{ outer_loop.index0 }},
    {%- endfor %}
    {%- endfor %}
    others => 0
  );

  -- Constant array of the property offsets
  constant PROPERTIES_OFFSETS : t_properties_offsets := (
    {%- for prop in fins['properties']['properties'] %}
    to_unsigned({{ prop['offset'] }}, G_ADDR_WIDTH),
    {%- endfor %}
    others => (others => '0')
  );

  ------------------------------------------------------------------------------
  -- Register Constants
  ------------------------------------------------------------------------------
  -- Default for Local Registers
  constant REG_DEFAULT_FOREACH_ADDR : t_reg_array(0 to NUM_ADDRESSES-1) := (
    {%- for prop in fins['properties']['properties'] %}
    {%- for default_value in prop['default_values'] %}
    {%- if prop['is_signed'] %}
    std_logic_vector(resize(to_signed({{ default_value }}, {{ prop['width'] }}), G_DATA_WIDTH)),
    {%- else %}
    std_logic_vector(resize(to_unsigned({{ default_value }}, {{ prop['width'] }}), G_DATA_WIDTH)),
    {%- endif %}
    {%- endfor %}
    {%- endfor %}
    others => (others => '0')
  );

  -- The Bit Mask for Writable Local Register Values
  -- Note: The mask prevents bits from being written in invalid areas.
  --       Remote registers have an entry here, but they are set to all zeros 
  --       since the write is happing in a remote location
  constant REG_WR_MASK_FOREACH_ADDR : t_reg_array(0 to NUM_ADDRESSES-1) := (
    {%- for prop in fins['properties']['properties'] %}
    {%- for n in range(prop['length']) %}
    {%- if (prop['type']|lower == 'read-write-internal') or (prop['type']|lower == 'read-write-data') %}
    "{% for b in range(fins['properties']['data_width']-prop['width']) %}0{% endfor %}{% for b in range(prop['width']) %}1{% endfor %}",
    {%- else %}
    std_logic_vector(to_unsigned(0, G_DATA_WIDTH)),
    {%- endif %}
    {%- endfor %}
    {%- endfor %}
    others => (others => '0')
  );

  ------------------------------------------------------------------------------
  -- Decoded signals
  ------------------------------------------------------------------------------
  -- Word-indexed address
  signal address : std_logic_vector(G_ADDR_WIDTH-1 downto 0);

  ------------------------------------------------------------------------------
  -- Register Signals
  ------------------------------------------------------------------------------
  -- Registered array signals that have an element per physical address
  signal reg_wr_enables_foreach_addr : std_logic_vector(0 to NUM_ADDRESSES-1);
  signal reg_wr_values_foreach_addr  : t_reg_array(0 to NUM_ADDRESSES-1) := REG_DEFAULT_FOREACH_ADDR;
  signal reg_rd_enables_foreach_addr : std_logic_vector(0 to NUM_ADDRESSES-1);
  signal reg_rd_valids_foreach_addr  : std_logic_vector(0 to NUM_ADDRESSES-1);
  signal reg_rd_values_foreach_addr  : t_reg_array(0 to NUM_ADDRESSES-1);

  -- Registered AXI write data signal
  signal reg_wr_data : std_logic_vector(G_DATA_WIDTH-1 downto 0);

  -- Registered array signals that have an element per property
  signal reg_wr_enables_foreach_prop : std_logic_vector(0 to NUM_PROPERTIES-1);
  signal reg_addr_foreach_prop       : t_addr_array(0 to NUM_PROPERTIES-1);
  signal reg_rd_enables_foreach_prop : std_logic_vector(0 to NUM_PROPERTIES-1);

begin

  ------------------------------------------------------------------------------
  -- Register Decode, Read, and Write
  ------------------------------------------------------------------------------
  -- Combinatorial process to convert address to word indexed
  c_convert_to_word_indexed : process (s_swconfig_address)
  begin
    if (G_BYTE_INDEXED) then
      address <= std_logic_vector(shift_right(unsigned(s_swconfig_address), ADDR_LSB));
    else
      address <= s_swconfig_address;
    end if;
  end process c_convert_to_word_indexed;

  -- Synchronous Process for Register Write
  s_reg_write : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      --****************************************
      -- Data registers without reset
      --****************************************
      -- Pipeline the write data
      reg_wr_data <= s_swconfig_wr_data;

      -- Pipeline the write address for all properties
      for prop_ix in 0 to NUM_PROPERTIES-1 loop
        reg_addr_foreach_prop(prop_ix) <= std_logic_vector(unsigned(address)-PROPERTIES_OFFSETS(prop_ix));
      end loop;

      --****************************************
      -- Control registers with reset
      --****************************************
      if (s_swconfig_reset = '1') then
        reg_wr_enables_foreach_addr <= (others => '0');
        reg_wr_enables_foreach_prop <= (others => '0');
      else
        -- Set defaults
        reg_wr_enables_foreach_addr <= (others => '0');
        reg_wr_enables_foreach_prop <= (others => '0');

        -- Loop through all registers
        for addr_ix in 0 to NUM_ADDRESSES-1 loop
          -- Decode Address
          if (addr_ix = unsigned(address)) then
            -- Set the write enables
            -- Note: The reg_wr_enables_foreach_prop(addr_ix) may be set multiple times
            --       by this loop; this behavior performs a reduction OR
            if (s_swconfig_wr_enable = '1') then
              reg_wr_enables_foreach_addr(addr_ix) <= '1';
              reg_wr_enables_foreach_prop(ADDRESS_TO_PROPERTY_MAP(addr_ix)) <= '1';
            end if;
          end if;
        end loop;
      end if;
    end if;
  end process s_reg_write;

  -- Synchronous Process for Write of Local Registers
  s_reg_write_local : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      if (s_swconfig_reset = '1') then
        reg_wr_values_foreach_addr <= REG_DEFAULT_FOREACH_ADDR;
      else
        -- Loop through all registers and then all bits
        for addr_ix in 0 to NUM_ADDRESSES-1 loop
          for bit_ix in 0 to G_DATA_WIDTH-1 loop
            if (REG_WR_MASK_FOREACH_ADDR(addr_ix)(bit_ix) = '1') then
              -- The bit of the register is writable, write it when enabled at runtime, otherwise hold
              if (reg_wr_enables_foreach_addr(addr_ix) = '1') then
                reg_wr_values_foreach_addr(addr_ix)(bit_ix) <= reg_wr_data(bit_ix);
              end if;
            else
              -- The bit of the register is not writable, set it to default constant at compile time
              reg_wr_values_foreach_addr(addr_ix)(bit_ix) <= REG_DEFAULT_FOREACH_ADDR(addr_ix)(bit_ix);
            end if;
          end loop;
        end loop;
      end if;
    end if;
  end process s_reg_write_local;

  -- Synchronous Process for Register Read
  s_reg_read : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      if (s_swconfig_reset = '1') then
        reg_rd_enables_foreach_addr <= (others => '0');
        reg_rd_enables_foreach_prop <= (others => '0');
        s_swconfig_rd_valid <= '0';
        s_swconfig_rd_data <= ERROR_CODE(G_DATA_WIDTH-1 downto 0);
      else
        -- Set Default
        reg_rd_enables_foreach_addr <= (others => '0');
        reg_rd_enables_foreach_prop <= (others => '0');
        s_swconfig_rd_valid <= s_swconfig_rd_enable;
        s_swconfig_rd_data <= ERROR_CODE(G_DATA_WIDTH-1 downto 0);

        -- Loop through Registers
        for addr_ix in 0 to NUM_ADDRESSES-1 loop
          -- Decode Address
          if (addr_ix = unsigned(address)) then
            -- Set read signals
            -- Note: The reg_rd_enables_foreach_prop(addr_ix) may be set multiple times
            --       by this loop; this behavior performs a reduction OR
            if (s_swconfig_rd_enable = '1') then
              reg_rd_enables_foreach_addr(addr_ix) <= '1';
              reg_rd_enables_foreach_prop(ADDRESS_TO_PROPERTY_MAP(addr_ix)) <= '1';
            end if;
            s_swconfig_rd_valid <= reg_rd_valids_foreach_addr(addr_ix);
            s_swconfig_rd_data <= reg_rd_values_foreach_addr(addr_ix);
          end if;
        end loop;
      end if;
    end if;
  end process s_reg_read;

  ------------------------------------------------------------------------------
  -- Input/Output Assignment for Properties
  ------------------------------------------------------------------------------
  -- Combinatorial Process to Remap Property Control Signals
  c_props_control : process (
    reg_wr_enables_foreach_addr,
    reg_rd_enables_foreach_addr,
    reg_wr_values_foreach_addr,
    reg_wr_enables_foreach_prop,
    reg_rd_enables_foreach_prop,
    reg_addr_foreach_prop,
    reg_wr_data
  )
  begin
    {%- for prop in fins['properties']['properties'] %}
    {%- if (prop['length'] > 1) %}
    {%- if ('memmap' in prop['type']) %}
    {%- if prop['type'] == 'read-only-memmap' %}
    -- Remap control signals for read-only-memmap sequence property
    props_control.{{ prop['name'] }}.rd_en   <= reg_rd_enables_foreach_prop({{ loop.index0 }});
    props_control.{{ prop['name'] }}.rd_addr <= reg_addr_foreach_prop({{ loop.index0 }})(integer(ceil(log2(real({{ prop['length'] }}))))-1 downto 0);
    {%- elif prop['type'] == 'write-only-memmap' %}
    -- Remap control signals for write-only-memmap sequence property
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
    props_control.{{ prop['name'] }}.wr_en   <= reg_wr_enables_foreach_prop({{ loop.index0 }});
    props_control.{{ prop['name'] }}.wr_addr <= reg_addr_foreach_prop({{ loop.index0 }})(integer(ceil(log2(real({{ prop['length'] }}))))-1 downto 0);
    {%- elif prop['type'] == 'read-write-memmap' %}
    -- Remap control signals for read-write-memmap sequence property
    props_control.{{ prop['name'] }}.rd_en   <= reg_rd_enables_foreach_prop({{ loop.index0 }});
    props_control.{{ prop['name'] }}.rd_addr <= reg_addr_foreach_prop({{ loop.index0 }})(integer(ceil(log2(real({{ prop['length'] }}))))-1 downto 0);
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
    props_control.{{ prop['name'] }}.wr_en   <= reg_wr_enables_foreach_prop({{ loop.index0 }});
    props_control.{{ prop['name'] }}.wr_addr <= reg_addr_foreach_prop({{ loop.index0 }})(integer(ceil(log2(real({{ prop['length'] }}))))-1 downto 0);
    {%- endif %}
    {%- else %}
    {%- if prop['type'] == 'read-only-external' %}
    -- Remap control signals by looping through the elements of read-only-external sequence property
    for ix in 0 to {{ prop['length'] }}-1 loop
      props_control.{{ prop['name'] }}(ix).rd_en   <= reg_rd_enables_foreach_addr({{ prop['offset'] }}+ix);
    end loop;
    {%- elif prop['type'] == 'write-only-external' %}
    -- Remap control signals by looping through the elements of write-only-external sequence property
    for ix in 0 to {{ prop['length'] }}-1 loop
      props_control.{{ prop['name'] }}(ix).wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
      props_control.{{ prop['name'] }}(ix).wr_en   <= reg_wr_enables_foreach_addr({{ prop['offset'] }}+ix);
    end loop;
    {%- elif prop['type'] == 'read-write-data' %}
    -- Remap control signals by looping through the elements of read-write-data sequence property
    for ix in 0 to {{ prop['length'] }}-1 loop
      props_control.{{ prop['name'] }}(ix).wr_data <= reg_wr_values_foreach_addr({{ prop['offset'] }}+ix)({{ prop['width'] }}-1 downto 0);
    end loop;
    {%- elif prop['type'] == 'read-write-external' %}
    -- Remap control signals by looping through the elements of read-write-external sequence property
    for ix in 0 to {{ prop['length'] }}-1 loop
      props_control.{{ prop['name'] }}(ix).rd_en   <= reg_rd_enables_foreach_addr({{ prop['offset'] }}+ix);
      props_control.{{ prop['name'] }}(ix).wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
      props_control.{{ prop['name'] }}(ix).wr_en   <= reg_wr_enables_foreach_addr({{ prop['offset'] }}+ix);
    end loop;
    {%- endif %}
    {%- endif %}
    {%- else %}
    {%- if prop['type'] == 'read-only-external' %}
    -- Remap control signals for non-sequence read-only-external property
    props_control.{{ prop['name'] }}.rd_en   <= reg_rd_enables_foreach_addr({{ prop['offset'] }});
    {%- elif prop['type'] == 'read-only-memmap' %}
    -- Remap control signals for non-sequence read-only-memmap property
    props_control.{{ prop['name'] }}.rd_en   <= reg_rd_enables_foreach_addr({{ prop['offset'] }});
    props_control.{{ prop['name'] }}.rd_addr <= (others => '0');
    {%- elif prop['type'] == 'write-only-external' %}
    -- Remap control signals for non-sequence write-only-external property
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
    props_control.{{ prop['name'] }}.wr_en   <= reg_wr_enables_foreach_addr({{ prop['offset'] }});
    {%- elif prop['type'] == 'write-only-memmap' %}
    -- Remap control signals for non-sequence write-only-memmap property
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
    props_control.{{ prop['name'] }}.wr_en   <= reg_wr_enables_foreach_addr({{ prop['offset'] }});
    props_control.{{ prop['name'] }}.wr_addr <= (others => '0');
    {%- elif prop['type'] == 'read-write-data' %}
    -- Remap control signals for non-sequence read-write-data property
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_values_foreach_addr({{ prop['offset'] }})({{ prop['width'] }}-1 downto 0);
    {%- elif prop['type'] == 'read-write-external' %}
    -- Remap control signals for non-sequence read-write-external property
    props_control.{{ prop['name'] }}.rd_en   <= reg_rd_enables_foreach_addr({{ prop['offset'] }});
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
    props_control.{{ prop['name'] }}.wr_en   <= reg_wr_enables_foreach_addr({{ prop['offset'] }});
    {%- elif prop['type'] == 'read-write-memmap' %}
    -- Remap control signals for non-sequence read-write-memmap property
    props_control.{{ prop['name'] }}.rd_en   <= reg_rd_enables_foreach_addr({{ prop['offset'] }});
    props_control.{{ prop['name'] }}.rd_addr <= (others => '0');
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
    props_control.{{ prop['name'] }}.wr_en   <= reg_wr_enables_foreach_addr({{ prop['offset'] }});
    props_control.{{ prop['name'] }}.wr_addr <= (others => '0');
    {%- endif %}
    {%- endif %}
    {%- endfor %}
  end process c_props_control;

  -- Synchronous Process to Assign Inputs
  s_props_status : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      --****************************************
      -- Data registers without reset
      --****************************************
      -- Set defaults
      -- NOTE: The default case covers read responses from internal registers and invalid addresses
      reg_rd_values_foreach_addr <= reg_wr_values_foreach_addr;

      {%- for prop in fins['properties']['properties'] %}
      {%- if (prop['length'] > 1) %}
      {%- if ('memmap' in prop['type']) %}
      {%- if prop['type'] != 'write-only-memmap' %}
      -- Assign read values by looping through the elements of sequence memmap property
      for ix in 0 to {{ prop['length'] }}-1 loop
        reg_rd_values_foreach_addr({{ prop['offset'] }}+ix)({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}.rd_data;
      end loop;
      {%- endif %}
      {%- else %}
      {%- if prop['type'] == 'read-only-data' %}
      -- Assign read values by looping through the elements of sequence read-only-data property
      for ix in 0 to {{ prop['length'] }}-1 loop
        reg_rd_values_foreach_addr({{ prop['offset'] }}+ix)({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}(ix).rd_data;
      end loop;
      {%- elif prop['type'] == 'read-only-external' %}
      -- Assign read values by looping through the elements of sequence read-only-external property
      for ix in 0 to {{ prop['length'] }}-1 loop
        reg_rd_values_foreach_addr({{ prop['offset'] }}+ix)({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}(ix).rd_data;
      end loop;
      {%- elif prop['type'] == 'read-write-external' %}
      -- Assign read values by looping through the elements of sequence read-write-external property
      for ix in 0 to {{ prop['length'] }}-1 loop
        reg_rd_values_foreach_addr({{ prop['offset'] }}+ix)({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}(ix).rd_data;
      end loop;
      {%- endif %}
      {%- endif %}
      {%- else %}
      {%- if prop['type'] == 'read-only-data' %}
      -- Assign read value for non-sequence read-only-data property
      reg_rd_values_foreach_addr({{ prop['offset'] }})({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}.rd_data;
      {%- elif prop['type'] == 'read-only-external' %}
      -- Assign read value for non-sequence read-only-external property
      reg_rd_values_foreach_addr({{ prop['offset'] }})({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}.rd_data;
      {%- elif prop['type'] == 'read-only-memmap' %}
      -- Assign read value for non-sequence read-only-memmap property
      reg_rd_values_foreach_addr({{ prop['offset'] }})({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}.rd_data;
      {%- elif prop['type'] == 'read-write-external' %}
      -- Assign read value for non-sequence read-write-external property
      reg_rd_values_foreach_addr({{ prop['offset'] }})({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}.rd_data;
      {%- elif prop['type'] == 'read-write-memmap' %}
      -- Assign read value for non-sequence read-write-memmap property
      reg_rd_values_foreach_addr({{ prop['offset'] }})({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}.rd_data;
      {%- endif %}
      {%- endif %}
      {%- endfor %}

      --****************************************
      -- Control registers with reset
      --****************************************
      if (s_swconfig_reset = '1') then
        reg_rd_valids_foreach_addr <= (others => '0');
      else
        -- Set defaults
        -- NOTE: The default case covers read responses from internal registers and invalid addresses
        reg_rd_valids_foreach_addr <= reg_rd_enables_foreach_addr;

        {%- for prop in fins['properties']['properties'] %}
        {%- if (prop['length'] > 1) %}
        {%- if ('memmap' in prop['type']) %}
        {%- if prop['type'] != 'write-only-memmap' %}
        -- Assign read valids by looping through the elements of sequence memmap property
        for ix in 0 to {{ prop['length'] }}-1 loop
          reg_rd_valids_foreach_addr({{ prop['offset'] }}+ix) <= props_status.{{ prop['name'] }}.rd_valid;
        end loop;
        {%- endif %}
        {%- else %}
        {%- if prop['type'] == 'read-only-external' %}
        -- Assign read valids by looping through the elements of sequence read-only-external property
        for ix in 0 to {{ prop['length'] }}-1 loop
          reg_rd_valids_foreach_addr({{ prop['offset'] }}+ix) <= props_status.{{ prop['name'] }}(ix).rd_valid;
        end loop;
        {%- elif prop['type'] == 'read-write-external' %}
        -- Assign read valids by looping through the elements of sequence read-write-external property
        for ix in 0 to {{ prop['length'] }}-1 loop
          reg_rd_valids_foreach_addr({{ prop['offset'] }}+ix) <= props_status.{{ prop['name'] }}(ix).rd_valid;;
        end loop;
        {%- endif %}
        {%- endif %}
        {%- else %}
        {%- if prop['type'] == 'read-only-external' %}
        -- Assign read valid for non-sequence read-only-external property
        reg_rd_valids_foreach_addr({{ prop['offset'] }}) <= props_status.{{ prop['name'] }}.rd_valid;
        {%- elif prop['type'] == 'read-only-memmap' %}
        -- Assign read valid for non-sequence read-only-memmap property
        reg_rd_valids_foreach_addr({{ prop['offset'] }}) <= props_status.{{ prop['name'] }}.rd_valid;
        {%- elif prop['type'] == 'read-write-external' %}
        -- Assign read valid for non-sequence read-write-external property
        reg_rd_valids_foreach_addr({{ prop['offset'] }}) <= props_status.{{ prop['name'] }}.rd_valid;
        {%- elif prop['type'] == 'read-write-memmap' %}
        -- Assign read valid for non-sequence read-write-memmap property
        reg_rd_valids_foreach_addr({{ prop['offset'] }}) <= props_status.{{ prop['name'] }}.rd_valid;
        {%- endif %}
        {%- endif %}
        {%- endfor %}
      end if;
    end if;
  end process s_props_status;

end rtl;
