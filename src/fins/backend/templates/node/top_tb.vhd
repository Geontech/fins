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
-- Template:    top_tb.vhd
-- Backend:     {{ fins['backend'] }}
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: Top-level testbench code stub for a FINS IP
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
{%- if 'properties' in fins %}
use work.{{ fins['name']|lower }}_axilite_verify.all;
{%- endif %}

-- Entity
entity {{ fins['name']|lower }}_tb is
  {%- if 'ports' in fins %}
  {%- if 'ports' in fins['ports'] %}
  generic (
    {%- for port in fins['ports']['ports'] %}
    {%- set outer_loop = loop %}
    {%- for i in range(port['num_instances']) %}
    {%- if port['direction'] == "in" %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_SAMPLE_PERIOD : positive := 1;
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_RANDOMIZE_BUS : boolean := false;
    {%- if fins['backend']|lower == 'quartus' %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH      : string := "../../../sim_data/sim_source_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}.txt"{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%- else %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH      : string := "../../../../../../sim_data/sim_source_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}.txt"{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%- endif %}
    {%- else %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_NUM_PACKETS_EXPECTED : natural := 1;
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_SAMPLE_PERIOD   : positive := 1;
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_RANDOMIZE_BUS   : boolean := false;
    {%- if fins['backend']|lower == 'quartus' %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_FILEPATH        : string := "../../../sim_data/sim_sink_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}.txt"{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%- else %}
    G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_FILEPATH        : string := "../../../../../../sim_data/sim_sink_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}.txt"{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%- endif %}
    {%- endif  %}{#### if port['direction'] == "in" ####}
    {%- endfor %}{#### for i in range(port['num_instances']) ####}
    {%- endfor %}{#### for port in fins['ports']['ports'] ####}
  );
  {%- endif  %}{#### if 'ports' in fins['ports'] ####}
  {%- endif  %}{#### if 'ports' in fins ####}
end entity {{ fins['name']|lower }}_tb;

-- Architecture
architecture behav of {{ fins['name']|lower }}_tb is
  --------------------------------------------------------------------------------
  -- Device Under Test Interface Signals
  --------------------------------------------------------------------------------
  {%- if 'properties' in fins %}
  -- AXI4-Lite Properties Bus
  signal S_AXI_ACLK    : std_logic;
  signal S_AXI_ARESETN : std_logic;
  signal S_AXI_AWADDR  : std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
  signal S_AXI_AWPROT  : std_logic_vector(2 downto 0);
  signal S_AXI_AWVALID : std_logic;
  signal S_AXI_AWREADY : std_logic;
  signal S_AXI_WDATA   : std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
  signal S_AXI_WSTRB   : std_logic_vector(({{ fins['properties']['data_width'] }}/8)-1 downto 0);
  signal S_AXI_WVALID  : std_logic;
  signal S_AXI_WREADY  : std_logic;
  signal S_AXI_BRESP   : std_logic_vector(1 downto 0);
  signal S_AXI_BVALID  : std_logic;
  signal S_AXI_BREADY  : std_logic;
  signal S_AXI_ARADDR  : std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
  signal S_AXI_ARPROT  : std_logic_vector(2 downto 0);
  signal S_AXI_ARVALID : std_logic;
  signal S_AXI_ARREADY : std_logic;
  signal S_AXI_RDATA   : std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
  signal S_AXI_RRESP   : std_logic_vector(1 downto 0);
  signal S_AXI_RVALID  : std_logic;
  signal S_AXI_RREADY  : std_logic;
  {%- endif %}
  {%- if 'ports' in fins %}
  {%- if 'hdl' in fins['ports'] %}
  -- Discrete HDL Ports
  {%- for port_hdl in fins['ports']['hdl'] %}
  {%- if port_hdl['bit_width'] > 1 %}
  signal {{ port_hdl['name'] }} : std_logic_vector({{ port_hdl['bit_width'] }}-1 downto 0);
  {%- else %}
  signal {{ port_hdl['name'] }} : std_logic;
  {%- endif %}
  {%- endfor %}
  {%- endif %}
  {%- if 'ports' in fins['ports'] %}
  {%- for port in fins['ports']['ports'] %}
  -- AXI4-Stream Port {{ port['direction']|upper }}: {{ port['name']|lower }}
  {%- for i in range(port['num_instances']) %}
  signal {{ port|axisprefix(i) }}_aclk    : std_logic;
  signal {{ port|axisprefix(i) }}_aresetn : std_logic;
  {%- if port['supports_backpressure'] %}
  signal {{ port|axisprefix(i) }}_tready  : std_logic;
  {%- endif %}
  {%- if port['supports_byte_enable'] %}
  signal {{ port|axisprefix(i) }}_tkeep   : std_logic_vector({{ port['data']['num_bytes'] }}-1 downto 0);
  {%- endif %}
  signal {{ port|axisprefix(i) }}_tdata   : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
  {%- if 'metadata' in port %}
  signal {{ port|axisprefix(i) }}_tuser   : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
  {%- endif %}
  signal {{ port|axisprefix(i) }}_tvalid  : std_logic;
  signal {{ port|axisprefix(i) }}_tlast   : std_logic;
  {%- endfor %}
  {%- endfor %}
  {%- endif %}
  {%- endif %}

  --------------------------------------------------------------------------------
  -- Testbench
  --------------------------------------------------------------------------------
  -- Constants
  constant CLOCK_PERIOD  : time := 5 ns; -- 200MHz

  -- Signals
  signal simulation_done : boolean := false;
  signal clock           : std_logic := '0';
  signal resetn          : std_logic := '1';
  {%- if 'ports' in fins %}
  {%- if 'ports' in fins['ports'] %}
  {%- for port in fins['ports']['ports'] %}
  {%- for i in range(port['num_instances']) %}
  {%- if port['direction']|lower == 'in' %}
  signal {{ port|axisprefix(i) }}_enable : std_logic := '0';
  {%- else %}
  signal {{ port|axisprefix(i) }}_verify_done : boolean := false;
  {%- endif %}
  {%- endfor %}
  {%- endfor %}
  {%- endif %}
  {%- endif %}

begin

  --------------------------------------------------------------------------------
  -- Device Under Test
  --------------------------------------------------------------------------------
  u_dut : entity work.{{ fins['name']|lower }}
    port map (
      {%- if 'properties' in fins %}
      S_AXI_ACLK    => S_AXI_ACLK,
      S_AXI_ARESETN => S_AXI_ARESETN,
      S_AXI_AWADDR  => S_AXI_AWADDR,
      S_AXI_AWPROT  => S_AXI_AWPROT,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_WDATA   => S_AXI_WDATA,
      S_AXI_WSTRB   => S_AXI_WSTRB,
      S_AXI_WVALID  => S_AXI_WVALID,
      S_AXI_WREADY  => S_AXI_WREADY,
      S_AXI_BRESP   => S_AXI_BRESP,
      S_AXI_BVALID  => S_AXI_BVALID,
      S_AXI_BREADY  => S_AXI_BREADY,
      S_AXI_ARADDR  => S_AXI_ARADDR,
      S_AXI_ARPROT  => S_AXI_ARPROT,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_RDATA   => S_AXI_RDATA,
      S_AXI_RRESP   => S_AXI_RRESP,
      S_AXI_RVALID  => S_AXI_RVALID,
      S_AXI_RREADY  => S_AXI_RREADY{% if 'ports' in fins %},{% endif %}
      {%- endif %}
      {%- if 'ports' in fins %}
      {%- if 'hdl' in fins['ports'] %}
      {%- for port_hdl in fins['ports']['hdl'] %}
      {{ port_hdl['name'] }} => {{ port_hdl['name'] }}{% if (not loop.last) or ('ports' in fins['ports']) %},{% endif %}
      {%- endfor %}
      {%- endif %}
      {%- if 'ports' in fins['ports'] %}
      {%- for port in fins['ports']['ports'] %}
      {%- set outer_loop = loop %}
      {%- for i in range(port['num_instances']) %}
      {{ port|axisprefix(i) }}_aclk    => {{ port|axisprefix(i) }}_aclk,
      {{ port|axisprefix(i) }}_aresetn => {{ port|axisprefix(i) }}_aresetn,
      {%- if port['supports_backpressure'] %}
      {{ port|axisprefix(i) }}_tready  => {{ port|axisprefix(i) }}_tready,
      {%- endif %}
      {%- if port['supports_byte_enable'] %}
      {{ port|axisprefix(i) }}_tkeep   => {{ port|axisprefix(i) }}_tkeep,
      {%- endif %}
      {{ port|axisprefix(i) }}_tdata   => {{ port|axisprefix(i) }}_tdata,
      {%- if 'metadata' in port %}
      {{ port|axisprefix(i) }}_tuser   => {{ port|axisprefix(i) }}_tuser,
      {%- endif %}
      {{ port|axisprefix(i) }}_tvalid  => {{ port|axisprefix(i) }}_tvalid,
      {{ port|axisprefix(i) }}_tlast   => {{ port|axisprefix(i) }}_tlast{% if not (outer_loop.last and loop.last) %},{% endif %}
      {%- endfor %}
      {%- endfor %}
      {%- endif %}
      {%- endif %}
    );

  {%- if 'ports' in fins %}
  {%- if 'ports' in fins['ports'] %}
  --------------------------------------------------------------------------------
  -- File Input/Output AXI4-Stream Port Verification
  --------------------------------------------------------------------------------
  -- NOTE: The source/sink filepaths are relative to where the simulation is executed
  u_file_io : entity work.{{ fins['name']|lower }}_axis_verify
    generic map (
      {%- for port in fins['ports']['ports'] %}
      {%- set outer_loop = loop %}
      {%- for i in range(port['num_instances']) %}
      {%- if port['direction'] == "in" %}
      G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_SAMPLE_PERIOD => G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_SAMPLE_PERIOD,
      G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_RANDOMIZE_BUS => G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_RANDOMIZE_BUS,
      G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH      => G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SOURCE_FILEPATH{% if not (outer_loop.last and loop.last) %},{% endif %}
      {%- else %}
      G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_SAMPLE_PERIOD => G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_SAMPLE_PERIOD,
      G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_RANDOMIZE_BUS => G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_RANDOMIZE_BUS,
      G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_FILEPATH      => G_{{ port['name']|upper }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_SINK_FILEPATH{% if not (outer_loop.last and loop.last) %},{% endif %}
      {%- endif %}
      {%- endfor %}
      {%- endfor %}
    )
    port map (
      simulation_done => simulation_done,
      {%- for port in fins['ports']['ports'] %}
      {%- set outer_loop = loop %}
      {%- for i in range(port['num_instances']) %}
      {%- if port['direction']|lower == 'out' %}
      {{ port|axisprefix(i,True) }}_aclk    => {{ port|axisprefix(i) }}_aclk,
      {%- if port['supports_backpressure'] %}
      {{ port|axisprefix(i,True) }}_tready  => {{ port|axisprefix(i) }}_tready,
      {%- endif %}
      {%- if port['supports_byte_enable'] %}
      {{ port|axisprefix(i,True) }}_tkeep   => {{ port|axisprefix(i) }}_tkeep,
      {%- endif %}
      {{ port|axisprefix(i,True) }}_tdata   => {{ port|axisprefix(i) }}_tdata,
      {%- if 'metadata' in port %}
      {{ port|axisprefix(i,True) }}_tuser   => {{ port|axisprefix(i) }}_tuser,
      {%- endif %}
      {{ port|axisprefix(i,True) }}_tvalid  => {{ port|axisprefix(i) }}_tvalid,
      {{ port|axisprefix(i,True) }}_tlast   => {{ port|axisprefix(i) }}_tlast{% if not (outer_loop.last and loop.last) %},{% endif %}
      {%- else %}
      {{ port|axisprefix(i,True) }}_aclk    => {{ port|axisprefix(i) }}_aclk,
      {{ port|axisprefix(i,True) }}_enable  => {{ port|axisprefix(i) }}_enable,
      {%- if port['supports_backpressure'] %}
      {{ port|axisprefix(i,True) }}_tready  => {{ port|axisprefix(i) }}_tready,
      {%- endif %}
      {%- if port['supports_byte_enable'] %}
      {{ port|axisprefix(i,True) }}_tkeep   => {{ port|axisprefix(i) }}_tkeep,
      {%- endif %}
      {{ port|axisprefix(i,True) }}_tdata   => {{ port|axisprefix(i) }}_tdata,
      {%- if 'metadata' in port %}
      {{ port|axisprefix(i,True) }}_tuser   => {{ port|axisprefix(i) }}_tuser,
      {%- endif %}
      {{ port|axisprefix(i,True) }}_tvalid  => {{ port|axisprefix(i) }}_tvalid,
      {{ port|axisprefix(i,True) }}_tlast   => {{ port|axisprefix(i) }}_tlast{% if not (outer_loop.last and loop.last) %},{% endif %}
      {%- endif %}
      {%- endfor %}
      {%- endfor %}
    );
  {%- endif %}{#### if 'ports' in fins['ports'] ####}
  {%- endif %}{#### if 'ports' in fins ####}

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
  {%- if 'properties' in fins %}
  S_AXI_ACLK    <= clock;
  S_AXI_ARESETN <= resetn;
  {%- endif %}
  {%- if 'ports' in fins %}
  {%- if 'ports' in fins['ports'] %}
  {%- for port in fins['ports']['ports'] %}
  {%- for i in range(port['num_instances']) %}
  {%- if port['direction']|lower == 'in' %}
  {{ port|axisprefix(i) }}_aclk    <= clock;
  {{ port|axisprefix(i) }}_aresetn <= resetn;
  {%- else %}
  {{ port|axisprefix(i) }}_aclk    <= clock;
  {{ port|axisprefix(i) }}_aresetn <= resetn;
  {%- endif %}
  {%- endfor %}
  {%- endfor %}
  {%- endif %}
  {%- endif %}

  {%- if 'ports' in fins %}
  {%- if 'ports' in fins['ports'] %}
  --------------------------------------------------------------------------------
  -- Port Verification Procedures
  --------------------------------------------------------------------------------
  {%- for port in fins['ports']['ports'] %}
  {%- if port['direction']|lower == 'out' %}
  {%- for i in range(port['num_instances']) %}
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
      
      {%- if port['supports_backpressure'] %}
      if (({{ port|axisprefix(i) }}_tvalid = '1') AND ({{ port|axisprefix(i) }}_tlast = '1') AND ({{ port|axisprefix(i) }}_tready = '1')) then
      {%- else %}
      if (({{ port|axisprefix(i) }}_tvalid = '1') AND ({{ port|axisprefix(i) }}_tlast = '1')) then
      {%- endif %}
        packets_received := packets_received + 1;
      end if;
    end loop;
    -- End this process
    write(my_line, string'("PASS: Data received from Port {{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}"));
    writeline(output, my_line);
    {{ port|axisprefix(i) }}_verify_done <= true;
    wait;
  end process w_{{ port['name']|lower }}{% if port['num_instances'] > 1 %}{{ '%0#2d'|format(i) }}{% endif %}_verify;
  {%- endfor %}
  {%- endif %}
  {%- endfor %}
  {%- endif %}{#### if 'ports' in fins['ports'] ####}
  {%- endif %}{#### if 'ports' in fins ####}

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

    {%- if 'properties' in fins %}
    --**************************************************
    -- Verify Properties
    --**************************************************
    {{ fins['name']|lower }}_axilite_verify (
      S_AXI_ACLK,   S_AXI_ARESETN,
      S_AXI_AWADDR, S_AXI_AWPROT, S_AXI_AWVALID, S_AXI_AWREADY,
      S_AXI_WDATA,  S_AXI_WSTRB,  S_AXI_WVALID,  S_AXI_WREADY,
      S_AXI_BRESP,  S_AXI_BVALID, S_AXI_BREADY,
      S_AXI_ARADDR, S_AXI_ARPROT, S_AXI_ARVALID, S_AXI_ARREADY,
      S_AXI_RDATA,  S_AXI_RRESP,  S_AXI_RVALID,  S_AXI_RREADY
    );

    {%- endif %}{#### if 'properties' in fins ####}

    {%- if 'ports' in fins %}
    {%- if 'ports' in fins['ports'] %}
    --**************************************************
    -- Verify Ports
    --**************************************************
    -- Enable the inputs
    {%- for port in fins['ports']['ports'] %}
    {%- if port['direction']|lower == 'in' %}
    {%- for i in range(port['num_instances']) %}
    {{ port|axisprefix(i) }}_enable <= '1';
    {%- endfor %}
    {%- endif %}
    {%- endfor %}

    -- Wait for the output verification processes to complete
    {%- for port in fins['ports']['ports'] %}
    {%- if port['direction']|lower == 'out' %}
    {%- for i in range(port['num_instances']) %}
    if (not {{ port|axisprefix(i) }}_verify_done) then
      wait until ({{ port|axisprefix(i) }}_verify_done);
    end if;
    {%- endfor %}
    {%- endif %}
    {%- endfor %}

    {%- endif %}{#### if 'ports' in fins['ports'] ####}
    {%- endif %}{#### if 'ports' in fins ####}

    --**************************************************
    -- End Simulation
    --**************************************************
    write(my_line, string'("***** SIMULATION PASSED *****"));
    writeline(output, my_line);
    simulation_done <= true;
    wait;

  end process w_test_procedure;

end behav;
