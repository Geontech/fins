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
use work.test_top_pkg.all;

-- Entity
entity test_top is
  port (
    -- AXI-Stream Bus for Ports
    s_axis_myinput_aclk         : in  std_logic;
    s_axis_myinput_aresetn      : in  std_logic;
    s_axis_myinput_tvalid       : in  std_logic;
    s_axis_myinput_tlast        : in  std_logic;
    s_axis_myinput_tdata        : in  std_logic_vector(PORTS_WIDTH-1 downto 0);
    m_axis_myoutput_aclk        : in  std_logic;
    m_axis_myoutput_aresetn     : in  std_logic;
    m_axis_myoutput_tvalid      : out std_logic;
    m_axis_myoutput_tlast       : out std_logic;
    m_axis_myoutput_tdata       : out std_logic_vector(PORTS_WIDTH-1 downto 0);
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
    -- test_top Properties Interface
    S_AXI_ACLK                  : in  std_logic;
    S_AXI_ARESETN               : in  std_logic;
    S_AXI_AWADDR                : in  std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
    S_AXI_AWPROT                : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID               : in  std_logic;
    S_AXI_AWREADY               : out std_logic;
    S_AXI_WDATA                 : in  std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB                 : in  std_logic_vector((PROPS_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID                : in  std_logic;
    S_AXI_WREADY                : out std_logic;
    S_AXI_BRESP                 : out std_logic_vector(1 downto 0);
    S_AXI_BVALID                : out std_logic;
    S_AXI_BREADY                : in  std_logic;
    S_AXI_ARADDR                : in  std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
    S_AXI_ARPROT                : in  std_logic_vector(2 downto 0);
    S_AXI_ARVALID               : in  std_logic;
    S_AXI_ARREADY               : out std_logic;
    S_AXI_RDATA                 : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP                 : out std_logic_vector(1 downto 0);
    S_AXI_RVALID                : out std_logic;
    S_AXI_RREADY                : in  std_logic;
    -- test_middle Properties Interface
    S_AXI_TEST_MIDDLE_ACLK      : in  std_logic;
    S_AXI_TEST_MIDDLE_ARESETN   : in  std_logic;
    S_AXI_TEST_MIDDLE_AWADDR    : in  std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
    S_AXI_TEST_MIDDLE_AWPROT    : in  std_logic_vector(2 downto 0);
    S_AXI_TEST_MIDDLE_AWVALID   : in  std_logic;
    S_AXI_TEST_MIDDLE_AWREADY   : out std_logic;
    S_AXI_TEST_MIDDLE_WDATA     : in  std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
    S_AXI_TEST_MIDDLE_WSTRB     : in  std_logic_vector((PROPS_DATA_WIDTH/8)-1 downto 0);
    S_AXI_TEST_MIDDLE_WVALID    : in  std_logic;
    S_AXI_TEST_MIDDLE_WREADY    : out std_logic;
    S_AXI_TEST_MIDDLE_BRESP     : out std_logic_vector(1 downto 0);
    S_AXI_TEST_MIDDLE_BVALID    : out std_logic;
    S_AXI_TEST_MIDDLE_BREADY    : in  std_logic;
    S_AXI_TEST_MIDDLE_ARADDR    : in  std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
    S_AXI_TEST_MIDDLE_ARPROT    : in  std_logic_vector(2 downto 0);
    S_AXI_TEST_MIDDLE_ARVALID   : in  std_logic;
    S_AXI_TEST_MIDDLE_ARREADY   : out std_logic;
    S_AXI_TEST_MIDDLE_RDATA     : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
    S_AXI_TEST_MIDDLE_RRESP     : out std_logic_vector(1 downto 0);
    S_AXI_TEST_MIDDLE_RVALID    : out std_logic;
    S_AXI_TEST_MIDDLE_RREADY    : in  std_logic;
    -- test_bottom Properties Interface
    S_AXI_TEST_BOTTOM_ACLK      : in  std_logic;
    S_AXI_TEST_BOTTOM_ARESETN   : in  std_logic;
    S_AXI_TEST_BOTTOM_AWADDR    : in  std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
    S_AXI_TEST_BOTTOM_AWPROT    : in  std_logic_vector(2 downto 0);
    S_AXI_TEST_BOTTOM_AWVALID   : in  std_logic;
    S_AXI_TEST_BOTTOM_AWREADY   : out std_logic;
    S_AXI_TEST_BOTTOM_WDATA     : in  std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
    S_AXI_TEST_BOTTOM_WSTRB     : in  std_logic_vector((PROPS_DATA_WIDTH/8)-1 downto 0);
    S_AXI_TEST_BOTTOM_WVALID    : in  std_logic;
    S_AXI_TEST_BOTTOM_WREADY    : out std_logic;
    S_AXI_TEST_BOTTOM_BRESP     : out std_logic_vector(1 downto 0);
    S_AXI_TEST_BOTTOM_BVALID    : out std_logic;
    S_AXI_TEST_BOTTOM_BREADY    : in  std_logic;
    S_AXI_TEST_BOTTOM_ARADDR    : in  std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
    S_AXI_TEST_BOTTOM_ARPROT    : in  std_logic_vector(2 downto 0);
    S_AXI_TEST_BOTTOM_ARVALID   : in  std_logic;
    S_AXI_TEST_BOTTOM_ARREADY   : out std_logic;
    S_AXI_TEST_BOTTOM_RDATA     : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
    S_AXI_TEST_BOTTOM_RRESP     : out std_logic_vector(1 downto 0);
    S_AXI_TEST_BOTTOM_RVALID    : out std_logic;
    S_AXI_TEST_BOTTOM_RREADY    : in  std_logic
  );
end entity test_top;

-- Architecture
architecture mixed of test_top is

  --------------------------------------------------------------------------------
  -- Constants
  --------------------------------------------------------------------------------
  constant TEST_RAM_ADDR_WIDTH : natural := integer(ceil(log2(real(TEST_RAM_DEPTH))));

  --------------------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------------------
  -- Autogenerated FINS HDL
  component test_top_axilite is
    generic (
      G_AXI_BYTE_INDEXED : boolean := True;
      G_AXI_ADDR_WIDTH   : natural := PROPS_ADDR_WIDTH;
      G_AXI_DATA_WIDTH   : natural := PROPS_DATA_WIDTH
    );
    port (
      -- AXI4-Lite Bus
      S_AXI_ACLK     : in  std_logic;
      S_AXI_ARESETN  : in  std_logic;
      S_AXI_AWADDR   : in  std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWPROT   : in  std_logic_vector(2 downto 0);
      S_AXI_AWVALID  : in  std_logic;
      S_AXI_AWREADY  : out std_logic;
      S_AXI_WDATA    : in  std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB    : in  std_logic_vector((G_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID   : in  std_logic;
      S_AXI_WREADY   : out std_logic;
      S_AXI_BRESP    : out std_logic_vector(1 downto 0);
      S_AXI_BVALID   : out std_logic;
      S_AXI_BREADY   : in  std_logic;
      S_AXI_ARADDR   : in  std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARPROT   : in  std_logic_vector(2 downto 0);
      S_AXI_ARVALID  : in  std_logic;
      S_AXI_ARREADY  : out std_logic;
      S_AXI_RDATA    : out std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP    : out std_logic_vector(1 downto 0);
      S_AXI_RVALID   : out std_logic;
      S_AXI_RREADY   : in  std_logic;
      props_control  : out t_test_top_props_control;
      props_status   : in  t_test_top_props_status
    );
  end component;

  -- Auto-generated AXI4-Stream FINS Ports interface
  component test_top_axis is
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
      ports_in  : out t_test_top_ports_in;
      ports_out : in  t_test_top_ports_out
    );
  end component;

  -- Xilinx IP created by external_property_fifo.tcl script
  component xilinx_external_property_fifo
    port (
      clk   : in  std_logic;
      srst  : in  std_logic;
      din   : in  std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      wr_en : in  std_logic;
      rd_en : in  std_logic;
      dout  : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      full  : out std_logic;
      empty : out std_logic
    );
  end component;

  -- Xilinx IP created by memmap_property_ram.tcl script
  component xilinx_memmap_property_ram
    port (
      clka  : in std_logic;
      ena   : in std_logic;
      wea   : in std_logic_vector(0 downto 0);
      addra : in std_logic_vector(TEST_RAM_ADDR_WIDTH-1 downto 0);
      dina  : in std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      clkb  : in std_logic;
      enb   : in std_logic;
      addrb : in std_logic_vector(TEST_RAM_ADDR_WIDTH-1 downto 0);
      doutb : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0)
    );
  end component;

  -- Intel IP created by external_property_fifo.tcl script
  component intel_external_property_fifo is
    port (
      data  : in  std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      wrreq : in  std_logic;
      rdreq : in  std_logic;
      clock : in  std_logic;
      q     : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      full  : out std_logic;
      empty : out std_logic
    );
  end component;

  -- Intel IP created by memmap_property_ram.tcl script
  component intel_memmap_property_ram is
    port (
      data      : in  std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      q         : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      wraddress : in  std_logic_vector(TEST_RAM_ADDR_WIDTH-1 downto 0);
      rdaddress : in  std_logic_vector(TEST_RAM_ADDR_WIDTH-1 downto 0);
      wren      : in  std_logic;
      clock     : in  std_logic
    );
  end component;

  -- Sub-ip
  component test_middle_0 is
    port (
      -- Sub-ip Software Configuration Bus
      s_swconfig_test_bottom_clk       : in  std_logic;
      s_swconfig_test_bottom_reset     : in  std_logic;
      s_swconfig_test_bottom_address   : in  std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
      s_swconfig_test_bottom_wr_enable : in  std_logic;
      s_swconfig_test_bottom_wr_data   : in  std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      s_swconfig_test_bottom_rd_enable : in  std_logic;
      s_swconfig_test_bottom_rd_valid  : out std_logic;
      s_swconfig_test_bottom_rd_data   : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      -- AXI4-Lite Properties Bus
      S_AXI_ACLK    : in  std_logic;
      S_AXI_ARESETN : in  std_logic;
      S_AXI_AWADDR  : in  std_logic_vector(16-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_AWVALID : in  std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA   : in  std_logic_vector(32-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_vector((32/8)-1 downto 0);
      S_AXI_WVALID  : in  std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in  std_logic;
      S_AXI_ARADDR  : in  std_logic_vector(16-1 downto 0);
      S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_ARVALID : in  std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(32-1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in  std_logic;
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
  end component;

  -- HDL Module
  component axilite_to_swconfig is
    generic (
      G_AXI_DATA_WIDTH : integer := 32;
      G_AXI_ADDR_WIDTH : integer := 16
    );
    port (
      -- AXI4-Lite Bus
      S_AXI_ACLK           : in  std_logic;
      S_AXI_ARESETN        : in  std_logic;
      S_AXI_AWADDR         : in  std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWPROT         : in  std_logic_vector(2 downto 0);
      S_AXI_AWVALID        : in  std_logic;
      S_AXI_AWREADY        : out std_logic;
      S_AXI_WDATA          : in  std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB          : in  std_logic_vector((G_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID         : in  std_logic;
      S_AXI_WREADY         : out std_logic;
      S_AXI_BRESP          : out std_logic_vector(1 downto 0);
      S_AXI_BVALID         : out std_logic;
      S_AXI_BREADY         : in  std_logic;
      S_AXI_ARADDR         : in  std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARPROT         : in  std_logic_vector(2 downto 0);
      S_AXI_ARVALID        : in  std_logic;
      S_AXI_ARREADY        : out std_logic;
      S_AXI_RDATA          : out std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP          : out std_logic_vector(1 downto 0);
      S_AXI_RVALID         : out std_logic;
      S_AXI_RREADY         : in  std_logic;
      -- Software Configuration Bus
      m_swconfig_clk       : out std_logic;
      m_swconfig_reset     : out std_logic;
      m_swconfig_address   : out std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
      m_swconfig_wr_enable : out std_logic;
      m_swconfig_wr_data   : out std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
      m_swconfig_rd_enable : out std_logic;
      m_swconfig_rd_valid  : in  std_logic;
      m_swconfig_rd_data   : in  std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0)
    );
  end component;

  --------------------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------------------
  -- FINS Ports and Properties Records
  signal props_control                : t_test_top_props_control;
  signal props_status                 : t_test_top_props_status;
  signal ports_in                     : t_test_top_ports_in;
  signal ports_out                    : t_test_top_ports_out;

  -- Internal Signals
  signal external_property_register   : std_logic_vector(props_control.test_prop_write_only_external.wr_data'length-1 downto 0);
  signal memmap_property_ram_wr_en    : std_logic_vector(0 downto 0);
  signal memmap_property_ram_rd_en_q  : std_logic;
  signal memmap_property_ram_rd_en_qq : std_logic;
  signal memmap_property_register     : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal external_property_fifo_rd_en : std_logic;
  signal myinput_valid                : std_logic;
  signal myinput_last                 : std_logic;
  signal myinput_data                 : unsigned(PORTS_WIDTH-1 downto 0);
  signal myinput_valid_q              : std_logic;
  signal myinput_last_q               : std_logic;
  signal myinput_data_q               : unsigned(PORTS_WIDTH-1 downto 0);
  signal myoutput_valid               : std_logic;
  signal myoutput_last                : std_logic;
  signal myoutput_data                : std_logic_vector(PORTS_WIDTH-1 downto 0);
  signal test_out00_tready            : std_logic;
  signal test_out00_tdata             : std_logic_vector(160-1 downto 0);
  signal test_out00_tuser             : std_logic_vector(128-1 downto 0);
  signal test_out00_tvalid            : std_logic;
  signal test_out00_tlast             : std_logic;
  signal test_out01_tready            : std_logic;
  signal test_out01_tdata             : std_logic_vector(160-1 downto 0);
  signal test_out01_tuser             : std_logic_vector(128-1 downto 0);
  signal test_out01_tvalid            : std_logic;
  signal test_out01_tlast             : std_logic;
  signal swconfig_clk                 : std_logic;
  signal swconfig_reset               : std_logic;
  signal swconfig_address             : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal swconfig_wr_enable           : std_logic;
  signal swconfig_wr_data             : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal swconfig_rd_enable           : std_logic;
  signal swconfig_rd_valid            : std_logic;
  signal swconfig_rd_data             : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);

begin

  --------------------------------------------------------------------------------
  -- Ports
  --------------------------------------------------------------------------------
  u_ports : test_top_axis
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
  -- Data Processing
  --------------------------------------------------------------------------------
  -- Synchronous process for data processsing
  s_data_processing : process (ports_in.myinput.clk)
  begin
    if (rising_edge(ports_in.myinput.clk)) then
      -- Data pipelines
      myinput_data <= ports_in.myinput.data;
      myinput_data_q <= resize(
        unsigned(myinput_data) * to_unsigned(TEST_PARAM_INTEGER, myinput_data'length),
        myinput_data'length
      );
      -- Control pipelines
      if (ports_in.myinput.resetn = '0') then
        myinput_valid   <= '0';
        myinput_last    <= '0';
        myinput_valid_q <= '0';
        myinput_last_q  <= '0';
      else
        myinput_valid   <= ports_in.myinput.valid;
        myinput_last    <= ports_in.myinput.last;
        myinput_valid_q <= myinput_valid;
        myinput_last_q  <= myinput_last;
      end if;
    end if;
  end process s_data_processing;

  -- Instantiate sub-ip
  u_test_middle : test_middle_0
    port map (
      s_swconfig_test_bottom_clk       => swconfig_clk,
      s_swconfig_test_bottom_reset     => swconfig_reset,
      s_swconfig_test_bottom_address   => swconfig_address,
      s_swconfig_test_bottom_wr_enable => swconfig_wr_enable,
      s_swconfig_test_bottom_wr_data   => swconfig_wr_data,
      s_swconfig_test_bottom_rd_enable => swconfig_rd_enable,
      s_swconfig_test_bottom_rd_valid  => swconfig_rd_valid,
      s_swconfig_test_bottom_rd_data   => swconfig_rd_data,
      S_AXI_ACLK                       => S_AXI_TEST_MIDDLE_ACLK,
      S_AXI_ARESETN                    => S_AXI_TEST_MIDDLE_ARESETN,
      S_AXI_AWADDR                     => S_AXI_TEST_MIDDLE_AWADDR,
      S_AXI_AWPROT                     => S_AXI_TEST_MIDDLE_AWPROT,
      S_AXI_AWVALID                    => S_AXI_TEST_MIDDLE_AWVALID,
      S_AXI_AWREADY                    => S_AXI_TEST_MIDDLE_AWREADY,
      S_AXI_WDATA                      => S_AXI_TEST_MIDDLE_WDATA,
      S_AXI_WSTRB                      => S_AXI_TEST_MIDDLE_WSTRB,
      S_AXI_WVALID                     => S_AXI_TEST_MIDDLE_WVALID,
      S_AXI_WREADY                     => S_AXI_TEST_MIDDLE_WREADY,
      S_AXI_BRESP                      => S_AXI_TEST_MIDDLE_BRESP,
      S_AXI_BVALID                     => S_AXI_TEST_MIDDLE_BVALID,
      S_AXI_BREADY                     => S_AXI_TEST_MIDDLE_BREADY,
      S_AXI_ARADDR                     => S_AXI_TEST_MIDDLE_ARADDR,
      S_AXI_ARPROT                     => S_AXI_TEST_MIDDLE_ARPROT,
      S_AXI_ARVALID                    => S_AXI_TEST_MIDDLE_ARVALID,
      S_AXI_ARREADY                    => S_AXI_TEST_MIDDLE_ARREADY,
      S_AXI_RDATA                      => S_AXI_TEST_MIDDLE_RDATA,
      S_AXI_RRESP                      => S_AXI_TEST_MIDDLE_RRESP,
      S_AXI_RVALID                     => S_AXI_TEST_MIDDLE_RVALID,
      S_AXI_RREADY                     => S_AXI_TEST_MIDDLE_RREADY,
      s_axis_myinput_aclk              => ports_in.myinput.clk,
      s_axis_myinput_aresetn           => ports_in.myinput.resetn,
      s_axis_myinput_tvalid            => myinput_valid_q,
      s_axis_myinput_tlast             => myinput_last_q,
      s_axis_myinput_tdata             => std_logic_vector(myinput_data_q),
      m_axis_myoutput_aclk             => ports_in.myoutput.clk,
      m_axis_myoutput_aresetn          => ports_in.myoutput.resetn,
      m_axis_myoutput_tvalid           => myoutput_valid,
      m_axis_myoutput_tlast            => myoutput_last,
      m_axis_myoutput_tdata            => myoutput_data,
      s00_axis_test_in_aclk            => ports_in.test_in(0).clk,
      s00_axis_test_in_aresetn         => ports_in.test_in(0).resetn,
      s00_axis_test_in_tready          => ports_out.test_in(0).ready,
      s00_axis_test_in_tdata           => f_serialize_test_top_test_in_data(ports_in.test_in(0).data),
      s00_axis_test_in_tuser           => f_serialize_test_top_test_in_metadata(ports_in.test_in(0).metadata),
      s00_axis_test_in_tvalid          => ports_in.test_in(0).valid,
      s00_axis_test_in_tlast           => ports_in.test_in(0).last,
      s01_axis_test_in_aclk            => ports_in.test_in(1).clk,
      s01_axis_test_in_aresetn         => ports_in.test_in(1).resetn,
      s01_axis_test_in_tready          => ports_out.test_in(1).ready,
      s01_axis_test_in_tdata           => f_serialize_test_top_test_in_data(ports_in.test_in(1).data),
      s01_axis_test_in_tuser           => f_serialize_test_top_test_in_metadata(ports_in.test_in(1).metadata),
      s01_axis_test_in_tvalid          => ports_in.test_in(1).valid,
      s01_axis_test_in_tlast           => ports_in.test_in(1).last,
      m00_axis_test_out_aclk           => ports_in.test_out(0).clk,
      m00_axis_test_out_aresetn        => ports_in.test_out(0).resetn,
      m00_axis_test_out_tready         => test_out00_tready,
      m00_axis_test_out_tdata          => test_out00_tdata,
      m00_axis_test_out_tuser          => test_out00_tuser,
      m00_axis_test_out_tvalid         => test_out00_tvalid,
      m00_axis_test_out_tlast          => test_out00_tlast,
      m01_axis_test_out_aclk           => ports_in.test_out(1).clk,
      m01_axis_test_out_aresetn        => ports_in.test_out(1).resetn,
      m01_axis_test_out_tready         => test_out01_tready,
      m01_axis_test_out_tdata          => test_out01_tdata,
      m01_axis_test_out_tuser          => test_out01_tuser,
      m01_axis_test_out_tvalid         => test_out01_tvalid,
      m01_axis_test_out_tlast          => test_out01_tlast
    );

  -- Assign output ports
  ports_out.myoutput.valid       <= myoutput_valid;
  ports_out.myoutput.last        <= myoutput_last;
  ports_out.myoutput.data        <= f_unserialize_test_top_myoutput_data(myoutput_data);
  ports_out.test_out(0).data     <= f_unserialize_test_top_test_out_data(test_out00_tdata);
  ports_out.test_out(0).metadata <= f_unserialize_test_top_test_out_metadata(test_out00_tuser);
  ports_out.test_out(0).valid    <= test_out00_tvalid;
  ports_out.test_out(0).last     <= test_out00_tlast;
  test_out00_tready              <= ports_in.test_out(0).ready;
  ports_out.test_out(1).data     <= f_unserialize_test_top_test_out_data(test_out01_tdata);
  ports_out.test_out(1).metadata <= f_unserialize_test_top_test_out_metadata(test_out01_tuser);
  ports_out.test_out(1).valid    <= test_out01_tvalid;
  ports_out.test_out(1).last     <= test_out01_tlast;
  test_out01_tready              <= ports_in.test_out(1).ready;

  --------------------------------------------------------------------------------
  -- Properties
  --------------------------------------------------------------------------------
  -- Instantiate the auto-generated AXI4-Lite module
  u_properties : test_top_axilite
    port map (
      S_AXI_ACLK    => S_AXI_ACLK    ,
      S_AXI_ARESETN => S_AXI_ARESETN ,
      S_AXI_AWADDR  => S_AXI_AWADDR  ,
      S_AXI_AWPROT  => S_AXI_AWPROT  ,
      S_AXI_AWVALID => S_AXI_AWVALID ,
      S_AXI_AWREADY => S_AXI_AWREADY ,
      S_AXI_WDATA   => S_AXI_WDATA   ,
      S_AXI_WSTRB   => S_AXI_WSTRB   ,
      S_AXI_WVALID  => S_AXI_WVALID  ,
      S_AXI_WREADY  => S_AXI_WREADY  ,
      S_AXI_BRESP   => S_AXI_BRESP   ,
      S_AXI_BVALID  => S_AXI_BVALID  ,
      S_AXI_BREADY  => S_AXI_BREADY  ,
      S_AXI_ARADDR  => S_AXI_ARADDR  ,
      S_AXI_ARPROT  => S_AXI_ARPROT  ,
      S_AXI_ARVALID => S_AXI_ARVALID ,
      S_AXI_ARREADY => S_AXI_ARREADY ,
      S_AXI_RDATA   => S_AXI_RDATA   ,
      S_AXI_RRESP   => S_AXI_RRESP   ,
      S_AXI_RVALID  => S_AXI_RVALID  ,
      S_AXI_RREADY  => S_AXI_RREADY  ,
      props_control => props_control ,
      props_status  => props_status  
    );

  -- Convert from AXI4-Lite to Software Configuration for the test_bottom IP
  u_axilite_to_swconfig : axilite_to_swconfig
    generic map (
      G_AXI_DATA_WIDTH => PROPS_DATA_WIDTH,
      G_AXI_ADDR_WIDTH => PROPS_ADDR_WIDTH
    )
    port map (
      S_AXI_ACLK           => S_AXI_TEST_BOTTOM_ACLK    ,
      S_AXI_ARESETN        => S_AXI_TEST_BOTTOM_ARESETN ,
      S_AXI_AWADDR         => S_AXI_TEST_BOTTOM_AWADDR  ,
      S_AXI_AWPROT         => S_AXI_TEST_BOTTOM_AWPROT  ,
      S_AXI_AWVALID        => S_AXI_TEST_BOTTOM_AWVALID ,
      S_AXI_AWREADY        => S_AXI_TEST_BOTTOM_AWREADY ,
      S_AXI_WDATA          => S_AXI_TEST_BOTTOM_WDATA   ,
      S_AXI_WSTRB          => S_AXI_TEST_BOTTOM_WSTRB   ,
      S_AXI_WVALID         => S_AXI_TEST_BOTTOM_WVALID  ,
      S_AXI_WREADY         => S_AXI_TEST_BOTTOM_WREADY  ,
      S_AXI_BRESP          => S_AXI_TEST_BOTTOM_BRESP   ,
      S_AXI_BVALID         => S_AXI_TEST_BOTTOM_BVALID  ,
      S_AXI_BREADY         => S_AXI_TEST_BOTTOM_BREADY  ,
      S_AXI_ARADDR         => S_AXI_TEST_BOTTOM_ARADDR  ,
      S_AXI_ARPROT         => S_AXI_TEST_BOTTOM_ARPROT  ,
      S_AXI_ARVALID        => S_AXI_TEST_BOTTOM_ARVALID ,
      S_AXI_ARREADY        => S_AXI_TEST_BOTTOM_ARREADY ,
      S_AXI_RDATA          => S_AXI_TEST_BOTTOM_RDATA   ,
      S_AXI_RRESP          => S_AXI_TEST_BOTTOM_RRESP   ,
      S_AXI_RVALID         => S_AXI_TEST_BOTTOM_RVALID  ,
      S_AXI_RREADY         => S_AXI_TEST_BOTTOM_RREADY  ,
      m_swconfig_clk       => swconfig_clk         ,
      m_swconfig_reset     => swconfig_reset       ,
      m_swconfig_address   => swconfig_address     ,
      m_swconfig_wr_enable => swconfig_wr_enable   ,
      m_swconfig_wr_data   => swconfig_wr_data     ,
      m_swconfig_rd_enable => swconfig_rd_enable   ,
      m_swconfig_rd_valid  => swconfig_rd_valid    ,
      m_swconfig_rd_data   => swconfig_rd_data     
    );

  --------------------------------------------------------------------------------
  -- Testing elements for "read-write-external"
  --------------------------------------------------------------------------------
  -- FWFT FIFO instantitation for test
  u_gen_xilinx_external_property_fifo : if (FINS_BACKEND = "vivado") generate
    u_external_property_fifo : xilinx_external_property_fifo
      port map (
        clk   => props_control.clk,
        srst  => '0',
        din   => props_control.test_prop_read_write_external.wr_data,
        wr_en => props_control.test_prop_read_write_external.wr_en,
        rd_en => external_property_fifo_rd_en,
        dout  => props_status.test_prop_read_write_external.rd_data,
        full  => open,
        empty => open
      );
  end generate u_gen_xilinx_external_property_fifo;
  u_gen_intel_external_property_fifo : if (FINS_BACKEND = "quartus") generate
    u_external_property_fifo : intel_external_property_fifo
      port map (
        clock   => props_control.clk,
        data    => props_control.test_prop_read_write_external.wr_data,
        wrreq   => props_control.test_prop_read_write_external.wr_en,
        rdreq   => external_property_fifo_rd_en,
        q       => props_status.test_prop_read_write_external.rd_data,
        full    => open,
        empty   => open
      );
  end generate u_gen_intel_external_property_fifo;

  -- Synchronous process to delay the fifo read enable one clock just due to this FIFO's timing
  s_external_property_fifo : process(props_control.clk)
  begin
    if (rising_edge(props_control.clk)) then
      if (props_control.resetn = '0') then
        external_property_fifo_rd_en <= '0';
      else
        external_property_fifo_rd_en <= props_control.test_prop_read_write_external.rd_en;
      end if;
    end if;
  end process s_external_property_fifo;

  -- Since this is a FWFT FIFO, the read data is valid as soon as the FIFO is read
  props_status.test_prop_read_write_external.rd_valid <= props_control.test_prop_read_write_external.rd_en;

  --------------------------------------------------------------------------------
  -- Testing elements for "write-only-external" and "read-only-external"
  --------------------------------------------------------------------------------
  -- Synchronous process for external property write
  s_external_property_register : process(props_control.clk)
  begin
    if (rising_edge(props_control.clk)) then
      if (props_control.resetn = '0') then
        external_property_register <= (others => '0');
      else
        if (props_control.test_prop_write_only_external.wr_en = '1') then
          external_property_register <= props_control.test_prop_write_only_external.wr_data;
        end if;
      end if;
    end if;
  end process s_external_property_register;

  -- Assign read signals to register written above
  props_status.test_prop_read_only_external.rd_valid <= props_control.test_prop_read_only_external.rd_en;
  props_status.test_prop_read_only_external.rd_data  <= external_property_register;

  --------------------------------------------------------------------------------
  -- Testing elements for "read-write-memmap"
  --------------------------------------------------------------------------------
  -- Simple Dual Port RAM for test
  u_gen_xilinx_memmap_property_ram : if (FINS_BACKEND = "vivado") generate
    u_memmap_property_ram : xilinx_memmap_property_ram
      port map (
        clka  => props_control.clk,
        ena   => '1',
        wea   => memmap_property_ram_wr_en,
        addra => props_control.test_prop_read_write_memmap.wr_addr,
        dina  => props_control.test_prop_read_write_memmap.wr_data,
        clkb  => props_control.clk,
        enb   => '1',
        addrb => props_control.test_prop_read_write_memmap.rd_addr,
        doutb => props_status.test_prop_read_write_memmap.rd_data
      );
  end generate u_gen_xilinx_memmap_property_ram;
  u_gen_intel_memmap_property_ram : if (FINS_BACKEND = "quartus") generate
    u_memmap_property_ram : intel_memmap_property_ram
      port map (
        clock     => props_control.clk,
        wren      => props_control.test_prop_read_write_memmap.wr_en,
        wraddress => props_control.test_prop_read_write_memmap.wr_addr,
        data      => props_control.test_prop_read_write_memmap.wr_data,
        rdaddress => props_control.test_prop_read_write_memmap.rd_addr,
        q         => props_status.test_prop_read_write_memmap.rd_data
      );
  end generate u_gen_intel_memmap_property_ram;

  -- Remap the write enable to a std_logic_vector of width 1
  memmap_property_ram_wr_en(0) <= props_control.test_prop_read_write_memmap.wr_en;

  -- Synchronous process to delay the read enable 2 clocks
  s_memmap_property_ram : process (props_control.clk)
  begin
    if (rising_edge(props_control.clk)) then
      if (props_control.resetn = '0') then
        memmap_property_ram_rd_en_q  <= '0';
        memmap_property_ram_rd_en_qq <= '0';
      else
        memmap_property_ram_rd_en_q  <= props_control.test_prop_read_write_memmap.rd_en;
        memmap_property_ram_rd_en_qq <= memmap_property_ram_rd_en_q;
      end if;
    end if;
  end process s_memmap_property_ram;

  -- Assign the read valid to the delayed copy of the read enable due to the latency of the
  -- Simple Dual Port RAM
  props_status.test_prop_read_write_memmap.rd_valid <= memmap_property_ram_rd_en_qq;

  --------------------------------------------------------------------------------
  -- Testing elements for "write-only-memmap" and "read-only-memmap"
  --------------------------------------------------------------------------------
  -- Note: Since this property has a length of 1, the addresses are unused and
  --       the behavior mirrors an "external" property. This use case is unusual
  --       but is tested for completeness.

  -- Synchronous process for memmap property write
  s_memmap_property_register : process(props_control.clk)
  begin
    if (rising_edge(props_control.clk)) then
      if (props_control.resetn = '0') then
        memmap_property_register <= (others => '0');
      else
        if (props_control.test_prop_write_only_memmap.wr_en = '1') then
          memmap_property_register <= props_control.test_prop_write_only_memmap.wr_data;
        end if;
      end if;
    end if;
  end process s_memmap_property_register;

  -- Assign read signals to register written above
  props_status.test_prop_read_only_memmap.rd_valid <= props_control.test_prop_read_only_memmap.rd_en;
  props_status.test_prop_read_only_memmap.rd_data  <= memmap_property_register;

  --------------------------------------------------------------------------------
  -- Testing elements for "read-only-data"
  --------------------------------------------------------------------------------
  props_status.test_prop_read_only_data(0).rd_data <= std_logic_vector(to_unsigned(0, PROPS_DATA_WIDTH));
  props_status.test_prop_read_only_data(1).rd_data <= std_logic_vector(to_unsigned(1, PROPS_DATA_WIDTH));
  props_status.test_prop_read_only_data(2).rd_data <= std_logic_vector(to_unsigned(2, PROPS_DATA_WIDTH));
  props_status.test_prop_read_only_data(3).rd_data <= std_logic_vector(to_unsigned(3, PROPS_DATA_WIDTH));

end mixed;
