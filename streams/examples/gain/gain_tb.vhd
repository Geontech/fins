--==============================================================================
-- Company:     Geon Technologies, LLC
-- File:        gain_tb.vhd
-- Description: This testbench simulates the gain algorithm
--
-- Revision History:
-- Date        Author             Revision
-- ----------  -----------------  ----------------------------------------------
-- 2017-08-08  Josh Schindehette  Initial Version
--
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Empty Entity
entity gain_tb is
end entity gain_tb;

-- Architecture
architecture behavioral of gain_tb is

  --------------------------------------------------------------------------------
  -- Device Under Test Generics
  --------------------------------------------------------------------------------
  constant GAIN_VALUE         : natural := 23;
  constant DATA_WIDTH         : natural := 16;
  constant DATA_IS_SIGNED     : boolean := true;

  --------------------------------------------------------------------------------
  -- Device Under Test Signals
  --------------------------------------------------------------------------------
  signal clk                  : std_logic := '0';
  signal reset                : std_logic;
  signal s_axis_data_tvalid   : std_logic;
  signal s_axis_data_tlast    : std_logic;
  signal s_axis_data_tdata    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal m_axis_data_tvalid   : std_logic;
  signal m_axis_data_tlast    : std_logic;
  signal m_axis_data_tdata    : std_logic_vector(DATA_WIDTH-1 downto 0);

  --------------------------------------------------------------------------------
  -- Testbench Constants
  --------------------------------------------------------------------------------
  constant CLK_PERIOD         : time    := 10 ns;
  constant FRAME_SIZE         : integer := 32;
  constant FRAMES_TO_RUN      : integer := 50;

  --------------------------------------------------------------------------------
  -- Testbench Signals
  --------------------------------------------------------------------------------
  signal simulation_done      : boolean   := false;
  signal simulation_go        : std_logic := '0';

begin

  --------------------------------------------------------------------------------
  -- Device Under Test
  --------------------------------------------------------------------------------
  u_dut : entity work.gain
    generic map (
      G_GAIN_VALUE         => GAIN_VALUE,
      G_DATA_WIDTH         => DATA_WIDTH,
      G_DATA_IS_SIGNED     => DATA_IS_SIGNED
    )
    port map (
      clk                  => clk                ,
      reset                => reset              ,
      s_axis_data_tvalid   => s_axis_data_tvalid ,
      s_axis_data_tlast    => s_axis_data_tlast  ,
      s_axis_data_tdata    => s_axis_data_tdata  ,
      m_axis_data_tvalid   => m_axis_data_tvalid ,
      m_axis_data_tlast    => m_axis_data_tlast  ,
      m_axis_data_tdata    => m_axis_data_tdata
    );

  --------------------------------------------------------------------------------
  -- Test Components
  --------------------------------------------------------------------------------
  -- Input from file
  u_input_data : entity work.axis_file_reader
    generic map (
      G_FILE_PATH   => "../../../../sim_in_data.txt",
      G_DATA_WIDTH  => DATA_WIDTH,
      G_PACKET_SIZE => FRAME_SIZE
    )
    port map (
      simulation_done => simulation_done,
      clk             => clk,
      m_axis_tready   => simulation_go,
      m_axis_tvalid   => s_axis_data_tvalid,
      m_axis_tlast    => s_axis_data_tlast,
      m_axis_tdata    => s_axis_data_tdata
    );

  -- Output to file
  u_output_data : entity work.axis_file_writer
    generic map (
      G_FILE_PATH  => "../../../../sim_out_data.txt",
      G_DATA_WIDTH => DATA_WIDTH
    )
    port map (
      simulation_done => simulation_done,
      clk             => clk,
      s_axis_tready   => open,
      s_axis_tvalid   => m_axis_data_tvalid,
      s_axis_tlast    => m_axis_data_tlast,
      s_axis_tdata    => m_axis_data_tdata
    );

  --------------------------------------------------------------------------------
  -- Clock Generation
  --------------------------------------------------------------------------------
  w_clk : process
  begin
    if (simulation_done = false) then
      clk <= not clk;
      wait for CLK_PERIOD/2;
      clk <= not clk;
      wait for CLK_PERIOD/2;
    else
      wait;
    end if;
  end process w_clk;

  --------------------------------------------------------------------------------
  -- Waveform Logic
  --------------------------------------------------------------------------------
  w_test_sequence : process
  begin

    --*************************************************
    -- Perform the reset
    --*************************************************
    -- Apply Reset
    reset <= '1';
    wait for CLK_PERIOD * 10;
    -- Remove Reset
    reset <= '0';
    wait for CLK_PERIOD;

    --*************************************************
    -- Start data
    --*************************************************
    wait until rising_edge(clk);
    simulation_go <= '1';

    --*************************************************
    -- Wait until the last output frame is received
    --*************************************************
    for f in 0 to FRAMES_TO_RUN-1 loop
      wait until falling_edge(m_axis_data_tlast);
    end loop;

    --*************************************************
    -- End the simulation
    --*************************************************
    simulation_done                   <= true;
    wait;

  end process w_test_sequence;

end architecture behavioral;
