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
-- Template:    axis.vhd
-- Backend:     {{ fins['backend'] }}
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: AXI4-Stream bus interpreter for FINS ports
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
    -- AXI4-Stream Port {{ port['direction']|upper }}: {{ port['name']|lower }}
    {%- for i in range(port['num_instances']) %}
    {{ port|axisprefix(i) }}_aclk    : in  std_logic;
    {{ port|axisprefix(i) }}_aresetn : in  std_logic;
    {%- if port['supports_backpressure'] %}
    {{ port|axisprefix(i) }}_tready  : {% if port['direction']|lower == 'in' %}out{% else %}in {% endif %} std_logic;
    {%- endif %}
    {%- if port['supports_byte_enable'] %}
    {{ port|axisprefix(i) }}_tkeep   : {% if port['direction']|lower == 'in' %}in{% else %}out {% endif %} std_logic_vector({{ port['data']['num_bytes'] }}-1 downto 0);
    {%- endif %}
    {{ port|axisprefix(i) }}_tdata   : {% if port['direction']|lower == 'in' %}in {% else %}out{% endif %} std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
    {%- if 'metadata' in port %}
    {{ port|axisprefix(i) }}_tuser   : {% if port['direction']|lower == 'in' %}in {% else %}out{% endif %}  std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
    {%- endif %}
    {{ port|axisprefix(i) }}_tvalid  : {% if port['direction']|lower == 'in' %}in {% else %}out{% endif %}  std_logic;
    {{ port|axisprefix(i) }}_tlast   : {% if port['direction']|lower == 'in' %}in {% else %}out{% endif %}  std_logic;
    {%- endfor %}
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
  {%- for i in range(port['num_instances']) %}
  {%- if port['use_pipeline'] %}
  -- Port {{ port['name'] }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %} Signals
  signal {{ port|axisprefix(i) }}_tlast_q       : std_logic;
  signal {{ port|axisprefix(i) }}_tdata_q       : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
  {%- if 'metadata' in port %}
  signal {{ port|axisprefix(i) }}_tuser_q       : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
  {%- endif %}
  {%- if port['supports_byte_enable'] %}
  signal {{ port|axisprefix(i) }}_tkeep_q       : std_logic_vector({{ port['data']['num_bytes'] }}-1 downto 0);
  {%- endif %}
  signal {{ port|axisprefix(i) }}_tvalid_q      : std_logic;
  {%- if port['supports_backpressure'] %}
  signal {{ port|axisprefix(i) }}_tready_q      : std_logic;
  {%- if port['supports_byte_enable'] %}
  signal {{ port|axisprefix(i) }}_tkeep_stored  : std_logic_vector({{ port['data']['num_bytes'] }}-1 downto 0);
  {%- endif %}
  signal {{ port|axisprefix(i) }}_tlast_stored  : std_logic;
  signal {{ port|axisprefix(i) }}_tdata_stored  : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
  {%- if 'metadata' in port %}
  signal {{ port|axisprefix(i) }}_tuser_stored  : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
  {%- endif %}
  signal {{ port|axisprefix(i) }}_tvalid_stored : std_logic;
  {%- endif  %}{#### if port['supports_backpressure'] ####}
  {%- endif  %}{#### if port['use_pipeline'] ####}
  {%- endfor %}{#### for i in range(port['num_instances']) ####}
  {%- endfor %}{#### for port in fins['ports']['ports'] ####}

begin

  ------------------------------------------------------------------------------
  -- Clock and Reset
  ------------------------------------------------------------------------------
  {%- for port in fins['ports']['ports'] %}
  {%- for i in range(port['num_instances']) %}
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.clk    <= {{ port|axisprefix(i) }}_aclk;
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.resetn <= {{ port|axisprefix(i) }}_aresetn;
  {%- endfor %}
  {%- endfor %}

  ------------------------------------------------------------------------------
  -- Inputs
  ------------------------------------------------------------------------------
  {%- for port in fins['ports']['ports'] %}
  {%- if port['direction']|lower == 'in' %}
  {%- for i in range(port['num_instances']) %}
  {%- if port['use_pipeline'] %}
  --*****************************************
  -- Input Port: {{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}
  --*****************************************
  -- Synchronous Process for Input Pipeline
  s_input_pipeline_{{ port['name']|lower }}{{ '%0#2d'|format(i) }} : process ({{ port|axisprefix(i) }}_aclk)
  begin
    if (rising_edge({{ port|axisprefix(i) }}_aclk)) then
      ---------------------
      -- Data registers
      ---------------------
      {%- if port['supports_backpressure'] %}
      -- AXI4-Stream Pipeline
      if (((ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.ready = '1') OR ({{ port|axisprefix(i) }}_tvalid_q = '0')) AND ({{ port|axisprefix(i) }}_tready_q = '1')) then
        -- Output gets input
        {{ port|axisprefix(i) }}_tlast_q <= {{ port|axisprefix(i) }}_tlast;
        {{ port|axisprefix(i) }}_tdata_q <= {{ port|axisprefix(i) }}_tdata;
        {%- if 'metadata' in port %}
        {{ port|axisprefix(i) }}_tuser_q <= {{ port|axisprefix(i) }}_tuser;
        {%- endif %}
        {%- if port['supports_byte_enable'] %}
        {{ port|axisprefix(i) }}_tkeep_q <= {{ port|axisprefix(i) }}_tkeep;
        {%- endif %}
      elsif ((ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.ready = '1') AND ({{ port|axisprefix(i) }}_tready_q = '0')) then
        -- Stored is sent to output
        {{ port|axisprefix(i) }}_tlast_q <= {{ port|axisprefix(i) }}_tlast_stored;
        {{ port|axisprefix(i) }}_tdata_q <= {{ port|axisprefix(i) }}_tdata_stored;
        {%- if 'metadata' in port %}
        {{ port|axisprefix(i) }}_tuser_q <= {{ port|axisprefix(i) }}_tuser_stored;
        {%- endif %}
        {%- if port['supports_byte_enable'] %}
        {{ port|axisprefix(i) }}_tkeep_q <= {{ port|axisprefix(i) }}_tkeep_stored;
        {%- endif %}
      end if;
      if (((ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.ready = '0') AND ({{ port|axisprefix(i) }}_tvalid_q = '1')) AND ({{ port|axisprefix(i) }}_tready_q = '1')) then
        -- Input is stored
        {{ port|axisprefix(i) }}_tlast_stored <= {{ port|axisprefix(i) }}_tlast;
        {{ port|axisprefix(i) }}_tdata_stored <= {{ port|axisprefix(i) }}_tdata;
        {%- if 'metadata' in port %}
        {{ port|axisprefix(i) }}_tuser_stored <= {{ port|axisprefix(i) }}_tuser;
        {%- endif %}
        {%- if port['supports_byte_enable'] %}
        {{ port|axisprefix(i) }}_tkeep_stored <= {{ port|axisprefix(i) }}_tkeep;
        {%- endif %}
      end if;
      {%- else %}
      -- Simple Pipeline
      {{ port|axisprefix(i) }}_tlast_q <= {{ port|axisprefix(i) }}_tlast;
      {{ port|axisprefix(i) }}_tdata_q <= {{ port|axisprefix(i) }}_tdata;
      {%- if 'metadata' in port %}
      {{ port|axisprefix(i) }}_tuser_q <= {{ port|axisprefix(i) }}_tuser;
      {%- endif %}
      {%- if port['supports_byte_enable'] %}
      {{ port|axisprefix(i) }}_tkeep_q <= {{ port|axisprefix(i) }}_tkeep;
      {%- endif %}
      {%- endif %}
      ---------------------
      -- Control registers
      ---------------------
      if ({{ port|axisprefix(i) }}_aresetn = '0') then
        {%- if port['supports_backpressure'] %}
        {{ port|axisprefix(i) }}_tready_q <= '0';
        {{ port|axisprefix(i) }}_tvalid_stored <= '0';
        {%- endif %}
        {{ port|axisprefix(i) }}_tvalid_q <= '0';
      else
        {%- if port['supports_backpressure'] %}
        -- AXI4-Stream Pipeline
        if (((ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.ready = '1') OR ({{ port|axisprefix(i) }}_tvalid_q = '0')) AND ({{ port|axisprefix(i) }}_tready_q = '1')) then
          -- Output gets input
          {{ port|axisprefix(i) }}_tvalid_q <= {{ port|axisprefix(i) }}_tvalid;
        elsif ((ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.ready = '1') AND ({{ port|axisprefix(i) }}_tready_q = '0')) then
          -- Stored is sent to output
          {{ port|axisprefix(i) }}_tvalid_q <= {{ port|axisprefix(i) }}_tvalid_stored;
        else
          -- Hold
          {{ port|axisprefix(i) }}_tvalid_q <= {{ port|axisprefix(i) }}_tvalid_q;
        end if;
        if (((ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.ready = '0') AND ({{ port|axisprefix(i) }}_tvalid_q = '1')) AND ({{ port|axisprefix(i) }}_tready_q = '1')) then
          -- Input is stored
          {{ port|axisprefix(i) }}_tvalid_stored <= {{ port|axisprefix(i) }}_tvalid;
        elsif ((ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.ready = '1') AND ({{ port|axisprefix(i) }}_tready_q = '0')) then
          -- Stored is sent to output, clear stored valid
          {{ port|axisprefix(i) }}_tvalid_stored <= '0';
        else
          -- Hold
          {{ port|axisprefix(i) }}_tvalid_stored <= {{ port|axisprefix(i) }}_tvalid_stored;
        end if;
        if ((({{ port|axisprefix(i) }}_tvalid_q = '0') OR ({{ port|axisprefix(i) }}_tvalid = '0')) AND ({{ port|axisprefix(i) }}_tvalid_stored = '0')) then
          -- Since our storage is clear and either input or output are clear, we are ready to accept data
          {{ port|axisprefix(i) }}_tready_q <= '1';
        elsif (ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.ready = '1') then
          -- When the output is ready we are ready to accept data
          {{ port|axisprefix(i) }}_tready_q <= '1';
        else
          -- Not ready
          {{ port|axisprefix(i) }}_tready_q <= '0';
        end if;
        {%- else %}
        -- Simple Pipeline
        {{ port|axisprefix(i) }}_tvalid_q <= {{ port|axisprefix(i) }}_tvalid;
        {%- endif %}
      end if;
    end if;
  end process s_input_pipeline_{{ port['name']|lower }}{{ '%0#2d'|format(i) }};

  -- Assign the record interfaces and outputs
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.last  <= {{ port|axisprefix(i) }}_tlast_q;
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.data <= f_unserialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data({{ port|axisprefix(i) }}_tdata_q);
  {%- if 'metadata' in port %}
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.metadata <= f_unserialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata({{ port|axisprefix(i) }}_tuser_q);
  {%- endif %}
  {%- if port['supports_backpressure'] %}
  {{ port|axisprefix(i) }}_tready <= {{ port|axisprefix(i) }}_tready_q;
  {%- endif %}
  {%- if port['supports_byte_enable'] %}
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.keep <= {{ port|axisprefix(i) }}_tkeep_q;
  {%- endif %}
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.valid <= {{ port|axisprefix(i) }}_tvalid_q;

  {%- else  %}{#### if port['use_pipeline'] ####}
  -- Reinterpret AXI4-Stream port only
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.last  <= {{ port|axisprefix(i) }}_tlast;
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.data <= f_unserialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data({{ port|axisprefix(i) }}_tdata);
  {%- if 'metadata' in port %}
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.metadata <= f_unserialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata({{ port|axisprefix(i) }}_tuser);
  {%- endif %}
  {%- if port['supports_backpressure'] %}
  {{ port|axisprefix(i) }}_tready <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.ready;
  {%- endif %}
  {%- if port['supports_byte_enable'] %}
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.keep <= {{ port|axisprefix(i) }}_keep;
  {%- endif %}
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.valid <= {{ port|axisprefix(i) }}_tvalid;

  {%- endif  %}{#### if port['use_pipeline'] ####}
  {%- endfor %}{#### for i in range(port['num_instances']) ####}
  {%- endif  %}{#### if port['direction']|lower == 'in' ####}
  {%- endfor %}{#### for port in fins['ports']['ports'] ####}

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------
  {%- for port in fins['ports']['ports'] %}
  {%- if port['direction']|lower == 'out' %}
  {%- for i in range(port['num_instances']) %}
  {%- if port['use_pipeline'] %}
  --*****************************************
  -- Output Port: {{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}
  --*****************************************
  s_output_pipeline_{{ port['name']|lower }}{{ '%0#2d'|format(i) }} : process ({{ port|axisprefix(i) }}_aclk)
  begin
    if (rising_edge({{ port|axisprefix(i) }}_aclk)) then
      ---------------------
      -- Data registers
      ---------------------
      {%- if port['supports_backpressure'] %}
      -- AXI4-Stream Pipeline
      if ((({{ port|axisprefix(i) }}_tready = '1') OR ({{ port|axisprefix(i) }}_tvalid_q = '0')) AND ({{ port|axisprefix(i) }}_tready_q = '1')) then
        -- Output gets input
        {{ port|axisprefix(i) }}_tlast_q <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.last;
        {{ port|axisprefix(i) }}_tdata_q <= f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data(ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.data);
        {%- if 'metadata' in port %}
        {{ port|axisprefix(i) }}_tuser_q <= f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata(ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.metadata);
        {%- endif %}
        {%- if port['supports_byte_enable'] %}
        {{ port|axisprefix(i) }}_tkeep_q <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.keep;
        {%- endif %}
      elsif (({{ port|axisprefix(i) }}_tready = '1') AND ({{ port|axisprefix(i) }}_tready_q = '0')) then
        -- Stored is sent to output
        {{ port|axisprefix(i) }}_tlast_q <= {{ port|axisprefix(i) }}_tlast_stored;
        {{ port|axisprefix(i) }}_tdata_q <= {{ port|axisprefix(i) }}_tdata_stored;
        {%- if 'metadata' in port %}
        {{ port|axisprefix(i) }}_tuser_q <= {{ port|axisprefix(i) }}_tuser_stored;
        {%- endif %}
        {%- if port['supports_byte_enable'] %}
        {{ port|axisprefix(i) }}_tkeep_q <= {{ port|axisprefix(i) }}_tkeep_stored;
        {%- endif %}
      end if;
      if ((({{ port|axisprefix(i) }}_tready = '0') AND ({{ port|axisprefix(i) }}_tvalid_q = '1')) AND ({{ port|axisprefix(i) }}_tready_q = '1')) then
        -- Input is stored
        {{ port|axisprefix(i) }}_tlast_stored <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.last;
        {{ port|axisprefix(i) }}_tdata_stored <= f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data(ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.data);
        {%- if 'metadata' in port %}
        {{ port|axisprefix(i) }}_tuser_stored <= f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata(ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.metadata);
        {%- endif %}
        {%- if port['supports_byte_enable'] %}
        {{ port|axisprefix(i) }}_tkeep_stored <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.keep;
        {%- endif %}
      end if;
      {%- else %}
      -- Simple Pipeline
      {{ port|axisprefix(i) }}_tlast_q <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.last;
      {{ port|axisprefix(i) }}_tdata_q <= f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data(ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.data);
      {%- if 'metadata' in port %}
      {{ port|axisprefix(i) }}_tuser_q <= f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata(ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.metadata);
      {%- endif %}
      {%- if port['supports_byte_enable'] %}
      {{ port|axisprefix(i) }}_tkeep_q <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.keep;
      {%- endif %}
      {%- endif %}
      ---------------------
      -- Control registers
      ---------------------
      if ({{ port|axisprefix(i) }}_aresetn = '0') then
        {%- if port['supports_backpressure'] %}
        {{ port|axisprefix(i) }}_tready_q       <= '0';
        {{ port|axisprefix(i) }}_tvalid_stored <= '0';
        {%- endif %}
        {{ port|axisprefix(i) }}_tvalid_q      <= '0';
      else
        {%- if port['supports_backpressure'] %}
        -- AXI4-Stream Pipeline
        if ((({{ port|axisprefix(i) }}_tready = '1') OR ({{ port|axisprefix(i) }}_tvalid_q = '0')) AND ({{ port|axisprefix(i) }}_tready_q = '1')) then
          -- Output gets input
          {{ port|axisprefix(i) }}_tvalid_q <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.valid;
        elsif (({{ port|axisprefix(i) }}_tready = '1') AND ({{ port|axisprefix(i) }}_tready_q = '0')) then
          -- Stored is sent to output
          {{ port|axisprefix(i) }}_tvalid_q <= {{ port|axisprefix(i) }}_tvalid_stored;
        else
          -- Hold
          {{ port|axisprefix(i) }}_tvalid_q <= {{ port|axisprefix(i) }}_tvalid_q;
        end if;
        if ((({{ port|axisprefix(i) }}_tready = '0') AND ({{ port|axisprefix(i) }}_tvalid_q = '1')) AND ({{ port|axisprefix(i) }}_tready_q = '1')) then
          -- Input is stored
          {{ port|axisprefix(i) }}_tvalid_stored <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.valid;
        elsif (({{ port|axisprefix(i) }}_tready = '1') AND ({{ port|axisprefix(i) }}_tready_q = '0')) then
          -- Stored is sent to output, clear stored valid
          {{ port|axisprefix(i) }}_tvalid_stored <= '0';
        else
          -- Hold
          {{ port|axisprefix(i) }}_tvalid_stored <= {{ port|axisprefix(i) }}_tvalid_stored;
        end if;
        if ((({{ port|axisprefix(i) }}_tvalid_q = '0') OR (ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.valid = '0')) AND ({{ port|axisprefix(i) }}_tvalid_stored = '0')) then
          -- Since our storage is clear and either input or output are clear, we are ready to accept data
          {{ port|axisprefix(i) }}_tready_q <= '1';
        elsif ({{ port|axisprefix(i) }}_tready = '1') then
          -- When the output is ready we are ready to accept data
          {{ port|axisprefix(i) }}_tready_q <= '1';
        else
          -- Not ready
          {{ port|axisprefix(i) }}_tready_q <= '0';
        end if;
        {%- else %}
        -- Simple Pipeline
        {{ port|axisprefix(i) }}_tvalid_q <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.valid;
        {%- endif %}
      end if;
    end if;
  end process s_output_pipeline_{{ port['name']|lower }}{{ '%0#2d'|format(i) }};

  -- Assign the record interfaces and outputs
  {{ port|axisprefix(i) }}_tlast  <= {{ port|axisprefix(i) }}_tlast_q;
  {{ port|axisprefix(i) }}_tdata  <= {{ port|axisprefix(i) }}_tdata_q;
  {%- if 'metadata' in port %}
  {{ port|axisprefix(i) }}_tuser  <= {{ port|axisprefix(i) }}_tuser_q;
  {%- endif %}
  {{ port|axisprefix(i) }}_tvalid <= {{ port|axisprefix(i) }}_tvalid_q;
  {%- if port['supports_backpressure'] %}
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.ready <= {{ port|axisprefix(i) }}_tready_q;
  {%- endif %}
  {%- if port['supports_byte_enable'] %}
  {{ port|axisprefix(i) }}_tkeep  <= {{ port|axisprefix(i) }}_tkeep_q;
  {%- endif %}

  {%- else  %}{#### if port['use_pipeline'] ####}
  -- Reinterpret AXI4-Stream port only
  {{ port|axisprefix(i) }}_tlast  <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.last;
  {{ port|axisprefix(i) }}_tdata  <= f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_data(ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.data);
  {%- if 'metadata' in port %}
  {{ port|axisprefix(i) }}_tuser  <= f_serialize_{{ fins['name']|lower }}_{{ port['name']|lower }}_metadata(ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.metadata);
  {%- endif %}
  {{ port|axisprefix(i) }}_tvalid <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.valid;
  {%- if port['supports_backpressure'] %}
  ports_in.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.ready <= {{ port|axisprefix(i) }}_tready;
  {%- endif %}
  {%- if port['supports_byte_enable'] %}
  {{ port|axisprefix(i) }}_tkeep  <= ports_out.{{ port['name']|lower }}{% if port['num_instances'] > 1 %}({{ i }}){% endif %}.keep;
  {%- endif %}

  {%- endif  %}{#### if port['use_pipeline'] ####}
  {%- endfor %}{#### for i in range(port['num_instances']) ####}
  {%- endif  %}{#### if port['direction']|lower == 'out' ####}
  {%- endfor %}{#### for port in fins['ports']['ports'] ####}

end rtl;
