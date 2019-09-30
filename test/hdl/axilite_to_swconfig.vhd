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

-- Entity
entity axilite_to_swconfig is
  generic (
    G_AXI_DATA_WIDTH : integer := 32;
    G_AXI_ADDR_WIDTH : integer := 16
  );
  port (
    -- AXI4-Lite Bus
    S_AXI_ACLK           : in  std_logic;
    S_AXI_ARESETN        : in  std_logic;
    S_AXI_AWADDR         : in  std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWPROT         : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID        : in  std_logic;
    S_AXI_AWREADY        : out std_logic;
    S_AXI_WDATA          : in  std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB          : in  std_logic_vector((G_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID         : in  std_logic;
    S_AXI_WREADY         : out std_logic;
    S_AXI_BRESP          : out std_logic_vector(1 downto 0);
    S_AXI_BVALID         : out std_logic;
    S_AXI_BREADY         : in  std_logic;
    S_AXI_ARADDR         : in  std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARPROT         : in  std_logic_vector(2 downto 0);
    S_AXI_ARVALID        : in  std_logic;
    S_AXI_ARREADY        : out std_logic;
    S_AXI_RDATA          : out std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP          : out std_logic_vector(1 downto 0);
    S_AXI_RVALID         : out std_logic;
    S_AXI_RREADY         : in  std_logic;
    -- Software Configuration Bus
    m_swconfig_clk       : out std_logic;
    m_swconfig_reset     : out std_logic;
    m_swconfig_address   : out std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
    m_swconfig_wr_enable : out std_logic;
    m_swconfig_wr_data   : out std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
    m_swconfig_rd_enable : out std_logic;
    m_swconfig_rd_valid  : in  std_logic;
    m_swconfig_rd_data   : in  std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0)
  );
end axilite_to_swconfig;

-- Architecture
architecture rtl of axilite_to_swconfig is

  ------------------------------------------------------------------------------
  -- Attributes
  ------------------------------------------------------------------------------
  -- Instruct IP Integrator to infer interface
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of m_swconfig_clk       : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG CLK";
  attribute X_INTERFACE_INFO of m_swconfig_reset     : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG RESET";
  attribute X_INTERFACE_INFO of m_swconfig_address   : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG ADDRESS";
  attribute X_INTERFACE_INFO of m_swconfig_wr_enable : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG WR_ENABLE";
  attribute X_INTERFACE_INFO of m_swconfig_wr_data   : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG WR_DATA";
  attribute X_INTERFACE_INFO of m_swconfig_rd_enable : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG RD_ENABLE";
  attribute X_INTERFACE_INFO of m_swconfig_rd_valid  : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG RD_VALID";
  attribute X_INTERFACE_INFO of m_swconfig_rd_data   : signal is "geontech.com:user:swconfig:1.0 M_SWCONFIG RD_DATA";

  ------------------------------------------------------------------------------
  -- AXI-Lite Signals
  ------------------------------------------------------------------------------
  signal axi_awaddr  : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
  signal axi_awready : std_logic;
  signal axi_wready  : std_logic;
  signal axi_bresp   : std_logic_vector(1 downto 0);
  signal axi_bvalid  : std_logic;
  signal axi_araddr  : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
  signal axi_arready : std_logic;
  signal axi_rdata   : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
  signal axi_rresp   : std_logic_vector(1 downto 0);
  signal axi_rvalid  : std_logic;
  signal read_active : std_logic;
  
  ------------------------------------------------------------------------------
  -- Software Configuration Bus Signals
  ------------------------------------------------------------------------------
  signal address     : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
  signal wr_enable   : std_logic;
  signal wr_data     : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
  signal rd_enable   : std_logic;
  
begin

  ------------------------------------------------------------------------------
  -- AXI-Lite: Output Assignments
  ------------------------------------------------------------------------------
  -- I/O Connections assignments
  S_AXI_AWREADY <= axi_awready;
  S_AXI_WREADY  <= axi_wready;
  S_AXI_BRESP   <= axi_bresp;
  S_AXI_BVALID  <= axi_bvalid;
  S_AXI_ARREADY <= axi_arready;
  S_AXI_RDATA   <= axi_rdata;
  S_AXI_RRESP   <= axi_rresp;
  S_AXI_RVALID  <= axi_rvalid;
  
  ------------------------------------------------------------------------------
  -- AXI-Lite: Write
  ------------------------------------------------------------------------------
  -- Implement axi_awready generation
  -- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
  -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
  -- de-asserted when reset is low.
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then 
      if S_AXI_ARESETN = '0' then
        axi_awready <= '0';
      else
        if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
          -- slave is ready to accept write address when
          -- there is a valid write address and write data
          -- on the write address and data bus. This design 
          -- expects no outstanding transactions. 
          axi_awready <= '1';
        else
          axi_awready <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Implement axi_awaddr latching
  -- This process is used to latch the address when both 
  -- S_AXI_AWVALID and S_AXI_WVALID are valid. 
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then 
      if S_AXI_ARESETN = '0' then
        axi_awaddr <= (others => '0');
      else
        if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
          -- Write Address latching
          axi_awaddr <= S_AXI_AWADDR;
        end if;
      end if;
    end if;                   
  end process; 

  -- Implement axi_wready generation
  -- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
  -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
  -- de-asserted when reset is low. 
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then 
      if S_AXI_ARESETN = '0' then
        axi_wready <= '0';
      else
        if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1') then
            -- slave is ready to accept write data when 
            -- there is a valid write address and write data
            -- on the write address and data bus. This design 
            -- expects no outstanding transactions.           
            axi_wready <= '1';
        else
          axi_wready <= '0';
        end if;
      end if;
    end if;
  end process; 

  -- Implement write response logic generation
  -- The write response and response valid signals are asserted by the slave 
  -- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
  -- This marks the acceptance of address and indicates the status of 
  -- write transaction.
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then 
      if S_AXI_ARESETN = '0' then
        axi_bvalid  <= '0';
        axi_bresp   <= "00"; --need to work more on the responses
      else
        if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
          axi_bvalid <= '1';
          axi_bresp  <= "00"; 
        elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
          axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
        end if;
      end if;
    end if;                   
  end process; 

  ------------------------------------------------------------------------------
  -- AXI-Lite: Read
  ------------------------------------------------------------------------------
  -- Implement axi_arready generation
  -- axi_arready is asserted for one S_AXI_ACLK clock cycle when
  -- S_AXI_ARVALID is asserted. axi_awready is 
  -- de-asserted when reset (active low) is asserted. 
  -- The read address is also latched when S_AXI_ARVALID is 
  -- asserted. axi_araddr is reset to zero on reset assertion.
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then 
      if S_AXI_ARESETN = '0' then
        axi_arready <= '0';
        axi_araddr  <= (others => '1');
      else
        if (axi_arready = '0' and S_AXI_ARVALID = '1') then
          -- indicates that the slave has acceped the valid read address
          axi_arready <= '1';
          -- Read Address latching 
          axi_araddr  <= S_AXI_ARADDR;           
        else
          axi_arready <= '0';
        end if;
      end if;
    end if;                   
  end process; 

  -- Implement axi_arvalid generation
  -- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
  -- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
  -- data are available on the axi_rdata bus at this instance. The 
  -- assertion of axi_rvalid marks the validity of read data on the 
  -- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
  -- is deasserted on reset (active low). axi_rresp and axi_rdata are 
  -- cleared to zero on reset (active low).  
  process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if S_AXI_ARESETN = '0' then
        axi_rvalid  <= '0';
        axi_rresp   <= "00";
        read_active <= '0';
      else
        if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
          -- Valid read data is available at the read data bus
          read_active <= '1';
          axi_rvalid  <= m_swconfig_rd_valid;
          axi_rresp   <= "00"; -- 'OKAY' response
        elsif (read_active = '1') then
          -- Waiting for read valid from swconfig bus
          axi_rvalid  <= m_swconfig_rd_valid;
          axi_rresp   <= "00"; -- 'OKAY' response
          if (axi_rvalid = '1' and S_AXI_RREADY = '1') then
            -- Read data is accepted by the master
            read_active <= '0';
            axi_rvalid  <= '0';
          end if;
        end if;            
      end if;
    end if;
  end process;
  
  ------------------------------------------------------------------------------
  -- Software Configuration Bus
  ------------------------------------------------------------------------------
  -- Assign Outputs
  m_swconfig_clk       <= S_AXI_ACLK;
  m_swconfig_reset     <= not S_AXI_ARESETN;
  m_swconfig_address   <= address;
  m_swconfig_wr_enable <= wr_enable;
  m_swconfig_wr_data   <= wr_data;
  m_swconfig_rd_enable <= rd_enable;
  
  -- Synchronous process for bus
  s_swconfig_bus : process (S_AXI_ACLK)
  begin
    if (rising_edge(S_AXI_ACLK)) then
      -- No reset needed for data buses
      wr_data   <= S_AXI_WDATA;
      axi_rdata <= m_swconfig_rd_data;
      
      -- Reset required for control signals
      if (S_AXI_ARESETN = '0') then
        wr_enable <= '0';
        rd_enable <= '0';
        address   <= (others => '1');
      else
        -- Enables
        wr_enable <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID;
        rd_enable <= axi_arready and S_AXI_ARVALID and (not axi_rvalid);
      
        -- Address: Give preference to a write over a read
        if (S_AXI_AWVALID = '1') then
          address <= axi_awaddr;
        else
          address <= axi_araddr;
        end if;
        
      end if;
    end if;
  end process s_swconfig_bus;

end rtl;