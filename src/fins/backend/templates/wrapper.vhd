--==============================================================================
-- Company:     Geon Technologies, LLC
-- Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: Auto-generated top-level wrapper for a FINS module
-- Generated:   {{ now }}
-- Reset Type:  Synchronous
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- User Libraries
library work;
use work.{{ fins['name']|lower }}_pkg.all;

-- Entity
entity {{ fins['name']|lower }}_wrapper is
  port (
    {%- if 'properties' in fins %}
    S_AXI_ACLK    : in  std_logic;
    S_AXI_ARESETN : in  std_logic;
    S_AXI_AWADDR  : in  std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID : in  std_logic;
    S_AXI_AWREADY : out std_logic;
    S_AXI_WDATA   : in  std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB   : in  std_logic_vector((G_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID  : in  std_logic;
    S_AXI_WREADY  : out std_logic;
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_BVALID  : out std_logic;
    S_AXI_BREADY  : in  std_logic;
    S_AXI_ARADDR  : in  std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_ARVALID : in  std_logic;
    S_AXI_ARREADY : out std_logic;
    S_AXI_RDATA   : out std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_RVALID  : out std_logic;
    S_AXI_RREADY  : in  std_logic;
    {%- endif %}
  );
end {{ fins['name']|lower }}_wrapper;

-- Architecture
architecture rtl of {{ fins['name']|lower }}_wrapper is

  {%- if 'properties' in fins %}
  -- Auto-generated AXI4-Lite properties interface
  component {{ fins['name']|lower }}_axilite is
    generic (
      G_AXI_BYTE_INDEXED : boolean := {{ fins['properties']['is_addr_byte_indexed']|lower }};
      G_AXI_ADDR_WIDTH   : natural := {{ fins['properties']['addr_width'] }};
      G_AXI_DATA_WIDTH   : natural := {{ fins['properties']['data_width'] }}
    );
    port (
      S_AXI_ACLK    : in  std_logic;
      S_AXI_ARESETN : in  std_logic;
      S_AXI_AWADDR  : in  std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_AWVALID : in  std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA   : in  std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_vector((G_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID  : in  std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in  std_logic;
      S_AXI_ARADDR  : in  std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_ARVALID : in  std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in  std_logic;
      props_control : out t_{{ fins['name']|lower }}_props_control;
      props_status  : in  t_{{ fins['name']|lower }}_props_status
    );
  end component;
  {%- endif %}

begin

  ------------------------------------------------------------------------------
  -- AXI4-Lite: Output Assignments
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
  -- AXI4-Lite: Write
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
  -- AXI4-Lite: Read
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
          axi_rvalid  <= rd_valid;
          axi_rresp   <= "00"; -- 'OKAY' response
        elsif (read_active = '1') then
          -- Waiting for read valid
          axi_rvalid  <= rd_valid;
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
  -- Decoded Simple Signals
  ------------------------------------------------------------------------------
  -- Synchronous process for bus
  s_decoded_bus : process (S_AXI_ACLK)
  begin
    if (rising_edge(S_AXI_ACLK)) then
      --****************************************
      -- Data registers without reset
      --****************************************
      wr_data   <= S_AXI_WDATA;
      axi_rdata <= rd_data;

      --****************************************
      -- Control registers with reset
      --****************************************
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
          if (G_AXI_BYTE_INDEXED) then
            -- If byte indexed, remove the LSBs of the address used to index the bytes
            address <= std_logic_vector(shift_right(unsigned(axi_awaddr), ADDR_LSB));
          else
            address <= axi_awaddr;
          end if;
        else
          if (G_AXI_BYTE_INDEXED) then
            -- If byte indexed, remove the LSBs of the address used to index the bytes
            address <= std_logic_vector(shift_right(unsigned(axi_araddr), ADDR_LSB));
          else 
            address <= axi_araddr;
          end if;
        end if;

      end if;
    end if;
  end process s_decoded_bus;

  ------------------------------------------------------------------------------
  -- Register Decode, Read, and Write
  ------------------------------------------------------------------------------
  -- Synchronous Process for Register Write
  s_reg_write : process (S_AXI_ACLK)
  begin
    if (rising_edge(S_AXI_ACLK)) then
      --****************************************
      -- Data registers without reset
      --****************************************
      -- Pipeline the write data
      reg_wr_data <= wr_data;

      -- Pipeline the write address for all properties
      for prop_ix in 0 to NUM_PROPERTIES-1 loop
        reg_addr_foreach_prop(prop_ix) <= std_logic_vector(unsigned(address)-PROPERTIES_OFFSETS(prop_ix));
      end loop;

      --****************************************
      -- Control registers with reset
      --****************************************
      if (S_AXI_ARESETN = '0') then
        reg_wr_enables_foreach_addr <= (others => '0');
        reg_wr_enables_foreach_prop <= (others => '0');
      else
        -- Set defaults
        reg_wr_enables_foreach_addr <= (others => '0');
        reg_wr_enables_foreach_prop <= (others => '0');

        -- Loop through all registers
        for addr_ix in 0 to NUM_ADDRESSES-1 loop
          -- Decode Address
          if (addr_ix = unsigned(address)) then
            -- Set the write enables
            -- Note: The reg_wr_enables_foreach_prop(addr_ix) may be set multiple times
            --       by this loop; this behavior performs a reduction OR
            if (wr_enable = '1') then
              reg_wr_enables_foreach_addr(addr_ix) <= '1';
              reg_wr_enables_foreach_prop(ADDRESS_TO_PROPERTY_MAP(addr_ix)) <= '1';
            end if;
          end if;
        end loop;
      end if;
    end if;
  end process s_reg_write;

  -- Synchronous Process for Write of Local Registers
  s_reg_write_local : process (S_AXI_ACLK)
  begin
    if (rising_edge(S_AXI_ACLK)) then
      if (S_AXI_ARESETN = '0') then
        reg_wr_values_foreach_addr <= REG_DEFAULT_FOREACH_ADDR;
      else
        -- Loop through all registers and then all bits
        for addr_ix in 0 to NUM_ADDRESSES-1 loop
          for bit_ix in 0 to G_AXI_DATA_WIDTH-1 loop
            if (REG_WR_MASK_FOREACH_ADDR(addr_ix)(bit_ix) = '1') then
              -- The bit of the register is writable, write it when enabled at runtime, otherwise hold
              if (reg_wr_enables_foreach_addr(addr_ix) = '1') then
                reg_wr_values_foreach_addr(addr_ix)(bit_ix) <= reg_wr_data(bit_ix);
              end if;
            else
              -- The bit of the register is not writable, set it to default constant at compile time
              reg_wr_values_foreach_addr(addr_ix)(bit_ix) <= REG_DEFAULT_FOREACH_ADDR(addr_ix)(bit_ix);
            end if;
          end loop;
        end loop;
      end if;
    end if;
  end process s_reg_write_local;

  -- Synchronous Process for Register Read
  s_reg_read : process (S_AXI_ACLK)
  begin
    if (rising_edge(S_AXI_ACLK)) then
      if (S_AXI_ARESETN = '0') then
        reg_rd_enables_foreach_addr <= (others => '0');
        reg_rd_enables_foreach_prop <= (others => '0');
        rd_valid <= '0';
        rd_data <= ERROR_CODE(G_AXI_DATA_WIDTH-1 downto 0);
      else
        -- Set Default
        reg_rd_enables_foreach_addr <= (others => '0');
        reg_rd_enables_foreach_prop <= (others => '0');
        rd_valid <= rd_enable;
        rd_data <= ERROR_CODE(G_AXI_DATA_WIDTH-1 downto 0);

        -- Loop through Registers
        for addr_ix in 0 to NUM_ADDRESSES-1 loop
          -- Decode Address
          if (addr_ix = unsigned(address)) then
            -- Set read signals
            -- Note: The reg_rd_enables_foreach_prop(addr_ix) may be set multiple times
            --       by this loop; this behavior performs a reduction OR
            if (rd_enable = '1') then
              reg_rd_enables_foreach_addr(addr_ix) <= '1';
              reg_rd_enables_foreach_prop(ADDRESS_TO_PROPERTY_MAP(addr_ix)) <= '1';
            end if;
            rd_valid <= reg_rd_valids_foreach_addr(addr_ix);
            rd_data <= reg_rd_values_foreach_addr(addr_ix);
          end if;
        end loop;
      end if;
    end if;
  end process s_reg_read;

  ------------------------------------------------------------------------------
  -- Input/Output Assignment for Properties
  ------------------------------------------------------------------------------
  -- Combinatorial Process to Remap Property Control Signals
  c_props_control : process (
    reg_wr_enables_foreach_addr,
    reg_rd_enables_foreach_addr,
    reg_wr_values_foreach_addr,
    reg_wr_enables_foreach_prop,
    reg_rd_enables_foreach_prop,
    reg_addr_foreach_prop,
    reg_wr_data
  )
  begin
    {%- for prop in fins['properties']['properties'] %}
    {%- if (prop['length'] > 1) %}
    {%- if ('memmap' in prop['type']) %}
    {%- if prop['type'] == 'read-only-memmap' %}
    -- Remap control signals for read-only-memmap sequence property
    props_control.{{ prop['name'] }}.rd_en   <= reg_rd_enables_foreach_prop({{ loop.index0 }});
    props_control.{{ prop['name'] }}.rd_addr <= reg_addr_foreach_prop({{ loop.index0 }})(integer(ceil(log2(real({{ prop['length'] }}))))-1 downto 0);
    {%- elif prop['type'] == 'write-only-memmap' %}
    -- Remap control signals for write-only-memmap sequence property
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
    props_control.{{ prop['name'] }}.wr_en   <= reg_wr_enables_foreach_prop({{ loop.index0 }});
    props_control.{{ prop['name'] }}.wr_addr <= reg_addr_foreach_prop({{ loop.index0 }})(integer(ceil(log2(real({{ prop['length'] }}))))-1 downto 0);
    {%- elif prop['type'] == 'read-write-memmap' %}
    -- Remap control signals for read-write-memmap sequence property
    props_control.{{ prop['name'] }}.rd_en   <= reg_rd_enables_foreach_prop({{ loop.index0 }});
    props_control.{{ prop['name'] }}.rd_addr <= reg_addr_foreach_prop({{ loop.index0 }})(integer(ceil(log2(real({{ prop['length'] }}))))-1 downto 0);
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
    props_control.{{ prop['name'] }}.wr_en   <= reg_wr_enables_foreach_prop({{ loop.index0 }});
    props_control.{{ prop['name'] }}.wr_addr <= reg_addr_foreach_prop({{ loop.index0 }})(integer(ceil(log2(real({{ prop['length'] }}))))-1 downto 0);
    {%- endif %}
    {%- else %}
    {%- if prop['type'] == 'read-only-external' %}
    -- Remap control signals by looping through the elements of read-only-external sequence property
    for ix in 0 to {{ prop['length'] }}-1 loop
      props_control.{{ prop['name'] }}(ix).rd_en   <= reg_rd_enables_foreach_addr({{ prop['offset'] }}+ix);
    end loop;
    {%- elif prop['type'] == 'write-only-external' %}
    -- Remap control signals by looping through the elements of write-only-external sequence property
    for ix in 0 to {{ prop['length'] }}-1 loop
      props_control.{{ prop['name'] }}(ix).wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
      props_control.{{ prop['name'] }}(ix).wr_en   <= reg_wr_enables_foreach_addr({{ prop['offset'] }}+ix);
    end loop;
    {%- elif prop['type'] == 'read-write-data' %}
    -- Remap control signals by looping through the elements of read-write-data sequence property
    for ix in 0 to {{ prop['length'] }}-1 loop
      props_control.{{ prop['name'] }}(ix).wr_data <= reg_wr_values_foreach_addr({{ prop['offset'] }}+ix)({{ prop['width'] }}-1 downto 0);
    end loop;
    {%- elif prop['type'] == 'read-write-external' %}
    -- Remap control signals by looping through the elements of read-write-external sequence property
    for ix in 0 to {{ prop['length'] }}-1 loop
      props_control.{{ prop['name'] }}(ix).rd_en   <= reg_rd_enables_foreach_addr({{ prop['offset'] }}+ix);
      props_control.{{ prop['name'] }}(ix).wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
      props_control.{{ prop['name'] }}(ix).wr_en   <= reg_wr_enables_foreach_addr({{ prop['offset'] }}+ix);
    end loop;
    {%- endif %}
    {%- endif %}
    {%- else %}
    {%- if prop['type'] == 'read-only-external' %}
    -- Remap control signals for non-sequence read-only-external property
    props_control.{{ prop['name'] }}.rd_en   <= reg_rd_enables_foreach_addr({{ prop['offset'] }});
    {%- elif prop['type'] == 'read-only-memmap' %}
    -- Remap control signals for non-sequence read-only-memmap property
    props_control.{{ prop['name'] }}.rd_en   <= reg_rd_enables_foreach_addr({{ prop['offset'] }});
    props_control.{{ prop['name'] }}.rd_addr <= (others => '0');
    {%- elif prop['type'] == 'write-only-external' %}
    -- Remap control signals for non-sequence write-only-external property
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
    props_control.{{ prop['name'] }}.wr_en   <= reg_wr_enables_foreach_addr({{ prop['offset'] }});
    {%- elif prop['type'] == 'write-only-memmap' %}
    -- Remap control signals for non-sequence write-only-memmap property
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
    props_control.{{ prop['name'] }}.wr_en   <= reg_wr_enables_foreach_addr({{ prop['offset'] }});
    props_control.{{ prop['name'] }}.wr_addr <= (others => '0');
    {%- elif prop['type'] == 'read-write-data' %}
    -- Remap control signals for non-sequence read-write-data property
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_values_foreach_addr({{ prop['offset'] }})({{ prop['width'] }}-1 downto 0);
    {%- elif prop['type'] == 'read-write-external' %}
    -- Remap control signals for non-sequence read-write-external property
    props_control.{{ prop['name'] }}.rd_en   <= reg_rd_enables_foreach_addr({{ prop['offset'] }});
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
    props_control.{{ prop['name'] }}.wr_en   <= reg_wr_enables_foreach_addr({{ prop['offset'] }});
    {%- elif prop['type'] == 'read-write-memmap' %}
    -- Remap control signals for non-sequence read-write-memmap property
    props_control.{{ prop['name'] }}.rd_en   <= reg_rd_enables_foreach_addr({{ prop['offset'] }});
    props_control.{{ prop['name'] }}.rd_addr <= (others => '0');
    props_control.{{ prop['name'] }}.wr_data <= reg_wr_data({{ prop['width'] }}-1 downto 0);
    props_control.{{ prop['name'] }}.wr_en   <= reg_wr_enables_foreach_addr({{ prop['offset'] }});
    props_control.{{ prop['name'] }}.wr_addr <= (others => '0');
    {%- endif %}
    {%- endif %}
    {%- endfor %}
  end process c_props_control;

  -- Synchronous Process to Assign Inputs
  s_props_status : process (S_AXI_ACLK)
  begin
    if (rising_edge(S_AXI_ACLK)) then
      --****************************************
      -- Data registers without reset
      --****************************************
      -- Set defaults
      -- NOTE: The default case covers read responses from internal registers and invalid addresses
      reg_rd_values_foreach_addr <= reg_wr_values_foreach_addr;

      {%- for prop in fins['properties']['properties'] %}
      {%- if (prop['length'] > 1) %}
      {%- if ('memmap' in prop['type']) %}
      {%- if prop['type'] != 'write-only-memmap' %}
      -- Assign read values by looping through the elements of sequence memmap property
      for ix in 0 to {{ prop['length'] }}-1 loop
        reg_rd_values_foreach_addr({{ prop['offset'] }}+ix)({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}.rd_data;
      end loop;
      {%- endif %}
      {%- else %}
      {%- if prop['type'] == 'read-only-data' %}
      -- Assign read values by looping through the elements of sequence read-only-data property
      for ix in 0 to {{ prop['length'] }}-1 loop
        reg_rd_values_foreach_addr({{ prop['offset'] }}+ix)({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}(ix).rd_data;
      end loop;
      {%- elif prop['type'] == 'read-only-external' %}
      -- Assign read values by looping through the elements of sequence read-only-external property
      for ix in 0 to {{ prop['length'] }}-1 loop
        reg_rd_values_foreach_addr({{ prop['offset'] }}+ix)({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}(ix).rd_data;
      end loop;
      {%- elif prop['type'] == 'read-write-external' %}
      -- Assign read values by looping through the elements of sequence read-write-external property
      for ix in 0 to {{ prop['length'] }}-1 loop
        reg_rd_values_foreach_addr({{ prop['offset'] }}+ix)({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}(ix).rd_data;
      end loop;
      {%- endif %}
      {%- endif %}
      {%- else %}
      {%- if prop['type'] == 'read-only-data' %}
      -- Assign read value for non-sequence read-only-data property
      reg_rd_values_foreach_addr({{ prop['offset'] }})({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}.rd_data;
      {%- elif prop['type'] == 'read-only-external' %}
      -- Assign read value for non-sequence read-only-external property
      reg_rd_values_foreach_addr({{ prop['offset'] }})({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}.rd_data;
      {%- elif prop['type'] == 'read-only-memmap' %}
      -- Assign read value for non-sequence read-only-memmap property
      reg_rd_values_foreach_addr({{ prop['offset'] }})({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}.rd_data;
      {%- elif prop['type'] == 'read-write-external' %}
      -- Assign read value for non-sequence read-write-external property
      reg_rd_values_foreach_addr({{ prop['offset'] }})({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}.rd_data;
      {%- elif prop['type'] == 'read-write-memmap' %}
      -- Assign read value for non-sequence read-write-memmap property
      reg_rd_values_foreach_addr({{ prop['offset'] }})({{ prop['width'] }}-1 downto 0) <= props_status.{{ prop['name'] }}.rd_data;
      {%- endif %}
      {%- endif %}
      {%- endfor %}

      --****************************************
      -- Control registers with reset
      --****************************************
      if (S_AXI_ARESETN = '0') then
        reg_rd_valids_foreach_addr <= (others => '0');
      else
        -- Set defaults
        -- NOTE: The default case covers read responses from internal registers and invalid addresses
        reg_rd_valids_foreach_addr <= reg_rd_enables_foreach_addr;

        {%- for prop in fins['properties']['properties'] %}
        {%- if (prop['length'] > 1) %}
        {%- if ('memmap' in prop['type']) %}
        {%- if prop['type'] != 'write-only-memmap' %}
        -- Assign read valids by looping through the elements of sequence memmap property
        for ix in 0 to {{ prop['length'] }}-1 loop
          reg_rd_valids_foreach_addr({{ prop['offset'] }}+ix) <= props_status.{{ prop['name'] }}.rd_valid;
        end loop;
        {%- endif %}
        {%- else %}
        {%- if prop['type'] == 'read-only-external' %}
        -- Assign read valids by looping through the elements of sequence read-only-external property
        for ix in 0 to {{ prop['length'] }}-1 loop
          reg_rd_valids_foreach_addr({{ prop['offset'] }}+ix) <= props_status.{{ prop['name'] }}(ix).rd_valid;
        end loop;
        {%- elif prop['type'] == 'read-write-external' %}
        -- Assign read valids by looping through the elements of sequence read-write-external property
        for ix in 0 to {{ prop['length'] }}-1 loop
          reg_rd_valids_foreach_addr({{ prop['offset'] }}+ix) <= props_status.{{ prop['name'] }}(ix).rd_valid;;
        end loop;
        {%- endif %}
        {%- endif %}
        {%- else %}
        {%- if prop['type'] == 'read-only-external' %}
        -- Assign read valid for non-sequence read-only-external property
        reg_rd_valids_foreach_addr({{ prop['offset'] }}) <= props_status.{{ prop['name'] }}.rd_valid;
        {%- elif prop['type'] == 'read-only-memmap' %}
        -- Assign read valid for non-sequence read-only-memmap property
        reg_rd_valids_foreach_addr({{ prop['offset'] }}) <= props_status.{{ prop['name'] }}.rd_valid;
        {%- elif prop['type'] == 'read-write-external' %}
        -- Assign read valid for non-sequence read-write-external property
        reg_rd_valids_foreach_addr({{ prop['offset'] }}) <= props_status.{{ prop['name'] }}.rd_valid;
        {%- elif prop['type'] == 'read-write-memmap' %}
        -- Assign read valid for non-sequence read-write-memmap property
        reg_rd_valids_foreach_addr({{ prop['offset'] }}) <= props_status.{{ prop['name'] }}.rd_valid;
        {%- endif %}
        {%- endif %}
        {%- endfor %}
      end if;
    end if;
  end process s_props_status;

end rtl;