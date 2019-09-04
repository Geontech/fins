--==============================================================================
-- Company:     Geon Technologies, LLC
-- Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: Auto-generated file I/O AXI4-Stream test component
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
entity {{ fins['name'] }}_axis_verify is
  generic (
    {%- for port in fins['ports']['ports'] %}
    {%- if port['direction'] == "in" %}
    G_{{ port['name']|upper }}_SOURCE_SAMPLE_PERIOD : natural := 1; -- Number of clocks per sample
    G_{{ port['name']|upper }}_SOURCE_FILEPATH : string := "../../../../sim_source_{{ port['name']|lower }}.txt"{% if not loop.last %};{% endif %}
    {%- else %}
    G_{{ port['name']|upper }}_SINK_FILEPATH : string := "../../../../sim_sink_{{ port['name']|lower }}.txt"{% if not loop.last %};{% endif %}
    {%- endif %}
    {%- endfor %}
  );
  port (
    simulation_done : in boolean;
    {%- for port in fins['ports']['ports'] %}
    {%- if port['direction']|lower == 'out' %}
    -- Sinks from AXI4-Stream Output Port: {{ port['name']|lower }}
    s_axis_{{ port['name']|lower }}_aclk    : in  std_logic;
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
    s_axis_{{ port['name']|lower }}_tlast   : in  std_logic{% if not loop.last %};{% endif %}
    {%- else %}
    -- Sources for AXI4-Stream Input Port: {{ port['name']|lower }}
    m_axis_{{ port['name']|lower }}_aclk    : in  std_logic;
    m_axis_{{ port['name']|lower }}_enable  : in  std_logic;
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
    m_axis_{{ port['name']|lower }}_tlast   : out std_logic{% if not loop.last %};{% endif %}
    {%- endif %}
    {%- endfor %}
  );
end {{ fins['name'] }}_axis_verify;

-- Architecture
architecture struct of {{ fins['name'] }}_axis_verify is
begin
{%- for port in fins['ports']['ports'] %}
  {%- if port['direction'] == "in" %}
  -- Input from file
  w_file_source_{{ port['name'] }} : process
    variable file_status    : file_open_status := NAME_ERROR;
    variable file_done      : boolean := false;
    file     read_file      : text;
    variable current_line   : line;
    variable current_tlast  : std_logic_vector(3 downto 0);
    variable period_counter : integer := 0;
    variable axis_tvalid    : std_logic := '0';
    variable axis_tlast     : std_logic := '0';
    {%- if 'data' in port %}
    variable axis_tdata     : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0) := (others => '0');
    variable current_tdata  : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
    {%- endif %}
    {%- if 'metadata' in port %}
    variable axis_tuser     : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0) := (others => '0');
    variable current_tuser  : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
    {%- endif %}
  begin
    -- Use "simulation_done" to suspend operations
    if (NOT simulation_done) then
      -- Start to read at the rising edge of the clock
      wait until rising_edge(m_axis_{{ port['name'] }}_aclk);
      if (m_axis_{{ port['name'] }}_enable = '0') then
        -- When disabled, set output signals low
        m_axis_{{ port['name'] }}_tvalid <= '0';
        m_axis_{{ port['name'] }}_tlast  <= '0';
        {%- if 'data' in port %}
        m_axis_{{ port['name'] }}_tdata  <= (others => '0');
        {%- endif %}
        {%- if 'metadata' in port %}
        m_axis_{{ port['name'] }}_tuser  <= (others => '0');
        {%- endif %}
      else
        --******************************************
        -- Calculate the values for the variables
        --******************************************
        if (file_done) then
          -- When the file is done and a transaction occurs, reset signals to 0
          -- (This is the last AXIS for the file)
          {%- if port['supports_backpressure'] %}
          if (axis_tvalid = '1' AND m_axis_{{ port['name'] }}_tready = '1') then
          {%- else %}
          if (axis_tvalid = '1') then
          {%- endif %}
            axis_tvalid := '0';
            axis_tlast  := '0';
            {%- if 'data' in port %}
            axis_tdata  := (others => '0');
            {%- endif %}
            {%- if 'metadata' in port %}
            axis_tuser  := (others => '0');
            {%- endif %}
          end if;
          -- Note: the file_done flag might NOT mean that the last AXIS transaction has occurred.
          -- This is the case if the file is done being read but the last chunk of data has not yet
          -- been part of a valid AXIS transaction. So, when the file is done AND a transaction
          -- occurs during that cycle or a later cycle, the data is done being consumed and AXIS
          -- signals can be reset to 0.
        else
          {%- if port['supports_backpressure'] %}
          -- When we get a TREADY, read the next value
          if (m_axis_{{ port['name'] }}_tready = '1') then
          {%- endif %}
            -- Respect the sample period
            if ((period_counter rem G_{{ port['name']|upper }}_SOURCE_SAMPLE_PERIOD) = 0) then
              -- Open the file if it's not open already
              if (file_status /= OPEN_OK) then
                file_open(file_status, read_file, G_{{ port['name']|upper }}_SOURCE_FILEPATH, READ_MODE);
              end if;
              -- Grab a valid value from the file if we haven't reached the EOF
              if (NOT endfile(read_file)) then
                -- Read a space-separated string from a line of the file
                -- NOTE: File format is one of the following
                --       TLAST_HEX_STRING TDATA_HEX_STRING TUSER_HEX_STRING
                --       TLAST_HEX_STRING TDATA_HEX_STRING
                --       TLAST_HEX_STRING TUSER_HEX_STRING
                readline(read_file, current_line);
                hread(current_line, current_tlast);
                {%- if 'data' in port %}
                hread(current_line, current_tdata);
                {%- endif %}
                {%- if 'metadata' in port %}
                hread(current_line, current_tuser);
                {%- endif %}
                -- Set the output values
                axis_tvalid := '1';
                if (unsigned(current_tlast) > 0) then
                  axis_tlast := '1';
                else
                  axis_tlast := '0';
                end if;
                {%- if 'data' in port %}
                axis_tdata  := current_tdata;
                {%- endif %}
                {%- if 'metadata' in port %}
                axis_tuser  := current_tuser;
                {%- endif %}
              else
                -- If the last AXIS transaction for the file occurs on this same cycle
                -- (which happens to be when the file is done being read) reset signals to 0
                if (axis_tvalid = '1') then
                  axis_tvalid := '0';
                  axis_tlast  := '0';
                  {%- if 'data' in port %}
                  axis_tdata  := (others => '0');
                  {%- endif %}
                  {%- if 'metadata' in port %}
                  axis_tuser  := (others => '0');
                  {%- endif %}
                end if;
                -- Set the file_done flag for reference during next cycle
                file_done := true;
              end if;
            end if;
          {%- if port['supports_backpressure'] %}
          end if;
          {%- endif %}
          -- Increment the period counter
          period_counter := period_counter + 1;
        end if;
        --******************************************
        -- Set outputs to the variables
        --******************************************
        m_axis_{{ port['name'] }}_tvalid <= axis_tvalid;
        m_axis_{{ port['name'] }}_tlast  <= axis_tlast;
        {%- if 'data' in port %}
        m_axis_{{ port['name'] }}_tdata  <= axis_tdata;
        {%- endif %}
        {%- if 'metadata' in port %}
        m_axis_{{ port['name'] }}_tuser  <= axis_tuser;
        {%- endif %}
      end if;
    else
      -- Close File
      file_close(read_file);
      -- Suspend operations when simulation is done
      wait;
    end if;
  end process w_file_source_{{ port['name'] }};
  {%- else %}
  -- Output to file
  w_file_sink_{{ port['name'] }} : process
    variable file_status   : file_open_status := NAME_ERROR;
    file     write_file    : text;
    variable current_line  : line;
    variable current_tlast : std_logic_vector(3 downto 0) := (others => '0');
    {%- if 'data' in port %}
    variable current_tdata : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
    {%- endif %}
    {%- if 'metadata' in port %}
    variable current_tuser : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
    {%- endif %}
  begin
    -- Use "simulation_done" to suspend operations
    if (simulation_done = false) then
      -- Read at the rising edge of the clock
      wait until rising_edge(s_axis_{{ port['name'] }}_aclk);
      {%- if port['supports_backpressure'] %}
      -- Hold TREADY high (this module is always ready to accept data)
      s_axis_{{ port['name'] }}_tready <= '1';
      {%- endif %}
      -- When we get a TVALID, write the next value
      if (s_axis_{{ port['name'] }}_tvalid = '1') then
        -- Open the file if it's not open already
        if (file_status /= OPEN_OK) then
          file_open(file_status, write_file, G_{{ port['name']|upper }}_SINK_FILEPATH, WRITE_MODE);
        end if;
        -- Write the value to the file in hexadecimal format
        current_tlast(0) := s_axis_{{ port['name'] }}_tlast;
        {%- if 'data' in port %}
        current_tdata    := s_axis_{{ port['name'] }}_tdata;
        {%- endif %}
        {%- if 'metadata' in port %}
        current_tuser    := s_axis_{{ port['name'] }}_tuser;
        {%- endif %}
        hwrite(current_line, current_tlast);
        write(current_line, string'(" "));
        {%- if 'data' in port %}
        hwrite(current_line, current_tdata);
        write(current_line, string'(" "));
        {%- endif %}
        {%- if 'metadata' in port %}
        hwrite(current_line, current_tuser);
        {%- endif %}
        writeline(write_file, current_line);
      end if;
    else
      -- Close File
      file_close(write_file);
      -- Suspend operations when simulation is done
      wait;
    end if;
  end process w_file_sink_{{ port['name'] }};
  {% endif %}
{% endfor %}
end struct;
