--==============================================================================
-- Company:     Geon Technologies, LLC
-- File:        gain.vhd
-- Description: This module multiplies an input by a positive fixed value
-- Reset Type:  Synchronous
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

-- Entity
entity gain is
  generic (
    G_GAIN_VALUE         : natural := 23;
    G_DATA_WIDTH         : natural := 16;
    G_DATA_IS_SIGNED     : boolean := true
  );
  port (
    clk                  : in  std_logic;
    reset                : in  std_logic;
    s_axis_data_tvalid   : in  std_logic;
    s_axis_data_tlast    : in  std_logic;
    s_axis_data_tdata    : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    m_axis_data_tvalid   : out std_logic;
    m_axis_data_tlast    : out std_logic;
    m_axis_data_tdata    : out std_logic_vector(G_DATA_WIDTH-1 downto 0)
  );
end entity gain;

-- Architecture
architecture rtl of gain is
begin

  s_mult : process (clk)
  begin
    if (rising_edge(clk)) then

      -- Data signals don't need synchronous reset
      if (G_DATA_IS_SIGNED) then
        m_axis_data_tdata <= std_logic_vector(resize((signed(s_axis_data_tdata) * to_signed(G_GAIN_VALUE, G_DATA_WIDTH)), G_DATA_WIDTH));
      else
        m_axis_data_tdata <= std_logic_vector(resize((unsigned(s_axis_data_tdata) * to_unsigned(G_GAIN_VALUE, G_DATA_WIDTH)), G_DATA_WIDTH));
      end if;

      -- Control signals need synchronous reset
      if (reset = '1') then
        m_axis_data_tvalid <= '0';
        m_axis_data_tlast  <= '0';
      else
        m_axis_data_tvalid <= s_axis_data_tvalid;
        m_axis_data_tlast  <= s_axis_data_tlast;
      end if;

    end if;
  end process s_mult;

end rtl;
