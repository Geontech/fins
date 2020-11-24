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
-- Template:    axis_verify.vhd
-- Backend:     {{ fins['backend'] }}
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: File I/O AXI4-Stream bus test component for FINS ports
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
    {%- set outer_loop = loop %}
    {%- for i in range(port['num_instances']) %}
    {%- if port['direction'] == "in" %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_SAMPLE_PERIOD : positive := 1;
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_RANDOMIZE_BUS : boolean := false;
    {%- if fins['backend']|lower == 'quartus' %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH : string := "../../../sim_data/sim_source_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}.txt"{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%- else %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH : string := "../../../../../../sim_data/sim_source_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}.txt"{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%- endif %}
    {%- else %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_SAMPLE_PERIOD : positive := 1;
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_RANDOMIZE_BUS : boolean := false;
    {%- if fins['backend']|lower == 'quartus' %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_FILEPATH : string := "../../../sim_data/sim_sink_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}.txt"{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%- else %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_FILEPATH : string := "../../../../../../sim_data/sim_sink_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}.txt"{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%- endif %}
    {%- endif %}
    {%- endfor %}
    {%- endfor %}
  );
  port (
    simulation_done : in boolean;
    {%- for port in fins['ports']['ports'] %}
    {%- if port['direction']|lower == 'out' %}
    -- File Sink for AXI4-Stream Output Port: {{ port['name']|lower }}
    {%- else %}
    -- File Source for AXI4-Stream Input Port: {{ port['name']|lower }}
    {%- endif %}
    {%- set outer_loop = loop %}
    {%- for i in range(port['num_instances']) %}
    {%- if port['direction']|lower == 'out' %}
    {{ port|axisprefix(i,True) }}_aclk    : in  std_logic;
    {%- if port['supports_backpressure'] %}
    {{ port|axisprefix(i,True) }}_tready  : out std_logic;
    {%- endif %}
    {%- if port['supports_byte_enable'] %}
    {{ port|axisprefix(i,True) }}_tkeep   : out std_logic_vector({{ port['data']['num_bytes'] }}-1 downto 0);
    {%- endif %}
    {{ port|axisprefix(i,True) }}_tdata   : in  std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
    {%- if 'metadata' in port %}
    {{ port|axisprefix(i,True) }}_tuser   : in  std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
    {%- endif %}
    {{ port|axisprefix(i,True) }}_tvalid  : in  std_logic;
    {{ port|axisprefix(i,True) }}_tlast   : in  std_logic{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%- else %}
    {{ port|axisprefix(i,True) }}_aclk    : in  std_logic;
    {{ port|axisprefix(i,True) }}_enable  : in  std_logic;
    {%- if port['supports_backpressure'] %}
    {{ port|axisprefix(i,True) }}_tready  : in  std_logic;
    {%- endif %}
    {%- if port['supports_byte_enable'] %}
    {{ port|axisprefix(i,True) }}_tkeep   : in std_logic_vector({{ port['data']['num_bytes'] }}-1 downto 0);
    {%- endif %}
    {{ port|axisprefix(i,True) }}_tdata   : out std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
    {%- if 'metadata' in port %}
    {{ port|axisprefix(i,True) }}_tuser   : out std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
    {%- endif %}
    {{ port|axisprefix(i,True) }}_tvalid  : out std_logic;
    {{ port|axisprefix(i,True) }}_tlast   : out std_logic{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%- endif %}
    {%- endfor %}
    {%- endfor %}
  );
end {{ fins['name'] }}_axis_verify;

-- Architecture
architecture struct of {{ fins['name'] }}_axis_verify is
begin
{%- for port in fins['ports']['ports'] %}
{%- for i in range(port['num_instances']) %}
  {%- if port['direction'] == "in" %}
  -- Input from file
  w_file_source_{{ port['name'] }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %} : process
    -- File reading variables
    variable file_status           : file_open_status := NAME_ERROR;
    variable file_done             : boolean := false;
    file     read_file             : text;
    variable current_line          : line;
    variable current_tlast         : std_logic_vector(3 downto 0);
    -- Variables to determine bus activity
    variable sample_period_counter : natural := 0;
    variable sample_active         : boolean := false;
    variable seed1, seed2          : positive;
    variable rand                  : real;
    -- Intermediate variables to assign to signals
    variable axis_tvalid           : std_logic := '0';
    variable axis_tlast            : std_logic := '0';
    variable axis_tdata            : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0) := (others => '0');
    variable current_tdata         : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
    {%- if 'metadata' in port %}
    variable axis_tuser            : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0) := (others => '0');
    variable current_tuser         : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
    {%- endif %}
    {%- if port['supports_byte_enable'] %}
    --variable axis_tkeep            : std_logic_vector({{ port['data']['num_bytes'] }}-1 downto 0) := (others => '0');
    --variable current_tkeep         : std_logic_vector({{ port['data']['num_bytes'] }}-1 downto 0);
    {%- endif %}
  begin
    -- Use "simulation_done" to suspend operations
    if (NOT simulation_done) then
      -- Start to read at the rising edge of the clock
      wait until rising_edge({{ port|axisprefix(i,True) }}_aclk);
      if ({{ port|axisprefix(i,True) }}_enable = '0') then
        -- When disabled, set output signals low
        {{ port|axisprefix(i,True) }}_tvalid <= '0';
        {{ port|axisprefix(i,True) }}_tlast  <= '0';
        {{ port|axisprefix(i,True) }}_tdata  <= (others => '0');
        {%- if 'metadata' in port %}
        {{ port|axisprefix(i,True) }}_tuser  <= (others => '0');
        {%- endif %}
        {%- if port['supports_byte_enable'] %}
        -- {{ port|axisprefix(i,True) }}_tkeep  <= (others => '0');
        {%- endif %}
      else
        --******************************************
        -- Calculate the values for the variables
        --******************************************
        -- Determine the values
        if (file_done) then
          -- When the file is done and a transaction occurs, reset signals to 0
          -- (This is the last AXIS transaction for the file)
          {%- if port['supports_backpressure'] %}
          if (axis_tvalid = '1' AND {{ port|axisprefix(i,True) }}_tready = '1') then
          {%- else %}
          if (axis_tvalid = '1') then
          {%- endif %}
            axis_tvalid := '0';
            axis_tlast  := '0';
            axis_tdata  := (others => '0');
            {%- if 'metadata' in port %}
            axis_tuser  := (others => '0');
            {%- endif %}
            {%- if port['supports_byte_enable'] %}
            --axis_tkeep  := (others => '0');
            {%- endif %}
          end if;
          -- Note: the file_done flag might NOT mean that the last AXIS transaction has occurred.
          -- This is the case if the file is done being read but the last chunk of data has not yet
          -- been part of a valid AXIS transaction. So, when the file is done AND a transaction
          -- occurs during that cycle or a later cycle, the data is done being consumed and AXIS
          -- signals can be reset to 0.
        else
          -- Check if there is already an active sample
          if(not sample_active) then
            axis_tvalid := '0';
            -- Calculate if this sample is active based upon the sample period
            if (G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_RANDOMIZE_BUS) then
              -- Randomize the transaction activity based upon a duty cycle calculated from the sample period
              uniform(seed1, seed2, rand);
              if (rand <= 1.0/real(G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_SAMPLE_PERIOD)) then
                sample_active := true;
              else
                sample_active := false;
              end if;
            else
              -- Create the transaction activity based upon the sample period counter
              if (sample_period_counter = 0) then
                sample_active := true;
              else
                sample_active := false;
              end if;
              -- Increment the sample period counter
              if (sample_period_counter >= G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_SAMPLE_PERIOD-1) then
                sample_period_counter := 0;
              else
                sample_period_counter := sample_period_counter + 1;
              end if;
            end if;
          end if;

          -- Respect the sample period
          if (sample_active) then
            axis_tvalid := '1';
            {%- if port['supports_backpressure'] %}
            -- When we get a TREADY, read the next value
            if ({{ port|axisprefix(i,True) }}_tready = '1') then
            {%- endif %}
              -- Open the file if it's not open already
              if (file_status /= OPEN_OK) then
                file_open(file_status, read_file, G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH, READ_MODE);
                assert (file_status = OPEN_OK)
                  report "ERROR: Failed to open file G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH in mode 'READ_MODE'"
                  severity failure;
              end if;
              -- Grab a valid value from the file if we haven't reached the EOF
              if (NOT endfile(read_file)) then
                -- Read a space-separated string from a line of the file
                -- NOTE: File format is one of the following
                --       TLAST_HEX_STRING TDATA_HEX_STRING TUSER_HEX_STRING
                --       TLAST_HEX_STRING TDATA_HEX_STRING
                readline(read_file, current_line);
                hread(current_line, current_tlast);
                hread(current_line, current_tdata);
                {%- if 'metadata' in port %}
                hread(current_line, current_tuser);
                {%- endif %}
                {%- if port['supports_byte_enable'] %}
                --hread(current_line, current_tkeep);
                {%- endif %}
                -- Set the output values
                if (unsigned(current_tlast) > 0) then
                  axis_tlast := '1';
                else
                  axis_tlast := '0';
                end if;
                axis_tdata  := current_tdata;
                {%- if 'metadata' in port %}
                axis_tuser  := current_tuser;
                {%- endif %}
                {%- if port['supports_byte_enable'] %}
                axis_tkeep  := current_tkeep;
                {%- endif %}
              else
                -- If the last AXIS transaction for the file occurs on this same cycle
                -- (which happens to be when the file is done being read) reset signals to 0
                if (axis_tvalid = '1') then
                  axis_tvalid := '0';
                  axis_tlast  := '0';
                  axis_tdata  := (others => '0');
                  {%- if 'metadata' in port %}
                  axis_tuser  := (others => '0');
                  {%- endif %}
                  {%- if port['supports_byte_enable'] %}
                  --axis_tkeep  := (others => '0');
                  {%- endif %}
                end if;
                -- Set the file_done flag for reference during next cycle
                file_done := true;
              end if;
              sample_active := false;
            {%- if port['supports_backpressure'] %}
            end if;
            {%- endif %}
          end if;
        end if;
        --******************************************
        -- Set outputs to the variables
        --******************************************
        {{ port|axisprefix(i,True) }}_tvalid <= axis_tvalid;
        {{ port|axisprefix(i,True) }}_tlast  <= axis_tlast;
        {{ port|axisprefix(i,True) }}_tdata  <= axis_tdata;
        {%- if 'metadata' in port %}
        {{ port|axisprefix(i,True) }}_tuser  <= axis_tuser;
        {%- endif %}
        {%- if port['supports_byte_enable'] %}
        --{{ port|axisprefix(i,True) }}_tkeep  <= axis_tkeep;
        {%- endif %}
      end if;
    else
      -- Close File
      file_close(read_file);
      -- Suspend operations when simulation is done
      wait;
    end if;
  end process w_file_source_{{ port['name'] }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %};
  {%- else %}
  -- Output to file
  w_file_sink_{{ port['name'] }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %} : process
    -- Variables to write to file
    variable file_status           : file_open_status := NAME_ERROR;
    file     write_file            : text;
    variable current_line          : line;
    -- Variables for intermediate signals
    variable current_tlast         : std_logic_vector(3 downto 0) := (others => '0');
    {%- if port['supports_backpressure'] %}
    variable current_tready        : std_logic;
    {%- endif %}
    {%- if port['supports_byte_enable'] %}
    variable current_tkeep        : std_logic_vector({{ port['data']['num_bytes'] }}-1 downto 0);
    {%- endif %}
    variable current_tdata         : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
    {%- if 'metadata' in port %}
    variable current_tuser         : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
    {%- endif %}
    -- Variables to determine bus activity
    variable sample_period_counter : natural := 0;
    variable sample_active         : boolean := false;
    variable seed1, seed2          : positive;
    variable rand                  : real;
  begin
    -- Use "simulation_done" to suspend operations
    if (simulation_done = false) then
      -- Perform operations at the rising edge of the clock
      wait until rising_edge({{ port|axisprefix(i,True) }}_aclk);

      -- Write valid transactions
      {%- if port['supports_backpressure'] %}
      if (({{ port|axisprefix(i,True) }}_tvalid = '1') AND (current_tready = '1')) then
      {%- else %}
      if ({{ port|axisprefix(i,True) }}_tvalid = '1') then
      {%- endif %}
        -- Open the file if it's not open already
        if (file_status /= OPEN_OK) then
          file_open(file_status, write_file, G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_FILEPATH, WRITE_MODE);
          assert (file_status = OPEN_OK)
            report "ERROR: Failed to open file G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH in mode 'WRITE_MODE'"
            severity failure;
        end if;
        -- Write the value to the file in hexadecimal format
        current_tlast(0) := {{ port|axisprefix(i,True) }}_tlast;
        current_tdata    := {{ port|axisprefix(i,True) }}_tdata;
        {%- if 'metadata' in port %}
        current_tuser    := {{ port|axisprefix(i,True) }}_tuser;
        {%- endif %}
        hwrite(current_line, current_tlast);
        write(current_line, string'(" "));
        hwrite(current_line, current_tdata);
        {%- if 'metadata' in port %}
        write(current_line, string'(" "));
        hwrite(current_line, current_tuser);
        {%- endif %}
        {%- if port['supports_byte_enable'] %}
        --write(current_line, string'(" "));
        --hwrite(current_line, current_tkeep);
        {%- endif %}
        writeline(write_file, current_line);
      end if;

      {%- if port['supports_backpressure'] %}
      -- Determine the TREADY activity
      if (G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_RANDOMIZE_BUS) then
        -- Randomize the transaction activity based upon a duty cycle calculated from the sample period
        uniform(seed1, seed2, rand);
        if (rand <= 1.0/real(G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_SAMPLE_PERIOD)) then
          current_tready := '1';
        else
          current_tready := '0';
        end if;
      else
        -- Create the transaction activity based upon the sample period counter
        if (sample_period_counter = 0) then
          current_tready := '1';
        else
          current_tready := '0';
        end if;
      end if;
      {{ port|axisprefix(i,True) }}_tready <= current_tready;
      

      -- Increment the sample period counter for the TREADY operation
      if (sample_period_counter >= G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_SAMPLE_PERIOD-1) then
        sample_period_counter := 0;
      else
        sample_period_counter := sample_period_counter + 1;
      end if;
      {%- endif %}{#### if port['supports_backpressure'] ####}

    else
      -- Close File
      file_close(write_file);
      -- Suspend operations when simulation is done
      wait;
    end if;
  end process w_file_sink_{{ port['name'] }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %};
  {% endif %}
{% endfor %}
{% endfor %}
end struct;
