-- Copyright (C) 2026 Geon Technologies, LLC
-- SPDX-License-Identifier: LGPL-3.0-or-later

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity primitive_counter_tb is
end entity primitive_counter_tb;

architecture test of primitive_counter_tb is
  constant CLOCK_PERIOD : time := 10 ns;

  signal clock           : std_logic := '0';
  signal resetn          : std_logic := '0';
  signal count_enable    : std_logic := '0';
  signal count           : unsigned(3 downto 0);
  signal simulation_done : boolean := false;
begin
  dut : entity work.primitive_counter
    port map (
      clock        => clock,
      resetn       => resetn,
      count_enable => count_enable,
      count        => count
    );

  clock_proc : process
  begin
    if not simulation_done then
      clock <= '0';
      wait for CLOCK_PERIOD / 2;
      clock <= '1';
      wait for CLOCK_PERIOD / 2;
    else
      wait;
    end if;
  end process clock_proc;

  stimulus_proc : process
  begin
    wait for 2 * CLOCK_PERIOD;
    wait until rising_edge(clock);
    resetn <= '1';
    count_enable <= '1';

    for iteration in 1 to 4 loop
      wait until rising_edge(clock);
    end loop;
    wait for 1 ns;

    assert count = to_unsigned(4, count'length)
      report "primitive counter produced an unexpected value"
      severity failure;

    simulation_done <= true;
    wait;
  end process stimulus_proc;
end architecture test;
