{#-
--
-- Copyright (C) 2020 Geon Technologies, LLC
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
-- Template:    {{ fins['name'] }}_tb.vhd
-- Backend:     {{ fins['backend'] }}
-- -------------------------------------------------------------
-- Description: Top-level testbench code stub for a FINS Application
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
use work.{{ fins['name']|lower }}_pkg.all;

{%  if 'prop_interfaces' in fins %}
{%-  for node_interfaces in fins['prop_interfaces'] %}
-- HDL imports for property-interfaces on node '{{ node_interfaces['node_name'] }}'
{%-   for interface in node_interfaces['interfaces'] %}
use work.{{ interface['name'] }}_axilite_verify.all;
{%-   endfor %}
{%-  endfor %}
{%  endif %}

-- Entity
entity {{ fins['name'] }}_tb is
  {%- if 'ports' in fins %}
  {%-  if 'ports' in fins['ports'] and fins['ports']['ports']|length > 0 %}
  generic (
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
  -- Clocks and resets
  {%- for clock in fins['clocks'] %}
  signal {{ clock['clock']  }} : std_logic := '0';
  signal {{ clock['resetn'] }} : std_logic := '1';
  {%- endfor %}


  {%- if 'prop_interfaces' in fins %}
  ----------------------------------------------------
  -- Properties Buses
  ----------------------------------------------------
  {%-  for node_interfaces in fins['prop_interfaces'] %}
  {%-   set node_name = node_interfaces['node_name'] %}

  {%-   set addr_width = node_interfaces['addr_width'] %}
  {%-   set data_width = node_interfaces['data_width'] %}

  {%-   for interface in node_interfaces['interfaces'] %}
  {%-    set iface_name = interface|axi4liteprefix(application_external=True) %}
  -- AXILite Interface "{{ iface_name }}" on node "{{ node_name }}"
  signal {{ iface_name }}_AWADDR  : std_logic_vector({{ addr_width }}-1 downto 0);
  signal {{ iface_name }}_AWPROT  : std_logic_vector(2 downto 0);
  signal {{ iface_name }}_AWVALID : std_logic;
  signal {{ iface_name }}_AWREADY : std_logic;
  signal {{ iface_name }}_WDATA   : std_logic_vector({{ data_width }}-1 downto 0);
  signal {{ iface_name }}_WSTRB   : std_logic_vector(({{ data_width }}/8)-1 downto 0);
  signal {{ iface_name }}_WVALID  : std_logic;
  signal {{ iface_name }}_WREADY  : std_logic;
  signal {{ iface_name }}_BRESP   : std_logic_vector(1 downto 0);
  signal {{ iface_name }}_BVALID  : std_logic;
  signal {{ iface_name }}_BREADY  : std_logic;
  signal {{ iface_name }}_ARADDR  : std_logic_vector({{ addr_width }}-1 downto 0);
  signal {{ iface_name }}_ARPROT  : std_logic_vector(2 downto 0);
  signal {{ iface_name }}_ARVALID : std_logic;
  signal {{ iface_name }}_ARREADY : std_logic;
  signal {{ iface_name }}_RDATA   : std_logic_vector({{ data_width }}-1 downto 0);
  signal {{ iface_name }}_RRESP   : std_logic_vector(1 downto 0);
  signal {{ iface_name }}_RVALID  : std_logic;
  signal {{ iface_name }}_RREADY  : std_logic;
  {%-   endfor %}{#### for interface in node_interfaces['interfaces'] ####}
  {%-  endfor %}{#### for node_interfaces in fins['prop_interfaces'] ####}
  {%- endif %}{#### if 'prop_interfaces' in fins ####}

  {% if 'ports' in fins %}
  {%-  if 'hdl' in fins['ports'] and fins['ports']['hdl']|length > 0 %}
  -- Discrete HDL Ports
  {%-   for hdl_port in fins['ports']['hdl'] %}
  {%-    if hdl_port['bit_width'] > 1 %}
  signal {{ hdl_port['name'] }}_port : std_logic_vector({{ hdl_port['bit_width'] }}-1 downto 0);
  {%-    else %}
  signal {{ hdl_port['name'] }}_port : std_logic;
  {%-    endif %}
  {%-   endfor %}
  {%-  endif %}

  {%-  if 'ports' in fins['ports'] and fins['ports']['ports']|length > 0 %}
  {%-   for port in fins['ports']['ports'] %}
  -- AXI4-Stream Port {{ port['direction']|upper }}: {{ port['name']|lower }}
  {%-    for i in range(port['num_instances']) %}
  {%-     if port['supports_backpressure'] %}
  signal {{ port|axisprefix(i) }}_tready  : std_logic;
  {%-     endif %}
  {%-     if port['supports_byte_enable'] %}
  signal {{ port|axisprefix(i) }}_tkeep   : std_logic_vector({{ port['data']['byte_width'] }}-1 downto 0);
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
  {%- for clock in fins['clocks'] %}
  constant {{ clock['base_name'] }}_CLOCK_PERIOD  : time := {{ clock['period_ns'] }} ns;
  {%- endfor %}

  -- Signals
  signal simulation_done : boolean := false;
  {%- if 'ports' in fins %}
  {%-  if 'ports' in fins['ports'] and fins['ports']['ports']|length > 0 %}
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
  u_dut : entity work.{{ fins['name'] }}
    port map (
      {%- if 'prop_interfaces' in fins %}
      {%-  for node_interfaces in fins['prop_interfaces'] %}
      {%-   set node_name = node_interfaces['node_name'] %}
      {%-   for interface in node_interfaces['interfaces'] %}
      {%-    set iface_name = interface|axi4liteprefix(application_external=True) %}
      {{ iface_name }}_AWADDR  => {{ iface_name }}_AWADDR ,
      {{ iface_name }}_AWPROT  => {{ iface_name }}_AWPROT ,
      {{ iface_name }}_AWVALID => {{ iface_name }}_AWVALID,
      {{ iface_name }}_AWREADY => {{ iface_name }}_AWREADY,
      {{ iface_name }}_WDATA   => {{ iface_name }}_WDATA  ,
      {{ iface_name }}_WSTRB   => {{ iface_name }}_WSTRB  ,
      {{ iface_name }}_WVALID  => {{ iface_name }}_WVALID ,
      {{ iface_name }}_WREADY  => {{ iface_name }}_WREADY ,
      {{ iface_name }}_BRESP   => {{ iface_name }}_BRESP  ,
      {{ iface_name }}_BVALID  => {{ iface_name }}_BVALID ,
      {{ iface_name }}_BREADY  => {{ iface_name }}_BREADY ,
      {{ iface_name }}_ARADDR  => {{ iface_name }}_ARADDR ,
      {{ iface_name }}_ARPROT  => {{ iface_name }}_ARPROT ,
      {{ iface_name }}_ARVALID => {{ iface_name }}_ARVALID,
      {{ iface_name }}_ARREADY => {{ iface_name }}_ARREADY,
      {{ iface_name }}_RDATA   => {{ iface_name }}_RDATA  ,
      {{ iface_name }}_RRESP   => {{ iface_name }}_RRESP  ,
      {{ iface_name }}_RVALID  => {{ iface_name }}_RVALID ,
      {{ iface_name }}_RREADY  => {{ iface_name }}_RREADY ,
      {%-   endfor %}{#### for interface in node_interfaces['interfaces'] ####}
      {%-  endfor %}{#### for node_interfaces in fins['prop_interfaces'] ####}
      {%- endif %}{#### if 'prop_interfaces' in fins ####}

      {%- if 'ports' in fins %}
      {%-  if 'hdl' in fins['ports'] and fins['ports']['hdl']|length > 0 %}
      -- Discrete HDL Ports
      {%-   for hdl_port in fins['ports']['hdl'] %}
      {{ hdl_port['name'] }}_port => {{ hdl_port['name'] }}_port ,
      {%-   endfor %}{#### for hdl_port in fins['ports']['hdl'] ####}
      {%-  endif  %}{#### if 'hdl' in fins['ports'] ####}

      {%-  if 'ports' in fins['ports'] and fins['ports']['ports']|length > 0 %}
      {%-   for port in fins['ports']['ports'] %}
      {%-    for i in range(port['num_instances']) %}
      {%-     if port['supports_backpressure'] %}
      {{ port|axisprefix(i) }}_tready  => {{ port|axisprefix(i) }}_tready  ,
      {%-     endif %}
      {%-     if port['supports_byte_enable'] %}
      {{ port|axisprefix(i) }}_tkeep   => {{ port|axisprefix(i) }}_tkeep   ,
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

      {%- for clock in fins['clocks'] %}
      {%-  set outer_loop = loop %}
      {{ clock['clock'] }} => {{ clock['clock'] }},
      {{ clock['resetn'] }} => {{ clock['resetn'] }}{% if not (outer_loop.last and loop.last) %},{% endif %}
      {%- endfor %}
    );

  {%- if 'ports' in fins %}
  {%-  if 'ports' in fins['ports'] and fins['ports']['ports']|length > 0 %}
  --------------------------------------------------------------------------------
  -- File Input/Output AXI4-Stream Port Verification
  --------------------------------------------------------------------------------
  -- NOTE: The source/sink filepaths are relative to where the simulation is executed
  u_file_io : entity work.{{ fins['name']|lower }}_axis_verify
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
      {{ port|axisprefix(i,reverse=True) }}_aclk    => {{ port['clock'] }},
      {%-    if port['supports_backpressure'] %}
      {{ port|axisprefix(i,reverse=True) }}_tready  => {{ port|axisprefix(i) }}_tready,
      {%-    endif %}
      {%-    if port['supports_byte_enable'] %}
      {{ port|axisprefix(i,reverse=True) }}_tkeep   => {{ port|axisprefix(i) }}_tkeep,
      {%-    endif %}
      {{ port|axisprefix(i,reverse=True) }}_tdata   => {{ port|axisprefix(i) }}_tdata,
      {%-    if 'metadata' in port %}
      {{ port|axisprefix(i,reverse=True) }}_tuser   => {{ port|axisprefix(i) }}_tuser,
      {%-    endif %}
      {{ port|axisprefix(i,reverse=True) }}_tvalid  => {{ port|axisprefix(i) }}_tvalid,
      {{ port|axisprefix(i,reverse=True) }}_tlast   => {{ port|axisprefix(i) }}_tlast{% if not (outer_loop.last and loop.last) %},{% endif %}
      {%-   else %}
      {{ port|axisprefix(i,reverse=True) }}_aclk    => {{ port['clock'] }},
      {{ port|axisprefix(i,reverse=True) }}_enable  => {{ port|axisprefix(i) }}_enable,
      {%-    if port['supports_backpressure'] %}
      {{ port|axisprefix(i,reverse=True) }}_tready  => {{ port|axisprefix(i) }}_tready,
      {%-    endif %}
      {%-    if port['supports_byte_enable'] %}
      {{ port|axisprefix(i,reverse=True) }}_tkeep   => {{ port|axisprefix(i) }}_tkeep,
      {%-    endif %}
      {{ port|axisprefix(i,reverse=True) }}_tdata   => {{ port|axisprefix(i) }}_tdata,
      {%-    if 'metadata' in port %}
      {{ port|axisprefix(i,reverse=True) }}_tuser   => {{ port|axisprefix(i) }}_tuser,
      {%-    endif %}
      {{ port|axisprefix(i,reverse=True) }}_tvalid  => {{ port|axisprefix(i) }}_tvalid,
      {{ port|axisprefix(i,reverse=True) }}_tlast   => {{ port|axisprefix(i) }}_tlast{% if not (outer_loop.last and loop.last) %},{% endif %}
      {%-   endif %}
      {%-  endfor %}
      {%- endfor %}
    );
  {%-  endif %}
  {%- endif %}

  --------------------------------------------------------------------------------
  -- Clocks and Resets
  --------------------------------------------------------------------------------
  {%- for clock in fins['clocks'] %}
  -- Waveform process to generate clock "{{ clock['clock'] }}"
  w_{{ clock['clock'] }} : process
  begin
    if (simulation_done = false) then
      {{ clock['clock'] }} <= '0';
      wait for {{ clock['base_name']|upper }}_CLOCK_PERIOD/2;
      {{ clock['clock'] }} <= '1';
      wait for {{ clock['base_name']|upper }}_CLOCK_PERIOD/2;
    else
      wait;
    end if;
  end process w_{{ clock['clock'] }};
  {%- endfor %}

  {%- if 'ports' in fins %}
  {%-  if 'ports' in fins['ports'] and fins['ports']['ports']|length > 0 %}
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
    if ({{ port['resetn'] }} = '0') then
      wait until ({{ port['resetn'] }} = '1');
    end if;
    -- Wait for all expected packets using the TLAST signal
    while (packets_received < G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_NUM_PACKETS_EXPECTED) loop
      wait until falling_edge({{ port['clock'] }});
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

  {%-     endfor %}{#### for i in range(port['num_instances']) ####}
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

    -- Initialize Resets
    {%- for clock in fins['clocks'] %}
    {{ clock['resetn'] }} <= '0';
    {%- endfor %}

    {%- if 'prop_interfaces' in fins %}
    -- deassert rall resets
    wait for PROPERTIES_CLOCK_PERIOD*10; -- Wait for an arbitrary 10 clocks
    {%- for clock in fins['clocks'] %}
    {{ clock['resetn'] }} <= '1';
    {%- endfor %}
    wait for PROPERTIES_CLOCK_PERIOD; -- Wait for an arbitrary 10 clocks

    ----------------------------------------------------
    -- Verify Properties
    ----------------------------------------------------
    {%-  for node_interfaces in fins['prop_interfaces'] %}
    {%-   set node_name = node_interfaces['node_name'] %}
    {%-   for interface in node_interfaces['interfaces'] %}
    {%-    set iface_name = interface|axi4liteprefix(application_external=True) %}
    {{ interface['name']|lower }}_axilite_verify (
      properties_aclk,   properties_aresetn,
      {{ iface_name }}_AWADDR, {{ iface_name }}_AWPROT, {{ iface_name }}_AWVALID, {{ iface_name }}_AWREADY,
      {{ iface_name }}_WDATA,  {{ iface_name }}_WSTRB,  {{ iface_name }}_WVALID,  {{ iface_name }}_WREADY,
      {{ iface_name }}_BRESP,  {{ iface_name }}_BVALID, {{ iface_name }}_BREADY,
      {{ iface_name }}_ARADDR, {{ iface_name }}_ARPROT, {{ iface_name }}_ARVALID, {{ iface_name }}_ARREADY,
      {{ iface_name }}_RDATA,  {{ iface_name }}_RRESP,  {{ iface_name }}_RVALID,  {{ iface_name }}_RREADY
    );
    {%-   endfor %}{#### for interface in node_interfaces['interfaces'] ####}
    {%-  endfor %}{#### for node_interfaces in fins['prop_interfaces'] ####}
    {%- endif %}{#### if 'prop_interfaces' in fins ####}

    {%- if 'ports' in fins %}
    {%-  if 'ports' in fins['ports'] and fins['ports']['ports']|length > 0 %}

    ----------------------------------------------------
    -- Verify Ports
    ----------------------------------------------------
    -- Enable the inputs
    {%-  for port in fins['ports']['ports'] %}
    {%-   if port['direction']|lower == 'in' %}
    {%-    for i in range(port['num_instances']) %}
    {{ port|axisprefix(i) }}_enable <= '1';
    {%-    endfor %}
    {%-   endif %}
    {%-  endfor %}

    -- Wait for the output verification processes to complete
    {%-  for port in fins['ports']['ports'] %}
    {%-   if port['direction']|lower == 'out' %}
    {%-    for i in range(port['num_instances']) %}
    if (not {{ port|axisprefix(i) }}_verify_done) then
      wait until ({{ port|axisprefix(i) }}_verify_done);
    end if;
    {%-    endfor %}{#### for i in range(port['num_instances']) ####}
    {%-   endif %}
    {%-  endfor %}{#### for port in fins['ports']['ports'] ####}

    {%-  endif  %}{#### if 'ports' in fins['ports'] ####}
    {%- endif  %}{#### if 'ports' in fins ####}

    ----------------------------------------------------
    -- End Simulation
    ----------------------------------------------------
    write(my_line, string'("***** SIMULATION PASSED *****"));
    writeline(output, my_line);
    simulation_done <= true;
    wait;

  end process w_test_procedure;

end behav;
