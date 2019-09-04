--==============================================================================
-- Company:     Geon Technologies, LLC
-- Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: Auto-generated AXI4-Stream Bus interpreter
-- Generated:   {{ now }}
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
entity {{ fins['name']|lower }}_axis is
  port (
    {%- for port in fins['ports']['ports'] %}
    {%- if port['direction']|lower == 'in' %}
    -- AXI4-Stream Input Port: {{ port['name']|lower }}
    s_axis_{{ port['name']|lower }}_aclk    : in  std_logic;
    s_axis_{{ port['name']|lower }}_aresetn : in  std_logic;
    {%- if port['supports_backpressure'] %}
    s_axis_{{ port['name']|lower }}_tready  : out std_logic;
    {%- endif %}
    {%- if 'data' in port %}
    s_axis_{{ port['name']|lower }}_tdata   : in  std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
    {%- endif %}
    {%- if 'metadata' in port %}
    s_axis_{{ port['name']|lower }}_tuser   : in  std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
    {%- endif %}
    s_axis_{{ port['name']|lower }}_tvalid  : in  std_logic;
    s_axis_{{ port['name']|lower }}_tlast   : in  std_logic;
    {%- else %}
    -- AXI4-Stream Output Port: {{ port['name']|lower }}
    m_axis_{{ port['name']|lower }}_aclk    : in  std_logic;
    m_axis_{{ port['name']|lower }}_aresetn : in  std_logic;
    {%- if port['supports_backpressure'] %}
    m_axis_{{ port['name']|lower }}_tready  : in  std_logic;
    {%- endif %}
    {%- if 'data' in port %}
    m_axis_{{ port['name']|lower }}_tdata   : out std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
    {%- endif %}
    {%- if 'metadata' in port %}
    m_axis_{{ port['name']|lower }}_tuser   : out std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
    {%- endif %}
    m_axis_{{ port['name']|lower }}_tvalid  : out std_logic;
    m_axis_{{ port['name']|lower }}_tlast   : out std_logic;
    {%- endif %}
    {%- endfor %}
    ports_in  : out t_{{ fins['name']|lower }}_ports_in;
    ports_out : in  t_{{ fins['name']|lower }}_ports_out
  );
end {{ fins['name']|lower }}_axis;

-- Architecture
architecture rtl of {{ fins['name']|lower }}_axis is

  ------------------------------------------------------------------------------
  -- Signals
  ------------------------------------------------------------------------------
  {%- for port in fins['ports']['ports'] %}
  {%- if port['direction']|lower == 'in' %}
  {%- if 'data' in port %}
  signal s_axis_{{ port['name']|lower }}_tdata_q  : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
  {%- endif %}
  {%- if 'metadata' in port %}
  signal s_axis_{{ port['name']|lower }}_tuser_q  : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
  {%- endif %}
  signal s_axis_{{ port['name']|lower }}_tvalid_q : std_logic;
  signal s_axis_{{ port['name']|lower }}_tlast_q  : std_logic;
  signal s_axis_{{ port['name']|lower }}_tfirst   : std_logic := '1'; -- Value on power-up must be 1
  {%- endif %}
  {%- endfor %}

begin

  ------------------------------------------------------------------------------
  -- Inputs
  ------------------------------------------------------------------------------
  {%- for port in fins['ports']['ports'] %}
  {%- if port['direction']|lower == 'in' %}
  --*****************************************
  -- Input Port: {{ port['name']|lower }}
  --*****************************************
  s_input_pipeline_{{ port['name']|lower }} : process (s_axis_{{ port['name']|lower }}_aclk)
  begin
    if (rising_edge(s_axis_{{ port['name']|lower }}_aclk)) then
      -- Data registers
      {%- if port['supports_backpressure'] %}
      if (ports_out.{{ port['name']|lower }}.ready = '1') then
      {%- endif %}
        {%- if 'data' in port %}
        s_axis_{{ port['name']|lower }}_tdata_q <= s_axis_{{ port['name']|lower }}_tdata;
        {%- endif %}
        {%- if 'metadata' in port %}
        {%- if port['streaming_metadata'] %}
        -- Streaming: Metadata is valid for each AXI4-Stream transaction
        s_axis_{{ port['name']|lower }}_tuser_q <= s_axis_{{ port['name']|lower }}_tuser;
        {%- else %}
        -- Not Streaming: Metadata is only valid on the first transaction of each AXI4-Stream packet
        if ((s_axis_{{ port['name']|lower }}_tvalid = '1') AND (s_axis_{{ port['name']|lower }}_tfirst = '1')) then
          -- Capture and hold the metadata
          s_axis_{{ port['name']|lower }}_tuser_q <= s_axis_{{ port['name']|lower }}_tuser;
        end if;
        {%- endif %}
        {%- endif %}
      {%- if port['supports_backpressure'] %}
      end if;
      {%- endif %}
      -- Control registers
      if (s_axis_{{ port['name']|lower }}_aresetn = '0') then
        s_axis_{{ port['name']|lower }}_tvalid_q <= '0';
        s_axis_{{ port['name']|lower }}_tlast_q  <= '0';
        s_axis_{{ port['name']|lower }}_tfirst   <= '1'; -- Value on reset must be 1
      else
        {%- if port['supports_backpressure'] %}
        if (ports_out.{{ port['name']|lower }}.ready = '1') then
        {%- endif %}
          -- Pipeline the control signals
          s_axis_{{ port['name']|lower }}_tvalid_q <= s_axis_{{ port['name']|lower }}_tvalid;
          s_axis_{{ port['name']|lower }}_tlast_q  <= s_axis_{{ port['name']|lower }}_tlast;
          -- Create a signal for detecting the first word of a packet
          if (s_axis_{{ port['name']|lower }}_tlast = '1') then
            s_axis_{{ port['name']|lower }}_tfirst <= '1';
          elsif (s_axis_{{ port['name']|lower }}_tvalid = '1') then
            s_axis_{{ port['name']|lower }}_tfirst <= '0';
          end if;
        {%- if port['supports_backpressure'] %}
        end if;
        {%- endif %}
      end if;
    end if;
  end process s_input_pipeline_{{ port['name']|lower }};
  {%- if port['supports_backpressure'] %}
  s_axis_{{ port['name']|lower }}_tready <= ports_out.{{ port['name']|lower }}.ready;
  {%- endif %}
  {%- if 'data' in port %}
  ports_in.{{ port['name']|lower }}.data <= f_unserialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data(s_axis_{{ port['name']|lower }}_tdata_q);
  {%- endif %}
  {%- if 'metadata' in port %}
  ports_in.{{ port['name']|lower }}.metadata <= f_unserialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata(s_axis_{{ port['name']|lower }}_tuser_q);
  {%- endif %}
  ports_in.{{ port['name']|lower }}.valid <= s_axis_{{ port['name']|lower }}_tvalid_q;
  ports_in.{{ port['name']|lower }}.last  <= s_axis_{{ port['name']|lower }}_tlast_q;
  {%- endif %}
  {%- endfor %}

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------
  {%- for port in fins['ports']['ports'] %}
  {%- if port['direction']|lower == 'out' %}
  --*****************************************
  -- Output Port: {{ port['name']|lower }}
  --*****************************************
  s_output_pipeline_{{ port['name']|lower }} : process (m_axis_{{ port['name']|lower }}_aclk)
  begin
    if (rising_edge(m_axis_{{ port['name']|lower }}_aclk)) then
      -- Data registers
      {%- if port['supports_backpressure'] %}
      if (m_axis_{{ port['name']|lower }}_tready = '1') then
      {%- endif %}
        {%- if 'data' in port %}
        m_axis_{{ port['name']|lower }}_tdata <= f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data(ports_out.{{ port['name']|lower }}.data);
        {%- endif %}
        {%- if 'metadata' in port %}
        m_axis_{{ port['name']|lower }}_tuser <= f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata(ports_out.{{ port['name']|lower }}.metadata);
        {%- endif %}
      {%- if port['supports_backpressure'] %}
      end if;
      {%- endif %}
      -- Control registers
      if (m_axis_{{ port['name']|lower }}_aresetn = '0') then
        m_axis_{{ port['name']|lower }}_tvalid <= '0';
        m_axis_{{ port['name']|lower }}_tlast  <= '0';
      else
        {%- if port['supports_backpressure'] %}
        if (m_axis_{{ port['name']|lower }}_tready = '1') then
        {%- endif %}
          m_axis_{{ port['name']|lower }}_tvalid <= ports_out.{{ port['name']|lower }}.valid;
          m_axis_{{ port['name']|lower }}_tlast  <= ports_out.{{ port['name']|lower }}.last;
        {%- if port['supports_backpressure'] %}
        end if;
        {%- endif %}
      end if;
    end if;
  end process s_output_pipeline_{{ port['name']|lower }};
  {%- if port['supports_backpressure'] %}
  ports_in.{{ port['name']|lower }}.ready <= m_axis_{{ port['name']|lower }}_tready;
  {%- endif %}
  {%- endif %}
  {%- endfor %}

end rtl;
