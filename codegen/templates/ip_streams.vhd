--==============================================================================
-- Company:     Geon Technologies, LLC
-- File:        {{ fins['name'] }}_streams.vhd
-- Description: Auto-generated from Jinja2 VHDL streams template
-- Generated:   {{ now }}
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- User Libraries
library work;
use work.{{ fins['name'] }}_params.all;

-- Entity
entity {{ fins['name'] }}_streams is
  generic (
    G_SIM_FILES_DEST : string := "../../../"
  );
  port (
    simulation_done : in boolean;
  {%- for stream in fins['streams'] %}
    -- {{ stream['name'] }} Stream
    {% if stream['mode'] == "slave" -%}m{%- else -%}s{%- endif -%}_axis_{{ stream['name'] }}_clk    : in std_logic;
    {% if stream['mode'] == "slave" -%}m{%- else -%}s{%- endif -%}_axis_{{ stream['name'] }}_tdata  : {% if stream['mode'] == "slave" -%}out{%- else -%}in{%- endif %} std_logic_vector({{ stream['bit_width'] }}-1 downto 0);
    {% if stream['mode'] == "slave" -%}m{%- else -%}s{%- endif -%}_axis_{{ stream['name'] }}_tvalid : {% if stream['mode'] == "slave" -%}out{%- else -%}in{%- endif %} std_logic;
    {% if stream['mode'] == "slave" -%}m{%- else -%}s{%- endif -%}_axis_{{ stream['name'] }}_tlast  : {% if stream['mode'] == "slave" -%}out{%- else -%}in{%- endif %} std_logic;
    {% if stream['mode'] == "slave" -%}m{%- else -%}s{%- endif -%}_axis_{{ stream['name'] }}_tready : {% if stream['mode'] == "slave" -%}in{%- else -%}out{%- endif %} std_logic{%- if loop.index < loop.length -%};{%- endif -%}
  {% endfor %}
  );
end {{ fins['name'] }}_streams;

-- Architecture
architecture struct of {{ fins['name'] }}_streams is
begin
{%- for stream in fins['streams'] %}
  {%- if stream['mode'] == "slave" %}
  -- Input from file
  u_stream_in_{{ stream['name'] }} : entity work.axis_file_reader
    generic map (
      G_FILE_PATH   => G_SIM_FILES_DEST & "sim_in_{{ stream['name'] }}.txt",
      G_DATA_WIDTH  => {{ stream['bit_width'] }},
      G_PACKET_SIZE => {{ stream['packet_size'] }}
    )
    port map (
      simulation_done => simulation_done,
      clk             => m_axis_{{ stream['name'] }}_clk,
      m_axis_tready   => m_axis_{{ stream['name'] }}_tready,
      m_axis_tvalid   => m_axis_{{ stream['name'] }}_tvalid,
      m_axis_tlast    => m_axis_{{ stream['name'] }}_tlast,
      m_axis_tdata    => m_axis_{{ stream['name'] }}_tdata
    );
  {%- else %}
  -- Output to file
  u_stream_out_{{ stream['name'] }} : entity work.axis_file_writer
    generic map (
      G_FILE_PATH   => G_SIM_FILES_DEST & "sim_out_{{ stream['name'] }}.txt",
      G_DATA_WIDTH  => {{ stream['bit_width'] }}
    )
    port map (
      simulation_done => simulation_done,
      clk             => s_axis_{{ stream['name'] }}_clk,
      s_axis_tready   => s_axis_{{ stream['name'] }}_tready,
      s_axis_tvalid   => s_axis_{{ stream['name'] }}_tvalid,
      s_axis_tlast    => s_axis_{{ stream['name'] }}_tlast,
      s_axis_tdata    => s_axis_{{ stream['name'] }}_tdata
    );
  {% endif %}
{% endfor %}
end struct;
