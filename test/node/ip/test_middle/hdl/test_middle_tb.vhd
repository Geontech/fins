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
use work.test_middle_pkg.all;
use work.test_middle_axilite_verify.all;
use work.test_bottom_swconfig_verify.all;

-- Entity
entity test_middle_tb is
  generic (
    G_NUM_PACKETS_EXPECTED_FOR_MYOUTPUT : natural := 1;
    G_NUM_PACKETS_EXPECTED_FOR_TEST_OUT00 : natural := 1;
    G_NUM_PACKETS_EXPECTED_FOR_TEST_OUT01 : natural := 1
  );
end entity test_middle_tb;

-- Architecture
architecture behav of test_middle_tb is
  --------------------------------------------------------------------------------
  -- Device Under Test Interface Signals
  --------------------------------------------------------------------------------
  -- Constants
  constant G_TEST_GENERIC_NATURAL:natural:=10;
  constant G_TEST_GENERIC_INTEGER : integer := 100 ;
  constant G_TEST_GENERIC_STRING  :  string  :=   "my_string"  ;
  constant G_TEST_GENERIC_BOOLEAN : boolean := false;
  constant G_TEST_GENERIC_POSITIVE : positive := 50;
  constant G_TEST_GENERIC_STD_LOGIC : std_logic := '1';
  constant G_TEST_GENERIC_STD_LOGIC_VECTOR : std_logic_vector(3 downto 0) := "0000";
  -- Software Confiugration Properties Bus
  signal s_swconfig_test_bottom_clk       : std_logic;
  signal s_swconfig_test_bottom_reset     : std_logic;
  signal s_swconfig_test_bottom_address   : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal s_swconfig_test_bottom_wr_enable : std_logic;
  signal s_swconfig_test_bottom_wr_data   : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal s_swconfig_test_bottom_rd_enable : std_logic;
  signal s_swconfig_test_bottom_rd_valid  : std_logic;
  signal s_swconfig_test_bottom_rd_data   : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  -- AXI4-Lite Properties Bus
  signal S_AXI_ACLK    : std_logic;
  signal S_AXI_ARESETN : std_logic;
  signal S_AXI_AWADDR  : std_logic_vector(16-1 downto 0);
  signal S_AXI_AWPROT  : std_logic_vector(2 downto 0);
  signal S_AXI_AWVALID : std_logic;
  signal S_AXI_AWREADY : std_logic;
  signal S_AXI_WDATA   : std_logic_vector(32-1 downto 0);
  signal S_AXI_WSTRB   : std_logic_vector((32/8)-1 downto 0);
  signal S_AXI_WVALID  : std_logic;
  signal S_AXI_WREADY  : std_logic;
  signal S_AXI_BRESP   : std_logic_vector(1 downto 0);
  signal S_AXI_BVALID  : std_logic;
  signal S_AXI_BREADY  : std_logic;
  signal S_AXI_ARADDR  : std_logic_vector(16-1 downto 0);
  signal S_AXI_ARPROT  : std_logic_vector(2 downto 0);
  signal S_AXI_ARVALID : std_logic;
  signal S_AXI_ARREADY : std_logic;
  signal S_AXI_RDATA   : std_logic_vector(32-1 downto 0);
  signal S_AXI_RRESP   : std_logic_vector(1 downto 0);
  signal S_AXI_RVALID  : std_logic;
  signal S_AXI_RREADY  : std_logic;
  -- AXI4-Stream Port IN: myinput
  signal s_axis_myinput_aclk    : std_logic;
  signal s_axis_myinput_aresetn : std_logic;
  signal s_axis_myinput_tdata   : std_logic_vector(16-1 downto 0);
  signal s_axis_myinput_tvalid  : std_logic;
  signal s_axis_myinput_tlast   : std_logic;
  -- AXI4-Stream Port OUT: myoutput
  signal m_axis_myoutput_aclk    : std_logic;
  signal m_axis_myoutput_aresetn : std_logic;
  signal m_axis_myoutput_tdata   : std_logic_vector(16-1 downto 0);
  signal m_axis_myoutput_tvalid  : std_logic;
  signal m_axis_myoutput_tlast   : std_logic;
  -- AXI4-Stream Port IN: test_in
  signal s00_axis_test_in_aclk    : std_logic;
  signal s00_axis_test_in_aresetn : std_logic;
  signal s00_axis_test_in_tready  : std_logic;
  signal s00_axis_test_in_tdata   : std_logic_vector(160-1 downto 0);
  signal s00_axis_test_in_tuser   : std_logic_vector(128-1 downto 0);
  signal s00_axis_test_in_tvalid  : std_logic;
  signal s00_axis_test_in_tlast   : std_logic;
  signal s01_axis_test_in_aclk    : std_logic;
  signal s01_axis_test_in_aresetn : std_logic;
  signal s01_axis_test_in_tready  : std_logic;
  signal s01_axis_test_in_tdata   : std_logic_vector(160-1 downto 0);
  signal s01_axis_test_in_tuser   : std_logic_vector(128-1 downto 0);
  signal s01_axis_test_in_tvalid  : std_logic;
  signal s01_axis_test_in_tlast   : std_logic;
  -- AXI4-Stream Port OUT: test_out
  signal m00_axis_test_out_aclk    : std_logic;
  signal m00_axis_test_out_aresetn : std_logic;
  signal m00_axis_test_out_tready  : std_logic;
  signal m00_axis_test_out_tdata   : std_logic_vector(160-1 downto 0);
  signal m00_axis_test_out_tuser   : std_logic_vector(128-1 downto 0);
  signal m00_axis_test_out_tvalid  : std_logic;
  signal m00_axis_test_out_tlast   : std_logic;
  signal m01_axis_test_out_aclk    : std_logic;
  signal m01_axis_test_out_aresetn : std_logic;
  signal m01_axis_test_out_tready  : std_logic;
  signal m01_axis_test_out_tdata   : std_logic_vector(160-1 downto 0);
  signal m01_axis_test_out_tuser   : std_logic_vector(128-1 downto 0);
  signal m01_axis_test_out_tvalid  : std_logic;
  signal m01_axis_test_out_tlast   : std_logic;

  --------------------------------------------------------------------------------
  -- Testbench
  --------------------------------------------------------------------------------
  -- Constants
  constant CLOCK_PERIOD  : time := 5 ns; -- 200MHz

  -- Signals
  signal simulation_done : boolean := false;
  signal clock           : std_logic := '0';
  signal resetn          : std_logic := '1';
  signal s_axis_myinput_enable : std_logic := '0';
  signal m_axis_myoutput_verify_done : boolean := false;
  signal s00_axis_test_in_enable : std_logic := '0';
  signal s01_axis_test_in_enable : std_logic := '0';
  signal m00_axis_test_out_verify_done : boolean := false;
  signal m01_axis_test_out_verify_done : boolean := false;

begin

  --------------------------------------------------------------------------------
  -- Device Under Test
  --------------------------------------------------------------------------------
  u_dut : entity work.test_middle
    generic map (
      G_TEST_GENERIC_NATURAL          => G_TEST_GENERIC_NATURAL          ,
      G_TEST_GENERIC_INTEGER          => G_TEST_GENERIC_INTEGER          ,
      G_TEST_GENERIC_STRING           => G_TEST_GENERIC_STRING           ,
      G_TEST_GENERIC_BOOLEAN          => G_TEST_GENERIC_BOOLEAN          ,
      G_TEST_GENERIC_POSITIVE         => G_TEST_GENERIC_POSITIVE         ,
      G_TEST_GENERIC_STD_LOGIC        => G_TEST_GENERIC_STD_LOGIC        ,
      G_TEST_GENERIC_STD_LOGIC_VECTOR => G_TEST_GENERIC_STD_LOGIC_VECTOR 
    )
    port map (
      s_swconfig_test_bottom_clk       => s_swconfig_test_bottom_clk       ,
      s_swconfig_test_bottom_reset     => s_swconfig_test_bottom_reset     ,
      s_swconfig_test_bottom_address   => s_swconfig_test_bottom_address   ,
      s_swconfig_test_bottom_wr_enable => s_swconfig_test_bottom_wr_enable ,
      s_swconfig_test_bottom_wr_data   => s_swconfig_test_bottom_wr_data   ,
      s_swconfig_test_bottom_rd_enable => s_swconfig_test_bottom_rd_enable ,
      s_swconfig_test_bottom_rd_valid  => s_swconfig_test_bottom_rd_valid  ,
      s_swconfig_test_bottom_rd_data   => s_swconfig_test_bottom_rd_data   ,
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
      s_axis_myinput_aclk    => s_axis_myinput_aclk,
      s_axis_myinput_aresetn => s_axis_myinput_aresetn,
      s_axis_myinput_tdata   => s_axis_myinput_tdata,
      s_axis_myinput_tvalid  => s_axis_myinput_tvalid,
      s_axis_myinput_tlast   => s_axis_myinput_tlast,
      m_axis_myoutput_aclk    => m_axis_myoutput_aclk,
      m_axis_myoutput_aresetn => m_axis_myoutput_aresetn,
      m_axis_myoutput_tdata   => m_axis_myoutput_tdata,
      m_axis_myoutput_tvalid  => m_axis_myoutput_tvalid,
      m_axis_myoutput_tlast   => m_axis_myoutput_tlast,
      s00_axis_test_in_aclk    => s00_axis_test_in_aclk,
      s00_axis_test_in_aresetn => s00_axis_test_in_aresetn,
      s00_axis_test_in_tready  => s00_axis_test_in_tready,
      s00_axis_test_in_tdata   => s00_axis_test_in_tdata,
      s00_axis_test_in_tuser   => s00_axis_test_in_tuser,
      s00_axis_test_in_tvalid  => s00_axis_test_in_tvalid,
      s00_axis_test_in_tlast   => s00_axis_test_in_tlast,
      s01_axis_test_in_aclk    => s01_axis_test_in_aclk,
      s01_axis_test_in_aresetn => s01_axis_test_in_aresetn,
      s01_axis_test_in_tready  => s01_axis_test_in_tready,
      s01_axis_test_in_tdata   => s01_axis_test_in_tdata,
      s01_axis_test_in_tuser   => s01_axis_test_in_tuser,
      s01_axis_test_in_tvalid  => s01_axis_test_in_tvalid,
      s01_axis_test_in_tlast   => s01_axis_test_in_tlast,
      m00_axis_test_out_aclk    => m00_axis_test_out_aclk,
      m00_axis_test_out_aresetn => m00_axis_test_out_aresetn,
      m00_axis_test_out_tready  => m00_axis_test_out_tready,
      m00_axis_test_out_tdata   => m00_axis_test_out_tdata,
      m00_axis_test_out_tuser   => m00_axis_test_out_tuser,
      m00_axis_test_out_tvalid  => m00_axis_test_out_tvalid,
      m00_axis_test_out_tlast   => m00_axis_test_out_tlast,
      m01_axis_test_out_aclk    => m01_axis_test_out_aclk,
      m01_axis_test_out_aresetn => m01_axis_test_out_aresetn,
      m01_axis_test_out_tready  => m01_axis_test_out_tready,
      m01_axis_test_out_tdata   => m01_axis_test_out_tdata,
      m01_axis_test_out_tuser   => m01_axis_test_out_tuser,
      m01_axis_test_out_tvalid  => m01_axis_test_out_tvalid,
      m01_axis_test_out_tlast   => m01_axis_test_out_tlast
    );
  --------------------------------------------------------------------------------
  -- File Input/Output AXI4-Stream Port Verification
  --------------------------------------------------------------------------------
  -- NOTE: The source/sink filepaths are relative to where the simulation is executed
  u_file_io : entity work.test_middle_axis_verify
    generic map (
      G_MYINPUT_SOURCE_SAMPLE_PERIOD => 1,
      G_MYINPUT_SOURCE_FILEPATH => "../../../../../../sim_data/sim_source_myinput.txt",
      G_MYOUTPUT_SINK_FILEPATH => "../../../../../../sim_data/sim_sink_myoutput.txt",
      G_TEST_IN00_SOURCE_SAMPLE_PERIOD => 1,
      G_TEST_IN00_SOURCE_FILEPATH => "../../../../../../sim_data/sim_source_test_in00.txt",
      G_TEST_IN01_SOURCE_SAMPLE_PERIOD => 1,
      G_TEST_IN01_SOURCE_FILEPATH => "../../../../../../sim_data/sim_source_test_in01.txt",
      G_TEST_OUT00_SINK_FILEPATH => "../../../../../../sim_data/sim_sink_test_out00.txt",
      G_TEST_OUT01_SINK_FILEPATH => "../../../../../../sim_data/sim_sink_test_out01.txt"
    )
    port map (
      simulation_done => simulation_done,
      m_axis_myinput_aclk    => s_axis_myinput_aclk,
      m_axis_myinput_enable  => s_axis_myinput_enable,
      m_axis_myinput_tdata   => s_axis_myinput_tdata,
      m_axis_myinput_tvalid  => s_axis_myinput_tvalid,
      m_axis_myinput_tlast   => s_axis_myinput_tlast,
      s_axis_myoutput_aclk    => m_axis_myoutput_aclk,
      s_axis_myoutput_tdata   => m_axis_myoutput_tdata,
      s_axis_myoutput_tvalid  => m_axis_myoutput_tvalid,
      s_axis_myoutput_tlast   => m_axis_myoutput_tlast,
      m00_axis_test_in_aclk    => s00_axis_test_in_aclk,
      m00_axis_test_in_enable  => s00_axis_test_in_enable,
      m00_axis_test_in_tready  => s00_axis_test_in_tready,
      m00_axis_test_in_tdata   => s00_axis_test_in_tdata,
      m00_axis_test_in_tuser   => s00_axis_test_in_tuser,
      m00_axis_test_in_tvalid  => s00_axis_test_in_tvalid,
      m00_axis_test_in_tlast   => s00_axis_test_in_tlast,
      m01_axis_test_in_aclk    => s01_axis_test_in_aclk,
      m01_axis_test_in_enable  => s01_axis_test_in_enable,
      m01_axis_test_in_tready  => s01_axis_test_in_tready,
      m01_axis_test_in_tdata   => s01_axis_test_in_tdata,
      m01_axis_test_in_tuser   => s01_axis_test_in_tuser,
      m01_axis_test_in_tvalid  => s01_axis_test_in_tvalid,
      m01_axis_test_in_tlast   => s01_axis_test_in_tlast,
      s00_axis_test_out_aclk    => m00_axis_test_out_aclk,
      s00_axis_test_out_tready  => m00_axis_test_out_tready,
      s00_axis_test_out_tdata   => m00_axis_test_out_tdata,
      s00_axis_test_out_tuser   => m00_axis_test_out_tuser,
      s00_axis_test_out_tvalid  => m00_axis_test_out_tvalid,
      s00_axis_test_out_tlast   => m00_axis_test_out_tlast,
      s01_axis_test_out_aclk    => m01_axis_test_out_aclk,
      s01_axis_test_out_tready  => m01_axis_test_out_tready,
      s01_axis_test_out_tdata   => m01_axis_test_out_tdata,
      s01_axis_test_out_tuser   => m01_axis_test_out_tuser,
      s01_axis_test_out_tvalid  => m01_axis_test_out_tvalid,
      s01_axis_test_out_tlast   => m01_axis_test_out_tlast
    );

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
  s_swconfig_test_bottom_clk   <= clock;
  s_swconfig_test_bottom_reset <= NOT resetn;
  S_AXI_ACLK    <= clock;
  S_AXI_ARESETN <= resetn;
  s_axis_myinput_aclk    <= clock;
  s_axis_myinput_aresetn <= resetn;
  m_axis_myoutput_aclk    <= clock;
  m_axis_myoutput_aresetn <= resetn;
  s00_axis_test_in_aclk    <= clock;
  s00_axis_test_in_aresetn <= resetn;
  s01_axis_test_in_aclk    <= clock;
  s01_axis_test_in_aresetn <= resetn;
  m00_axis_test_out_aclk    <= clock;
  m00_axis_test_out_aresetn <= resetn;
  m01_axis_test_out_aclk    <= clock;
  m01_axis_test_out_aresetn <= resetn;
  --------------------------------------------------------------------------------
  -- Port Verification Procedures
  --------------------------------------------------------------------------------
  -- Waveform process to wait for packets on the myoutput output port, instance 
  w_myoutput_verify : process
    variable my_line : line;
  begin
    -- Wait for global reset to complete
    if (resetn = '0') then
      wait until (resetn = '1');
    end if;
    -- Wait for the falling edge of TLAST
    for packet in 0 to G_NUM_PACKETS_EXPECTED_FOR_MYOUTPUT-1 loop
      wait until falling_edge(m_axis_myoutput_tlast);
    end loop;
    -- End this process
    write(my_line, string'("PASS: Data received from Port myoutput"));
    writeline(output, my_line);
    m_axis_myoutput_verify_done <= true;
    wait;
  end process w_myoutput_verify;
  -- Waveform process to wait for packets on the test_out output port, instance 00
  w_test_out00_verify : process
    variable my_line : line;
  begin
    -- Wait for global reset to complete
    if (resetn = '0') then
      wait until (resetn = '1');
    end if;
    -- Wait for the falling edge of TLAST
    for packet in 0 to G_NUM_PACKETS_EXPECTED_FOR_TEST_OUT00-1 loop
      wait until falling_edge(m00_axis_test_out_tlast);
    end loop;
    -- End this process
    write(my_line, string'("PASS: Data received from Port test_out"));
    writeline(output, my_line);
    m00_axis_test_out_verify_done <= true;
    wait;
  end process w_test_out00_verify;
  -- Waveform process to wait for packets on the test_out output port, instance 01
  w_test_out01_verify : process
    variable my_line : line;
  begin
    -- Wait for global reset to complete
    if (resetn = '0') then
      wait until (resetn = '1');
    end if;
    -- Wait for the falling edge of TLAST
    for packet in 0 to G_NUM_PACKETS_EXPECTED_FOR_TEST_OUT01-1 loop
      wait until falling_edge(m01_axis_test_out_tlast);
    end loop;
    -- End this process
    write(my_line, string'("PASS: Data received from Port test_out"));
    writeline(output, my_line);
    m01_axis_test_out_verify_done <= true;
    wait;
  end process w_test_out01_verify;

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
    --**************************************************
    -- Verify Properties
    --**************************************************
    test_middle_axilite_verify (
      S_AXI_ACLK,   S_AXI_ARESETN,
      S_AXI_AWADDR, S_AXI_AWPROT, S_AXI_AWVALID, S_AXI_AWREADY,
      S_AXI_WDATA,  S_AXI_WSTRB,  S_AXI_WVALID,  S_AXI_WREADY,
      S_AXI_BRESP,  S_AXI_BVALID, S_AXI_BREADY,
      S_AXI_ARADDR, S_AXI_ARPROT, S_AXI_ARVALID, S_AXI_ARREADY,
      S_AXI_RDATA,  S_AXI_RRESP,  S_AXI_RVALID,  S_AXI_RREADY
    );
    --**************************************************
    -- Verify Properties for test_bottom module
    --**************************************************
    test_bottom_swconfig_verify (
      s_swconfig_test_bottom_clk       ,
      s_swconfig_test_bottom_reset     ,
      s_swconfig_test_bottom_address   ,
      s_swconfig_test_bottom_wr_enable ,
      s_swconfig_test_bottom_wr_data   ,
      s_swconfig_test_bottom_rd_enable ,
      s_swconfig_test_bottom_rd_valid  ,
      s_swconfig_test_bottom_rd_data   
    );
    --**************************************************
    -- Verify Ports
    --**************************************************
    -- Enable the inputs
    s_axis_myinput_enable <= '1';
    s00_axis_test_in_enable <= '1';
    s01_axis_test_in_enable <= '1';

    -- Wait for the output verification processes to complete
    if (not m_axis_myoutput_verify_done) then
      wait until (m_axis_myoutput_verify_done);
    end if;
    if (not m00_axis_test_out_verify_done) then
      wait until (m00_axis_test_out_verify_done);
    end if;
    if (not m01_axis_test_out_verify_done) then
      wait until (m01_axis_test_out_verify_done);
    end if;

    --**************************************************
    -- End Simulation
    --**************************************************
    write(my_line, string'("***** SIMULATION PASSED *****"));
    writeline(output, my_line);
    simulation_done <= true;
    wait;

  end process w_test_procedure;

end behav;