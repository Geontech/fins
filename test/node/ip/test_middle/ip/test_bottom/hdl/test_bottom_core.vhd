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
use ieee.math_real.all;

-- User Libraries
library work;
use work.test_bottom_pkg.all;

-- Entity
entity test_bottom_core is
  port (
    props_control : in  t_test_bottom_props_control;
    props_status  : out t_test_bottom_props_status;
    ports_in      : in  t_test_bottom_ports_in;
    ports_out     : out t_test_bottom_ports_out
  );
end test_bottom_core;

-- Architecture
architecture rtl of test_bottom_core is

  --------------------------------------------------------------------------------
  -- Constants
  --------------------------------------------------------------------------------
  constant TEST_RAM_ADDR_WIDTH : natural := integer(ceil(log2(real(TEST_RAM_DEPTH))));

  --------------------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------------------
  -- Xilinx IP created by external_property_fifo.tcl script
  component xilinx_external_property_fifo
    port (
      clk   : in  std_logic;
      srst  : in  std_logic;
      din   : in  std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      wr_en : in  std_logic;
      rd_en : in  std_logic;
      dout  : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      full  : out std_logic;
      empty : out std_logic
    );
  end component;

  -- Xilinx IP created by memmap_property_ram.tcl script
  component xilinx_memmap_property_ram
    port (
      clka  : in std_logic;
      ena   : in std_logic;
      wea   : in std_logic_vector(0 downto 0);
      addra : in std_logic_vector(TEST_RAM_ADDR_WIDTH-1 downto 0);
      dina  : in std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      clkb  : in std_logic;
      enb   : in std_logic;
      addrb : in std_logic_vector(TEST_RAM_ADDR_WIDTH-1 downto 0);
      doutb : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0)
    );
  end component;

  -- Intel IP created by external_property_fifo.tcl script
  component intel_external_property_fifo is
    port (
      data  : in  std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      wrreq : in  std_logic;
      rdreq : in  std_logic;
      clock : in  std_logic;
      q     : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      full  : out std_logic;
      empty : out std_logic
    );
  end component;

  -- Intel IP created by memmap_property_ram.tcl script
  component intel_memmap_property_ram is
    port (
      data      : in  std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      q         : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
      wraddress : in  std_logic_vector(TEST_RAM_ADDR_WIDTH-1 downto 0);
      rdaddress : in  std_logic_vector(TEST_RAM_ADDR_WIDTH-1 downto 0);
      wren      : in  std_logic;
      clock     : in  std_logic
    );
  end component;

  --------------------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------------------
  signal external_property_register   : std_logic_vector(props_control.test_prop_write_only_external.wr_data'length-1 downto 0);
  signal memmap_property_ram_wr_en    : std_logic_vector(0 downto 0);
  signal memmap_property_ram_rd_en_q  : std_logic;
  signal memmap_property_ram_rd_en_qq : std_logic;
  signal memmap_property_register     : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal myinput_valid                : std_logic;
  signal myinput_last                 : std_logic;
  signal myinput_data                 : unsigned(PORTS_WIDTH-1 downto 0);
  signal myinput_valid_q              : std_logic;
  signal myinput_last_q               : std_logic;
  signal myinput_data_q               : unsigned(PORTS_WIDTH-1 downto 0);
  signal external_property_fifo_rd_en : std_logic;

begin

  --------------------------------------------------------------------------------
  -- Data Processing
  --------------------------------------------------------------------------------
  -- Combinatorial process to assign test_out to test_in
  c_passthrough : process (ports_in)
  begin
    for ix in 0 to 2-1 loop
      ports_out.test_out(ix).data     <= f_unserialize_test_bottom_test_out_data(f_serialize_test_bottom_test_in_data(ports_in.test_in(ix).data));
      ports_out.test_out(ix).metadata <= f_unserialize_test_bottom_test_out_metadata(f_serialize_test_bottom_test_in_metadata(ports_in.test_in(ix).metadata));
      ports_out.test_out(ix).valid    <= ports_in.test_in(ix).valid;
      ports_out.test_out(ix).last     <= ports_in.test_in(ix).last;
      ports_out.test_in(ix).ready     <= ports_in.test_out(ix).ready;
    end loop;
  end process c_passthrough;

  -- Synchronous process for data processsing
  s_data_processing : process (ports_in.myinput.clk)
  begin
    if (rising_edge(ports_in.myinput.clk)) then
      -- Data pipelines
      myinput_data <= ports_in.myinput.data;
      myinput_data_q <= resize(
        unsigned(myinput_data) * to_unsigned(TEST_PARAM_INTEGER, myinput_data'length),
        myinput_data'length
      );
      -- Control pipelines
      if (ports_in.myinput.resetn = '0') then
        myinput_valid   <= '0';
        myinput_last    <= '0';
        myinput_valid_q <= '0';
        myinput_last_q  <= '0';
      else
        myinput_valid   <= ports_in.myinput.valid;
        myinput_last    <= ports_in.myinput.last;
        myinput_valid_q <= myinput_valid;
        myinput_last_q  <= myinput_last;
      end if;
    end if;
  end process s_data_processing;

  -- Assign output ports
  ports_out.myoutput.valid <= myinput_valid_q;
  ports_out.myoutput.last  <= myinput_last_q;
  ports_out.myoutput.data  <= myinput_data_q;

  --------------------------------------------------------------------------------
  -- Testing elements for "read-write-external"
  --------------------------------------------------------------------------------
  -- FWFT FIFO instantitation for test
  u_gen_xilinx_external_property_fifo : if (FINS_BACKEND = "vivado") generate
    u_external_property_fifo : xilinx_external_property_fifo
      port map (
        clk   => props_control.clk,
        srst  => '0',
        din   => props_control.test_prop_read_write_external.wr_data,
        wr_en => props_control.test_prop_read_write_external.wr_en,
        rd_en => external_property_fifo_rd_en,
        dout  => props_status.test_prop_read_write_external.rd_data,
        full  => open,
        empty => open
      );
  end generate u_gen_xilinx_external_property_fifo;
  u_gen_intel_external_property_fifo : if (FINS_BACKEND = "quartus") generate
    u_external_property_fifo : intel_external_property_fifo
      port map (
        clock   => props_control.clk,
        data    => props_control.test_prop_read_write_external.wr_data,
        wrreq   => props_control.test_prop_read_write_external.wr_en,
        rdreq   => external_property_fifo_rd_en,
        q       => props_status.test_prop_read_write_external.rd_data,
        full    => open,
        empty   => open
      );
  end generate u_gen_intel_external_property_fifo;

  -- Synchronous process to delay the fifo read enable one clock just due to this FIFO's timing
  s_external_property_fifo : process(props_control.clk)
  begin
    if (rising_edge(props_control.clk)) then
      if (props_control.resetn = '0') then
        external_property_fifo_rd_en <= '0';
      else
        external_property_fifo_rd_en <= props_control.test_prop_read_write_external.rd_en;
      end if;
    end if;
  end process s_external_property_fifo;

  -- Since this is a FWFT FIFO, the read data is valid as soon as the FIFO is read
  props_status.test_prop_read_write_external.rd_valid <= external_property_fifo_rd_en;

  --------------------------------------------------------------------------------
  -- Testing elements for "write-only-external" and "read-only-external"
  --------------------------------------------------------------------------------
  -- Synchronous process for external property write
  s_external_property_register : process(props_control.clk)
  begin
    if (rising_edge(props_control.clk)) then
      if (props_control.resetn = '0') then
        external_property_register <= (others => '0');
      else
        if (props_control.test_prop_write_only_external.wr_en = '1') then
          external_property_register <= props_control.test_prop_write_only_external.wr_data;
        end if;
      end if;
    end if;
  end process s_external_property_register;

  -- Assign read signals to register written above
  props_status.test_prop_read_only_external.rd_valid <= props_control.test_prop_read_only_external.rd_en;
  props_status.test_prop_read_only_external.rd_data  <= external_property_register;

  --------------------------------------------------------------------------------
  -- Testing elements for "read-write-memmap"
  --------------------------------------------------------------------------------
  -- Simple Dual Port RAM for test
  u_gen_xilinx_memmap_property_ram : if (FINS_BACKEND = "vivado") generate
    u_memmap_property_ram : xilinx_memmap_property_ram
      port map (
        clka  => props_control.clk,
        ena   => '1',
        wea   => memmap_property_ram_wr_en,
        addra => props_control.test_prop_read_write_memmap.wr_addr,
        dina  => props_control.test_prop_read_write_memmap.wr_data,
        clkb  => props_control.clk,
        enb   => '1',
        addrb => props_control.test_prop_read_write_memmap.rd_addr,
        doutb => props_status.test_prop_read_write_memmap.rd_data
      );
  end generate u_gen_xilinx_memmap_property_ram;
  u_gen_intel_memmap_property_ram : if (FINS_BACKEND = "quartus") generate
    u_memmap_property_ram : intel_memmap_property_ram
      port map (
        clock     => props_control.clk,
        wren      => props_control.test_prop_read_write_memmap.wr_en,
        wraddress => props_control.test_prop_read_write_memmap.wr_addr,
        data      => props_control.test_prop_read_write_memmap.wr_data,
        rdaddress => props_control.test_prop_read_write_memmap.rd_addr,
        q         => props_status.test_prop_read_write_memmap.rd_data
      );
  end generate u_gen_intel_memmap_property_ram;

  -- Remap the write enable to a std_logic_vector of width 1
  memmap_property_ram_wr_en(0) <= props_control.test_prop_read_write_memmap.wr_en;

  -- Synchronous process to delay the read enable 2 clocks
  s_memmap_property_ram : process (props_control.clk)
  begin
    if (rising_edge(props_control.clk)) then
      if (props_control.resetn = '0') then
        memmap_property_ram_rd_en_q  <= '0';
        memmap_property_ram_rd_en_qq <= '0';
      else
        memmap_property_ram_rd_en_q  <= props_control.test_prop_read_write_memmap.rd_en;
        memmap_property_ram_rd_en_qq <= memmap_property_ram_rd_en_q;
      end if;
    end if;
  end process s_memmap_property_ram;

  -- Assign the read valid to the delayed copy of the read enable due to the latency of the
  -- Simple Dual Port RAM
  props_status.test_prop_read_write_memmap.rd_valid <= memmap_property_ram_rd_en_qq;

  --------------------------------------------------------------------------------
  -- Testing elements for "write-only-memmap" and "read-only-memmap"
  --------------------------------------------------------------------------------
  -- Note: Since this property has a length of 1, the addresses are unused and
  --       the behavior mirrors an "external" property. This use case is unusual
  --       but is tested for completeness.

  -- Synchronous process for memmap property write
  s_memmap_property_register : process(props_control.clk)
  begin
    if (rising_edge(props_control.clk)) then
      if (props_control.resetn = '0') then
        memmap_property_register <= (others => '0');
      else
        if (props_control.test_prop_write_only_memmap.wr_en = '1') then
          memmap_property_register <= props_control.test_prop_write_only_memmap.wr_data;
        end if;
      end if;
    end if;
  end process s_memmap_property_register;

  -- Assign read signals to register written above
  props_status.test_prop_read_only_memmap.rd_valid <= props_control.test_prop_read_only_memmap.rd_en;
  props_status.test_prop_read_only_memmap.rd_data  <= memmap_property_register;

  --------------------------------------------------------------------------------
  -- Testing elements for "read-only-data"
  --------------------------------------------------------------------------------
  props_status.test_prop_read_only_data(0).rd_data <= std_logic_vector(to_unsigned(0, PROPS_DATA_WIDTH));
  props_status.test_prop_read_only_data(1).rd_data <= std_logic_vector(to_unsigned(1, PROPS_DATA_WIDTH));
  props_status.test_prop_read_only_data(2).rd_data <= std_logic_vector(to_unsigned(2, PROPS_DATA_WIDTH));
  props_status.test_prop_read_only_data(3).rd_data <= std_logic_vector(to_unsigned(3, PROPS_DATA_WIDTH));

end rtl;