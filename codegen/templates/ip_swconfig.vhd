--==============================================================================
-- Company:     Geon Technologies, LLC
-- Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this 
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: Auto-generated Software Configuration Bus register decode
-- Generated:   {{ now }}
-- Reset Type:  Synchronous
-- Latency:     With G_BAR_WIDTH > 0:
--                * Local Write = 3 Clocks
--                * Remote Write = 3 Clocks Minimum
--                * Invalid Base Address Region Read = 1 Clocks
--                * Invalid Register Address Read = 2 Clocks
--                * Valid Local Read = 4 Clocks
--                * Valid Remote Read = 4 Clocks Minimum
--              With G_BAR_WIDTH == 0:
--                * Local Write = 2 Clocks
--                * Remote Write = 2 Clocks Minimum
--                * Invalid Base Address Region Read = 1 Clocks
--                * Invalid Register Address Read = 2 Clocks
--                * Valid Local Read = 3 Clocks
--                * Valid Remote Read = 3 Clocks Minimum
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Entity
entity {{ fins['name'] }}_swconfig is
  generic (
    G_ADDR_WIDTH : natural := {{ fins['swconfig']['addr_width'] }};
    G_DATA_WIDTH : natural := {{ fins['swconfig']['data_width'] }};
    G_BAR_WIDTH  : natural := {{ fins['swconfig']['bar_width'] }}
  );
  port (
    --**********************************************************
    -- Slave Software Configuration Bus
    --**********************************************************
    s_swconfig_clk       : in  std_logic;
    s_swconfig_reset     : in  std_logic;
    s_swconfig_address   : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    s_swconfig_wr_enable : in  std_logic;
    s_swconfig_wr_data   : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    s_swconfig_rd_enable : in  std_logic;
    s_swconfig_rd_valid  : out std_logic;
    s_swconfig_rd_data   : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    {%- for region in fins['swconfig']['regions'] %}
    {%- if (not 'regs' in region) or (region['regs'] | selectattr('is_ram') | list | length > 0) %}
    --**********************************************************
    -- Decoded Passthrough Master Software Configuration Bus
    --**********************************************************
    m_swconfig_{{ region['name'] }}_clk       : out std_logic;
    m_swconfig_{{ region['name'] }}_reset     : out std_logic;
    m_swconfig_{{ region['name'] }}_address   : out std_logic_vector(G_ADDR_WIDTH-G_BAR_WIDTH-1 downto 0);
    m_swconfig_{{ region['name'] }}_wr_enable : out std_logic;
    m_swconfig_{{ region['name'] }}_wr_data   : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    m_swconfig_{{ region['name'] }}_rd_enable : out std_logic;
    m_swconfig_{{ region['name'] }}_rd_valid  : in  std_logic;
    m_swconfig_{{ region['name'] }}_rd_data   : in  std_logic_vector(G_DATA_WIDTH-1 downto 0)
    {%- else %}
    --**********************************************************
    -- Registers for Region: {{ region['name'] }}
    --**********************************************************
    {%- for reg in region['regs'] | selectattr('is_writable') | selectattr('is_ram', 'eq', False) | selectattr('write_ports', 'ne', 'internal') | list %}
    {%- if (reg['write_ports'] | lower) == 'remote' %}
    {{ region['name'] }}_{{ reg['name'] }}_wr_en    : out std_logic_vector({{ reg['length'] }}-1 downto 0);
    {%- endif %}
    {{ region['name'] }}_{{ reg['name'] }}_wr_data  : out std_logic_vector({{ reg['width'] }}*{{ reg['length'] }}-1 downto 0)
    {%- if (region['regs'] | selectattr('is_readable') | selectattr('read_ports', 'ne', 'internal') | list | length > 0) or (not loop.last) %};{% endif %}
    {%- endfor %}
    {%- for reg in region['regs'] | selectattr('is_readable') | selectattr('is_ram', 'eq', False) | selectattr('read_ports', 'ne', 'internal') | list %}
    {%- if (reg['read_ports'] | lower) == 'remote' %}
    {{ region['name'] }}_{{ reg['name'] }}_rd_en    : out std_logic_vector({{ reg['length'] }}-1 downto 0);
    {{ region['name'] }}_{{ reg['name'] }}_rd_valid : in  std_logic_vector({{ reg['length'] }}-1 downto 0);
    {%- endif %}
    {{ region['name'] }}_{{ reg['name'] }}_rd_data  : in  std_logic_vector({{ reg['width'] }}*{{ reg['length'] }}-1 downto 0)
    {%- if not loop.last %};{% endif %}
    {%- endfor %}
    {%- endif %}
    {%- if not loop.last -%};{%- endif -%}
    {%- endfor %}
  );
end {{ fins['name'] }}_swconfig;

architecture rtl of {{ fins['name'] }}_swconfig is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- The maximum software configuration data width
  constant MAX_DATA_WIDTH : natural := 32;

  -- Error code when address does not correspond to a register
  constant ERROR_CODE : std_logic_vector(MAX_DATA_WIDTH-1 downto 0) := x"BADADD00";

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

  {%- for region in fins['swconfig']['regions'] %}
  {%- if (not 'regs' in region) or (region['regs'] | selectattr('is_ram') | list | length > 0) %}
  -- Infer swconfig bus on master interface for {{ region['name'] }}
  attribute X_INTERFACE_INFO of m_swconfig_{{ region['name'] }}_clk       : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG CLK";
  attribute X_INTERFACE_INFO of m_swconfig_{{ region['name'] }}_reset     : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG RESET";
  attribute X_INTERFACE_INFO of m_swconfig_{{ region['name'] }}_address   : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG ADDRESS";
  attribute X_INTERFACE_INFO of m_swconfig_{{ region['name'] }}_wr_enable : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG WR_ENABLE";
  attribute X_INTERFACE_INFO of m_swconfig_{{ region['name'] }}_wr_data   : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG WR_DATA";
  attribute X_INTERFACE_INFO of m_swconfig_{{ region['name'] }}_rd_enable : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG RD_ENABLE";
  attribute X_INTERFACE_INFO of m_swconfig_{{ region['name'] }}_rd_valid  : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG RD_VALID";
  attribute X_INTERFACE_INFO of m_swconfig_{{ region['name'] }}_rd_data   : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG RD_DATA";
  {%- endif %}
  {%- endfor %}

  {%- for region in fins['swconfig']['regions'] %}
  {%- if ('regs' in region) and (region['regs'] | selectattr('is_ram') | list | length == 0) %}
  ------------------------------------------------------------------------------
  -- Signals: Decoded "{{ region['name'] }}" base address region
  ------------------------------------------------------------------------------
  -- The total number of physical registers (addresses)
  -- * Logical registers can have a length>1, so this is the sum of all logical
  --   register lengths
  constant {{ region['name'] | upper }}_NUM_REGS : natural := {{ region['regs']|sum(attribute='length') }};

  -- Default for Local Registers
  constant {{ region['name'] }}_reg_default : std_logic_vector(G_DATA_WIDTH*{{ region['name'] | upper }}_NUM_REGS-1 downto 0) :=
    {%- for reg in region['regs']|reverse|list -%}
    {%- set reg_loop = loop -%}
    {%- for value in reg['default_values']|reverse|list %}
    {%- if reg['is_signed'] %}
    std_logic_vector(resize(to_signed({{ value }}, {{ reg['width'] }}), G_DATA_WIDTH))
    {%- else %}
    std_logic_vector(resize(to_unsigned({{ value }}, {{ reg['width'] }}), G_DATA_WIDTH))
    {%- endif -%}
    {%- if loop.last and reg_loop.last %};{% else %} &{% endif %} -- {{ reg['name'] }}, {% if reg['is_writable'] %}WRITE:{{ reg['write_ports'] }}, {% endif %}{% if reg['is_readable'] %}READ:{{ reg['read_ports'] }}{% endif %}
    {%- endfor -%}
    {% endfor %}

  -- The Bit Mask for Writable Local Register Values
  -- Note: The mask prevents bits from being written in invalid areas.
  --       Remote registers have an entry here, but they are set to all zeros 
  --       since the write is happing in a remote location
  constant {{ region['name'] }}_reg_wr_mask : std_logic_vector(G_DATA_WIDTH*{{ region['name'] | upper }}_NUM_REGS-1 downto 0) :=
    {%- for reg in region['regs'] | reverse | list %}
    {%- set reg_loop = loop %}
    {%- for n in range(reg['length']) %}
    {%- if (reg['write_ports'] | lower) == 'remote' %}
    std_logic_vector(to_unsigned(0, G_DATA_WIDTH))
    {%- elif reg['is_writable'] and ((reg['width'] == 32) or (reg['width'] == '32')) %}
    x"FFFFFFFF"
    {%- else %}
    std_logic_vector(resize(unsigned(to_signed({% if reg['is_writable'] %}-1{% else %}0{% endif %}, {{ reg['width'] }})), G_DATA_WIDTH))
    {%- endif %}
    {%- if loop.last and reg_loop.last %};{% else %} &{% endif %} -- {{ reg['name'] }}, {% if reg['is_writable'] %}WRITE:{{ reg['write_ports'] }}, {% endif %}{% if reg['is_readable'] %}READ:{{ reg['read_ports'] }}{% endif %}
    {%- endfor %}
    {%- endfor %}

  -- Software Configuration Bus Signals
  signal m_swconfig_{{ region['name'] }}_address   : std_logic_vector(G_ADDR_WIDTH-G_BAR_WIDTH-1 downto 0);
  signal m_swconfig_{{ region['name'] }}_wr_enable : std_logic;
  signal m_swconfig_{{ region['name'] }}_wr_data   : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal m_swconfig_{{ region['name'] }}_rd_enable : std_logic;
  signal m_swconfig_{{ region['name'] }}_rd_valid  : std_logic;
  signal m_swconfig_{{ region['name'] }}_rd_data   : std_logic_vector(G_DATA_WIDTH-1 downto 0);

  -- Register Signals
  signal {{ region['name'] }}_reg_wr_enables : std_logic_vector({{ region['name'] | upper }}_NUM_REGS-1 downto 0); -- Registered Array of Decoded Write Enables
  signal {{ region['name'] }}_reg_wr_values  : std_logic_vector(G_DATA_WIDTH*{{ region['name'] | upper }}_NUM_REGS-1 downto 0) := {{ region['name'] }}_reg_default; -- Registered Array Writable Local Registers
  signal {{ region['name'] }}_reg_wr_data    : std_logic_vector(G_DATA_WIDTH-1 downto 0); -- Registered Write Data
  signal {{ region['name'] }}_reg_rd_enables : std_logic_vector({{ region['name'] | upper }}_NUM_REGS-1 downto 0); -- Registered Array of Decoded Read Enables
  signal {{ region['name'] }}_reg_rd_valids  : std_logic_vector({{ region['name'] | upper }}_NUM_REGS-1 downto 0); -- Non-registered Array of Decoded Read Valids
  signal {{ region['name'] }}_reg_rd_values  : std_logic_vector(G_DATA_WIDTH*{{ region['name'] | upper }}_NUM_REGS-1 downto 0); -- Non-registered Array of Read Data
  {%- endif %}
  {%- endfor %}

begin

  {%- for region in fins['swconfig']['regions'] %}
  {%- if (not 'regs' in region) or (region['regs'] | selectattr('is_ram') | list | length > 0) %}
  -- Passthrough Clock and Reset: {{ region['name'] }}
  m_swconfig_{{ region['name'] }}_clk   <= s_swconfig_clk;
  m_swconfig_{{ region['name'] }}_reset <= s_swconfig_reset;
  {%- endif %}
  {%- endfor %}

  ------------------------------------------------------------------------------
  -- Base Address Regions Decode
  ------------------------------------------------------------------------------
  {%- if fins['swconfig']['bar_width'] > 0 %}
  -- Synchronous Process for Decoding the Base Address Regions
  s_bar_decode : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      -- Software Configuration Data
      {%- for region in fins['swconfig']['regions'] %}
      m_swconfig_{{ region['name'] }}_wr_data <= s_swconfig_wr_data;
      {%- endfor %}

      if (s_swconfig_reset = '1') then
        -- Software Configuration Master Control Signals
        {%- for region in fins['swconfig']['regions'] %}
        m_swconfig_{{ region['name'] }}_wr_enable <= '0';
        m_swconfig_{{ region['name'] }}_rd_enable <= '0';
        m_swconfig_{{ region['name'] }}_address   <= (others => '0');
        {%- endfor %}
        -- Software Configuration Slave Control Signals
        s_swconfig_rd_valid <= '0';
        s_swconfig_rd_data  <= (others => '0');
      else
        -- Set Defaults: Software Configuration Master Control Signals
        {%- for region in fins['swconfig']['regions'] %}
        m_swconfig_{{ region['name'] }}_wr_enable <= '0';
        m_swconfig_{{ region['name'] }}_rd_enable <= '0';
        m_swconfig_{{ region['name'] }}_address   <= s_swconfig_address(G_ADDR_WIDTH-G_BAR_WIDTH-1 downto 0);
        {%- endfor %}

        -- Set Defaults: Software Configuration Slave Control Signals
        s_swconfig_rd_valid <= s_swconfig_rd_enable;
        s_swconfig_rd_data  <= ERROR_CODE(MAX_DATA_WIDTH-1 downto MAX_DATA_WIDTH-G_DATA_WIDTH);

        -- Decode base address region
        {%- for region in fins['swconfig']['regions'] %}
        if ({{ loop.index0 }} = unsigned(s_swconfig_address(G_ADDR_WIDTH-1 downto G_ADDR_WIDTH-G_BAR_WIDTH))) then
          m_swconfig_{{ region['name'] }}_wr_enable <= s_swconfig_wr_enable;
          m_swconfig_{{ region['name'] }}_rd_enable <= s_swconfig_rd_enable;
          s_swconfig_rd_valid <= m_swconfig_{{ region['name'] }}_rd_valid;
          s_swconfig_rd_data  <= m_swconfig_{{ region['name'] }}_rd_data;
        end if;
        {%- endfor %}
      end if;
    end if;
  end process s_bar_decode;
  {%- else %}
  -- No decode necessary since G_BAR_WIDTH is 0
  {%- for region in fins['swconfig']['regions'] %}
  m_swconfig_{{ region['name'] }}_address   <= s_swconfig_address;
  m_swconfig_{{ region['name'] }}_wr_enable <= s_swconfig_wr_enable;
  m_swconfig_{{ region['name'] }}_wr_data   <= s_swconfig_wr_data;
  m_swconfig_{{ region['name'] }}_rd_enable <= s_swconfig_rd_enable;
  s_swconfig_rd_valid <= m_swconfig_{{ region['name'] }}_rd_valid;
  s_swconfig_rd_data  <= m_swconfig_{{ region['name'] }}_rd_data;
  {%- endfor %}
  {%- endif %}

  {%- for region in fins['swconfig']['regions'] %}
  {%- if ('regs' in region) and (region['regs'] | selectattr('is_ram') | list | length == 0) %}
  ------------------------------------------------------------------------------
  -- Local Register Decode for "{{ region['name'] }}" Base Address Region
  ------------------------------------------------------------------------------
  -- Synchronous Process for Register Write
  s_{{ region['name'] }}_write : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      -- Pipeline the write data for all registers
      {{ region['name'] }}_reg_wr_data <= m_swconfig_{{ region['name'] }}_wr_data;
      -- Control signals for the write
      if (s_swconfig_reset = '1') then
        {{ region['name'] }}_reg_wr_enables <= (others => '0');
      else
        -- Set defaults for write enables
        {{ region['name'] }}_reg_wr_enables <= (others => '0');
        -- Loop through all registers
        for reg_ix in 0 to {{ region['name'] | upper }}_NUM_REGS-1 loop
          -- Decode Address
          if (reg_ix = unsigned(m_swconfig_{{ region['name'] }}_address)) then
            -- Set the write enable
            {{ region['name'] }}_reg_wr_enables(reg_ix) <= m_swconfig_{{ region['name'] }}_wr_enable;
          end if;
        end loop;
      end if;
    end if;
  end process s_{{ region['name'] }}_write;

  -- Synchronous Process for Write of Local Registers
  s_{{ region['name'] }}_write_local : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      if (s_swconfig_reset = '1') then
        {{ region['name'] }}_reg_wr_values <= {{ region['name'] }}_reg_default;
      else
        -- Loop through all registers and then all bits
        for reg_ix in 0 to {{ region['name'] | upper }}_NUM_REGS-1 loop
          for bit_ix in 0 to G_DATA_WIDTH-1 loop
            if ({{ region['name'] }}_reg_wr_mask(reg_ix*G_DATA_WIDTH+bit_ix) = '1') then
              -- The bit of the register is writable, write it when enabled at runtime, otherwise hold
              if ({{ region['name'] }}_reg_wr_enables(reg_ix) = '1') then
                {{ region['name'] }}_reg_wr_values(reg_ix*G_DATA_WIDTH+bit_ix) <= {{ region['name'] }}_reg_wr_data(bit_ix);
              end if;
            else
              -- The bit of the register is not writable, set it to default constant at compile time
              {{ region['name'] }}_reg_wr_values(reg_ix*G_DATA_WIDTH+bit_ix) <= {{ region['name'] }}_reg_default(reg_ix*G_DATA_WIDTH+bit_ix);
            end if;
          end loop;
        end loop;
      end if;
    end if;
  end process s_{{ region['name'] }}_write_local;

  -- Synchronous Process for Register Read
  s_{{ region['name'] }}_read : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      if (s_swconfig_reset = '1') then
        {{ region['name'] }}_reg_rd_enables      <= (others => '0');
        m_swconfig_{{ region['name'] }}_rd_valid <= '0';
        m_swconfig_{{ region['name'] }}_rd_data  <= ERROR_CODE(MAX_DATA_WIDTH-1 downto MAX_DATA_WIDTH-G_DATA_WIDTH);
      else
        -- Set Default
        {{ region['name'] }}_reg_rd_enables      <= (others => '0');
        m_swconfig_{{ region['name'] }}_rd_valid <= m_swconfig_{{ region['name'] }}_rd_enable;
        m_swconfig_{{ region['name'] }}_rd_data  <= ERROR_CODE(MAX_DATA_WIDTH-1 downto MAX_DATA_WIDTH-G_DATA_WIDTH);

        -- Loop through Registers
        for reg_ix in 0 to {{ region['name'] | upper }}_NUM_REGS-1 loop
          -- Decode Address
          if (reg_ix = unsigned(m_swconfig_{{ region['name'] }}_address)) then
            -- Set read signals
            {{ region['name'] }}_reg_rd_enables(reg_ix) <= m_swconfig_{{ region['name'] }}_rd_enable;
            m_swconfig_{{ region['name'] }}_rd_valid    <= {{ region['name'] }}_reg_rd_valids(reg_ix);
            m_swconfig_{{ region['name'] }}_rd_data     <= {{ region['name'] }}_reg_rd_values((reg_ix+1)*G_DATA_WIDTH-1 downto reg_ix*G_DATA_WIDTH);
          end if;
        end loop;
      end if;
    end if;
  end process s_{{ region['name'] }}_read;

  ------------------------------------------------------------------------------
  -- Input/Output Assignment for "{{ region['name'] }}" Base Address Region
  ------------------------------------------------------------------------------
  -- Combinatorial Process to Assign Outputs
  c_{{ region['name'] }}_reg_outputs : process (
    {{ region['name'] }}_reg_wr_enables,
    {{ region['name'] }}_reg_rd_enables,
    {{ region['name'] }}_reg_wr_data,
    {{ region['name'] }}_reg_wr_values
  )
  begin
    {%- set data_word = {'index':0} %}
    {%- for reg in region['regs'] %}
    {%- if reg['is_readable'] %}
    {%- if (reg['read_ports'] | lower) == 'remote' %}
    {{ region['name'] }}_{{ reg['name'] }}_rd_en <= {{ region['name'] }}_reg_rd_enables({{ data_word['index'] }}+{{ reg['length'] }}-1 downto {{ data_word['index'] }});
    {%- endif %}
    {%- endif %}
    {%- if reg['is_writable'] %}
    {%- if (reg['write_ports'] | lower) == 'remote' %}
    {{ region['name'] }}_{{ reg['name'] }}_wr_en <= {{ region['name'] }}_reg_wr_enables({{ data_word['index'] }}+{{ reg['length'] }}-1 downto {{ data_word['index'] }});
    {%- endif %}
    {%- if (reg['write_ports'] | lower) == 'remote' %}
    for n in 0 to {{ reg['length'] }}-1 loop
      {{ region['name'] }}_{{ reg['name'] }}_wr_data((n+1)*{{ reg['width'] }}-1 downto n*{{ reg['width'] }}) <= {{ region['name'] }}_reg_wr_data({{ reg['width'] }}-1 downto 0);
    end loop;
    {%- elif (reg['write_ports'] | lower) == 'external' %}
    for n in 0 to {{ reg['length'] }}-1 loop
      {{ region['name'] }}_{{ reg['name'] }}_wr_data((n+1)*{{ reg['width'] }}-1 downto n*{{ reg['width'] }}) <= {{ region['name'] }}_reg_wr_values((n+{{ data_word['index'] }})*G_DATA_WIDTH+{{ reg['width'] }}-1 downto (n+{{ data_word['index'] }})*G_DATA_WIDTH);
    end loop;
    {%- endif %}
    {%- endif %}
    {%- set _ = data_word.update({'index':data_word['index'] + reg['length']}) %}
    {%- endfor %}
  end process c_{{ region['name'] }}_reg_outputs;

  -- Combinatorial Process to Assign Inputs
  c_{{ region['name'] }}_reg_inputs : process (
    {%- for reg in region['regs'] %}
    {%- if reg['is_readable'] %}
    {%- if (reg['read_ports'] | lower) == 'remote' %}
    {{ region['name'] }}_{{ reg['name'] }}_rd_valid,
    {%- endif %}
    {%- if (reg['read_ports'] | lower) != 'internal' %}
    {{ region['name'] }}_{{ reg['name'] }}_rd_data,
    {%- endif %}
    {%- endif %}
    {%- endfor %}
    {{ region['name'] }}_reg_rd_enables,
    {{ region['name'] }}_reg_wr_values
  )
  begin
    -- Set defaults
    {{ region['name'] }}_reg_rd_values <= {{ region['name'] }}_reg_wr_values;
    {{ region['name'] }}_reg_rd_valids <= {{ region['name'] }}_reg_rd_enables;

    {%- set data_word = {'index':0} %}
    {%- for reg in region['regs'] %}
    {%- if reg['is_readable'] %}
    {%- if (reg['read_ports'] | lower) == 'remote' %}
    {{ region['name'] }}_reg_rd_valids({{ data_word['index'] }}+{{ reg['length'] }}-1 downto {{ data_word['index'] }}) <= {{ region['name'] }}_{{ reg['name'] }}_rd_valid;
    {%- endif %}
    {%- if (reg['read_ports'] | lower) != 'internal' %}
    for n in 0 to {{ reg['length'] }}-1 loop
      {{ region['name'] }}_reg_rd_values({{ reg['width'] }}+(n+{{ data_word['index'] }})*G_DATA_WIDTH-1 downto (n+{{ data_word['index'] }})*G_DATA_WIDTH) <= {{ region['name'] }}_{{ reg['name'] }}_rd_data((n+1)*{{ reg['width'] }}-1 downto n*{{ reg['width'] }});
    end loop;
    {%- endif %}
    {%- endif %}
    {%- set _ = data_word.update({'index':data_word['index'] + reg['length']}) %}
    {%- endfor %}
  end process c_{{ region['name'] }}_reg_inputs;

  {%- endif %}
  {%- endfor %}

end rtl;
