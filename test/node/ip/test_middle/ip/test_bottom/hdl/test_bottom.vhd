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
use ieee.math_real.all;

-- User Libraries
library work;
use work.test_bottom_pkg.all;

-- Entity
entity test_bottom is
  port (
    -- Software Configuration Bus for Properties
    s_swconfig_clk         : in  std_logic;
    s_swconfig_reset       : in  std_logic;
    s_swconfig_address     : in  std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
    s_swconfig_wr_enable   : in  std_logic;
    s_swconfig_wr_data     : in  std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
    s_swconfig_rd_enable   : in  std_logic;
    s_swconfig_rd_valid    : out std_logic;
    s_swconfig_rd_data     : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
    -- AXI4-Stream Port IN: myinput
    s_axis_myinput_aclk    : in  std_logic;
    s_axis_myinput_aresetn : in  std_logic;
    s_axis_myinput_tdata   : in  std_logic_vector(16-1 downto 0);
    s_axis_myinput_tvalid  : in   std_logic;
    s_axis_myinput_tlast   : in   std_logic;
    -- AXI4-Stream Port OUT: myoutput
    m_axis_myoutput_aclk    : in  std_logic;
    m_axis_myoutput_aresetn : in  std_logic;
    m_axis_myoutput_tdata   : out std_logic_vector(16-1 downto 0);
    m_axis_myoutput_tvalid  : out  std_logic;
    m_axis_myoutput_tlast   : out  std_logic;
    -- AXI4-Stream Port IN: test_in
    s00_axis_test_in_aclk    : in  std_logic;
    s00_axis_test_in_aresetn : in  std_logic;
    s00_axis_test_in_tready  : out std_logic;
    s00_axis_test_in_tdata   : in  std_logic_vector(160-1 downto 0);
    s00_axis_test_in_tuser   : in   std_logic_vector(128-1 downto 0);
    s00_axis_test_in_tvalid  : in   std_logic;
    s00_axis_test_in_tlast   : in   std_logic;
    s01_axis_test_in_aclk    : in  std_logic;
    s01_axis_test_in_aresetn : in  std_logic;
    s01_axis_test_in_tready  : out std_logic;
    s01_axis_test_in_tdata   : in  std_logic_vector(160-1 downto 0);
    s01_axis_test_in_tuser   : in   std_logic_vector(128-1 downto 0);
    s01_axis_test_in_tvalid  : in   std_logic;
    s01_axis_test_in_tlast   : in   std_logic;
    -- AXI4-Stream Port OUT: test_out
    m00_axis_test_out_aclk    : in  std_logic;
    m00_axis_test_out_aresetn : in  std_logic;
    m00_axis_test_out_tready  : in  std_logic;
    m00_axis_test_out_tdata   : out std_logic_vector(160-1 downto 0);
    m00_axis_test_out_tuser   : out  std_logic_vector(128-1 downto 0);
    m00_axis_test_out_tvalid  : out  std_logic;
    m00_axis_test_out_tlast   : out  std_logic;
    m01_axis_test_out_aclk    : in  std_logic;
    m01_axis_test_out_aresetn : in  std_logic;
    m01_axis_test_out_tready  : in  std_logic;
    m01_axis_test_out_tdata   : out std_logic_vector(160-1 downto 0);
    m01_axis_test_out_tuser   : out  std_logic_vector(128-1 downto 0);
    m01_axis_test_out_tvalid  : out  std_logic;
    m01_axis_test_out_tlast   : out  std_logic
  );
end test_bottom;

-- Architecture
architecture struct of test_bottom is

  --------------------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------------------
  -- Auto-generated Software Configuration FINS Properties interface
  component test_bottom_swconfig is
    generic (
      G_BYTE_INDEXED : boolean := PROPS_IS_ADDR_BYTE_INDEXED;
      G_ADDR_WIDTH   : natural := PROPS_ADDR_WIDTH;
      G_DATA_WIDTH   : natural := PROPS_DATA_WIDTH
    );
    port (
      s_swconfig_clk       : in  std_logic;
      s_swconfig_reset     : in  std_logic;
      s_swconfig_address   : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
      s_swconfig_wr_enable : in  std_logic;
      s_swconfig_wr_data   : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
      s_swconfig_rd_enable : in  std_logic;
      s_swconfig_rd_valid  : out std_logic;
      s_swconfig_rd_data   : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
      props_control        : out t_test_bottom_props_control;
      props_status         : in  t_test_bottom_props_status
    );
  end component;
  -- Auto-generated AXI4-Stream FINS Ports interface
  component test_bottom_axis is
    port (
      -- AXI4-Stream Port IN: myinput
      s_axis_myinput_aclk    : in  std_logic;
      s_axis_myinput_aresetn : in  std_logic;
      s_axis_myinput_tdata   : in  std_logic_vector(16-1 downto 0);
      s_axis_myinput_tvalid  : in   std_logic;
      s_axis_myinput_tlast   : in   std_logic;
      -- AXI4-Stream Port OUT: myoutput
      m_axis_myoutput_aclk    : in  std_logic;
      m_axis_myoutput_aresetn : in  std_logic;
      m_axis_myoutput_tdata   : out std_logic_vector(16-1 downto 0);
      m_axis_myoutput_tvalid  : out  std_logic;
      m_axis_myoutput_tlast   : out  std_logic;
      -- AXI4-Stream Port IN: test_in
      s00_axis_test_in_aclk    : in  std_logic;
      s00_axis_test_in_aresetn : in  std_logic;
      s00_axis_test_in_tready  : out std_logic;
      s00_axis_test_in_tdata   : in  std_logic_vector(160-1 downto 0);
      s00_axis_test_in_tuser   : in   std_logic_vector(128-1 downto 0);
      s00_axis_test_in_tvalid  : in   std_logic;
      s00_axis_test_in_tlast   : in   std_logic;
      s01_axis_test_in_aclk    : in  std_logic;
      s01_axis_test_in_aresetn : in  std_logic;
      s01_axis_test_in_tready  : out std_logic;
      s01_axis_test_in_tdata   : in  std_logic_vector(160-1 downto 0);
      s01_axis_test_in_tuser   : in   std_logic_vector(128-1 downto 0);
      s01_axis_test_in_tvalid  : in   std_logic;
      s01_axis_test_in_tlast   : in   std_logic;
      -- AXI4-Stream Port OUT: test_out
      m00_axis_test_out_aclk    : in  std_logic;
      m00_axis_test_out_aresetn : in  std_logic;
      m00_axis_test_out_tready  : in  std_logic;
      m00_axis_test_out_tdata   : out std_logic_vector(160-1 downto 0);
      m00_axis_test_out_tuser   : out  std_logic_vector(128-1 downto 0);
      m00_axis_test_out_tvalid  : out  std_logic;
      m00_axis_test_out_tlast   : out  std_logic;
      m01_axis_test_out_aclk    : in  std_logic;
      m01_axis_test_out_aresetn : in  std_logic;
      m01_axis_test_out_tready  : in  std_logic;
      m01_axis_test_out_tdata   : out std_logic_vector(160-1 downto 0);
      m01_axis_test_out_tuser   : out  std_logic_vector(128-1 downto 0);
      m01_axis_test_out_tvalid  : out  std_logic;
      m01_axis_test_out_tlast   : out  std_logic;
      ports_in  : out t_test_bottom_ports_in;
      ports_out : in  t_test_bottom_ports_out
    );
  end component;

  component test_bottom_core is
    port (
      props_control : in  t_test_bottom_props_control;
      props_status  : out t_test_bottom_props_status;
      ports_in      : in  t_test_bottom_ports_in;
      ports_out     : out t_test_bottom_ports_out
    );
  end component;

  --------------------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------------------
  signal props_control : t_test_bottom_props_control;
  signal props_status  : t_test_bottom_props_status;
  signal ports_in      : t_test_bottom_ports_in;
  signal ports_out     : t_test_bottom_ports_out;

begin
  --------------------------------------------------------------------------------
  -- Properties
  --------------------------------------------------------------------------------
  u_properties : test_bottom_swconfig
    port map (
      s_swconfig_clk       => s_swconfig_clk,
      s_swconfig_reset     => s_swconfig_reset,
      s_swconfig_address   => s_swconfig_address,
      s_swconfig_wr_enable => s_swconfig_wr_enable,
      s_swconfig_wr_data   => s_swconfig_wr_data,
      s_swconfig_rd_enable => s_swconfig_rd_enable,
      s_swconfig_rd_valid  => s_swconfig_rd_valid,
      s_swconfig_rd_data   => s_swconfig_rd_data,
      props_control        => props_control,
      props_status         => props_status
    );
  --------------------------------------------------------------------------------
  -- Ports
  --------------------------------------------------------------------------------
  u_ports : test_bottom_axis
    port map (
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
      m01_axis_test_out_tlast   => m01_axis_test_out_tlast,
      ports_in  => ports_in,
      ports_out => ports_out
    );

  --------------------------------------------------------------------------------
  -- User Core
  --------------------------------------------------------------------------------
  u_core : test_bottom_core
    port map (
      props_control => props_control,
      props_status  => props_status,
      ports_in      => ports_in,
      ports_out     => ports_out
    );

end struct;