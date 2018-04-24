--==============================================================================
-- Company:     Geon Technologies, LLC
-- Author:      Josh Schindehette
-- Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this 
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: This testbench module reads data from a file and outputs with an
--              AXI-Stream
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

-- Entity
entity axis_file_reader is
  generic (
    G_FILE_PATH     : string  := "../../../sim_in_data.txt";
    G_DATA_WIDTH    : integer := 32;
    G_PACKET_SIZE   : integer := 1024;
    G_SAMPLE_PERIOD : integer := 1
  );
  port (
    simulation_done : in  boolean;
    clk             : in  std_logic;
    m_axis_tready   : in  std_logic;
    m_axis_tvalid   : out std_logic;
    m_axis_tlast    : out std_logic;
    m_axis_tdata    : out std_logic_vector(G_DATA_WIDTH-1 downto 0)
  );
end entity axis_file_reader;

-- Architecture
architecture behavioral of axis_file_reader is

begin

  w_read_file : process
    variable file_status    : file_open_status := NAME_ERROR;
    file     read_file      : text;
    variable read_line      : line;
    variable read_value     : std_logic_vector(G_DATA_WIDTH-1 downto 0);
    variable sample_counter : integer := 0;
    variable period_counter : integer := 0;
    variable axis_tvalid    : std_logic;
    variable axis_tlast     : std_logic;
    variable axis_tdata     : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  begin

    -- Use "simulation_done" to suspend operations
    if (NOT simulation_done) then

      -- Read at the rising edge of the clock
      wait until rising_edge(clk);

      --******************************************
      -- Calculate the values for the variables
      --******************************************
      -- Set defaults
      axis_tvalid := '0';
      axis_tlast  := '0';
      axis_tdata  := (others => '0');

      -- When we get a TREADY, read the next value
      if (m_axis_tready = '1') then
        -- Respect the sample period
        if ((period_counter rem G_SAMPLE_PERIOD) = 0) then
          -- Open the file if it's not open already
          if (file_status /= OPEN_OK) then
            file_open(file_status, read_file, G_FILE_PATH, READ_MODE);
          end if;
          -- Grab a valid value from the file if we haven't reached the EOF
          if (NOT endfile(read_file)) then
            -- Read a hexadecimal string from a line of the file
            readline(read_file, read_line);
            hread(read_line, read_value);
            -- Set the output values
            axis_tvalid := '1';
            axis_tdata  := read_value;
            -- TLAST is active only when we've reached the final
            -- value in an AXI-Stream packet
            if (sample_counter = G_PACKET_SIZE-1) then
              axis_tlast := '1';
              sample_counter := 0;
            else
              axis_tlast := '0';
              sample_counter := sample_counter + 1;
            end if;
          end if;
        end if;
        -- Increment the period counter
        period_counter := period_counter + 1;
      end if;

      --******************************************
      -- Set outputs to the variables
      --******************************************
      m_axis_tvalid <= axis_tvalid;
      m_axis_tlast  <= axis_tlast;
      m_axis_tdata  <= axis_tdata;

    else

      -- Close File
      file_close(read_file);

      -- Suspend operations when simulation is done
      wait;

    end if;

  end process w_read_file;

end behavioral;
