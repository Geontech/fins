-- Copyright (C) 2026 Geon Technologies, LLC
-- SPDX-License-Identifier: LGPL-3.0-or-later

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity primitive_counter is
  port (
    clock        : in  std_logic;
    resetn       : in  std_logic;
    count_enable : in  std_logic;
    count        : out unsigned(3 downto 0)
  );
end entity primitive_counter;

architecture rtl of primitive_counter is
  signal count_internal : unsigned(count'range) := (others => '0');
begin
  count <= count_internal;

  count_proc : process (clock)
  begin
    if rising_edge(clock) then
      if resetn = '0' then
        count_internal <= (others => '0');
      elsif count_enable = '1' then
        count_internal <= count_internal + 1;
      end if;
    end if;
  end process count_proc;
end architecture rtl;
