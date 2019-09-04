--==============================================================================
-- Company:     Geon Technologies, LLC
-- Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: Auto-generated top-level testbench for a FINS module
-- Generated:   {{ now }}
-- Reset Type:  Synchronous
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
  signal S_AXI_AWADDR  : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
  signal S_AXI_AWPROT  : std_logic_vector(2 downto 0);
  signal S_AXI_AWVALID : std_logic;
  signal S_AXI_AWREADY : std_logic;
  signal S_AXI_WDATA   : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
  signal S_AXI_WSTRB   : std_logic_vector((G_AXI_DATA_WIDTH/8)-1 downto 0);
  signal S_AXI_WVALID  : std_logic;
  signal S_AXI_WREADY  : std_logic;
  signal S_AXI_BRESP   : std_logic_vector(1 downto 0);
  signal S_AXI_BVALID  : std_logic;
  signal S_AXI_BREADY  : std_logic;
  signal S_AXI_ARADDR  : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
  signal S_AXI_ARPROT  : std_logic_vector(2 downto 0);
  signal S_AXI_ARVALID : std_logic;
  signal S_AXI_ARREADY : std_logic;
  signal S_AXI_RDATA   : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
  signal S_AXI_RRESP   : std_logic_vector(1 downto 0);
  signal S_AXI_RVALID  : std_logic;
  signal S_AXI_RREADY  : std_logic;
  {%- endif %}
  {%- if 'ports' in fins %}
  {%- for port in fins['ports']['ports'] %}
  {%- if port['direction']|lower == 'in' %}
  -- AXI4-Stream Input Port: {{ port['name']|lower }}
  signal s_axis_{{ port['name']|lower }}_aclk    : std_logic;
  signal s_axis_{{ port['name']|lower }}_aresetn : std_logic;
  {%- if port['supports_backpressure'] %}
  signal s_axis_{{ port['name']|lower }}_tready  : std_logic;
  {%- endif %}
  {%- if 'data' in port %}
  signal s_axis_{{ port['name']|lower }}_tdata   : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
  {%- endif %}
  {%- if 'metadata' in port %}
  signal s_axis_{{ port['name']|lower }}_tuser   : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
  {%- endif %}
  signal s_axis_{{ port['name']|lower }}_tvalid  : std_logic;
  signal s_axis_{{ port['name']|lower }}_tlast   : std_logic;
  {%- else %}
  -- AXI4-Stream Output Port: {{ port['name']|lower }}
  signal m_axis_{{ port['name']|lower }}_aclk    : std_logic;
  signal m_axis_{{ port['name']|lower }}_aresetn : std_logic;
  {%- if port['supports_backpressure'] %}
  signal m_axis_{{ port['name']|lower }}_tready  : std_logic;
  {%- endif %}
  {%- if 'data' in port %}
  signal m_axis_{{ port['name']|lower }}_tdata   : std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
  {%- endif %}
  {%- if 'metadata' in port %}
  signal m_axis_{{ port['name']|lower }}_tuser   : std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
  {%- endif %}
  signal m_axis_{{ port['name']|lower }}_tvalid  : std_logic;
  signal m_axis_{{ port['name']|lower }}_tlast   : std_logic;
  {%- endif %}
  {%- endfor %}
  {%- endif %}

  --------------------------------------------------------------------------------
  -- Testbench Signals
  --------------------------------------------------------------------------------
  constant CLOCK_PERIOD  : time := 5 ns; -- 200MHz
  signal simulation_done : boolean := false;
  signal clock           : std_logic := '0';
  signal resetn          : std_logic := '1';
  {%- if 'ports' in fins %}
  {%- for port in fins['ports']['ports'] %}
  {%- if port['direction']|lower == 'in' %}
  signal s_axis_{{ port['name']|lower }}_enable : std_logic := '0';
  {%- else %}
  signal {{ port['name']|lower }}_verify_done : boolean := false;
  {%- endif %}
  {%- endfor %}
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
      S_AXI_RREADY  => S_AXI_RREADY,
      {%- endif %}
      {%- if 'ports' in fins %}
      {%- for port in fins['ports']['ports'] %}
      {%- if port['direction']|lower == 'in' %}
      s_axis_{{ port['name']|lower }}_aclk    => s_axis_{{ port['name']|lower }}_aclk,
      s_axis_{{ port['name']|lower }}_aresetn => s_axis_{{ port['name']|lower }}_aresetn,
      {%- if port['supports_backpressure'] %}
      s_axis_{{ port['name']|lower }}_tready  => s_axis_{{ port['name']|lower }}_tready,
      {%- endif %}
      {%- if 'data' in port %}
      s_axis_{{ port['name']|lower }}_tdata   => s_axis_{{ port['name']|lower }}_tdata,
      {%- endif %}
      {%- if 'metadata' in port %}
      s_axis_{{ port['name']|lower }}_tuser   => s_axis_{{ port['name']|lower }}_tuser,
      {%- endif %}
      s_axis_{{ port['name']|lower }}_tvalid  => s_axis_{{ port['name']|lower }}_tvalid,
      s_axis_{{ port['name']|lower }}_tlast   => s_axis_{{ port['name']|lower }}_tlast{% if not loop.last %},{% endif %}
      {%- else %}
      m_axis_{{ port['name']|lower }}_aclk    => m_axis_{{ port['name']|lower }}_aclk,
      m_axis_{{ port['name']|lower }}_aresetn => m_axis_{{ port['name']|lower }}_aresetn,
      {%- if port['supports_backpressure'] %}
      m_axis_{{ port['name']|lower }}_tready  => m_axis_{{ port['name']|lower }}_tready,
      {%- endif %}
      {%- if 'data' in port %}
      m_axis_{{ port['name']|lower }}_tdata   => m_axis_{{ port['name']|lower }}_tdata,
      {%- endif %}
      {%- if 'metadata' in port %}
      m_axis_{{ port['name']|lower }}_tuser   => m_axis_{{ port['name']|lower }}_tuser,
      {%- endif %}
      m_axis_{{ port['name']|lower }}_tvalid  => m_axis_{{ port['name']|lower }}_tvalid,
      m_axis_{{ port['name']|lower }}_tlast   => m_axis_{{ port['name']|lower }}_tlast{% if not loop.last %},{% endif %}
      {%- endif %}
      {%- endfor %}
      {%- endif %}
    );

  {%- if 'ports' in fins %}
  --------------------------------------------------------------------------------
  -- File Input/Output AXI4-Stream Port Verification
  --------------------------------------------------------------------------------
  -- NOTE: The source/sink filepaths are relative to where the simulation is executed
  u_file_io : entity work.{{ fins['name']|lower }}_axis_verify
    generic map (
      {%- for port in fins['ports']['ports'] %}
      {%- if port['direction'] == "in" %}
      G_{{ port['name']|upper }}_SOURCE_SAMPLE_PERIOD => 1, -- Number of clocks per sample
      G_{{ port['name']|upper }}_SOURCE_FILEPATH => "../../../../sim_source_{{ port['name']|lower }}.txt"{% if not loop.last %},{% endif %}
      {%- else %}
      G_{{ port['name']|upper }}_SINK_FILEPATH => "../../../../sim_sink_{{ port['name']|lower }}.txt"{% if not loop.last %},{% endif %}
      {%- endif %}
      {%- endfor %}
    )
    port map (
      simulation_done => simulation_done,
      {%- for port in fins['ports']['ports'] %}
      {%- if port['direction']|lower == 'out' %}
      s_axis_{{ port['name']|lower }}_aclk    => m_axis_{{ port['name']|lower }}_aclk,
      {%- if port['supports_backpressure'] %}
      s_axis_{{ port['name']|lower }}_tready  => m_axis_{{ port['name']|lower }}_tready,
      {%- endif %}
      {%- if 'data' in port %}
      s_axis_{{ port['name']|lower }}_tdata   => m_axis_{{ port['name']|lower }}_tdata,
      {%- endif %}
      {%- if 'metadata' in port %}
      s_axis_{{ port['name']|lower }}_tuser   => m_axis_{{ port['name']|lower }}_tuser,
      {%- endif %}
      s_axis_{{ port['name']|lower }}_tvalid  => m_axis_{{ port['name']|lower }}_tvalid,
      s_axis_{{ port['name']|lower }}_tlast   => m_axis_{{ port['name']|lower }}_tlast{% if not loop.last %},{% endif %}
      {%- else %}
      m_axis_{{ port['name']|lower }}_aclk    => s_axis_{{ port['name']|lower }}_aclk,
      m_axis_{{ port['name']|lower }}_enable  => s_axis_{{ port['name']|lower }}_enable,
      {%- if port['supports_backpressure'] %}
      m_axis_{{ port['name']|lower }}_tready  => s_axis_{{ port['name']|lower }}_tready,
      {%- endif %}
      {%- if 'data' in port %}
      m_axis_{{ port['name']|lower }}_tdata   => s_axis_{{ port['name']|lower }}_tdata,
      {%- endif %}
      {%- if 'metadata' in port %}
      m_axis_{{ port['name']|lower }}_tuser   => s_axis_{{ port['name']|lower }}_tuser,
      {%- endif %}
      m_axis_{{ port['name']|lower }}_tvalid  => s_axis_{{ port['name']|lower }}_tvalid,
      m_axis_{{ port['name']|lower }}_tlast   => s_axis_{{ port['name']|lower }}_tlast{% if not loop.last %},{% endif %}
      {%- endif %}
      {%- endfor %}
    );
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
  {%- for port in fins['ports']['ports'] %}
  {%- if port['direction']|lower == 'in' %}
  s_axis_{{ port['name']|lower }}_aclk    <= clock;
  s_axis_{{ port['name']|lower }}_aresetn <= resetn;
  {%- else %}
  m_axis_{{ port['name']|lower }}_aclk    <= clock;
  m_axis_{{ port['name']|lower }}_aresetn <= resetn;
  {%- endif %}
  {%- endfor %}
  {%- endif %}

  {%- if 'ports' in fins %}
  --------------------------------------------------------------------------------
  -- Port Verification Procedures
  --------------------------------------------------------------------------------
  {%- for port in fins['ports']['ports'] %}
  {%- if port['direction']|lower == 'out' %}
  -- Waveform process to wait for packets on the {{ port['name']|lower }} output port
  w_{{ port['name']|lower }}_verify : process
    variable my_line : line;
    variable num_packets_expected : natural := 1;
  begin
    -- Wait for global reset to complete
    if (resetn = '0') then
      wait until (resetn = '1');
    end if;
    -- Wait for the falling edge of TLAST num_packets_expected times
    for packet in 0 to num_packets_expected-1 loop
      wait until falling_edge(m_axis_{{ port['name']|lower }}_tlast);
    end loop;
    -- End this process
    write(my_line, string'("PASS: Data received from Port {{ port['name']|lower }}"));
    writeline(output, my_line);
    {{ port['name']|lower }}_verify_done <= true;
    wait;
  end process w_{{ port['name']|lower }}_verify;
  {%- endif %}
  {%- endfor %}
  {%- endif %}

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
    {%- endif %}

    {%- if 'ports' in fins %}
    --**************************************************
    -- Verify Ports
    --**************************************************
    -- Enable the inputs
    {%- for port in fins['ports']['ports'] %}
    {%- if port['direction']|lower == 'in' %}
    s_axis_{{ port['name']|lower }}_enable <= '1';
    {%- endif %}
    {%- endfor %}

    -- Wait for the output verification processes to complete
    {%- for port in fins['ports']['ports'] %}
    {%- if port['direction']|lower == 'out' %}
    if (not {{ port['name']|lower }}_verify_done) then
      wait until ({{ port['name']|lower }}_verify_done);
    end if;
    {%- endif %}
    {%- endfor %}
    {%- endif %}

    --**************************************************
    -- End Simulation
    --**************************************************
    write(my_line, string'("***** SIMULATION PASSED *****"));
    writeline(output, my_line);
    simulation_done <= true;
    wait;

  end process w_test_procedure;

end behav;
