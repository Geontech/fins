--==============================================================================
-- Company:     Geon Technologies, LLC
-- File:        {{ fins['name'] }}_regs.vhd
-- Description: Auto-generated from Jinja2 VHDL regs template
-- Generated:   {{ now }}
--==============================================================================

{%- set expanded_regions = [] %}
{%- for region in fins['regs']['regions'] %}
  {%- set temp_region = {'name':region['name'],'description':region['description'],'regs':[]} %}
  {%- for reg in region['regs'] if 'regs' in region %}
    {%- for param in fins['params'] if ((param['name'] == reg['default_values'][0]) and (param['value'] is iterable)) %}
      {%- for value in param['value'] %}
        {%- set temp = {'name':reg['name']~loop.index|string,
                        'width':reg['width'],
                        'default_values':[value],
                        'writable':reg['writable'],
                        'description':reg['description']} %}
        {%- set _dummy = temp_region['regs'].append(temp) %}
      {%- endfor %}
    {%- else %}
      {%- set temp = reg %}
      {%- set _dummy = temp_region['regs'].append(temp) %}
    {%- endfor %}
  {%- endfor %}
  {%- set _dummy = expanded_regions.append(temp_region) %}
{%- endfor %}

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- User Libraries
library work;
use work.{{ fins['name'] }}_params.all;

-- Entity
entity {{ fins['name'] }}_regs is
  generic (
    G_ADDR_WIDTH : natural := 16;
    G_DATA_WIDTH : natural := 32;
    G_BAR_WIDTH  : natural := 2
  );
  port (
    -- Slave Software Configuration Bus
    s_swconfig_clk       : in  std_logic;
    s_swconfig_reset     : in  std_logic;
    s_swconfig_address   : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    s_swconfig_wr_enable : in  std_logic;
    s_swconfig_wr_data   : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    s_swconfig_rd_enable : in  std_logic;
    s_swconfig_rd_valid  : out std_logic;
    s_swconfig_rd_data   : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    {% for region in expanded_regions -%}
    {% if not 'regs' in region -%}
    -- Decoded Passthrough Master Software Configuration Bus
    m_swconfig_{{ region['name'] }}_clk       : out std_logic;
    m_swconfig_{{ region['name'] }}_reset     : out std_logic;
    m_swconfig_{{ region['name'] }}_address   : out std_logic_vector(G_ADDR_WIDTH-G_BAR_WIDTH-1 downto 0);
    m_swconfig_{{ region['name'] }}_wr_enable : out std_logic;
    m_swconfig_{{ region['name'] }}_wr_data   : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    m_swconfig_{{ region['name'] }}_rd_enable : out std_logic;
    m_swconfig_{{ region['name'] }}_rd_valid  : in  std_logic;
    m_swconfig_{{ region['name'] }}_rd_data   : in  std_logic_vector(G_DATA_WIDTH-1 downto 0){%- if loop.index < loop.length -%};{%- endif -%}
    {% else -%}
    -- Register Inputs/Outputs
    {% for reg in region['regs'] %}
    {{ region['name'] }}_{{ reg['name'] }} : {% if reg['writable'] %}out{% else %}in {% endif %} std_logic_vector({{ reg['width'] }}-1 downto 0){% if loop.index < loop.length %};{% endif %}
    {%- endfor -%}
    {%- if loop.index < loop.length %};{% endif %}
    {% endif %}
    {% endfor %}
  );
end {{ fins['name'] }}_regs;

architecture rtl of {{ fins['name'] }}_regs is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  constant REG_RD_ERROR_CODE : std_logic_vector(G_DATA_WIDTH-1 downto 0) := x"BADADD00";

  {% for region in expanded_regions|selectattr('regs', 'defined')|list -%}
  ------------------------------------------------------------------------------
  -- Signals: Local Decode of "{{ region['name'] }}" base address region
  ------------------------------------------------------------------------------
  -- Locally Decoded Software Configuration Bus Signals
  signal m_swconfig_{{ region['name'] }}_address   : std_logic_vector(G_ADDR_WIDTH-G_BAR_WIDTH-1 downto 0);
  signal m_swconfig_{{ region['name'] }}_wr_enable : std_logic;
  signal m_swconfig_{{ region['name'] }}_wr_data   : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal m_swconfig_{{ region['name'] }}_rd_enable : std_logic;
  signal m_swconfig_{{ region['name'] }}_rd_valid  : std_logic;
  signal m_swconfig_{{ region['name'] }}_rd_data   : std_logic_vector(G_DATA_WIDTH-1 downto 0);

  -- Stored writable Register Values
  signal {{ region['name'] }}_reg_values    : std_logic_vector(G_DATA_WIDTH*{{ region['regs']|length }}-1 downto 0);

  -- Register Read Values
  -- Note: If not writable, then the read values come from an external source
  signal {{ region['name'] }}_reg_rd_values : std_logic_vector(G_DATA_WIDTH*{{ region['regs']|length }}-1 downto 0);

  -- Default for writable Register Values
  constant {{ region['name'] }}_reg_default : std_logic_vector(G_DATA_WIDTH*{{ region['regs']|length }}-1 downto 0) :=
    {% for reg in region['regs']|reverse|list -%}
    std_logic_vector(resize(to_unsigned({% if 'default_values' in reg %}{{ reg['default_values'][0] }}{% else %}0{% endif %}, {{ reg['width'] }}), G_DATA_WIDTH)){% if loop.index < loop.length %} &{% else %};{% endif %}
    {% endfor %}

  -- The Bit Mask for writable Register Values
  -- Note: The mask prevents bits from being written in invalid areas
  constant {{ region['name'] }}_reg_wr_mask : std_logic_vector(G_DATA_WIDTH*{{ region['regs']|length }}-1 downto 0) :=
    {% for reg in region['regs']|reverse|list -%}
    {% if reg['writable'] and ((reg['width'] == 32) or (reg['width'] == '32')) -%}
    x"FFFFFFFF"{% if loop.index < loop.length %} &{% else %};{% endif %}
    {% else -%}
    std_logic_vector(resize(to_unsigned({% if reg['writable'] %}2**{{ reg['width'] }}-1{% else %}0{% endif %}, {{ reg['width'] }}), G_DATA_WIDTH)){% if loop.index < loop.length %} &{% else %};{% endif %}
    {% endif -%}
    {% endfor %}

  {% endfor %}

begin

  ------------------------------------------------------------------------------
  -- Passthrough Clocks and Resets
  ------------------------------------------------------------------------------
  {% for region in expanded_regions|selectattr('regs', 'undefined')|list -%}
  m_swconfig_{{ region['name'] }}_clk   <= s_swconfig_clk;
  m_swconfig_{{ region['name'] }}_reset <= s_swconfig_reset;
  {% endfor %}

  ------------------------------------------------------------------------------
  -- Base Address Regions Decode
  ------------------------------------------------------------------------------
  s_bar_decode : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      -- Data
      {% for region in expanded_regions -%}
      m_swconfig_{{ region['name'] }}_wr_data <= s_swconfig_wr_data;
      {% endfor %}

      if (s_swconfig_reset = '1') then
        {% for region in expanded_regions -%}
        m_swconfig_{{ region['name'] }}_wr_enable <= '0';
        m_swconfig_{{ region['name'] }}_rd_enable <= '0';
        m_swconfig_{{ region['name'] }}_address   <= (others => '0');
        {% endfor %}
        s_swconfig_rd_valid <= '0';
        s_swconfig_rd_data  <= (others => '0');
      else
        -- Address
        {% for region in expanded_regions -%}
        m_swconfig_{{ region['name'] }}_address <= s_swconfig_address(G_ADDR_WIDTH-G_BAR_WIDTH-1 downto 0);
        {% endfor %}

        -- Set defaults
        -- Note: Read responds by default with this error code
        s_swconfig_rd_valid <= s_swconfig_rd_enable;
        s_swconfig_rd_data  <= REG_RD_ERROR_CODE;
        {% for region in expanded_regions -%}
        m_swconfig_{{ region['name'] }}_wr_enable <= '0';
        m_swconfig_{{ region['name'] }}_rd_enable <= '0';
        {% endfor %}

        -- Decode base address region
        {% if expanded_regions|length > 1 %}
        {% for region in expanded_regions -%}
        if ({{ loop.index-1 }} = unsigned(s_swconfig_address(G_ADDR_WIDTH-1 downto G_ADDR_WIDTH-G_BAR_WIDTH))) then
          m_swconfig_{{ region['name'] }}_wr_enable <= s_swconfig_wr_enable;
          m_swconfig_{{ region['name'] }}_rd_enable <= s_swconfig_rd_enable;
          s_swconfig_rd_valid <= m_swconfig_{{ region['name'] }}_rd_valid;
          s_swconfig_rd_data  <= m_swconfig_{{ region['name'] }}_rd_data;
        end if;
        {% endfor %}
        {% else %}
        {% for region in expanded_regions -%}
        m_swconfig_{{ region['name'] }}_wr_enable <= s_swconfig_wr_enable;
        m_swconfig_{{ region['name'] }}_rd_enable <= s_swconfig_rd_enable;
        s_swconfig_rd_valid <= m_swconfig_{{ region['name'] }}_rd_valid;
        s_swconfig_rd_data  <= m_swconfig_{{ region['name'] }}_rd_data;
        {% endfor %}
        {% endif %}
      end if;
    end if;
  end process s_bar_decode;

  {% for region in expanded_regions|selectattr('regs', 'defined')|list -%}
  ------------------------------------------------------------------------------
  -- Local Register Decode of "{{ region['name'] }}" base address region
  ------------------------------------------------------------------------------
  -- Synchronous Process for Register Write
  s_{{ region['name'] }}_write : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      if (s_swconfig_reset = '1') then
        {{ region['name'] }}_reg_values <= {{ region['name'] }}_reg_default;
      else
        -- Check if writing
        if (m_swconfig_{{ region['name'] }}_wr_enable = '1') then
          -- Loop through Registers
          for reg_ix in 0 to {{ region['regs']|length }}-1 loop
            -- Decode Address
            if (reg_ix = unsigned(m_swconfig_{{ region['name'] }}_address)) then
              -- Loop through Bits
              for bit_ix in 0 to G_DATA_WIDTH-1 loop
                -- Enabled and Masked Register Bit Assignment
                {{ region['name'] }}_reg_values(reg_ix*G_DATA_WIDTH+bit_ix) <= m_swconfig_{{ region['name'] }}_wr_data(bit_ix) AND {{ region['name'] }}_reg_wr_mask(reg_ix*G_DATA_WIDTH+bit_ix);
              end loop;
            end if;
          end loop;
        end if;
      end if;
    end if;
  end process s_{{ region['name'] }}_write;

  -- Synchronous Process for Register Read
  s_{{ region['name'] }}_read : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      if (s_swconfig_reset = '1') then
        m_swconfig_{{ region['name'] }}_rd_data  <= REG_RD_ERROR_CODE;
        m_swconfig_{{ region['name'] }}_rd_valid <= '0';
      else
        -- Set Default
        m_swconfig_{{ region['name'] }}_rd_data  <= REG_RD_ERROR_CODE;
        m_swconfig_{{ region['name'] }}_rd_valid <= '0';
        -- Check if reading
        if (m_swconfig_{{ region['name'] }}_rd_enable = '1') then
          -- Set read valid when read enable received
          m_swconfig_{{ region['name'] }}_rd_valid <= '1';
          -- Loop through Registers
          for reg_ix in 0 to {{ region['regs']|length }}-1 loop
            -- Decode Address
            if (reg_ix = unsigned(m_swconfig_{{ region['name'] }}_address)) then
              m_swconfig_{{ region['name'] }}_rd_data <= {{ region['name'] }}_reg_rd_values((reg_ix+1)*G_DATA_WIDTH-1 downto reg_ix*G_DATA_WIDTH);
            end if;
          end loop;
        end if;
      end if;
    end if;
  end process s_{{ region['name'] }}_read;

  -- Assign register outputs
  {% for reg in region['regs'] -%}
  {% if reg['writable'] -%}
  {{ region['name'] }}_{{ reg['name'] }} <= {{ region['name'] }}_reg_values({{ loop.index-1 }}*G_DATA_WIDTH+{{ reg['width'] }}-1 downto {{ loop.index-1 }}*G_DATA_WIDTH);
  {% endif -%}
  {% endfor %}

  -- Combinatorial Process to assign register read values
  c_{{ region['name'] }}_read : process (
    {% for reg in region['regs']|selectattr('writable', 'equalto', False)|list -%}
    {{ region['name'] }}_{{ reg['name'] }},
    {% endfor %}
    {{ region['name'] }}_reg_values
  )
  begin
    -- Set defaults
    {{ region['name'] }}_reg_rd_values <= {{ region['name'] }}_reg_values;

    -- Assign external read values
    {% for reg in region['regs'] -%}
    {% if not reg['writable'] -%}
    {{ region['name'] }}_reg_rd_values({{ loop.index-1 }}*G_DATA_WIDTH+{{ reg['width'] }}-1 downto {{ loop.index-1 }}*G_DATA_WIDTH) <= {{ region['name'] }}_{{ reg['name'] }};
    {% endif -%}
    {% endfor %}
  end process c_{{ region['name'] }}_read;

  {% endfor %}

end rtl;
