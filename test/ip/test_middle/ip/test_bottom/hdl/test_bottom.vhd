--==============================================================================
-- Company:     Geon Technologies, LLC
-- Author:      Josh Schindehette
-- Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: This is the top level of the FINS test module
-- Reset Type:  Synchronous
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- User Libraries
library work;
use work.test_bottom_pkg.all;

-- Entity
entity test_bottom is
  port (
    -- AXI-Stream Bus for Ports
    s_axis_myinput_tvalid  : in  std_logic;
    s_axis_myinput_tlast   : in  std_logic;
    s_axis_myinput_tdata   : in  std_logic_vector(PORTS_WIDTH-1 downto 0);
    m_axis_myoutput_tvalid : out std_logic;
    m_axis_myoutput_tlast  : out std_logic;
    m_axis_myoutput_tdata  : out std_logic_vector(PORTS_WIDTH-1 downto 0);
    -- Software Configuration Bus for Properties
    s_swconfig_clk         : in  std_logic;
    s_swconfig_reset       : in  std_logic;
    s_swconfig_address     : in  std_logic_vector(PROPS_ADDR_WIDTH-1 downto 0);
    s_swconfig_wr_enable   : in  std_logic;
    s_swconfig_wr_data     : in  std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
    s_swconfig_rd_enable   : in  std_logic;
    s_swconfig_rd_valid    : out std_logic;
    s_swconfig_rd_data     : out std_logic_vector(PROPS_DATA_WIDTH-1 downto 0)
  );
end entity test_bottom;

-- Architecture
architecture mixed of test_bottom is

  --------------------------------------------------------------------------------
  -- Constants
  --------------------------------------------------------------------------------
  constant TEST_RAM_ADDR_WIDTH : natural := integer(ceil(log2(real(TEST_RAM_DEPTH))));

  --------------------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------------------
  -- Autogenerated FINS HDL
  component test_bottom_swconfig is
    generic (
      G_BYTE_INDEXED : boolean := PROPS_IS_ADDR_BYTE_INDEXED;
      G_ADDR_WIDTH   : natural := PROPS_ADDR_WIDTH;
      G_DATA_WIDTH   : natural := PROPS_DATA_WIDTH
    );
    port (
      s_swconfig_clk       : in  std_logic;
      s_swconfig_reset     : in  std_logic;
      s_swconfig_address   : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
      s_swconfig_wr_enable : in  std_logic;
      s_swconfig_wr_data   : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
      s_swconfig_rd_enable : in  std_logic;
      s_swconfig_rd_valid  : out std_logic;
      s_swconfig_rd_data   : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
      props_control        : out t_test_bottom_props_control;
      props_status         : in  t_test_bottom_props_status
    );
  end component;

  -- Xilinx IP created by external_property_fifo.tcl script
  component external_property_fifo
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
  component memmap_property_ram
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

  --------------------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------------------
  signal props_control                : t_test_bottom_props_control;
  signal props_status                 : t_test_bottom_props_status;
  signal external_property_register   : std_logic_vector(props_control.test_prop_write_only_external.wr_data'length-1 downto 0);
  signal memmap_property_ram_wr_en    : std_logic_vector(0 downto 0);
  signal memmap_property_ram_rd_en_q  : std_logic;
  signal memmap_property_ram_rd_en_qq : std_logic;
  signal memmap_property_register     : std_logic_vector(PROPS_DATA_WIDTH-1 downto 0);
  signal axis_myinput_tvalid          : std_logic;
  signal axis_myinput_tlast           : std_logic;
  signal axis_myinput_tdata           : std_logic_vector(PORTS_WIDTH-1 downto 0);
  signal axis_myinput_tvalid_q        : std_logic;
  signal axis_myinput_tlast_q         : std_logic;
  signal axis_myinput_tdata_q         : std_logic_vector(PORTS_WIDTH-1 downto 0);
  signal external_property_fifo_rd_en : std_logic;

begin

  --------------------------------------------------------------------------------
  -- Data Processing
  --------------------------------------------------------------------------------
  -- Synchronous process for data processsing
  s_data_processing : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      -- Data pipelines
      axis_myinput_tdata   <= s_axis_myinput_tdata;
      axis_myinput_tdata_q <= std_logic_vector(
        resize(
          unsigned(axis_myinput_tdata) * to_unsigned(TEST_PARAM_INTEGER, axis_myinput_tdata'length),
          axis_myinput_tdata'length
        )
      );
      -- Control pipelines
      if (s_swconfig_reset = '1') then
        axis_myinput_tvalid   <= '0';
        axis_myinput_tlast    <= '0';
        axis_myinput_tvalid_q <= '0';
        axis_myinput_tlast_q  <= '0';
      else
        axis_myinput_tvalid   <= s_axis_myinput_tvalid;
        axis_myinput_tlast    <= s_axis_myinput_tlast;
        axis_myinput_tvalid_q <= axis_myinput_tvalid;
        axis_myinput_tlast_q  <= axis_myinput_tlast;
      end if;
    end if;
  end process s_data_processing;

  -- Assign output ports
  m_axis_myoutput_tvalid <= axis_myinput_tvalid_q;
  m_axis_myoutput_tlast  <= axis_myinput_tlast_q;
  m_axis_myoutput_tdata  <= axis_myinput_tdata_q;

  --------------------------------------------------------------------------------
  -- Properties
  --------------------------------------------------------------------------------
  -- Instantiate the auto-generated Software Configuration module
  u_properties : test_bottom_swconfig
    port map (
      s_swconfig_clk       => s_swconfig_clk       ,
      s_swconfig_reset     => s_swconfig_reset     ,
      s_swconfig_address   => s_swconfig_address   ,
      s_swconfig_wr_enable => s_swconfig_wr_enable ,
      s_swconfig_wr_data   => s_swconfig_wr_data   ,
      s_swconfig_rd_enable => s_swconfig_rd_enable ,
      s_swconfig_rd_valid  => s_swconfig_rd_valid  ,
      s_swconfig_rd_data   => s_swconfig_rd_data   ,
      props_control        => props_control        ,
      props_status         => props_status         
    );

  --------------------------------------------------------------------------------
  -- Testing elements for "read-write-external"
  --------------------------------------------------------------------------------
  -- FWFT FIFO instantitation for test
  u_external_property_fifo : external_property_fifo
    port map (
      clk   => s_swconfig_clk,
      srst  => s_swconfig_reset,
      din   => props_control.test_prop_read_write_external.wr_data,
      wr_en => props_control.test_prop_read_write_external.wr_en,
      rd_en => external_property_fifo_rd_en,
      dout  => props_status.test_prop_read_write_external.rd_data,
      full  => open,
      empty => open
    );

  -- Synchronous process to delay the fifo read enable one clock just due to this FIFO's timing
  s_external_property_fifo : process(s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      if (s_swconfig_reset = '1') then
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
  s_external_property_register : process(s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      if (s_swconfig_reset = '1') then
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
  u_memmap_property_ram : memmap_property_ram
    port map (
      clka  => s_swconfig_clk,
      ena   => '1',
      wea   => memmap_property_ram_wr_en,
      addra => props_control.test_prop_read_write_memmap.wr_addr,
      dina  => props_control.test_prop_read_write_memmap.wr_data,
      clkb  => s_swconfig_clk,
      enb   => '1',
      addrb => props_control.test_prop_read_write_memmap.rd_addr,
      doutb => props_status.test_prop_read_write_memmap.rd_data
    );

  -- Remap the write enable to a std_logic_vector of width 1
  memmap_property_ram_wr_en(0) <= props_control.test_prop_read_write_memmap.wr_en;

  -- Synchronous process to delay the read enable 2 clocks
  s_memmap_property_ram : process (s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      if (s_swconfig_reset = '1') then
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
  s_memmap_property_register : process(s_swconfig_clk)
  begin
    if (rising_edge(s_swconfig_clk)) then
      if (s_swconfig_reset = '1') then
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

end mixed;
