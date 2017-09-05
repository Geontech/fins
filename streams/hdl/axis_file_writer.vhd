--==============================================================================
-- Company:     Geon Technologies, LLC
-- File:        axis_file_writer.vhd
-- Description: This testbench module writes data to a file from an AXI-Stream
--
-- Revision History:
-- Date        Author             Revision
-- ----------  -----------------  ----------------------------------------------
-- 2017-08-04  Josh Schindehette  Initial Version
--
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

-- Entity
entity axis_file_writer is
  generic (
    G_FILE_PATH   : string  := "../../../sim_out_data.txt";
    G_DATA_WIDTH  : integer := 32
  );
  port (
    simulation_done : in  boolean;
    clk             : in  std_logic;
    s_axis_tready   : out std_logic;
    s_axis_tvalid   : in  std_logic;
    s_axis_tlast    : in  std_logic;
    s_axis_tdata    : in  std_logic_vector(G_DATA_WIDTH-1 downto 0)
  );
end entity axis_file_writer;

-- Architecture
architecture behavioral of axis_file_writer is

begin

  w_write_file : process
    variable file_status    : file_open_status := NAME_ERROR;
    file     write_file     : text;
    variable write_line     : line;
    variable write_value    : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  begin

    -- Use "simulation_done" to suspend operations
    if (simulation_done = false) then

      -- Read at the rising edge of the clock
      wait until rising_edge(clk);

      -- Hold TREADY high (this module is always ready to accept data)
      s_axis_tready <= '1';

      -- When we get a TVALID, write the next value
      if (s_axis_tvalid = '1') then
        -- Open the file if it's not open already
        if (file_status /= OPEN_OK) then
          file_open(file_status, write_file, G_FILE_PATH, WRITE_MODE);
        end if;
        -- Write the value to the file in hexadecimal format
        write_value := s_axis_tdata;
        hwrite(write_line, write_value);
        writeline(write_file, write_line);
      end if;

    else
      -- Close File
      file_close(write_file);
      -- Suspend operations when simulation is done
      wait;
    end if;

  end process w_write_file;

end behavioral;
