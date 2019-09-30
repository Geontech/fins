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
use work.test_bottom_pkg.all;
use work.test_bottom_swconfig_verify.all;

-- Entity
entity test_bottom_tb is
end entity test_bottom_tb;

-- Architecture
architecture rtl of test_bottom_tb is

  -- Device Under Test interface
  signal s_axis_myinput_aclk     : std_logic;
  signal s_axis_myinput_aresetn  : std_logic;
  signal s_axis_myinput_tvalid   : std_logic;
  signal s_axis_myinput_tlast    : std_logic;
  signal s_axis_myinput_tdata    : std_logic_vector(PORTS_WIDTH-1 downto 0);
  signal m_axis_myoutput_aclk    : std_logic;
  signal m_axis_myoutput_aresetn : std_logic;
  signal m_axis_myoutput_tvalid  : std_logic;
  signal m_axis_myoutput_tlast   : std_logic;
  signal m_axis_myoutput_tdata   : std_logic_vector(PORTS_WIDTH-1 downto 0);
  signal s_axis_test_in_aclk     : std_logic;
  signal s_axis_test_in_aresetn  : std_logic;
  signal s_axis_test_in_tready   : std_logic;
  signal s_axis_test_in_tdata    : std_logic_vector(160-1 downto 0);
  signal s_axis_test_in_tuser    : std_logic_vector(128-1 downto 0);
  signal s_axis_test_in_tvalid   : std_logic;
  signal s_axis_test_in_tlast    : std_logic;
  signal m_axis_test_out_aclk    : std_logic;
  signal m_axis_test_out_aresetn : std_logic;
  signal m_axis_test_out_tready  : std_logic;
  signal m_axis_test_out_tdata   : std_logic_vector(160-1 downto 0);
  signal m_axis_test_out_tuser   : std_logic_vector(128-1 downto 0);
  signal m_axis_test_out_tvalid  : std_logic;
  signal m_axis_test_out_tlast   : std_logic;
  signal s_swconfig_clk          : std_logic;
  signal s_swconfig_reset        : std_logic;
  signal s_swconfig_address      : std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
  signal s_swconfig_wr_enable    : std_logic;
  signal s_swconfig_wr_data      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal s_swconfig_rd_enable    : std_logic;
  signal s_swconfig_rd_valid     : std_logic;
  signal s_swconfig_rd_data      : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);

  -- Testbench
  signal simulation_done  : boolean := false;
  constant CLK_PERIOD : time := 5 ns;
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
  u_dut : entity work.test_bottom
    port map (
      s_axis_myinput_aclk     => s_axis_myinput_aclk     ,
      s_axis_myinput_aresetn  => s_axis_myinput_aresetn  ,
      s_axis_myinput_tvalid   => s_axis_myinput_tvalid   ,
      s_axis_myinput_tlast    => s_axis_myinput_tlast    ,
      s_axis_myinput_tdata    => s_axis_myinput_tdata    ,
      m_axis_myoutput_aclk    => m_axis_myoutput_aclk    ,
      m_axis_myoutput_aresetn => m_axis_myoutput_aresetn ,
      m_axis_myoutput_tvalid  => m_axis_myoutput_tvalid  ,
      m_axis_myoutput_tlast   => m_axis_myoutput_tlast   ,
      m_axis_myoutput_tdata   => m_axis_myoutput_tdata   ,
      s_axis_test_in_aclk     => s_axis_test_in_aclk     ,
      s_axis_test_in_aresetn  => s_axis_test_in_aresetn  ,
      s_axis_test_in_tready   => s_axis_test_in_tready   ,
      s_axis_test_in_tdata    => s_axis_test_in_tdata    ,
      s_axis_test_in_tuser    => s_axis_test_in_tuser    ,
      s_axis_test_in_tvalid   => s_axis_test_in_tvalid   ,
      s_axis_test_in_tlast    => s_axis_test_in_tlast    ,
      m_axis_test_out_aclk    => m_axis_test_out_aclk    ,
      m_axis_test_out_aresetn => m_axis_test_out_aresetn ,
      m_axis_test_out_tready  => m_axis_test_out_tready  ,
      m_axis_test_out_tdata   => m_axis_test_out_tdata   ,
      m_axis_test_out_tuser   => m_axis_test_out_tuser   ,
      m_axis_test_out_tvalid  => m_axis_test_out_tvalid  ,
      m_axis_test_out_tlast   => m_axis_test_out_tlast   ,
      s_swconfig_clk          => s_swconfig_clk          ,
      s_swconfig_reset        => s_swconfig_reset        ,
      s_swconfig_address      => s_swconfig_address      ,
      s_swconfig_wr_enable    => s_swconfig_wr_enable    ,
      s_swconfig_wr_data      => s_swconfig_wr_data      ,
      s_swconfig_rd_enable    => s_swconfig_rd_enable    ,
      s_swconfig_rd_valid     => s_swconfig_rd_valid     ,
      s_swconfig_rd_data      => s_swconfig_rd_data      
    );

  -- File input/output streams
  -- NOTE: The source/sink filepaths are relative to where the simulation is executed
  u_file_io : entity work.test_bottom_axis_verify
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

  -- Clock
  w_clk : process
  begin
    if (simulation_done = false) then
      s_swconfig_clk <= '0';
      wait for CLK_PERIOD/2;
      s_swconfig_clk <= '1';
      wait for CLK_PERIOD/2;
    else
      wait;
    end if;
  end process w_clk;
  s_axis_myinput_aclk <= s_swconfig_clk;
  m_axis_myoutput_aclk <= s_swconfig_clk;
  s_axis_test_in_aclk <= s_swconfig_clk;
  m_axis_test_out_aclk <= s_swconfig_clk;

  -- Reset
  m_axis_myoutput_aresetn <= NOT s_swconfig_reset;
  s_axis_myinput_aresetn  <= NOT s_swconfig_reset;
  m_axis_test_out_aresetn <= NOT s_swconfig_reset;
  s_axis_test_in_aresetn  <= NOT s_swconfig_reset;

  w_test_procedure : process
    variable my_line : line;
  begin

    --**************************************************
    -- Reset
    --**************************************************
    s_swconfig_reset <= '1';
    wait for CLK_PERIOD*10;
    s_swconfig_reset <= '0';
    if (s_swconfig_reset = '1') then
      wait until (s_swconfig_reset = '0');
    end if;

    --**************************************************
    -- Verify registers
    --**************************************************
    test_bottom_swconfig_verify (
      s_swconfig_clk       ,
      s_swconfig_reset     ,
      s_swconfig_address   ,
      s_swconfig_wr_enable ,
      s_swconfig_wr_data   ,
      s_swconfig_rd_enable ,
      s_swconfig_rd_valid  ,
      s_swconfig_rd_data   
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
