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
-- -------------------------------------------------------------
-- Template:    nodeset_tb.vhd
-- Backend:     {{ fins['backend'] }}
-- Generated:   {{ now }}
-- -------------------------------------------------------------
-- Description: Top-level testbench code stub for a FINS nodeset
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;
library std;
use std.textio.all;

-- User Libraries
library work;
-- TODO codegen based on component nodes
{%  for node in fins['nodes'] %}
{%-  if 'descriptive_node' not in node or not node['descriptive_node'] %}
{%-   set node_name = node['node_details']['name']|lower %}
library {{ node_name }}_00;
use {{ node_name }}_00.all;
use {{ node_name }}_00.{{ node_name }}_pkg.all;
{%   endif %}
{%- endfor %}

-- Entity
entity {{ fins['name'] }}_tb is
  {%- if 'ports' in fins %}
  {%-  if 'ports' in fins['ports'] %}
  generic (
    -- TODO codegen based on generics of component nodes? or params of nodeset?
    {%- for port in fins['ports']['ports'] %}
    {%-  set outer_loop = loop %}
    {%-  for i in range(port['num_instances']) %}
    {%-   if port['direction'] == "in" %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_SAMPLE_PERIOD : positive := 1;
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_RANDOMIZE_BUS : boolean := false;
    {%-    if fins['backend']|lower == 'quartus' %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH      : string := "../../../sim_data/sim_source_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}.txt"{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%-    else %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH      : string := "../../../../../../sim_data/sim_source_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}.txt"{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%-    endif %}
    {%-   else %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_NUM_PACKETS_EXPECTED : natural := 1;
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_SAMPLE_PERIOD   : positive := 1;
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_RANDOMIZE_BUS   : boolean := false;
    {%-    if fins['backend']|lower == 'quartus' %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_FILEPATH        : string := "../../../sim_data/sim_sink_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}.txt"{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%-    else %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_FILEPATH        : string := "../../../../../../sim_data/sim_sink_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}.txt"{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%-    endif %}
    {%-   endif  %}{#### if port['direction'] == "in" ####}
    {%-  endfor %}{#### for i in range(port['num_instances']) ####}
    {%- endfor %}{#### for port in fins['ports']['ports'] ####}
  );
  {%-  endif  %}{#### if 'ports' in fins['ports'] ####}
  {%- endif  %}{#### if 'ports' in fins ####}
end entity {{ fins['name'] }}_tb;

-- Architecture
architecture behav of {{ fins['name'] }}_tb is
  --------------------------------------------------------------------------------
  -- Device Under Test Interface Signals
  --------------------------------------------------------------------------------
  -- AXI4-Lite Properties Buses

  {%- if 'interface-exports' in fins %}
  {%-  for interface_export in fins['interface-exports'] %}
  {%-   set node_name = interface_export['node_name']|lower %}
  {%-   set node      = interface_export['node'] %}
  {%-   for interface in interface_export['interfaces'] %}
  -- AXILite Interface "{{ interface['name'] }}" on node "{{ node_name }}"
  {%- set addr_width = node['node_details']['properties']['addr_width'] %}
  {%- set data_width = node['node_details']['properties']['data_width'] %}
  --signal {{ node_name }}_{{ interface['name'] }}_ACLK    : std_logic;
  --signal {{ node_name }}_{{ interface['name'] }}_ARESETN : std_logic;
  signal {{ node_name }}_{{ interface['name'] }}_AWADDR  : std_logic_vector({{ addr_width }}-1 downto 0);
  signal {{ node_name }}_{{ interface['name'] }}_AWPROT  : std_logic_vector(2 downto 0);
  signal {{ node_name }}_{{ interface['name'] }}_AWVALID : std_logic;
  signal {{ node_name }}_{{ interface['name'] }}_AWREADY : std_logic;
  signal {{ node_name }}_{{ interface['name'] }}_WDATA   : std_logic_vector({{ data_width }}-1 downto 0);
  signal {{ node_name }}_{{ interface['name'] }}_WSTRB   : std_logic_vector(({{ data_width }}/8)-1 downto 0);
  signal {{ node_name }}_{{ interface['name'] }}_WVALID  : std_logic;
  signal {{ node_name }}_{{ interface['name'] }}_WREADY  : std_logic;
  signal {{ node_name }}_{{ interface['name'] }}_BRESP   : std_logic_vector(1 downto 0);
  signal {{ node_name }}_{{ interface['name'] }}_BVALID  : std_logic;
  signal {{ node_name }}_{{ interface['name'] }}_BREADY  : std_logic;
  signal {{ node_name }}_{{ interface['name'] }}_ARADDR  : std_logic_vector({{ addr_width }}-1 downto 0);
  signal {{ node_name }}_{{ interface['name'] }}_ARPROT  : std_logic_vector(2 downto 0);
  signal {{ node_name }}_{{ interface['name'] }}_ARVALID : std_logic;
  signal {{ node_name }}_{{ interface['name'] }}_ARREADY : std_logic;
  signal {{ node_name }}_{{ interface['name'] }}_RDATA   : std_logic_vector({{ data_width }}-1 downto 0);
  signal {{ node_name }}_{{ interface['name'] }}_RRESP   : std_logic_vector(1 downto 0);
  signal {{ node_name }}_{{ interface['name'] }}_RVALID  : std_logic;
  signal {{ node_name }}_{{ interface['name'] }}_RREADY  : std_logic;
  {%-   endfor %}
  {%-  endfor %}
  {%- endif %}


  {%- if 'ports' in fins %}
  {%-  if 'hdl_ports' in fins['ports'] %}
  -- Discrete HDL Ports
  {%-   for hdl_port in fins['ports']['hdl_ports'] %}
  {%-    if hdl_port['bit_width'] > 1 %}
  signal {{ hdl_port['name'] }} : std_logic_vector({{ hdl_port['bit_width'] }}-1 downto 0);
  {%-    else %}
  signal {{ hdl_port['name'] }} : std_logic;
  {%-    endif %}
  {%-   endfor %}
  {%-  endif %}

  {%-  if 'ports' in fins['ports'] %}
  generic (
    -- TODO codegen based on generics of component nodes? or params of nodeset?
  {%-   for port in fins['ports']['ports'] %}
  -- AXI4-Stream Port {{ port['direction']|upper }}: {{ port['name']|lower }}
  {%-    for i in range(port['num_instances']) %}
  signal {{ port|axisprefix(i) }}_aclk    : std_logic;
  signal {{ port|axisprefix(i) }}_aresetn : std_logic;
  {%-     if port['supports_backpressure'] %}
  signal {{ port|axisprefix(i) }}_tready  : std_logic;
  {%-     endif %}
  signal {{ port|axisprefix(i) }}_tdata   : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
  {%-     if 'metadata' in port %}
  signal {{ port|axisprefix(i) }}_tuser   : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
  {%-     endif %}
  signal {{ port|axisprefix(i) }}_tvalid  : std_logic;
  signal {{ port|axisprefix(i) }}_tlast   : std_logic;
  {%-    endfor %}{#### for i in range(port['num_instances']) ####}
  {%-   endfor %}{#### for port in fins['ports']['ports'] ####}
  {%-  endif  %}{#### if 'ports' in fins['ports'] ####}
  {%- endif  %}{#### if 'ports' in fins ####}

  --------------------------------------------------------------------------------
  -- Testbench
  --------------------------------------------------------------------------------
  -- Constants
  -- TODO generate a clock for each node?
  constant CLOCK_PERIOD  : time := 5 ns; -- 200MHz

  -- Signals
  signal simulation_done : boolean := false;
  signal clock           : std_logic := '0';
  signal resetn          : std_logic := '1';
  {%- if 'ports' in fins %}
  {%-  if 'ports' in fins['ports'] %}
  {%-   for port in fins['ports']['ports'] %}
  {%-    for i in range(port['num_instances']) %}
  {%-     if port['direction']|lower == 'in' %}
  signal {{ port|axisprefix(i) }}_enable : std_logic := '0';
  {%-     else %}
  signal {{ port|axisprefix(i) }}_verify_done : boolean := false;
  {%-     endif %}
  {%-    endfor %}{#### for i in range(port['num_instances']) ####}
  {%-   endfor %}{#### for port in fins['ports']['ports'] ####}
  {%-  endif  %}{#### if 'ports' in fins['ports'] ####}
  {%- endif  %}{#### if 'ports' in fins ####}
begin

  --------------------------------------------------------------------------------
  -- Device Under Test
  --------------------------------------------------------------------------------
  -- TODO last comma? three different possible loops
  --u_dut : entity work.nodeset_test
  u_dut : entity work.nodeset_test
    port map (
      clk_clk => clock,
      {%- if 'interface-exports' in fins %}
      {%-  for interface_export in fins['interface-exports'] %}
      {%-   set node_name = interface_export['node_name']|lower %}
      {%-   for interface in interface_export['interfaces'] %}
      --{{ node_name }}_{{ interface['name'] }}_ACLK    => {{ node_name }}_{{ interface['name'] }}_ACLK   ,
      --{{ node_name }}_{{ interface['name'] }}_ARESETN => {{ node_name }}_{{ interface['name'] }}_ARESETN,
      {{ node_name }}_{{ interface['name'] }}_AWADDR  => {{ node_name }}_{{ interface['name'] }}_AWADDR ,
      {{ node_name }}_{{ interface['name'] }}_AWPROT  => {{ node_name }}_{{ interface['name'] }}_AWPROT ,
      {{ node_name }}_{{ interface['name'] }}_AWVALID => {{ node_name }}_{{ interface['name'] }}_AWVALID,
      {{ node_name }}_{{ interface['name'] }}_AWREADY => {{ node_name }}_{{ interface['name'] }}_AWREADY,
      {{ node_name }}_{{ interface['name'] }}_WDATA   => {{ node_name }}_{{ interface['name'] }}_WDATA  ,
      {{ node_name }}_{{ interface['name'] }}_WSTRB   => {{ node_name }}_{{ interface['name'] }}_WSTRB  ,
      {{ node_name }}_{{ interface['name'] }}_WVALID  => {{ node_name }}_{{ interface['name'] }}_WVALID ,
      {{ node_name }}_{{ interface['name'] }}_WREADY  => {{ node_name }}_{{ interface['name'] }}_WREADY ,
      {{ node_name }}_{{ interface['name'] }}_BRESP   => {{ node_name }}_{{ interface['name'] }}_BRESP  ,
      {{ node_name }}_{{ interface['name'] }}_BVALID  => {{ node_name }}_{{ interface['name'] }}_BVALID ,
      {{ node_name }}_{{ interface['name'] }}_BREADY  => {{ node_name }}_{{ interface['name'] }}_BREADY ,
      {{ node_name }}_{{ interface['name'] }}_ARADDR  => {{ node_name }}_{{ interface['name'] }}_ARADDR ,
      {{ node_name }}_{{ interface['name'] }}_ARPROT  => {{ node_name }}_{{ interface['name'] }}_ARPROT ,
      {{ node_name }}_{{ interface['name'] }}_ARVALID => {{ node_name }}_{{ interface['name'] }}_ARVALID,
      {{ node_name }}_{{ interface['name'] }}_ARREADY => {{ node_name }}_{{ interface['name'] }}_ARREADY,
      {{ node_name }}_{{ interface['name'] }}_RDATA   => {{ node_name }}_{{ interface['name'] }}_RDATA  ,
      {{ node_name }}_{{ interface['name'] }}_RRESP   => {{ node_name }}_{{ interface['name'] }}_RRESP  ,
      {{ node_name }}_{{ interface['name'] }}_RVALID  => {{ node_name }}_{{ interface['name'] }}_RVALID ,
      {{ node_name }}_{{ interface['name'] }}_RREADY  => {{ node_name }}_{{ interface['name'] }}_RREADY ,
      {%-   endfor %}
      {%-  endfor %}
      {%- endif %}

      {%- if 'ports' in fins %}
      {%-  if 'hdl_ports' in fins['ports'] %}
      -- Discrete HDL Ports
      {%-   for hdl_port in fins['ports']['hdl_ports'] %}
      {{ hdl_port['name'] }} => {{ hdl_port['name'] }} ,
      {%-   endfor %}{#### for hdl_port in fins['ports']['hdl_ports'] ####}
      {%-  endif  %}{#### if 'hdl_ports' in fins['ports'] ####}

      {%-  if 'ports' in fins['ports'] %}
      {%-   for port in fins['ports']['ports'] %}
      {%-    for i in range(port['num_instances']) %}
      --{{ port|axisprefix(i) }}_aclk    => {{ port|axisprefix(i) }}_aclk    ,
      --{{ port|axisprefix(i) }}_aresetn => {{ port|axisprefix(i) }}_aresetn ,
      {%-     if port['supports_backpressure'] %}
      {{ port|axisprefix(i) }}_tready  => {{ port|axisprefix(i) }}_tready  ,
      {%-     endif %}
      {{ port|axisprefix(i) }}_tdata   => {{ port|axisprefix(i) }}_tdata   ,
      {%-     if 'metadata' in port %}
      {{ port|axisprefix(i) }}_tuser   => {{ port|axisprefix(i) }}_tuser   ,
      {%-     endif %}
      {{ port|axisprefix(i) }}_tvalid  => {{ port|axisprefix(i) }}_tvalid  ,
      {{ port|axisprefix(i) }}_tlast   => {{ port|axisprefix(i) }}_tlast   ,
      {%-    endfor %}{#### for i in range(port['num_instances']) ####}
      {%-   endfor %}{#### for port in fins['ports']['ports'] ####}
      {%-  endif  %}{#### if 'ports' in fins['ports'] ####}

      {%- endif  %}{#### if 'ports' in fins ####}

      reset_reset_n => resetn
    );

  {%- if 'ports' in fins %}
  {%-  if 'ports' in fins['ports'] %}
  --------------------------------------------------------------------------------
  -- File Input/Output AXI4-Stream Port Verification
  --------------------------------------------------------------------------------
  -- NOTE: The source/sink filepaths are relative to where the simulation is executed
  u_file_io : entity test_top_00.test_top_axis_verify
    generic map (
    {%- for port in fins['ports']['ports'] %}
    {%-  set outer_loop = loop %}
    {%-  for i in range(port['num_instances']) %}
    {%-   if port['direction'] == "in" %}
      G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_SAMPLE_PERIOD => G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_SAMPLE_PERIOD,
      G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_RANDOMIZE_BUS => G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_RANDOMIZE_BUS,
      G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH      => G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH{% if not (outer_loop.last and loop.last) %},{% endif %}
      {%- else %}
      G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_SAMPLE_PERIOD => G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_SAMPLE_PERIOD,
      G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_RANDOMIZE_BUS => G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_RANDOMIZE_BUS,
      G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_FILEPATH      => G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_FILEPATH{% if not (outer_loop.last and loop.last) %},{% endif %}
    {%-   endif %}
    {%-  endfor %}
    {%- endfor %}
    )
    port map (
      simulation_done => simulation_done,
      {%- for port in fins['ports']['ports'] %}
      {%-  set outer_loop = loop %}
      {%-  for i in range(port['num_instances']) %}
      {%-   if port['direction']|lower == 'out' %}
      --{{ port|axisprefix(i,True) }}_aclk    => {{ port|axisprefix(i) }}_aclk,
      {{ port|axisprefix(i,True) }}_aclk    => clock,
      {%-    if port['supports_backpressure'] %}
      {{ port|axisprefix(i,True) }}_tready  => {{ port|axisprefix(i) }}_tready,
      {%-    endif %}
      {{ port|axisprefix(i,True) }}_tdata   => {{ port|axisprefix(i) }}_tdata,
      {%-    if 'metadata' in port %}
      {{ port|axisprefix(i,True) }}_tuser   => {{ port|axisprefix(i) }}_tuser,
      {%-    endif %}
      {{ port|axisprefix(i,True) }}_tvalid  => {{ port|axisprefix(i) }}_tvalid,
      {{ port|axisprefix(i,True) }}_tlast   => {{ port|axisprefix(i) }}_tlast{% if not (outer_loop.last and loop.last) %},{% endif %}
      {%-   else %}
      --{{ port|axisprefix(i,True) }}_aclk    => {{ port|axisprefix(i) }}_aclk,
      {{ port|axisprefix(i,True) }}_aclk    => clock,
      {{ port|axisprefix(i,True) }}_enable  => {{ port|axisprefix(i) }}_enable,
      {%-    if port['supports_backpressure'] %}
      {{ port|axisprefix(i,True) }}_tready  => {{ port|axisprefix(i) }}_tready,
      {%-    endif %}
      {{ port|axisprefix(i,True) }}_tdata   => {{ port|axisprefix(i) }}_tdata,
      {%-    if 'metadata' in port %}
      {{ port|axisprefix(i,True) }}_tuser   => {{ port|axisprefix(i) }}_tuser,
      {%-    endif %}
      {{ port|axisprefix(i,True) }}_tvalid  => {{ port|axisprefix(i) }}_tvalid,
      {{ port|axisprefix(i,True) }}_tlast   => {{ port|axisprefix(i) }}_tlast{% if not (outer_loop.last and loop.last) %},{% endif %}
      {%-   endif %}
      {%-  endfor %}
      {%- endfor %}
    );
  {%-  endif %}
  {%- endif %}

  --------------------------------------------------------------------------------
  -- Clocks and Resets
  --------------------------------------------------------------------------------
  -- Waveform process to generate a clock
  w_clock : process
  begin
    if (simulation_done = false) then
      clock <= '0';
      wait for CLOCK_PERIOD/2;
      clock <= '1';
      wait for CLOCK_PERIOD/2;
    else
      wait;
    end if;
  end process w_clock;

  -- By default, copy the clock and reset for the Ports and Properties interfaces
  --S_AXI_ACLK    <= clock;
  --S_AXI_ARESETN <= resetn;
  --S_AXI_TEST_MIDDLE_ACLK    <= clock;
  --S_AXI_TEST_MIDDLE_ARESETN <= resetn;
  --S_AXI_TEST_BOTTOM_ACLK    <= clock;
  --S_AXI_TEST_BOTTOM_ARESETN <= resetn;
  --s_axis_myinput_aclk    <= clock;
  --s_axis_myinput_aresetn <= resetn;
  --m_axis_myoutput_aclk    <= clock;
  --m_axis_myoutput_aresetn <= resetn;
  --s00_axis_test_in_aclk    <= clock;
  --s00_axis_test_in_aresetn <= resetn;
  --s01_axis_test_in_aclk    <= clock;
  --s01_axis_test_in_aresetn <= resetn;
  --m00_axis_test_out_aclk    <= clock;
  --m00_axis_test_out_aresetn <= resetn;
  --m01_axis_test_out_aclk    <= clock;
  --m01_axis_test_out_aresetn <= resetn;
  --s_axis_sfix_cpx_in_aclk    <= clock;
  --s_axis_sfix_cpx_in_aresetn <= resetn;
  --m_axis_sfix_cpx_out_aclk    <= clock;
  --m_axis_sfix_cpx_out_aresetn <= resetn;

  {%- if 'ports' in fins %}
  {%-  if 'ports' in fins['ports'] %}
  --------------------------------------------------------------------------------
  -- Port Verification Procedures
  --------------------------------------------------------------------------------
  {%-  for port in fins['ports']['ports'] %}
  {%-   if port['direction']|lower == 'out' %}
  {%-    for i in range(port['num_instances']) %}
  -- Waveform process to wait for packets on the {{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %} output port
  w_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_verify : process
    variable my_line          : line;
    variable packets_received : natural := 0;
  begin
    -- Wait for global reset to complete
    if (resetn = '0') then
      wait until (resetn = '1');
    end if;
    -- Wait for all expected packets using the TLAST signal
    while (packets_received < G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_NUM_PACKETS_EXPECTED) loop
      wait until falling_edge({{ port|axisprefix(i) }}_aclk);
      {%-  if port['supports_backpressure'] %}
      if (({{ port|axisprefix(i) }}_tvalid = '1') AND ({{ port|axisprefix(i) }}_tlast = '1') AND ({{ port|axisprefix(i) }}_tready = '1')) then
      {%-  else %}
      if (({{ port|axisprefix(i) }}_tvalid = '1') AND ({{ port|axisprefix(i) }}_tlast = '1')) then
      {%-  endif %}
        packets_received := packets_received + 1;
      end if;
    end loop;
    -- End this process
    write(my_line, string'("PASS: Data received from Port {{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}"));
    writeline(output, my_line);
    {{ port|axisprefix(i) }}_verify_done <= true;
    wait;
  end process w_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_verify;

  {%      endfor %}{#### for i in range(port['num_instances']) ####}
  {%-    endif %}
  {%-   endfor %}{#### for port in fins['ports']['ports'] ####}
  {%-  endif  %}{#### if 'ports' in fins['ports'] ####}
  {%- endif  %}{#### if 'ports' in fins ####}

  --------------------------------------------------------------------------------
  -- Main Test Procedure
  --------------------------------------------------------------------------------
  w_test_procedure : process
    variable my_line : line;
  begin

    --**************************************************
    -- Reset
    --**************************************************
    resetn <= '0';
    wait for CLOCK_PERIOD*10; -- Wait for an arbitrary 10 clocks
    resetn <= '1';
    wait for CLOCK_PERIOD;

    {%- if 'interface-exports' in fins %}
    --**************************************************
    -- Verify Properties
    --**************************************************
    {%-  for interface_export in fins['interface-exports'] %}
    {%-   set node_name = interface_export['node_name']|lower %}
    {%-   set node      = interface_export['node'] %}
    {%-   for interface in interface_export['interfaces'] %}
    -- Verify Properties on AXILite Interface "{{ interface['name'] }}" on node "{{ node_name }}"
    {{ node_name }}_{{ fins['name']|lower }}_axilite_verify (
      {{ node_name }}_{{ interface['name'] }}_ACLK,   {{ node_name }}_{{ interface['name'] }}_ARESETN,
      {{ node_name }}_{{ interface['name'] }}_AWADDR, {{ node_name }}_{{ interface['name'] }}_AWPROT, {{ node_name }}_{{ interface['name'] }}_AWVALID, {{ node_name }}_{{ interface['name'] }}_AWREADY,
      {{ node_name }}_{{ interface['name'] }}_WDATA,  {{ node_name }}_{{ interface['name'] }}_WSTRB,  {{ node_name }}_{{ interface['name'] }}_WVALID,  {{ node_name }}_{{ interface['name'] }}_WREADY,
      {{ node_name }}_{{ interface['name'] }}_BRESP,  {{ node_name }}_{{ interface['name'] }}_BVALID, {{ node_name }}_{{ interface['name'] }}_BREADY,
      {{ node_name }}_{{ interface['name'] }}_ARADDR, {{ node_name }}_{{ interface['name'] }}_ARPROT, {{ node_name }}_{{ interface['name'] }}_ARVALID, {{ node_name }}_{{ interface['name'] }}_ARREADY,
      {{ node_name }}_{{ interface['name'] }}_RDATA,  {{ node_name }}_{{ interface['name'] }}_RRESP,  {{ node_name }}_{{ interface['name'] }}_RVALID,  {{ node_name }}_{{ interface['name'] }}_RREADY
    );

    {%-   endfor %}{#### for interface in range(interface-exports['interfaces']) ####}
    {%-  endfor %}{#### for interface_export in fins['interface-exports'] ####}
    {%- endif %}{#### if 'interface-exports' in fins ####}

    {%- if 'ports' in fins %}
    {%-  if 'ports' in fins['ports'] %}
    --**************************************************
    -- Verify Ports
    --**************************************************
    -- Enable the inputs
    {%-  for port in fins['ports']['ports'] %}
    {%-   if port['direction']|lower == 'in' %}
    {%-    for i in range(port['num_instances']) %}
    {{ port|axisprefix(i) }}_enable <= '1';
    {%-    endfor %}
    {%-   endif %}
    {%-  endfor %}

    write(my_line, string'("Beggining ouptut verification"));
    writeline(output, my_line);

    -- Wait for the output verification processes to complete
    {%-  for port in fins['ports']['ports'] %}
    {%-   if port['direction']|lower == 'out' %}
    {%-    for i in range(port['num_instances']) %}
    if (not {{ port|axisprefix(i) }}_verify_done) then
      wait until ({{ port|axisprefix(i) }}_verify_done);
    end if;
    write(my_line, string'("Verification complete for '{{ port['name'] }}'"));
    writeline(output, my_line);
    {%-    endfor %}{#### for i in range(port['num_instances']) ####}
    {%-   endif %}
    {%-  endfor %}{#### for port in fins['ports']['ports'] ####}

    {%-  endif  %}{#### if 'ports' in fins['ports'] ####}
    {%- endif  %}{#### if 'ports' in fins ####}

    --**************************************************
    -- End Simulation
    --**************************************************
    write(my_line, string'("***** SIMULATION PASSED *****"));
    writeline(output, my_line);
    simulation_done <= true;
    wait;

  end process w_test_procedure;

end behav;
