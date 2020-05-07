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
--use work.test_top_pkg.all;
--use work.test_top_axilite_verify.all;
--use work.test_middle_axilite_verify.all;
--use work.test_bottom_axilite_verify.all;
library test_top_00;
use test_top_00.all;
use test_top_00.test_top_pkg.all;
--use test_top_00.test_top_axis_verify.all;
library test_middle_00;
use test_middle_00.all;
library test_bottom_00;
use test_bottom_00.all;

-- Entity
entity nodeset_test_tb is
  generic (
    G_MYOUTPUT_NUM_PACKETS_EXPECTED : natural := 8;
    G_TEST_OUT00_NUM_PACKETS_EXPECTED : natural := 2;
    G_TEST_OUT01_NUM_PACKETS_EXPECTED : natural := 2
  );
end entity nodeset_test_tb;

-- Architecture
architecture behav of nodeset_test_tb is
  --------------------------------------------------------------------------------
  -- Device Under Test Interface Signals
  --------------------------------------------------------------------------------
  -- AXI4-Lite Properties Bus
  --signal fins_test_ip_0_S_AXI_ACLK    : std_logic;
  --signal fins_test_ip_0_S_AXI_ARESETN : std_logic;
  signal fins_test_ip_0_S_AXI_AWADDR  : std_logic_vector(16-1 downto 0);
  signal fins_test_ip_0_S_AXI_AWPROT  : std_logic_vector(2 downto 0);
  signal fins_test_ip_0_S_AXI_AWVALID : std_logic;
  signal fins_test_ip_0_S_AXI_AWREADY : std_logic;
  signal fins_test_ip_0_S_AXI_WDATA   : std_logic_vector(32-1 downto 0);
  signal fins_test_ip_0_S_AXI_WSTRB   : std_logic_vector((32/8)-1 downto 0);
  signal fins_test_ip_0_S_AXI_WVALID  : std_logic;
  signal fins_test_ip_0_S_AXI_WREADY  : std_logic;
  signal fins_test_ip_0_S_AXI_BRESP   : std_logic_vector(1 downto 0);
  signal fins_test_ip_0_S_AXI_BVALID  : std_logic;
  signal fins_test_ip_0_S_AXI_BREADY  : std_logic;
  signal fins_test_ip_0_S_AXI_ARADDR  : std_logic_vector(16-1 downto 0);
  signal fins_test_ip_0_S_AXI_ARPROT  : std_logic_vector(2 downto 0);
  signal fins_test_ip_0_S_AXI_ARVALID : std_logic;
  signal fins_test_ip_0_S_AXI_ARREADY : std_logic;
  signal fins_test_ip_0_S_AXI_RDATA   : std_logic_vector(32-1 downto 0);
  signal fins_test_ip_0_S_AXI_RRESP   : std_logic_vector(1 downto 0);
  signal fins_test_ip_0_S_AXI_RVALID  : std_logic;
  signal fins_test_ip_0_S_AXI_RREADY  : std_logic;
  --signal fins_test_ip_0_S_AXI_TEST_MIDDLE_ACLK       : std_logic;
  --signal fins_test_ip_0_S_AXI_TEST_MIDDLE_ARESETN    : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_AWADDR     : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_AWPROT     : std_logic_vector(2 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_AWVALID    : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_AWREADY    : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_WDATA      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_WSTRB      : std_logic_vector((PROPS_DATA_WIDTH/8)-1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_WVALID     : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_WREADY     : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_BRESP      : std_logic_vector(1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_BVALID     : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_BREADY     : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_ARADDR     : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_ARPROT     : std_logic_vector(2 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_ARVALID    : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_ARREADY    : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_RDATA      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_RRESP      : std_logic_vector(1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_RVALID     : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_MIDDLE_RREADY     : std_logic;
  --signal fins_test_ip_0_S_AXI_TEST_BOTTOM_ACLK       : std_logic;
  --signal fins_test_ip_0_S_AXI_TEST_BOTTOM_ARESETN    : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_AWADDR     : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_AWPROT     : std_logic_vector(2 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_AWVALID    : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_AWREADY    : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_WDATA      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_WSTRB      : std_logic_vector((PROPS_DATA_WIDTH/8)-1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_WVALID     : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_WREADY     : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_BRESP      : std_logic_vector(1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_BVALID     : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_BREADY     : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_ARADDR     : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_ARPROT     : std_logic_vector(2 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_ARVALID    : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_ARREADY    : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_RDATA      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_RRESP      : std_logic_vector(1 downto 0);
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_RVALID     : std_logic;
  signal fins_test_ip_0_S_AXI_TEST_BOTTOM_RREADY     : std_logic;
  --signal fins_test_ip_1_S_AXI_ACLK    : std_logic;
  --signal fins_test_ip_1_S_AXI_ARESETN : std_logic;
  signal fins_test_ip_1_S_AXI_AWADDR  : std_logic_vector(16-1 downto 0);
  signal fins_test_ip_1_S_AXI_AWPROT  : std_logic_vector(2 downto 0);
  signal fins_test_ip_1_S_AXI_AWVALID : std_logic;
  signal fins_test_ip_1_S_AXI_AWREADY : std_logic;
  signal fins_test_ip_1_S_AXI_WDATA   : std_logic_vector(32-1 downto 0);
  signal fins_test_ip_1_S_AXI_WSTRB   : std_logic_vector((32/8)-1 downto 0);
  signal fins_test_ip_1_S_AXI_WVALID  : std_logic;
  signal fins_test_ip_1_S_AXI_WREADY  : std_logic;
  signal fins_test_ip_1_S_AXI_BRESP   : std_logic_vector(1 downto 0);
  signal fins_test_ip_1_S_AXI_BVALID  : std_logic;
  signal fins_test_ip_1_S_AXI_BREADY  : std_logic;
  signal fins_test_ip_1_S_AXI_ARADDR  : std_logic_vector(16-1 downto 0);
  signal fins_test_ip_1_S_AXI_ARPROT  : std_logic_vector(2 downto 0);
  signal fins_test_ip_1_S_AXI_ARVALID : std_logic;
  signal fins_test_ip_1_S_AXI_ARREADY : std_logic;
  signal fins_test_ip_1_S_AXI_RDATA   : std_logic_vector(32-1 downto 0);
  signal fins_test_ip_1_S_AXI_RRESP   : std_logic_vector(1 downto 0);
  signal fins_test_ip_1_S_AXI_RVALID  : std_logic;
  signal fins_test_ip_1_S_AXI_RREADY  : std_logic;
  --signal fins_test_ip_1_S_AXI_TEST_MIDDLE_ACLK       : std_logic;
  --signal fins_test_ip_1_S_AXI_TEST_MIDDLE_ARESETN    : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_AWADDR     : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_AWPROT     : std_logic_vector(2 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_AWVALID    : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_AWREADY    : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_WDATA      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_WSTRB      : std_logic_vector((PROPS_DATA_WIDTH/8)-1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_WVALID     : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_WREADY     : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_BRESP      : std_logic_vector(1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_BVALID     : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_BREADY     : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_ARADDR     : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_ARPROT     : std_logic_vector(2 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_ARVALID    : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_ARREADY    : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_RDATA      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_RRESP      : std_logic_vector(1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_RVALID     : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_MIDDLE_RREADY     : std_logic;
  --signal fins_test_ip_1_S_AXI_TEST_BOTTOM_ACLK       : std_logic;
  --signal fins_test_ip_1_S_AXI_TEST_BOTTOM_ARESETN    : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_AWADDR     : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_AWPROT     : std_logic_vector(2 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_AWVALID    : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_AWREADY    : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_WDATA      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_WSTRB      : std_logic_vector((PROPS_DATA_WIDTH/8)-1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_WVALID     : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_WREADY     : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_BRESP      : std_logic_vector(1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_BVALID     : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_BREADY     : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_ARADDR     : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_ARPROT     : std_logic_vector(2 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_ARVALID    : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_ARREADY    : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_RDATA      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_RRESP      : std_logic_vector(1 downto 0);
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_RVALID     : std_logic;
  signal fins_test_ip_1_S_AXI_TEST_BOTTOM_RREADY     : std_logic;
  -- AXI4-Stream Port IN: myinput
  --signal fins_test_ip_0_s_axis_myinput_aclk    : std_logic;
  --signal fins_test_ip_0_s_axis_myinput_aresetn : std_logic;
  signal fins_test_ip_0_s_axis_myinput_tdata   : std_logic_vector(16-1 downto 0);
  signal fins_test_ip_0_s_axis_myinput_tuser   : std_logic_vector(128-1 downto 0);
  signal fins_test_ip_0_s_axis_myinput_tvalid  : std_logic;
  signal fins_test_ip_0_s_axis_myinput_tlast   : std_logic;
  -- AXI4-Stream Port OUT: myoutput
  --signal fins_test_ip_1_m_axis_myoutput_aclk    : std_logic;
  --signal fins_test_ip_1_m_axis_myoutput_aresetn : std_logic;
  signal fins_test_ip_1_m_axis_myoutput_tdata   : std_logic_vector(16-1 downto 0);
  signal fins_test_ip_1_m_axis_myoutput_tuser   : std_logic_vector(128-1 downto 0);
  signal fins_test_ip_1_m_axis_myoutput_tvalid  : std_logic;
  signal fins_test_ip_1_m_axis_myoutput_tlast   : std_logic;
  -- AXI4-Stream Port IN: test_in
  --signal fins_test_ip_0_s00_axis_test_in_aclk    : std_logic;
  --signal fins_test_ip_0_s00_axis_test_in_aresetn : std_logic;
  signal fins_test_ip_0_s00_axis_test_in_tready  : std_logic;
  signal fins_test_ip_0_s00_axis_test_in_tdata   : std_logic_vector(160-1 downto 0);
  signal fins_test_ip_0_s00_axis_test_in_tuser   : std_logic_vector(128-1 downto 0);
  signal fins_test_ip_0_s00_axis_test_in_tvalid  : std_logic;
  signal fins_test_ip_0_s00_axis_test_in_tlast   : std_logic;
  --signal fins_test_ip_0_s01_axis_test_in_aclk    : std_logic;
  --signal fins_test_ip_0_s01_axis_test_in_aresetn : std_logic;
  signal fins_test_ip_0_s01_axis_test_in_tready  : std_logic;
  signal fins_test_ip_0_s01_axis_test_in_tdata   : std_logic_vector(160-1 downto 0);
  signal fins_test_ip_0_s01_axis_test_in_tuser   : std_logic_vector(128-1 downto 0);
  signal fins_test_ip_0_s01_axis_test_in_tvalid  : std_logic;
  signal fins_test_ip_0_s01_axis_test_in_tlast   : std_logic;
  -- AXI4-Stream Port OUT: test_out
  --signal fins_test_ip_1_m00_axis_test_out_aclk    : std_logic;
  --signal fins_test_ip_1_m00_axis_test_out_aresetn : std_logic;
  signal fins_test_ip_1_m00_axis_test_out_tready  : std_logic;
  signal fins_test_ip_1_m00_axis_test_out_tdata   : std_logic_vector(160-1 downto 0);
  signal fins_test_ip_1_m00_axis_test_out_tuser   : std_logic_vector(128-1 downto 0);
  signal fins_test_ip_1_m00_axis_test_out_tvalid  : std_logic;
  signal fins_test_ip_1_m00_axis_test_out_tlast   : std_logic;
  --signal fins_test_ip_1_m01_axis_test_out_aclk    : std_logic;
  --signal fins_test_ip_1_m01_axis_test_out_aresetn : std_logic;
  signal fins_test_ip_1_m01_axis_test_out_tready  : std_logic;
  signal fins_test_ip_1_m01_axis_test_out_tdata   : std_logic_vector(160-1 downto 0);
  signal fins_test_ip_1_m01_axis_test_out_tuser   : std_logic_vector(128-1 downto 0);
  signal fins_test_ip_1_m01_axis_test_out_tvalid  : std_logic;
  signal fins_test_ip_1_m01_axis_test_out_tlast   : std_logic;
  --signal fins_test_ip_0_s_axis_sfix_cpx_in_aclk     : std_logic;
  --signal fins_test_ip_0_s_axis_sfix_cpx_in_aresetn  : std_logic;
  signal fins_test_ip_0_s_axis_sfix_cpx_in_tready   : std_logic;
  signal fins_test_ip_0_s_axis_sfix_cpx_in_tdata    : std_logic_vector(32-1 downto 0);
  signal fins_test_ip_0_s_axis_sfix_cpx_in_tuser    : std_logic_vector(121-1 downto 0);
  signal fins_test_ip_0_s_axis_sfix_cpx_in_tvalid   : std_logic;
  signal fins_test_ip_0_s_axis_sfix_cpx_in_tlast    : std_logic;
  --signal fins_test_ip_1_m_axis_sfix_cpx_out_aclk    : std_logic;
  --signal fins_test_ip_1_m_axis_sfix_cpx_out_aresetn : std_logic;
  signal fins_test_ip_1_m_axis_sfix_cpx_out_tready  : std_logic;
  signal fins_test_ip_1_m_axis_sfix_cpx_out_tdata   : std_logic_vector(32-1 downto 0);
  signal fins_test_ip_1_m_axis_sfix_cpx_out_tuser   : std_logic_vector(121-1 downto 0);
  signal fins_test_ip_1_m_axis_sfix_cpx_out_tvalid  : std_logic;
  signal fins_test_ip_1_m_axis_sfix_cpx_out_tlast   : std_logic;

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
  signal s_axis_sfix_cpx_in_enable : std_logic := '0';

begin

  --------------------------------------------------------------------------------
  -- Device Under Test
  --------------------------------------------------------------------------------
  --u_dut : entity work.nodeset_test
  u_dut : entity work.nodeset_test
    port map (
      clk_clk => clock,
      --fins_test_ip_0_S_AXI_ACLK    => fins_test_ip_0_S_AXI_ACLK,
      --fins_test_ip_0_S_AXI_ARESETN => fins_test_ip_0_S_AXI_ARESETN,
      fins_test_ip_0_S_AXI_AWADDR  => fins_test_ip_0_S_AXI_AWADDR,
      fins_test_ip_0_S_AXI_AWPROT  => fins_test_ip_0_S_AXI_AWPROT,
      fins_test_ip_0_S_AXI_AWVALID => fins_test_ip_0_S_AXI_AWVALID,
      fins_test_ip_0_S_AXI_AWREADY => fins_test_ip_0_S_AXI_AWREADY,
      fins_test_ip_0_S_AXI_WDATA   => fins_test_ip_0_S_AXI_WDATA,
      fins_test_ip_0_S_AXI_WSTRB   => fins_test_ip_0_S_AXI_WSTRB,
      fins_test_ip_0_S_AXI_WVALID  => fins_test_ip_0_S_AXI_WVALID,
      fins_test_ip_0_S_AXI_WREADY  => fins_test_ip_0_S_AXI_WREADY,
      fins_test_ip_0_S_AXI_BRESP   => fins_test_ip_0_S_AXI_BRESP,
      fins_test_ip_0_S_AXI_BVALID  => fins_test_ip_0_S_AXI_BVALID,
      fins_test_ip_0_S_AXI_BREADY  => fins_test_ip_0_S_AXI_BREADY,
      fins_test_ip_0_S_AXI_ARADDR  => fins_test_ip_0_S_AXI_ARADDR,
      fins_test_ip_0_S_AXI_ARPROT  => fins_test_ip_0_S_AXI_ARPROT,
      fins_test_ip_0_S_AXI_ARVALID => fins_test_ip_0_S_AXI_ARVALID,
      fins_test_ip_0_S_AXI_ARREADY => fins_test_ip_0_S_AXI_ARREADY,
      fins_test_ip_0_S_AXI_RDATA   => fins_test_ip_0_S_AXI_RDATA,
      fins_test_ip_0_S_AXI_RRESP   => fins_test_ip_0_S_AXI_RRESP,
      fins_test_ip_0_S_AXI_RVALID  => fins_test_ip_0_S_AXI_RVALID,
      fins_test_ip_0_S_AXI_RREADY  => fins_test_ip_0_S_AXI_RREADY,
      --fins_test_ip_0_S_AXI_TEST_MIDDLE_ACLK       => fins_test_ip_0_S_AXI_TEST_MIDDLE_ACLK       ,
      --fins_test_ip_0_S_AXI_TEST_MIDDLE_ARESETN    => fins_test_ip_0_S_AXI_TEST_MIDDLE_ARESETN    ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_AWADDR     => fins_test_ip_0_S_AXI_TEST_MIDDLE_AWADDR     ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_AWPROT     => fins_test_ip_0_S_AXI_TEST_MIDDLE_AWPROT     ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_AWVALID    => fins_test_ip_0_S_AXI_TEST_MIDDLE_AWVALID    ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_AWREADY    => fins_test_ip_0_S_AXI_TEST_MIDDLE_AWREADY    ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_WDATA      => fins_test_ip_0_S_AXI_TEST_MIDDLE_WDATA      ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_WSTRB      => fins_test_ip_0_S_AXI_TEST_MIDDLE_WSTRB      ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_WVALID     => fins_test_ip_0_S_AXI_TEST_MIDDLE_WVALID     ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_WREADY     => fins_test_ip_0_S_AXI_TEST_MIDDLE_WREADY     ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_BRESP      => fins_test_ip_0_S_AXI_TEST_MIDDLE_BRESP      ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_BVALID     => fins_test_ip_0_S_AXI_TEST_MIDDLE_BVALID     ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_BREADY     => fins_test_ip_0_S_AXI_TEST_MIDDLE_BREADY     ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_ARADDR     => fins_test_ip_0_S_AXI_TEST_MIDDLE_ARADDR     ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_ARPROT     => fins_test_ip_0_S_AXI_TEST_MIDDLE_ARPROT     ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_ARVALID    => fins_test_ip_0_S_AXI_TEST_MIDDLE_ARVALID    ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_ARREADY    => fins_test_ip_0_S_AXI_TEST_MIDDLE_ARREADY    ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_RDATA      => fins_test_ip_0_S_AXI_TEST_MIDDLE_RDATA      ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_RRESP      => fins_test_ip_0_S_AXI_TEST_MIDDLE_RRESP      ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_RVALID     => fins_test_ip_0_S_AXI_TEST_MIDDLE_RVALID     ,
      fins_test_ip_0_S_AXI_TEST_MIDDLE_RREADY     => fins_test_ip_0_S_AXI_TEST_MIDDLE_RREADY     ,
      --fins_test_ip_0_S_AXI_TEST_BOTTOM_ACLK       => fins_test_ip_0_S_AXI_TEST_BOTTOM_ACLK       ,
      --fins_test_ip_0_S_AXI_TEST_BOTTOM_ARESETN    => fins_test_ip_0_S_AXI_TEST_BOTTOM_ARESETN    ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_AWADDR     => fins_test_ip_0_S_AXI_TEST_BOTTOM_AWADDR     ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_AWPROT     => fins_test_ip_0_S_AXI_TEST_BOTTOM_AWPROT     ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_AWVALID    => fins_test_ip_0_S_AXI_TEST_BOTTOM_AWVALID    ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_AWREADY    => fins_test_ip_0_S_AXI_TEST_BOTTOM_AWREADY    ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_WDATA      => fins_test_ip_0_S_AXI_TEST_BOTTOM_WDATA      ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_WSTRB      => fins_test_ip_0_S_AXI_TEST_BOTTOM_WSTRB      ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_WVALID     => fins_test_ip_0_S_AXI_TEST_BOTTOM_WVALID     ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_WREADY     => fins_test_ip_0_S_AXI_TEST_BOTTOM_WREADY     ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_BRESP      => fins_test_ip_0_S_AXI_TEST_BOTTOM_BRESP      ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_BVALID     => fins_test_ip_0_S_AXI_TEST_BOTTOM_BVALID     ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_BREADY     => fins_test_ip_0_S_AXI_TEST_BOTTOM_BREADY     ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_ARADDR     => fins_test_ip_0_S_AXI_TEST_BOTTOM_ARADDR     ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_ARPROT     => fins_test_ip_0_S_AXI_TEST_BOTTOM_ARPROT     ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_ARVALID    => fins_test_ip_0_S_AXI_TEST_BOTTOM_ARVALID    ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_ARREADY    => fins_test_ip_0_S_AXI_TEST_BOTTOM_ARREADY    ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_RDATA      => fins_test_ip_0_S_AXI_TEST_BOTTOM_RDATA      ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_RRESP      => fins_test_ip_0_S_AXI_TEST_BOTTOM_RRESP      ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_RVALID     => fins_test_ip_0_S_AXI_TEST_BOTTOM_RVALID     ,
      fins_test_ip_0_S_AXI_TEST_BOTTOM_RREADY     => fins_test_ip_0_S_AXI_TEST_BOTTOM_RREADY     ,
      --fins_test_ip_1_S_AXI_ACLK    => fins_test_ip_1_S_AXI_ACLK,
      --fins_test_ip_1_S_AXI_ARESETN => fins_test_ip_1_S_AXI_ARESETN,
      fins_test_ip_1_S_AXI_AWADDR  => fins_test_ip_1_S_AXI_AWADDR,
      fins_test_ip_1_S_AXI_AWPROT  => fins_test_ip_1_S_AXI_AWPROT,
      fins_test_ip_1_S_AXI_AWVALID => fins_test_ip_1_S_AXI_AWVALID,
      fins_test_ip_1_S_AXI_AWREADY => fins_test_ip_1_S_AXI_AWREADY,
      fins_test_ip_1_S_AXI_WDATA   => fins_test_ip_1_S_AXI_WDATA,
      fins_test_ip_1_S_AXI_WSTRB   => fins_test_ip_1_S_AXI_WSTRB,
      fins_test_ip_1_S_AXI_WVALID  => fins_test_ip_1_S_AXI_WVALID,
      fins_test_ip_1_S_AXI_WREADY  => fins_test_ip_1_S_AXI_WREADY,
      fins_test_ip_1_S_AXI_BRESP   => fins_test_ip_1_S_AXI_BRESP,
      fins_test_ip_1_S_AXI_BVALID  => fins_test_ip_1_S_AXI_BVALID,
      fins_test_ip_1_S_AXI_BREADY  => fins_test_ip_1_S_AXI_BREADY,
      fins_test_ip_1_S_AXI_ARADDR  => fins_test_ip_1_S_AXI_ARADDR,
      fins_test_ip_1_S_AXI_ARPROT  => fins_test_ip_1_S_AXI_ARPROT,
      fins_test_ip_1_S_AXI_ARVALID => fins_test_ip_1_S_AXI_ARVALID,
      fins_test_ip_1_S_AXI_ARREADY => fins_test_ip_1_S_AXI_ARREADY,
      fins_test_ip_1_S_AXI_RDATA   => fins_test_ip_1_S_AXI_RDATA,
      fins_test_ip_1_S_AXI_RRESP   => fins_test_ip_1_S_AXI_RRESP,
      fins_test_ip_1_S_AXI_RVALID  => fins_test_ip_1_S_AXI_RVALID,
      fins_test_ip_1_S_AXI_RREADY  => fins_test_ip_1_S_AXI_RREADY,
      --fins_test_ip_1_S_AXI_TEST_MIDDLE_ACLK       => fins_test_ip_1_S_AXI_TEST_MIDDLE_ACLK       ,
      --fins_test_ip_1_S_AXI_TEST_MIDDLE_ARESETN    => fins_test_ip_1_S_AXI_TEST_MIDDLE_ARESETN    ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_AWADDR     => fins_test_ip_1_S_AXI_TEST_MIDDLE_AWADDR     ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_AWPROT     => fins_test_ip_1_S_AXI_TEST_MIDDLE_AWPROT     ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_AWVALID    => fins_test_ip_1_S_AXI_TEST_MIDDLE_AWVALID    ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_AWREADY    => fins_test_ip_1_S_AXI_TEST_MIDDLE_AWREADY    ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_WDATA      => fins_test_ip_1_S_AXI_TEST_MIDDLE_WDATA      ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_WSTRB      => fins_test_ip_1_S_AXI_TEST_MIDDLE_WSTRB      ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_WVALID     => fins_test_ip_1_S_AXI_TEST_MIDDLE_WVALID     ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_WREADY     => fins_test_ip_1_S_AXI_TEST_MIDDLE_WREADY     ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_BRESP      => fins_test_ip_1_S_AXI_TEST_MIDDLE_BRESP      ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_BVALID     => fins_test_ip_1_S_AXI_TEST_MIDDLE_BVALID     ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_BREADY     => fins_test_ip_1_S_AXI_TEST_MIDDLE_BREADY     ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_ARADDR     => fins_test_ip_1_S_AXI_TEST_MIDDLE_ARADDR     ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_ARPROT     => fins_test_ip_1_S_AXI_TEST_MIDDLE_ARPROT     ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_ARVALID    => fins_test_ip_1_S_AXI_TEST_MIDDLE_ARVALID    ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_ARREADY    => fins_test_ip_1_S_AXI_TEST_MIDDLE_ARREADY    ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_RDATA      => fins_test_ip_1_S_AXI_TEST_MIDDLE_RDATA      ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_RRESP      => fins_test_ip_1_S_AXI_TEST_MIDDLE_RRESP      ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_RVALID     => fins_test_ip_1_S_AXI_TEST_MIDDLE_RVALID     ,
      fins_test_ip_1_S_AXI_TEST_MIDDLE_RREADY     => fins_test_ip_1_S_AXI_TEST_MIDDLE_RREADY     ,
      --fins_test_ip_1_S_AXI_TEST_BOTTOM_ACLK       => fins_test_ip_1_S_AXI_TEST_BOTTOM_ACLK       ,
      --fins_test_ip_1_S_AXI_TEST_BOTTOM_ARESETN    => fins_test_ip_1_S_AXI_TEST_BOTTOM_ARESETN    ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_AWADDR     => fins_test_ip_1_S_AXI_TEST_BOTTOM_AWADDR     ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_AWPROT     => fins_test_ip_1_S_AXI_TEST_BOTTOM_AWPROT     ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_AWVALID    => fins_test_ip_1_S_AXI_TEST_BOTTOM_AWVALID    ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_AWREADY    => fins_test_ip_1_S_AXI_TEST_BOTTOM_AWREADY    ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_WDATA      => fins_test_ip_1_S_AXI_TEST_BOTTOM_WDATA      ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_WSTRB      => fins_test_ip_1_S_AXI_TEST_BOTTOM_WSTRB      ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_WVALID     => fins_test_ip_1_S_AXI_TEST_BOTTOM_WVALID     ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_WREADY     => fins_test_ip_1_S_AXI_TEST_BOTTOM_WREADY     ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_BRESP      => fins_test_ip_1_S_AXI_TEST_BOTTOM_BRESP      ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_BVALID     => fins_test_ip_1_S_AXI_TEST_BOTTOM_BVALID     ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_BREADY     => fins_test_ip_1_S_AXI_TEST_BOTTOM_BREADY     ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_ARADDR     => fins_test_ip_1_S_AXI_TEST_BOTTOM_ARADDR     ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_ARPROT     => fins_test_ip_1_S_AXI_TEST_BOTTOM_ARPROT     ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_ARVALID    => fins_test_ip_1_S_AXI_TEST_BOTTOM_ARVALID    ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_ARREADY    => fins_test_ip_1_S_AXI_TEST_BOTTOM_ARREADY    ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_RDATA      => fins_test_ip_1_S_AXI_TEST_BOTTOM_RDATA      ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_RRESP      => fins_test_ip_1_S_AXI_TEST_BOTTOM_RRESP      ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_RVALID     => fins_test_ip_1_S_AXI_TEST_BOTTOM_RVALID     ,
      fins_test_ip_1_S_AXI_TEST_BOTTOM_RREADY     => fins_test_ip_1_S_AXI_TEST_BOTTOM_RREADY     ,
      --fins_test_ip_0_s_axis_myinput_aclk    => fins_test_ip_0_s_axis_myinput_aclk,
      --fins_test_ip_0_s_axis_myinput_aclk    => clock,
      --fins_test_ip_0_s_axis_myinput_aresetn => fins_test_ip_0_s_axis_myinput_aresetn,
      fins_test_ip_0_s_axis_myinput_tdata   => fins_test_ip_0_s_axis_myinput_tdata,
      fins_test_ip_0_s_axis_myinput_tuser   => fins_test_ip_0_s_axis_myinput_tuser,
      fins_test_ip_0_s_axis_myinput_tvalid  => fins_test_ip_0_s_axis_myinput_tvalid,
      fins_test_ip_0_s_axis_myinput_tlast   => fins_test_ip_0_s_axis_myinput_tlast,
      --fins_test_ip_1_m_axis_myoutput_aclk    => fins_test_ip_1_m_axis_myoutput_aclk,
      --fins_test_ip_1_m_axis_myoutput_aclk    => clock,
      --fins_test_ip_1_m_axis_myoutput_aresetn => fins_test_ip_1_m_axis_myoutput_aresetn,
      fins_test_ip_1_m_axis_myoutput_tdata   => fins_test_ip_1_m_axis_myoutput_tdata,
      fins_test_ip_1_m_axis_myoutput_tuser   => fins_test_ip_1_m_axis_myoutput_tuser,
      fins_test_ip_1_m_axis_myoutput_tvalid  => fins_test_ip_1_m_axis_myoutput_tvalid,
      fins_test_ip_1_m_axis_myoutput_tlast   => fins_test_ip_1_m_axis_myoutput_tlast,
      --fins_test_ip_0_s00_axis_test_in_aclk    => fins_test_ip_0_s00_axis_test_in_aclk,
      --fins_test_ip_0_s00_axis_test_in_aclk    => clock,
      --fins_test_ip_0_s00_axis_test_in_aresetn => fins_test_ip_0_s00_axis_test_in_aresetn,
      fins_test_ip_0_s00_axis_test_in_tready  => fins_test_ip_0_s00_axis_test_in_tready,
      fins_test_ip_0_s00_axis_test_in_tdata   => fins_test_ip_0_s00_axis_test_in_tdata,
      fins_test_ip_0_s00_axis_test_in_tuser   => fins_test_ip_0_s00_axis_test_in_tuser,
      fins_test_ip_0_s00_axis_test_in_tvalid  => fins_test_ip_0_s00_axis_test_in_tvalid,
      fins_test_ip_0_s00_axis_test_in_tlast   => fins_test_ip_0_s00_axis_test_in_tlast,
      --fins_test_ip_0_s01_axis_test_in_aclk    => fins_test_ip_0_s01_axis_test_in_aclk,
      --fins_test_ip_0_s01_axis_test_in_aclk    => clock,
      --fins_test_ip_0_s01_axis_test_in_aresetn => fins_test_ip_0_s01_axis_test_in_aresetn,
      fins_test_ip_0_s01_axis_test_in_tready  => fins_test_ip_0_s01_axis_test_in_tready,
      fins_test_ip_0_s01_axis_test_in_tdata   => fins_test_ip_0_s01_axis_test_in_tdata,
      fins_test_ip_0_s01_axis_test_in_tuser   => fins_test_ip_0_s01_axis_test_in_tuser,
      fins_test_ip_0_s01_axis_test_in_tvalid  => fins_test_ip_0_s01_axis_test_in_tvalid,
      fins_test_ip_0_s01_axis_test_in_tlast   => fins_test_ip_0_s01_axis_test_in_tlast,
      --fins_test_ip_1_m00_axis_test_out_aclk    => fins_test_ip_1_m00_axis_test_out_aclk,
      --fins_test_ip_1_m00_axis_test_out_aclk    => clock,
      --fins_test_ip_1_m00_axis_test_out_aresetn => fins_test_ip_1_m00_axis_test_out_aresetn,
      fins_test_ip_1_m00_axis_test_out_tready  => fins_test_ip_1_m00_axis_test_out_tready,
      fins_test_ip_1_m00_axis_test_out_tdata   => fins_test_ip_1_m00_axis_test_out_tdata,
      fins_test_ip_1_m00_axis_test_out_tuser   => fins_test_ip_1_m00_axis_test_out_tuser,
      fins_test_ip_1_m00_axis_test_out_tvalid  => fins_test_ip_1_m00_axis_test_out_tvalid,
      fins_test_ip_1_m00_axis_test_out_tlast   => fins_test_ip_1_m00_axis_test_out_tlast,
      --fins_test_ip_1_m01_axis_test_out_aclk    => fins_test_ip_1_m01_axis_test_out_aclk,
      --fins_test_ip_1_m01_axis_test_out_aclk    => clock,
      --fins_test_ip_1_m01_axis_test_out_aresetn => fins_test_ip_1_m01_axis_test_out_aresetn,
      fins_test_ip_1_m01_axis_test_out_tready  => fins_test_ip_1_m01_axis_test_out_tready,
      fins_test_ip_1_m01_axis_test_out_tdata   => fins_test_ip_1_m01_axis_test_out_tdata,
      fins_test_ip_1_m01_axis_test_out_tuser   => fins_test_ip_1_m01_axis_test_out_tuser,
      fins_test_ip_1_m01_axis_test_out_tvalid  => fins_test_ip_1_m01_axis_test_out_tvalid,
      fins_test_ip_1_m01_axis_test_out_tlast   => fins_test_ip_1_m01_axis_test_out_tlast,
      --fins_test_ip_0_s_axis_sfix_cpx_in_aclk     => fins_test_ip_0_s_axis_sfix_cpx_in_aclk,
      --fins_test_ip_0_s_axis_sfix_cpx_in_aclk     => clock,
      --fins_test_ip_0_s_axis_sfix_cpx_in_aresetn  => fins_test_ip_0_s_axis_sfix_cpx_in_aresetn,
      fins_test_ip_0_s_axis_sfix_cpx_in_tready   => fins_test_ip_0_s_axis_sfix_cpx_in_tready,
      fins_test_ip_0_s_axis_sfix_cpx_in_tdata    => fins_test_ip_0_s_axis_sfix_cpx_in_tdata,
      fins_test_ip_0_s_axis_sfix_cpx_in_tuser    => fins_test_ip_0_s_axis_sfix_cpx_in_tuser,
      fins_test_ip_0_s_axis_sfix_cpx_in_tvalid   => fins_test_ip_0_s_axis_sfix_cpx_in_tvalid,
      fins_test_ip_0_s_axis_sfix_cpx_in_tlast    => fins_test_ip_0_s_axis_sfix_cpx_in_tlast,
      --fins_test_ip_1_m_axis_sfix_cpx_out_aclk    => fins_test_ip_1_m_axis_sfix_cpx_out_aclk,
      --fins_test_ip_1_m_axis_sfix_cpx_out_aclk    => clock,
      --fins_test_ip_1_m_axis_sfix_cpx_out_aresetn => fins_test_ip_1_m_axis_sfix_cpx_out_aresetn,
      fins_test_ip_1_m_axis_sfix_cpx_out_tready  => fins_test_ip_1_m_axis_sfix_cpx_out_tready,
      fins_test_ip_1_m_axis_sfix_cpx_out_tdata   => fins_test_ip_1_m_axis_sfix_cpx_out_tdata,
      fins_test_ip_1_m_axis_sfix_cpx_out_tuser   => fins_test_ip_1_m_axis_sfix_cpx_out_tuser,
      fins_test_ip_1_m_axis_sfix_cpx_out_tvalid  => fins_test_ip_1_m_axis_sfix_cpx_out_tvalid,
      fins_test_ip_1_m_axis_sfix_cpx_out_tlast   => fins_test_ip_1_m_axis_sfix_cpx_out_tlast,
      reset_reset_n => resetn
    );
  --------------------------------------------------------------------------------
  -- File Input/Output AXI4-Stream Port Verification
  --------------------------------------------------------------------------------
  -- NOTE: The source/sink filepaths are relative to where the simulation is executed
  --u_file_io : entity work.test_top_axis_verify
  u_file_io : entity test_top_00.test_top_axis_verify
    generic map (
      G_MYINPUT_SOURCE_SAMPLE_PERIOD => 15,
      G_MYINPUT_SOURCE_RANDOMIZE_BUS => true,
      --G_MYINPUT_SOURCE_FILEPATH => "../../../../../../sim_data/sim_source_myinput.txt",
      G_MYOUTPUT_SINK_SAMPLE_PERIOD => 2,
      G_MYOUTPUT_SINK_RANDOMIZE_BUS => true,
      --G_MYOUTPUT_SINK_FILEPATH => "../../../../../../sim_data/sim_sink_myoutput.txt",
      G_TEST_IN00_SOURCE_SAMPLE_PERIOD => 16,
      G_TEST_IN00_SOURCE_RANDOMIZE_BUS => false,
      --G_TEST_IN00_SOURCE_FILEPATH => "../../../../../../sim_data/sim_source_test_in00.txt",
      G_TEST_IN01_SOURCE_SAMPLE_PERIOD => 31,
      G_TEST_IN01_SOURCE_RANDOMIZE_BUS => true,
      --G_TEST_IN01_SOURCE_FILEPATH => "../../../../../../sim_data/sim_source_test_in01.txt",
      G_TEST_OUT00_SINK_SAMPLE_PERIOD => 31,
      G_TEST_OUT00_SINK_RANDOMIZE_BUS => true,
      --G_TEST_OUT00_SINK_FILEPATH => "../../../../../../sim_data/sim_sink_test_out00.txt",
      G_TEST_OUT01_SINK_SAMPLE_PERIOD => 16,
      G_TEST_OUT01_SINK_RANDOMIZE_BUS => false,
      --G_TEST_OUT01_SINK_FILEPATH => "../../../../../../sim_data/sim_sink_test_out01.txt",
      G_SFIX_CPX_IN_SOURCE_SAMPLE_PERIOD => 1,
      G_SFIX_CPX_IN_SOURCE_RANDOMIZE_BUS => false,
      --G_SFIX_CPX_IN_SOURCE_FILEPATH => "../../../../../../sim_data/sim_source_sfix_cpx_in.txt",
      G_SFIX_CPX_OUT_SINK_SAMPLE_PERIOD => 1,
      G_SFIX_CPX_OUT_SINK_RANDOMIZE_BUS => false
      --G_SFIX_CPX_OUT_SINK_FILEPATH => "../../../../../../sim_data/sim_sink_sfix_cpx_out.txt"
    )
    port map (
      simulation_done => simulation_done,
      --m_axis_myinput_aclk    => fins_test_ip_0_s_axis_myinput_aclk,
      m_axis_myinput_aclk    => clock,
      m_axis_myinput_enable  => s_axis_myinput_enable,
      m_axis_myinput_tdata   => fins_test_ip_0_s_axis_myinput_tdata,
      m_axis_myinput_tuser   => fins_test_ip_0_s_axis_myinput_tuser,
      m_axis_myinput_tvalid  => fins_test_ip_0_s_axis_myinput_tvalid,
      m_axis_myinput_tlast   => fins_test_ip_0_s_axis_myinput_tlast,
      --s_axis_myoutput_aclk    => fins_test_ip_1_m_axis_myoutput_aclk,
      s_axis_myoutput_aclk    => clock,
      s_axis_myoutput_tdata   => fins_test_ip_1_m_axis_myoutput_tdata,
      s_axis_myoutput_tuser   => fins_test_ip_1_m_axis_myoutput_tuser,
      s_axis_myoutput_tvalid  => fins_test_ip_1_m_axis_myoutput_tvalid,
      s_axis_myoutput_tlast   => fins_test_ip_1_m_axis_myoutput_tlast,
      --m00_axis_test_in_aclk    => fins_test_ip_0_s00_axis_test_in_aclk,
      m00_axis_test_in_aclk    => clock,
      m00_axis_test_in_enable  => s00_axis_test_in_enable,
      m00_axis_test_in_tready  => fins_test_ip_0_s00_axis_test_in_tready,
      m00_axis_test_in_tdata   => fins_test_ip_0_s00_axis_test_in_tdata,
      m00_axis_test_in_tuser   => fins_test_ip_0_s00_axis_test_in_tuser,
      m00_axis_test_in_tvalid  => fins_test_ip_0_s00_axis_test_in_tvalid,
      m00_axis_test_in_tlast   => fins_test_ip_0_s00_axis_test_in_tlast,
      --m01_axis_test_in_aclk    => fins_test_ip_0_s01_axis_test_in_aclk,
      m01_axis_test_in_aclk    => clock,
      m01_axis_test_in_enable  => s01_axis_test_in_enable,
      m01_axis_test_in_tready  => fins_test_ip_0_s01_axis_test_in_tready,
      m01_axis_test_in_tdata   => fins_test_ip_0_s01_axis_test_in_tdata,
      m01_axis_test_in_tuser   => fins_test_ip_0_s01_axis_test_in_tuser,
      m01_axis_test_in_tvalid  => fins_test_ip_0_s01_axis_test_in_tvalid,
      m01_axis_test_in_tlast   => fins_test_ip_0_s01_axis_test_in_tlast,
      --s00_axis_test_out_aclk    => fins_test_ip_1_m00_axis_test_out_aclk,
      s00_axis_test_out_aclk    => clock,
      s00_axis_test_out_tready  => fins_test_ip_1_m00_axis_test_out_tready,
      s00_axis_test_out_tdata   => fins_test_ip_1_m00_axis_test_out_tdata,
      s00_axis_test_out_tuser   => fins_test_ip_1_m00_axis_test_out_tuser,
      s00_axis_test_out_tvalid  => fins_test_ip_1_m00_axis_test_out_tvalid,
      s00_axis_test_out_tlast   => fins_test_ip_1_m00_axis_test_out_tlast,
      --s01_axis_test_out_aclk    => fins_test_ip_1_m01_axis_test_out_aclk,
      s01_axis_test_out_aclk    => clock,
      s01_axis_test_out_tready  => fins_test_ip_1_m01_axis_test_out_tready,
      s01_axis_test_out_tdata   => fins_test_ip_1_m01_axis_test_out_tdata,
      s01_axis_test_out_tuser   => fins_test_ip_1_m01_axis_test_out_tuser,
      s01_axis_test_out_tvalid  => fins_test_ip_1_m01_axis_test_out_tvalid,
      s01_axis_test_out_tlast   => fins_test_ip_1_m01_axis_test_out_tlast,
      --m_axis_sfix_cpx_in_aclk    => fins_test_ip_0_s_axis_sfix_cpx_in_aclk,
      m_axis_sfix_cpx_in_aclk    => clock,
      m_axis_sfix_cpx_in_enable  => s_axis_sfix_cpx_in_enable,
      m_axis_sfix_cpx_in_tready  => fins_test_ip_0_s_axis_sfix_cpx_in_tready,
      m_axis_sfix_cpx_in_tdata   => fins_test_ip_0_s_axis_sfix_cpx_in_tdata,
      m_axis_sfix_cpx_in_tuser   => fins_test_ip_0_s_axis_sfix_cpx_in_tuser,
      m_axis_sfix_cpx_in_tvalid  => fins_test_ip_0_s_axis_sfix_cpx_in_tvalid,
      m_axis_sfix_cpx_in_tlast   => fins_test_ip_0_s_axis_sfix_cpx_in_tlast,
      --s_axis_sfix_cpx_out_aclk   => fins_test_ip_1_m_axis_sfix_cpx_out_aclk,
      s_axis_sfix_cpx_out_aclk   => clock,
      s_axis_sfix_cpx_out_tready => fins_test_ip_1_m_axis_sfix_cpx_out_tready,
      s_axis_sfix_cpx_out_tdata  => fins_test_ip_1_m_axis_sfix_cpx_out_tdata,
      s_axis_sfix_cpx_out_tuser  => fins_test_ip_1_m_axis_sfix_cpx_out_tuser,
      s_axis_sfix_cpx_out_tvalid => fins_test_ip_1_m_axis_sfix_cpx_out_tvalid,
      s_axis_sfix_cpx_out_tlast  => fins_test_ip_1_m_axis_sfix_cpx_out_tlast
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

  --------------------------------------------------------------------------------
  -- Port Verification Procedures
  --------------------------------------------------------------------------------
  -- Waveform process to wait for packets on the myoutput output port
  w_myoutput_verify : process
    variable my_line          : line;
    variable packets_received : natural := 0;
  begin
    -- Wait for global reset to complete
    if (resetn = '0') then
      wait until (resetn = '1');
    end if;
    -- Wait for all expected packets using the TLAST signal
    while (packets_received < G_MYOUTPUT_NUM_PACKETS_EXPECTED) loop
      --wait until falling_edge(m_axis_myoutput_aclk);
      wait until falling_edge(clock);
      if ((fins_test_ip_1_m_axis_myoutput_tlast = '1') AND (fins_test_ip_1_m_axis_myoutput_tlast = '1')) then
        packets_received := packets_received + 1;
      end if;
    end loop;
    -- End this process
    write(my_line, string'("PASS: Data received from Port myoutput"));
    writeline(output, my_line);
    m_axis_myoutput_verify_done <= true;
    wait;
  end process w_myoutput_verify;
  -- Waveform process to wait for packets on the test_out00 output port
  w_test_out00_verify : process
    variable my_line          : line;
    variable packets_received : natural := 0;
  begin
    -- Wait for global reset to complete
    if (resetn = '0') then
      wait until (resetn = '1');
    end if;
    -- Wait for all expected packets using the TLAST signal
    while (packets_received < G_TEST_OUT00_NUM_PACKETS_EXPECTED) loop
      --wait until falling_edge(fins_test_ip_1_m00_axis_test_out_aclk);
      wait until falling_edge(clock);
      if ((fins_test_ip_1_m00_axis_test_out_tvalid = '1') AND (fins_test_ip_1_m00_axis_test_out_tlast = '1') AND (fins_test_ip_1_m00_axis_test_out_tready = '1')) then
        packets_received := packets_received + 1;
      end if;
    end loop;
    -- End this process
    write(my_line, string'("PASS: Data received from Port test_out00"));
    writeline(output, my_line);
    m00_axis_test_out_verify_done <= true;
    wait;
  end process w_test_out00_verify;
  -- Waveform process to wait for packets on the test_out01 output port
  w_test_out01_verify : process
    variable my_line          : line;
    variable packets_received : natural := 0;
  begin
    -- Wait for global reset to complete
    if (resetn = '0') then
      wait until (resetn = '1');
    end if;
    -- Wait for all expected packets using the TLAST signal
    while (packets_received < G_TEST_OUT01_NUM_PACKETS_EXPECTED) loop
      --wait until falling_edge(m01_axis_test_out_aclk);
      wait until falling_edge(clock);
      if ((fins_test_ip_1_m01_axis_test_out_tvalid = '1') AND (fins_test_ip_1_m01_axis_test_out_tlast = '1') AND (fins_test_ip_1_m01_axis_test_out_tready = '1')) then
        packets_received := packets_received + 1;
      end if;
    end loop;
    -- End this process
    write(my_line, string'("PASS: Data received from Port test_out01"));
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
    write(my_line, string'("Beggining AXILite verification"));
    writeline(output, my_line);
    test_top_00.test_top_axilite_verify.test_top_axilite_verify (
      --fins_test_ip_0_S_AXI_ACLK,   fins_test_ip_0_S_AXI_ARESETN,
      clock,   resetn,
      fins_test_ip_0_S_AXI_AWADDR, fins_test_ip_0_S_AXI_AWPROT, fins_test_ip_0_S_AXI_AWVALID, fins_test_ip_0_S_AXI_AWREADY,
      fins_test_ip_0_S_AXI_WDATA,  fins_test_ip_0_S_AXI_WSTRB,  fins_test_ip_0_S_AXI_WVALID,  fins_test_ip_0_S_AXI_WREADY,
      fins_test_ip_0_S_AXI_BRESP,  fins_test_ip_0_S_AXI_BVALID, fins_test_ip_0_S_AXI_BREADY,
      fins_test_ip_0_S_AXI_ARADDR, fins_test_ip_0_S_AXI_ARPROT, fins_test_ip_0_S_AXI_ARVALID, fins_test_ip_0_S_AXI_ARREADY,
      fins_test_ip_0_S_AXI_RDATA,  fins_test_ip_0_S_AXI_RRESP,  fins_test_ip_0_S_AXI_RVALID,  fins_test_ip_0_S_AXI_RREADY
    );
    write(my_line, string'("Top 0 AXILite verification complete"));
    writeline(output, my_line);
    test_middle_00.test_middle_axilite_verify.test_middle_axilite_verify (
      --fins_test_ip_0_S_AXI_ACLK,   fins_test_ip_0_S_AXI_ARESETN,
      clock,   resetn,
      fins_test_ip_0_S_AXI_AWADDR, fins_test_ip_0_S_AXI_AWPROT, fins_test_ip_0_S_AXI_AWVALID, fins_test_ip_0_S_AXI_AWREADY,
      fins_test_ip_0_S_AXI_WDATA,  fins_test_ip_0_S_AXI_WSTRB,  fins_test_ip_0_S_AXI_WVALID,  fins_test_ip_0_S_AXI_WREADY,
      fins_test_ip_0_S_AXI_BRESP,  fins_test_ip_0_S_AXI_BVALID, fins_test_ip_0_S_AXI_BREADY,
      fins_test_ip_0_S_AXI_ARADDR, fins_test_ip_0_S_AXI_ARPROT, fins_test_ip_0_S_AXI_ARVALID, fins_test_ip_0_S_AXI_ARREADY,
      fins_test_ip_0_S_AXI_RDATA,  fins_test_ip_0_S_AXI_RRESP,  fins_test_ip_0_S_AXI_RVALID,  fins_test_ip_0_S_AXI_RREADY
    );
    write(my_line, string'("Middle 0 AXILite verification complete"));
    writeline(output, my_line);
    --test_bottom_00.test_bottom_axilite_verify.test_bottom_axilite_verify (
    --  --fins_test_ip_0_S_AXI_ACLK,   fins_test_ip_0_S_AXI_ARESETN,
    --  clock,   resetn,
    --  fins_test_ip_0_S_AXI_AWADDR, fins_test_ip_0_S_AXI_AWPROT, fins_test_ip_0_S_AXI_AWVALID, fins_test_ip_0_S_AXI_AWREADY,
    --  fins_test_ip_0_S_AXI_WDATA,  fins_test_ip_0_S_AXI_WSTRB,  fins_test_ip_0_S_AXI_WVALID,  fins_test_ip_0_S_AXI_WREADY,
    --  fins_test_ip_0_S_AXI_BRESP,  fins_test_ip_0_S_AXI_BVALID, fins_test_ip_0_S_AXI_BREADY,
    --  fins_test_ip_0_S_AXI_ARADDR, fins_test_ip_0_S_AXI_ARPROT, fins_test_ip_0_S_AXI_ARVALID, fins_test_ip_0_S_AXI_ARREADY,
    --  fins_test_ip_0_S_AXI_RDATA,  fins_test_ip_0_S_AXI_RRESP,  fins_test_ip_0_S_AXI_RVALID,  fins_test_ip_0_S_AXI_RREADY
    --);
    test_top_00.test_top_axilite_verify.test_top_axilite_verify (
      --fins_test_ip_1_S_AXI_ACLK,   fins_test_ip_1_S_AXI_ARESETN,
      clock,   resetn,
      fins_test_ip_1_S_AXI_AWADDR, fins_test_ip_1_S_AXI_AWPROT, fins_test_ip_1_S_AXI_AWVALID, fins_test_ip_1_S_AXI_AWREADY,
      fins_test_ip_1_S_AXI_WDATA,  fins_test_ip_1_S_AXI_WSTRB,  fins_test_ip_1_S_AXI_WVALID,  fins_test_ip_1_S_AXI_WREADY,
      fins_test_ip_1_S_AXI_BRESP,  fins_test_ip_1_S_AXI_BVALID, fins_test_ip_1_S_AXI_BREADY,
      fins_test_ip_1_S_AXI_ARADDR, fins_test_ip_1_S_AXI_ARPROT, fins_test_ip_1_S_AXI_ARVALID, fins_test_ip_1_S_AXI_ARREADY,
      fins_test_ip_1_S_AXI_RDATA,  fins_test_ip_1_S_AXI_RRESP,  fins_test_ip_1_S_AXI_RVALID,  fins_test_ip_1_S_AXI_RREADY
    );
    write(my_line, string'("Top 1 AXILite verification complete"));
    writeline(output, my_line);
    test_middle_00.test_middle_axilite_verify.test_middle_axilite_verify (
      --fins_test_ip_1_S_AXI_ACLK,   fins_test_ip_1_S_AXI_ARESETN,
      clock,   resetn,
      fins_test_ip_1_S_AXI_AWADDR, fins_test_ip_1_S_AXI_AWPROT, fins_test_ip_1_S_AXI_AWVALID, fins_test_ip_1_S_AXI_AWREADY,
      fins_test_ip_1_S_AXI_WDATA,  fins_test_ip_1_S_AXI_WSTRB,  fins_test_ip_1_S_AXI_WVALID,  fins_test_ip_1_S_AXI_WREADY,
      fins_test_ip_1_S_AXI_BRESP,  fins_test_ip_1_S_AXI_BVALID, fins_test_ip_1_S_AXI_BREADY,
      fins_test_ip_1_S_AXI_ARADDR, fins_test_ip_1_S_AXI_ARPROT, fins_test_ip_1_S_AXI_ARVALID, fins_test_ip_1_S_AXI_ARREADY,
      fins_test_ip_1_S_AXI_RDATA,  fins_test_ip_1_S_AXI_RRESP,  fins_test_ip_1_S_AXI_RVALID,  fins_test_ip_1_S_AXI_RREADY
    );
    write(my_line, string'("Middle 1 AXILite verification complete"));
    writeline(output, my_line);
    --test_bottom_00.test_bottom_axilite_verify.test_bottom_axilite_verify (
    --  --fins_test_ip_1_S_AXI_ACLK,   fins_test_ip_1_S_AXI_ARESETN,
    --  clock,   resetn,
    --  fins_test_ip_1_S_AXI_AWADDR, fins_test_ip_1_S_AXI_AWPROT, fins_test_ip_1_S_AXI_AWVALID, fins_test_ip_1_S_AXI_AWREADY,
    --  fins_test_ip_1_S_AXI_WDATA,  fins_test_ip_1_S_AXI_WSTRB,  fins_test_ip_1_S_AXI_WVALID,  fins_test_ip_1_S_AXI_WREADY,
    --  fins_test_ip_1_S_AXI_BRESP,  fins_test_ip_1_S_AXI_BVALID, fins_test_ip_1_S_AXI_BREADY,
    --  fins_test_ip_1_S_AXI_ARADDR, fins_test_ip_1_S_AXI_ARPROT, fins_test_ip_1_S_AXI_ARVALID, fins_test_ip_1_S_AXI_ARREADY,
    --  fins_test_ip_1_S_AXI_RDATA,  fins_test_ip_1_S_AXI_RRESP,  fins_test_ip_1_S_AXI_RVALID,  fins_test_ip_1_S_AXI_RREADY
    --);
    --**************************************************
    -- Verify Ports
    --**************************************************
    -- Enable the inputs
    s_axis_myinput_enable <= '1';
    s00_axis_test_in_enable <= '1';
    s01_axis_test_in_enable <= '1';
    s_axis_sfix_cpx_in_enable <= '1';

    write(my_line, string'("Beggining ouptut verification"));
    writeline(output, my_line);
    -- Wait for the output verification processes to complete
    if (not m_axis_myoutput_verify_done) then
      wait until (m_axis_myoutput_verify_done);
    end if;
    write(my_line, string'("Verification complete for 'myoutput'"));
    writeline(output, my_line);
    if (not m00_axis_test_out_verify_done) then
      wait until (m00_axis_test_out_verify_done);
    end if;
    write(my_line, string'("Verification complete for '0 test_out'"));
    writeline(output, my_line);
    if (not m01_axis_test_out_verify_done) then
      wait until (m01_axis_test_out_verify_done);
    end if;
    write(my_line, string'("Verification complete for '1 test_out'"));
    writeline(output, my_line);

    --**************************************************
    -- End Simulation
    --**************************************************
    write(my_line, string'("***** SIMULATION PASSED *****"));
    writeline(output, my_line);
    simulation_done <= true;
    wait;

  end process w_test_procedure;

end behav;
