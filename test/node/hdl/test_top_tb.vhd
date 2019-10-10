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
use work.test_top_pkg.all;
use work.test_top_axilite_verify.all;
use work.test_middle_axilite_verify.all;
use work.test_bottom_axilite_verify.all;

-- Entity
entity test_top_tb is
end entity test_top_tb;

-- Architecture
architecture rtl of test_top_tb is

  -- Device Under Test interface
  signal s_axis_myinput_aclk          : std_logic;
  signal s_axis_myinput_aresetn       : std_logic;
  signal s_axis_myinput_tvalid        : std_logic;
  signal s_axis_myinput_tlast         : std_logic;
  signal s_axis_myinput_tdata         : std_logic_vector(PORTS_WIDTH-1 downto 0);
  signal m_axis_myoutput_aclk         : std_logic;
  signal m_axis_myoutput_aresetn      : std_logic;
  signal m_axis_myoutput_tvalid       : std_logic;
  signal m_axis_myoutput_tlast        : std_logic;
  signal m_axis_myoutput_tdata        : std_logic_vector(PORTS_WIDTH-1 downto 0);
  signal s_axis_test_in_aclk          : std_logic;
  signal s_axis_test_in_aresetn       : std_logic;
  signal s_axis_test_in_tready        : std_logic;
  signal s_axis_test_in_tdata         : std_logic_vector(160-1 downto 0);
  signal s_axis_test_in_tuser         : std_logic_vector(128-1 downto 0);
  signal s_axis_test_in_tvalid        : std_logic;
  signal s_axis_test_in_tlast         : std_logic;
  signal m_axis_test_out_aclk         : std_logic;
  signal m_axis_test_out_aresetn      : std_logic;
  signal m_axis_test_out_tready       : std_logic;
  signal m_axis_test_out_tdata        : std_logic_vector(160-1 downto 0);
  signal m_axis_test_out_tuser        : std_logic_vector(128-1 downto 0);
  signal m_axis_test_out_tvalid       : std_logic;
  signal m_axis_test_out_tlast        : std_logic;
  signal S_AXI_ACLK                   : std_logic;
  signal S_AXI_ARESETN                : std_logic;
  signal S_AXI_AWADDR                 : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal S_AXI_AWPROT                 : std_logic_vector(2 downto 0);
  signal S_AXI_AWVALID                : std_logic;
  signal S_AXI_AWREADY                : std_logic;
  signal S_AXI_WDATA                  : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal S_AXI_WSTRB                  : std_logic_vector((PROPS_DATA_WIDTH/8)-1 downto 0);
  signal S_AXI_WVALID                 : std_logic;
  signal S_AXI_WREADY                 : std_logic;
  signal S_AXI_BRESP                  : std_logic_vector(1 downto 0);
  signal S_AXI_BVALID                 : std_logic;
  signal S_AXI_BREADY                 : std_logic;
  signal S_AXI_ARADDR                 : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal S_AXI_ARPROT                 : std_logic_vector(2 downto 0);
  signal S_AXI_ARVALID                : std_logic;
  signal S_AXI_ARREADY                : std_logic;
  signal S_AXI_RDATA                  : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal S_AXI_RRESP                  : std_logic_vector(1 downto 0);
  signal S_AXI_RVALID                 : std_logic;
  signal S_AXI_RREADY                 : std_logic;
  signal S_AXI_TEST_MIDDLE_ACLK       : std_logic;
  signal S_AXI_TEST_MIDDLE_ARESETN    : std_logic;
  signal S_AXI_TEST_MIDDLE_AWADDR     : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal S_AXI_TEST_MIDDLE_AWPROT     : std_logic_vector(2 downto 0);
  signal S_AXI_TEST_MIDDLE_AWVALID    : std_logic;
  signal S_AXI_TEST_MIDDLE_AWREADY    : std_logic;
  signal S_AXI_TEST_MIDDLE_WDATA      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal S_AXI_TEST_MIDDLE_WSTRB      : std_logic_vector((PROPS_DATA_WIDTH/8)-1 downto 0);
  signal S_AXI_TEST_MIDDLE_WVALID     : std_logic;
  signal S_AXI_TEST_MIDDLE_WREADY     : std_logic;
  signal S_AXI_TEST_MIDDLE_BRESP      : std_logic_vector(1 downto 0);
  signal S_AXI_TEST_MIDDLE_BVALID     : std_logic;
  signal S_AXI_TEST_MIDDLE_BREADY     : std_logic;
  signal S_AXI_TEST_MIDDLE_ARADDR     : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal S_AXI_TEST_MIDDLE_ARPROT     : std_logic_vector(2 downto 0);
  signal S_AXI_TEST_MIDDLE_ARVALID    : std_logic;
  signal S_AXI_TEST_MIDDLE_ARREADY    : std_logic;
  signal S_AXI_TEST_MIDDLE_RDATA      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal S_AXI_TEST_MIDDLE_RRESP      : std_logic_vector(1 downto 0);
  signal S_AXI_TEST_MIDDLE_RVALID     : std_logic;
  signal S_AXI_TEST_MIDDLE_RREADY     : std_logic;
  signal S_AXI_TEST_BOTTOM_ACLK       : std_logic;
  signal S_AXI_TEST_BOTTOM_ARESETN    : std_logic;
  signal S_AXI_TEST_BOTTOM_AWADDR     : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal S_AXI_TEST_BOTTOM_AWPROT     : std_logic_vector(2 downto 0);
  signal S_AXI_TEST_BOTTOM_AWVALID    : std_logic;
  signal S_AXI_TEST_BOTTOM_AWREADY    : std_logic;
  signal S_AXI_TEST_BOTTOM_WDATA      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal S_AXI_TEST_BOTTOM_WSTRB      : std_logic_vector((PROPS_DATA_WIDTH/8)-1 downto 0);
  signal S_AXI_TEST_BOTTOM_WVALID     : std_logic;
  signal S_AXI_TEST_BOTTOM_WREADY     : std_logic;
  signal S_AXI_TEST_BOTTOM_BRESP      : std_logic_vector(1 downto 0);
  signal S_AXI_TEST_BOTTOM_BVALID     : std_logic;
  signal S_AXI_TEST_BOTTOM_BREADY     : std_logic;
  signal S_AXI_TEST_BOTTOM_ARADDR     : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal S_AXI_TEST_BOTTOM_ARPROT     : std_logic_vector(2 downto 0);
  signal S_AXI_TEST_BOTTOM_ARVALID    : std_logic;
  signal S_AXI_TEST_BOTTOM_ARREADY    : std_logic;
  signal S_AXI_TEST_BOTTOM_RDATA      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal S_AXI_TEST_BOTTOM_RRESP      : std_logic_vector(1 downto 0);
  signal S_AXI_TEST_BOTTOM_RVALID     : std_logic;
  signal S_AXI_TEST_BOTTOM_RREADY     : std_logic;

  -- Testbench
  signal simulation_done       : boolean := false;
  constant AXI_CLK_PERIOD      : time := 5 ns;
  signal s_axis_myinput_enable : std_logic := '0';
  signal s_axis_test_in_enable : std_logic := '0';

  -- Function
  function f_get_sim_file_path return string is
  begin
    if (FINS_BACKEND = "vivado") then
      return "../../../../../../sim_data/";
    else
      return "../../../sim_data/";
    end if;
  end function f_get_sim_file_path;

begin

  -- Device Under Test
  u_dut : entity work.test_top
    port map (
      s_axis_myinput_aclk          => s_axis_myinput_aclk          ,
      s_axis_myinput_aresetn       => s_axis_myinput_aresetn       ,
      s_axis_myinput_tvalid        => s_axis_myinput_tvalid        ,
      s_axis_myinput_tlast         => s_axis_myinput_tlast         ,
      s_axis_myinput_tdata         => s_axis_myinput_tdata         ,
      m_axis_myoutput_aclk         => m_axis_myoutput_aclk         ,
      m_axis_myoutput_aresetn      => m_axis_myoutput_aresetn      ,
      m_axis_myoutput_tvalid       => m_axis_myoutput_tvalid       ,
      m_axis_myoutput_tlast        => m_axis_myoutput_tlast        ,
      m_axis_myoutput_tdata        => m_axis_myoutput_tdata        ,
      s_axis_test_in_aclk          => s_axis_test_in_aclk          ,
      s_axis_test_in_aresetn       => s_axis_test_in_aresetn       ,
      s_axis_test_in_tready        => s_axis_test_in_tready        ,
      s_axis_test_in_tdata         => s_axis_test_in_tdata         ,
      s_axis_test_in_tuser         => s_axis_test_in_tuser         ,
      s_axis_test_in_tvalid        => s_axis_test_in_tvalid        ,
      s_axis_test_in_tlast         => s_axis_test_in_tlast         ,
      m_axis_test_out_aclk         => m_axis_test_out_aclk         ,
      m_axis_test_out_aresetn      => m_axis_test_out_aresetn      ,
      m_axis_test_out_tready       => m_axis_test_out_tready       ,
      m_axis_test_out_tdata        => m_axis_test_out_tdata        ,
      m_axis_test_out_tuser        => m_axis_test_out_tuser        ,
      m_axis_test_out_tvalid       => m_axis_test_out_tvalid       ,
      m_axis_test_out_tlast        => m_axis_test_out_tlast        ,
      S_AXI_ACLK                   => S_AXI_ACLK                   ,
      S_AXI_ARESETN                => S_AXI_ARESETN                ,
      S_AXI_AWADDR                 => S_AXI_AWADDR                 ,
      S_AXI_AWPROT                 => S_AXI_AWPROT                 ,
      S_AXI_AWVALID                => S_AXI_AWVALID                ,
      S_AXI_AWREADY                => S_AXI_AWREADY                ,
      S_AXI_WDATA                  => S_AXI_WDATA                  ,
      S_AXI_WSTRB                  => S_AXI_WSTRB                  ,
      S_AXI_WVALID                 => S_AXI_WVALID                 ,
      S_AXI_WREADY                 => S_AXI_WREADY                 ,
      S_AXI_BRESP                  => S_AXI_BRESP                  ,
      S_AXI_BVALID                 => S_AXI_BVALID                 ,
      S_AXI_BREADY                 => S_AXI_BREADY                 ,
      S_AXI_ARADDR                 => S_AXI_ARADDR                 ,
      S_AXI_ARPROT                 => S_AXI_ARPROT                 ,
      S_AXI_ARVALID                => S_AXI_ARVALID                ,
      S_AXI_ARREADY                => S_AXI_ARREADY                ,
      S_AXI_RDATA                  => S_AXI_RDATA                  ,
      S_AXI_RRESP                  => S_AXI_RRESP                  ,
      S_AXI_RVALID                 => S_AXI_RVALID                 ,
      S_AXI_RREADY                 => S_AXI_RREADY                 ,
      S_AXI_TEST_MIDDLE_ACLK       => S_AXI_TEST_MIDDLE_ACLK       ,
      S_AXI_TEST_MIDDLE_ARESETN    => S_AXI_TEST_MIDDLE_ARESETN    ,
      S_AXI_TEST_MIDDLE_AWADDR     => S_AXI_TEST_MIDDLE_AWADDR     ,
      S_AXI_TEST_MIDDLE_AWPROT     => S_AXI_TEST_MIDDLE_AWPROT     ,
      S_AXI_TEST_MIDDLE_AWVALID    => S_AXI_TEST_MIDDLE_AWVALID    ,
      S_AXI_TEST_MIDDLE_AWREADY    => S_AXI_TEST_MIDDLE_AWREADY    ,
      S_AXI_TEST_MIDDLE_WDATA      => S_AXI_TEST_MIDDLE_WDATA      ,
      S_AXI_TEST_MIDDLE_WSTRB      => S_AXI_TEST_MIDDLE_WSTRB      ,
      S_AXI_TEST_MIDDLE_WVALID     => S_AXI_TEST_MIDDLE_WVALID     ,
      S_AXI_TEST_MIDDLE_WREADY     => S_AXI_TEST_MIDDLE_WREADY     ,
      S_AXI_TEST_MIDDLE_BRESP      => S_AXI_TEST_MIDDLE_BRESP      ,
      S_AXI_TEST_MIDDLE_BVALID     => S_AXI_TEST_MIDDLE_BVALID     ,
      S_AXI_TEST_MIDDLE_BREADY     => S_AXI_TEST_MIDDLE_BREADY     ,
      S_AXI_TEST_MIDDLE_ARADDR     => S_AXI_TEST_MIDDLE_ARADDR     ,
      S_AXI_TEST_MIDDLE_ARPROT     => S_AXI_TEST_MIDDLE_ARPROT     ,
      S_AXI_TEST_MIDDLE_ARVALID    => S_AXI_TEST_MIDDLE_ARVALID    ,
      S_AXI_TEST_MIDDLE_ARREADY    => S_AXI_TEST_MIDDLE_ARREADY    ,
      S_AXI_TEST_MIDDLE_RDATA      => S_AXI_TEST_MIDDLE_RDATA      ,
      S_AXI_TEST_MIDDLE_RRESP      => S_AXI_TEST_MIDDLE_RRESP      ,
      S_AXI_TEST_MIDDLE_RVALID     => S_AXI_TEST_MIDDLE_RVALID     ,
      S_AXI_TEST_MIDDLE_RREADY     => S_AXI_TEST_MIDDLE_RREADY     ,
      S_AXI_TEST_BOTTOM_ACLK       => S_AXI_TEST_BOTTOM_ACLK       ,
      S_AXI_TEST_BOTTOM_ARESETN    => S_AXI_TEST_BOTTOM_ARESETN    ,
      S_AXI_TEST_BOTTOM_AWADDR     => S_AXI_TEST_BOTTOM_AWADDR     ,
      S_AXI_TEST_BOTTOM_AWPROT     => S_AXI_TEST_BOTTOM_AWPROT     ,
      S_AXI_TEST_BOTTOM_AWVALID    => S_AXI_TEST_BOTTOM_AWVALID    ,
      S_AXI_TEST_BOTTOM_AWREADY    => S_AXI_TEST_BOTTOM_AWREADY    ,
      S_AXI_TEST_BOTTOM_WDATA      => S_AXI_TEST_BOTTOM_WDATA      ,
      S_AXI_TEST_BOTTOM_WSTRB      => S_AXI_TEST_BOTTOM_WSTRB      ,
      S_AXI_TEST_BOTTOM_WVALID     => S_AXI_TEST_BOTTOM_WVALID     ,
      S_AXI_TEST_BOTTOM_WREADY     => S_AXI_TEST_BOTTOM_WREADY     ,
      S_AXI_TEST_BOTTOM_BRESP      => S_AXI_TEST_BOTTOM_BRESP      ,
      S_AXI_TEST_BOTTOM_BVALID     => S_AXI_TEST_BOTTOM_BVALID     ,
      S_AXI_TEST_BOTTOM_BREADY     => S_AXI_TEST_BOTTOM_BREADY     ,
      S_AXI_TEST_BOTTOM_ARADDR     => S_AXI_TEST_BOTTOM_ARADDR     ,
      S_AXI_TEST_BOTTOM_ARPROT     => S_AXI_TEST_BOTTOM_ARPROT     ,
      S_AXI_TEST_BOTTOM_ARVALID    => S_AXI_TEST_BOTTOM_ARVALID    ,
      S_AXI_TEST_BOTTOM_ARREADY    => S_AXI_TEST_BOTTOM_ARREADY    ,
      S_AXI_TEST_BOTTOM_RDATA      => S_AXI_TEST_BOTTOM_RDATA      ,
      S_AXI_TEST_BOTTOM_RRESP      => S_AXI_TEST_BOTTOM_RRESP      ,
      S_AXI_TEST_BOTTOM_RVALID     => S_AXI_TEST_BOTTOM_RVALID     ,
      S_AXI_TEST_BOTTOM_RREADY     => S_AXI_TEST_BOTTOM_RREADY     
    );

  -- File input/output streams
  -- NOTE: The source/sink filepaths are relative to where the simulation is executed
  u_file_io : entity work.test_top_axis_verify
    generic map (
      G_MYINPUT_SOURCE_FILEPATH => f_get_sim_file_path & "sim_source_myinput.txt",
      G_MYOUTPUT_SINK_FILEPATH  => f_get_sim_file_path & "sim_sink_myoutput.txt",
      G_TEST_IN_SOURCE_FILEPATH => f_get_sim_file_path & "sim_source_test_in.txt",
      G_TEST_OUT_SINK_FILEPATH  => f_get_sim_file_path & "sim_sink_test_out.txt"
    )
    port map (
      simulation_done         => simulation_done        ,
      m_axis_myinput_aclk     => s_axis_myinput_aclk    ,
      m_axis_myinput_enable   => s_axis_myinput_enable  ,
      m_axis_myinput_tdata    => s_axis_myinput_tdata   ,
      m_axis_myinput_tvalid   => s_axis_myinput_tvalid  ,
      m_axis_myinput_tlast    => s_axis_myinput_tlast   ,
      s_axis_myoutput_aclk    => m_axis_myoutput_aclk   ,
      s_axis_myoutput_tdata   => m_axis_myoutput_tdata  ,
      s_axis_myoutput_tvalid  => m_axis_myoutput_tvalid ,
      s_axis_myoutput_tlast   => m_axis_myoutput_tlast  ,
      m_axis_test_in_aclk     => s_axis_test_in_aclk    ,
      m_axis_test_in_enable   => s_axis_test_in_enable  ,
      m_axis_test_in_tready   => s_axis_test_in_tready  ,
      m_axis_test_in_tdata    => s_axis_test_in_tdata   ,
      m_axis_test_in_tuser    => s_axis_test_in_tuser   ,
      m_axis_test_in_tvalid   => s_axis_test_in_tvalid  ,
      m_axis_test_in_tlast    => s_axis_test_in_tlast   ,
      s_axis_test_out_aclk    => m_axis_test_out_aclk   ,
      s_axis_test_out_tready  => m_axis_test_out_tready ,
      s_axis_test_out_tdata   => m_axis_test_out_tdata  ,
      s_axis_test_out_tuser   => m_axis_test_out_tuser  ,
      s_axis_test_out_tvalid  => m_axis_test_out_tvalid ,
      s_axis_test_out_tlast   => m_axis_test_out_tlast  
    );

  -- AXI Clock
  w_axi_clk : process
  begin
    if (simulation_done = false) then
      S_AXI_ACLK <= '0';
      wait for AXI_CLK_PERIOD/2;
      S_AXI_ACLK <= '1';
      wait for AXI_CLK_PERIOD/2;
    else
      wait;
    end if;
  end process w_axi_clk;

  -- Copy the clocks and resets
  S_AXI_TEST_BOTTOM_ACLK    <= S_AXI_ACLK;
  S_AXI_TEST_BOTTOM_ARESETN <= S_AXI_ARESETN;
  S_AXI_TEST_MIDDLE_ACLK    <= S_AXI_ACLK;
  S_AXI_TEST_MIDDLE_ARESETN <= S_AXI_ARESETN;
  s_axis_myinput_aclk       <= S_AXI_ACLK;
  s_axis_myinput_aresetn    <= S_AXI_ARESETN;
  m_axis_myoutput_aclk      <= S_AXI_ACLK;
  m_axis_myoutput_aresetn   <= S_AXI_ARESETN;
  s_axis_test_in_aclk       <= S_AXI_ACLK;
  s_axis_test_in_aresetn    <= S_AXI_ARESETN;
  m_axis_test_out_aclk      <= S_AXI_ACLK;
  m_axis_test_out_aresetn   <= S_AXI_ARESETN;

  w_test_procedure : process
    variable my_line : line;
  begin

    --**************************************************
    -- Reset
    --**************************************************
    S_AXI_ARESETN <= '0';
    wait for AXI_CLK_PERIOD*10;
    S_AXI_ARESETN <= '1';
    if (S_AXI_ARESETN = '0') then
      wait until (S_AXI_ARESETN = '1');
    end if;

    --**************************************************
    -- Verify registers
    --**************************************************
    test_top_axilite_verify (
      S_AXI_ACLK,
      S_AXI_ARESETN,
      S_AXI_AWADDR,
      S_AXI_AWPROT,
      S_AXI_AWVALID,
      S_AXI_AWREADY,
      S_AXI_WDATA,
      S_AXI_WSTRB,
      S_AXI_WVALID,
      S_AXI_WREADY,
      S_AXI_BRESP,
      S_AXI_BVALID,
      S_AXI_BREADY,
      S_AXI_ARADDR,
      S_AXI_ARPROT,
      S_AXI_ARVALID,
      S_AXI_ARREADY,
      S_AXI_RDATA,
      S_AXI_RRESP,
      S_AXI_RVALID,
      S_AXI_RREADY
    );

    --**************************************************
    -- Verify registers for test_middle module
    --**************************************************
    test_middle_axilite_verify (
      S_AXI_TEST_MIDDLE_ACLK,
      S_AXI_TEST_MIDDLE_ARESETN,
      S_AXI_TEST_MIDDLE_AWADDR,
      S_AXI_TEST_MIDDLE_AWPROT,
      S_AXI_TEST_MIDDLE_AWVALID,
      S_AXI_TEST_MIDDLE_AWREADY,
      S_AXI_TEST_MIDDLE_WDATA,
      S_AXI_TEST_MIDDLE_WSTRB,
      S_AXI_TEST_MIDDLE_WVALID,
      S_AXI_TEST_MIDDLE_WREADY,
      S_AXI_TEST_MIDDLE_BRESP,
      S_AXI_TEST_MIDDLE_BVALID,
      S_AXI_TEST_MIDDLE_BREADY,
      S_AXI_TEST_MIDDLE_ARADDR,
      S_AXI_TEST_MIDDLE_ARPROT,
      S_AXI_TEST_MIDDLE_ARVALID,
      S_AXI_TEST_MIDDLE_ARREADY,
      S_AXI_TEST_MIDDLE_RDATA,
      S_AXI_TEST_MIDDLE_RRESP,
      S_AXI_TEST_MIDDLE_RVALID,
      S_AXI_TEST_MIDDLE_RREADY
    );

    --**************************************************
    -- Verify registers for test_bottom module
    --**************************************************
    test_bottom_axilite_verify (
      S_AXI_TEST_BOTTOM_ACLK,
      S_AXI_TEST_BOTTOM_ARESETN,
      S_AXI_TEST_BOTTOM_AWADDR,
      S_AXI_TEST_BOTTOM_AWPROT,
      S_AXI_TEST_BOTTOM_AWVALID,
      S_AXI_TEST_BOTTOM_AWREADY,
      S_AXI_TEST_BOTTOM_WDATA,
      S_AXI_TEST_BOTTOM_WSTRB,
      S_AXI_TEST_BOTTOM_WVALID,
      S_AXI_TEST_BOTTOM_WREADY,
      S_AXI_TEST_BOTTOM_BRESP,
      S_AXI_TEST_BOTTOM_BVALID,
      S_AXI_TEST_BOTTOM_BREADY,
      S_AXI_TEST_BOTTOM_ARADDR,
      S_AXI_TEST_BOTTOM_ARPROT,
      S_AXI_TEST_BOTTOM_ARVALID,
      S_AXI_TEST_BOTTOM_ARREADY,
      S_AXI_TEST_BOTTOM_RDATA,
      S_AXI_TEST_BOTTOM_RRESP,
      S_AXI_TEST_BOTTOM_RVALID,
      S_AXI_TEST_BOTTOM_RREADY
    );

    --**************************************************
    -- Process data
    --**************************************************
    s_axis_myinput_enable <= '1';
    s_axis_test_in_enable <= '1';
    wait until falling_edge(m_axis_myoutput_tlast);

    --**************************************************
    -- End Simulation
    --**************************************************
    write(my_line, string'("***** SIMULATION PASSED *****"));
    writeline(output, my_line);
    simulation_done <= true;
    wait;

  end process w_test_procedure;

end rtl;
