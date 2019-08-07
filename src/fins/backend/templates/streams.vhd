--==============================================================================
-- Company:     Geon Technologies, LLC
-- Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: Auto-generated file I/O AXI-Stream test component
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

-- Entity
entity {{ fins['name'] }}_streams is
  generic (
    {%- for stream in fins['streams'] %}
    {%- if stream['mode'] == "slave" %}
    G_{{ stream['name']|upper }}_SOURCE_SAMPLE_PERIOD : natural := 1; -- Number of clocks per sample
    G_{{ stream['name']|upper }}_SOURCE_FILEPATH : string := "../../../../sim_source_{{ stream['name']|lower }}.txt"{% if not loop.last %};{% endif %}
    {%- else %}
    G_{{ stream['name']|upper }}_SINK_FILEPATH : string := "../../../../sim_sink_{{ stream['name']|lower }}.txt"{% if not loop.last %};{% endif %}
    {%- endif %}
    {%- endfor %}
  );
  port (
    simulation_done : in boolean;
    {%- for stream in fins['streams'] %}
    -- {{ stream['name'] }} Stream
    {% if stream['mode'] == "slave" %}m{% else %}s{% endif %}_axis_{{ stream['name'] }}_clk    : in std_logic;
    {% if stream['mode'] == "slave" %}m_axis_{{ stream['name'] }}_enable : in std_logic;{% endif %}
    {% if stream['mode'] == "slave" %}m{% else %}s{% endif %}_axis_{{ stream['name'] }}_tdata  : {% if stream['mode'] == "slave" %}out{% else %}in {% endif %} std_logic_vector({{ stream['bit_width'] }}-1 downto 0);
    {% if stream['mode'] == "slave" %}m{% else %}s{% endif %}_axis_{{ stream['name'] }}_tvalid : {% if stream['mode'] == "slave" %}out{% else %}in {% endif %} std_logic;
    {% if stream['mode'] == "slave" %}m{% else %}s{% endif %}_axis_{{ stream['name'] }}_tlast  : {% if stream['mode'] == "slave" %}out{% else %}in {% endif %} std_logic;
    {% if stream['mode'] == "slave" %}m{% else %}s{% endif %}_axis_{{ stream['name'] }}_tready : {% if stream['mode'] == "slave" %}in {% else %}out{% endif %} std_logic{% if loop.index < loop.length %};{% endif %}
    {%- endfor %}
  );
end {{ fins['name'] }}_streams;

-- Architecture
architecture struct of {{ fins['name'] }}_streams is
begin
{%- for stream in fins['streams'] %}
  {%- if stream['mode'] == "slave" %}
  -- Input from file
  w_stream_in_{{ stream['name'] }} : process
    variable file_status    : file_open_status := NAME_ERROR;
    variable file_done      : boolean := false;
    file     read_file      : text;
    variable read_line      : line;
    variable read_value     : std_logic_vector({{ stream['bit_width'] }}-1 downto 0);
    variable sample_counter : integer := 0;
    variable period_counter : integer := 0;
    variable axis_tvalid    : std_logic := '0';
    variable axis_tlast     : std_logic := '0';
    variable axis_tdata     : std_logic_vector({{ stream['bit_width'] }}-1 downto 0) := (others => '0');
  begin
    -- Use "simulation_done" to suspend operations
    if (NOT simulation_done) then
      -- Start to read at the rising edge of the clock
      wait until rising_edge(m_axis_{{ stream['name'] }}_clk);
      if (m_axis_{{ stream['name'] }}_enable = '0') then
        -- When disabled, set output signals low
        m_axis_{{ stream['name'] }}_tvalid <= '0';
        m_axis_{{ stream['name'] }}_tlast  <= '0';
        m_axis_{{ stream['name'] }}_tdata  <= (others => '0');
      else
        --******************************************
        -- Calculate the values for the variables
        --******************************************
        if (file_done) then
          -- When the file is done and a transaction occurs, reset signals to 0
          -- (This is the last AXIS for the file)
          if (axis_tvalid = '1' AND m_axis_{{ stream['name'] }}_tready = '1') then
            axis_tvalid := '0';
            axis_tlast  := '0';
            axis_tdata  := (others => '0');
          end if;
          -- Note: the file_done flag might NOT mean that the last AXIS transaction has occurred.
          -- This is the case if the file is done being read but the last chunk of data has not yet
          -- been part of a valid AXIS transaction. So, when the file is done AND a transaction
          -- occurs during that cycle or a later cycle, the data is done being consumed and AXIS
          -- signals can be reset to 0.
        else
          -- When we get a TREADY, read the next value
          if (m_axis_{{ stream['name'] }}_tready = '1') then
            -- Respect the sample period
            if ((period_counter rem G_{{ stream['name']|upper }}_SOURCE_SAMPLE_PERIOD) = 0) then
              -- Open the file if it's not open already
              if (file_status /= OPEN_OK) then
                file_open(file_status, read_file, G_{{ stream['name']|upper }}_SOURCE_FILEPATH, READ_MODE);
              end if;
              -- Grab a valid value from the file if we haven't reached the EOF
              if (NOT endfile(read_file)) then
                -- Read a hexadecimal string from a line of the file
                readline(read_file, read_line);
                hread(read_line, read_value);
                -- Set the output values
                axis_tvalid := '1';
                axis_tdata  := read_value;
                -- TLAST is active only when we've reached the final
                -- value in an AXI-Stream packet
                if (sample_counter = {{ stream['packet_size'] }}-1) then
                  axis_tlast := '1';
                  sample_counter := 0;
                else
                  axis_tlast := '0';
                  sample_counter := sample_counter + 1;
                end if;
              else
                -- If the last AXIS transaction for the file occurs on this same cycle
                -- (which happens to be when the file is done being read) reset signals to 0
                if (axis_tvalid = '1') then
                  axis_tvalid := '0';
                  axis_tlast := '0';
                  axis_tdata  := (others => '0');
                end if;
                -- Set the file_done flag for reference during next cycle
                file_done := true;
              end if;
            end if;
          end if;
          -- Increment the period counter
          period_counter := period_counter + 1;
        end if;
        --******************************************
        -- Set outputs to the variables
        --******************************************
        m_axis_{{ stream['name'] }}_tvalid <= axis_tvalid;
        m_axis_{{ stream['name'] }}_tlast  <= axis_tlast;
        m_axis_{{ stream['name'] }}_tdata  <= axis_tdata;
      end if;
    else
      -- Close File
      file_close(read_file);
      -- Suspend operations when simulation is done
      wait;
    end if;
  end process w_stream_in_{{ stream['name'] }};
  {%- else %}
  -- Output to file
  w_stream_out_{{ stream['name'] }} : process
    variable file_status    : file_open_status := NAME_ERROR;
    file     write_file     : text;
    variable write_line     : line;
    variable write_value    : std_logic_vector({{ stream['bit_width'] }}-1 downto 0);
  begin
    -- Use "simulation_done" to suspend operations
    if (simulation_done = false) then
      -- Read at the rising edge of the clock
      wait until rising_edge(s_axis_{{ stream['name'] }}_clk);
      -- Hold TREADY high (this module is always ready to accept data)
      s_axis_{{ stream['name'] }}_tready <= '1';
      -- When we get a TVALID, write the next value
      if (s_axis_{{ stream['name'] }}_tvalid = '1') then
        -- Open the file if it's not open already
        if (file_status /= OPEN_OK) then
          file_open(file_status, write_file, G_{{ stream['name']|upper }}_SINK_FILEPATH, WRITE_MODE);
        end if;
        -- Write the value to the file in hexadecimal format
        write_value := s_axis_{{ stream['name'] }}_tdata;
        hwrite(write_line, write_value);
        writeline(write_file, write_line);
      end if;
    else
      -- Close File
      file_close(write_file);
      -- Suspend operations when simulation is done
      wait;
    end if;
  end process w_stream_out_{{ stream['name'] }};
  {% endif %}
{% endfor %}
end struct;
