--==============================================================================
-- Company:     Geon Technologies, LLC
-- Author:      Josh Schindehette
-- Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this 
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: This file generates clocks and resets for a simulation
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity
entity clock_and_reset is
  generic (
      G_CLK_PERIOD0   : time    := 5 ns;
      G_CLK_PERIOD1   : time    := 5 ns;
      G_RESET_LENGTH0 : integer := 10; -- clock periods
      G_RESET_LENGTH1 : integer := 10  -- clock periods
  );
  port (
      simulation_done : in  boolean;
      clk0            : out std_logic;
      reset0          : out std_logic;
      clk1            : out std_logic;
      reset1          : out std_logic
  );
end entity clock_and_reset;

-- Architecture
architecture behavioral of clock_and_reset is

  signal clk0_int   : std_logic := '0';
  signal reset0_int : std_logic := '0';
  signal clk1_int   : std_logic := '0';
  signal reset1_int : std_logic := '0';

begin

  -- Assign outputs
  clk0   <= clk0_int;
  reset0 <= reset0_int;
  clk1   <= clk1_int;
  reset1 <= reset1_int;

  -- Clock 0 Generation
  w_clk0 : process
  begin
    if (simulation_done = false) then
      clk0_int <= not clk0_int;
      wait for G_CLK_PERIOD0/2;
      clk0_int <= not clk0_int;
      wait for G_CLK_PERIOD0/2;
    else
      wait;
    end if;
  end process w_clk0;

  -- Clock 1 Generation
  w_clk1 : process
  begin
    if (simulation_done = false) then
      clk1_int <= not clk1_int;
      wait for G_CLK_PERIOD1/2;
      clk1_int <= not clk1_int;
      wait for G_CLK_PERIOD1/2;
    else
      wait;
    end if;
  end process w_clk1;

  -- Reset 0 Generation
  w_reset0 : process
  begin
    reset0_int <= '1';
    wait for G_CLK_PERIOD0 * G_RESET_LENGTH0;
    reset0_int <= '0';
    wait;
  end process w_reset0;

  -- Reset 1 Generation
  w_reset1 : process
  begin
    reset1_int <= '1';
    wait for G_CLK_PERIOD1 * G_RESET_LENGTH1;
    reset1_int <= '0';
    wait;
  end process w_reset1;

end architecture behavioral;
