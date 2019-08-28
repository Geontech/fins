--==============================================================================
-- Company:     Geon Technologies, LLC
-- Author:      Josh Schindehette
-- Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: This is the top level testbench of the FINS test module
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
  signal myinput_enable   : std_logic := '0';

begin

  -- Device Under Test
  u_dut : entity work.test_bottom
    port map (
      s_axis_myinput_aclk     => s_axis_myinput_aclk    ,
      s_axis_myinput_aresetn  => s_axis_myinput_aresetn ,
      s_axis_myinput_tvalid   => s_axis_myinput_tvalid  ,
      s_axis_myinput_tlast    => s_axis_myinput_tlast   ,
      s_axis_myinput_tdata    => s_axis_myinput_tdata   ,
      m_axis_myoutput_aclk    => m_axis_myoutput_aclk   ,
      m_axis_myoutput_aresetn => m_axis_myoutput_aresetn,
      m_axis_myoutput_tvalid  => m_axis_myoutput_tvalid ,
      m_axis_myoutput_tlast   => m_axis_myoutput_tlast  ,
      m_axis_myoutput_tdata   => m_axis_myoutput_tdata  ,
      s_swconfig_clk          => s_swconfig_clk         ,
      s_swconfig_reset        => s_swconfig_reset       ,
      s_swconfig_address      => s_swconfig_address     ,
      s_swconfig_wr_enable    => s_swconfig_wr_enable   ,
      s_swconfig_wr_data      => s_swconfig_wr_data     ,
      s_swconfig_rd_enable    => s_swconfig_rd_enable   ,
      s_swconfig_rd_valid     => s_swconfig_rd_valid    ,
      s_swconfig_rd_data      => s_swconfig_rd_data     
    );

  -- File input/output streams
  -- NOTE: The source/sink filepaths are relative to where the simulation is executed
  u_file_io : entity work.test_bottom_streams
    generic map (
      G_MYINPUT_SOURCE_FILEPATH => SIM_FILE_PATH & "sim_source_myinput.txt",
      G_MYOUTPUT_SINK_FILEPATH  => SIM_FILE_PATH & "sim_sink_myoutput.txt"
    )
    port map (
      simulation_done        => simulation_done,
      m_axis_myinput_clk     => s_swconfig_clk,
      m_axis_myinput_enable  => myinput_enable,
      m_axis_myinput_tdata   => s_axis_myinput_tdata,
      m_axis_myinput_tvalid  => s_axis_myinput_tvalid,
      m_axis_myinput_tlast   => s_axis_myinput_tlast,
      m_axis_myinput_tready  => '1',
      s_axis_myoutput_clk    => s_swconfig_clk,
      s_axis_myoutput_tdata  => m_axis_myoutput_tdata,
      s_axis_myoutput_tvalid => m_axis_myoutput_tvalid,
      s_axis_myoutput_tlast  => m_axis_myoutput_tlast,
      s_axis_myoutput_tready => open
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

  -- Reset
  m_axis_myoutput_aresetn <= NOT s_swconfig_reset;
  s_axis_myinput_aresetn <= NOT s_swconfig_reset;

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
    myinput_enable <= '1';
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
