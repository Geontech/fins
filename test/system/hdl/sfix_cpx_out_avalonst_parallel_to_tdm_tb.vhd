----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/12/2021 02:02:12 PM
-- Design Name: 
-- Module Name: sfix_cpx_out_avalonst_parallel_to_tdm_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- User Libraries
library work;
use work.sfix_cpx_out_avalonst_parallel_to_tdm_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sfix_cpx_out_avalonst_parallel_to_tdm_tb is
--  Port ( );
end sfix_cpx_out_avalonst_parallel_to_tdm_tb;

architecture behav of sfix_cpx_out_avalonst_parallel_to_tdm_tb is
  constant G_TDM_WORD_WIDTH   : integer := 32;
  constant G_BIG_ENDIAN       : boolean := true;
  
  constant CLOCK_PERIOD      : time := 5 ns;
  
  signal clock    : std_logic := '0';
  signal resetn   : std_logic := '1';
  
  signal num_packets_sent     : unsigned(31 downto 0) := (others => '0');
  signal num_packets_received : unsigned(31 downto 0) := (others => '0');
  signal meta      : std_logic_vector(128-1 downto 0);
  signal meta_index : natural := 0;

  -- AXI4-Stream Parallel Bus
  signal s_axis_aclk       : std_logic;
  signal s_axis_aresetn    : std_logic;
  signal s_axis_tready     : std_logic;
  signal s_axis_tkeep      : std_logic_vector(4-1 downto 0);
  signal s_axis_tdata      : std_logic_vector(32-1 downto 0);
  signal s_axis_tuser      : std_logic_vector(121-1 downto 0);
  signal s_axis_tvalid     : std_logic;
  signal s_axis_tlast      : std_logic;
    -- Avalon-ST Time-Division Multiplexed Bus (Big Endian)
  signal aso_clock         : std_logic;
  signal aso_reset         : std_logic;
  signal aso_ready         : std_logic;
  signal aso_data          : std_logic_vector(G_TDM_WORD_WIDTH-1 downto 0);
  signal aso_valid         : std_logic;
  signal aso_startofpacket : std_logic;
  signal aso_empty         : std_logic_vector(2-1 downto 0);
  signal aso_endofpacket   : std_logic;
  signal simulation_done   : boolean := false;

  signal debug    : std_logic := '0';
  
  function f_to_big_endian(data : std_logic_vector(32-1 downto 0) := (others => '0')) return std_logic_vector is
      variable reformat_data: std_logic_vector(32-1 downto 0) := (others => '0');
      variable i_up : natural := 0;
      variable i_down : natural := (32/8);
    begin
      for i in 0 to 4-1 loop
        reformat_data((i_down*8)-1 downto (i_down-1)*8) := data(((i_up+1)*8)-1 downto i_up*8);
        i_up := i_up + 1;
        i_down := i_down - 1;        
      end loop;
      return reformat_data;
    end function;

begin
  u_uut : entity work.sfix_cpx_out_avalonst_parallel_to_tdm
    generic map (
      G_TDM_WORD_WIDTH => G_TDM_WORD_WIDTH,
      G_BIG_ENDIAN     => G_BIG_ENDIAN
    )
    port map(
      -- AXI4-Stream Parallel Bus
      s_axis_aclk        => s_axis_aclk,
      s_axis_aresetn     => s_axis_aresetn,
      s_axis_tready      => s_axis_tready,
      s_axis_tkeep       => s_axis_tkeep,
      s_axis_tdata       => s_axis_tdata,
      s_axis_tuser       => s_axis_tuser,
      s_axis_tvalid      => s_axis_tvalid,
      s_axis_tlast       => s_axis_tlast,
      -- Avalon-ST Time-Division Multiplexed Bus (Big Endian)
      aso_clock          => aso_clock,
      aso_reset          => aso_reset,
      aso_ready          => aso_ready,
      aso_data           => aso_data,
      aso_valid          => aso_valid,
      aso_startofpacket  => aso_startofpacket,
      aso_empty          => aso_empty,
      aso_endofpacket    => aso_endofpacket
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

  s_axis_aclk <= clock;
  s_axis_aresetn <= resetn;
  
  aso_clock   <= clock;
  aso_reset   <= resetn;
  
  w_input_generation : process
    -- Variables for calculating inputs
    variable tvalid : std_logic := '0';
    variable tlast  : std_logic := '0';
    variable tdata  : std_logic_vector(32-1 downto 0) := (others => '0');
    variable tkeep  : std_logic_vector(4-1 downto 0) := (others => '0');
    variable tuser  : std_logic_vector(121-1 downto 0) := (others => '0');
    variable tready : std_logic := '1';
    
    variable current_size : natural := 1;
    variable packet_size : natural := 1;
    
    -- Variables for random number generation
    variable seed1, seed2 : positive;
    variable rand         : real;

  begin

    if (simulation_done = false) then
      wait until falling_edge(clock);
      -- Assign signals
      s_axis_tvalid <= tvalid;
      s_axis_tlast  <= tlast;
      s_axis_tdata  <= tdata;
      s_axis_tkeep  <= tkeep;
      s_axis_tuser  <= tuser;
      aso_ready <= tready;
      
      if(s_axis_tready = '1' and resetn = '1') then
        if(current_size <= packet_size) then
          tvalid := '1';
          tdata  := std_logic_vector(unsigned(tdata) + 1);
          
          if(current_size = 1) then
            tuser  := std_logic_vector(unsigned(tuser) + 1);
          end if;
                              
          current_size := current_size + 1;
          
          if(current_size <= packet_size) then
            tlast := '0';
          else
            tlast := '1';
            current_size := 1;
            packet_size := packet_size + 1;
          end if;
        end if;          
      end if;  
    else
      wait;
    end if;
  end process w_input_generation;
  
  w_test_procedure : process
    type t_metadata_int is array (4-1 downto 0) of std_logic_vector(32-1 downto 0);

    type state_machine is (METADATA, DATA);

    variable metadata_created : std_logic_vector(128-1 downto 0) := (others => '0');
    variable p_state : state_machine := METADATA;

    variable metadata_index : natural := 0;
    variable metadata_int : t_metadata_int;
    variable metadata_formed : std_logic_vector(121-1 downto 0);

    variable expected_metadata: std_logic_vector(121-1 downto 0) := std_logic_vector(to_unsigned(1, 121));
    variable expected_data: std_logic_vector(32-1 downto 0) := std_logic_vector(to_unsigned(1, 32));

    variable sample_ix: natural := 0;  
  
    begin

      resetn <= '0';
      wait for CLOCK_PERIOD*10; -- Wait for an arbitrary 10 clocks
      resetn <= '1';
      wait for CLOCK_PERIOD*3;
      
      while (sample_ix < 10000) loop
        wait until falling_edge(aso_clock);
        if ((aso_valid = '1') AND (aso_ready = '1')) then
          if (metadata_index < 4) then
            if (aso_startofpacket = '1') then
              metadata_index := 0;
            end if;
            metadata_int(metadata_index) := aso_data;
            metadata_index := metadata_index + 1;
          else
            assert (unsigned(expected_data) = unsigned(f_to_big_endian(aso_data)))
            report "ERROR: The TDATA field is incorrect"
            severity failure;            
            expected_data := std_logic_vector(unsigned(expected_data) + 1);
            
            if(aso_endofpacket = '1') then
              metadata_created := f_to_big_endian(metadata_int(3)) & f_to_big_endian(metadata_int(2)) & f_to_big_endian(metadata_int(1)) & f_to_big_endian(metadata_int(0));
              meta <= metadata_created;
              metadata_index := 0;
              assert (unsigned(expected_metadata) = unsigned(metadata_created))
              report "ERROR: The TUSER field is incorrect"
              severity failure;
              expected_metadata:= std_logic_vector(unsigned(expected_metadata) + 1);
            end if;
          end if;
        meta_index <= metadata_index; 
        sample_ix := sample_ix + 1;
        end if;
        
      end loop;
      
      wait for CLOCK_PERIOD*10; -- Wait for an arbitrary 10 clocks
      simulation_done <= true;
      wait;
  end process w_test_procedure;
      
      
end behav;
