--==============================================================================
-- Company:     Geon Technologies, LLC
-- Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this 
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: Auto-generated AXI-Lite Bus register decode
-- Generated:   {{ now }}
-- Reset Type:  Synchronous
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity
entity {{ fins['name'] }}_axilite is
  generic (
    G_AXI_ADDR_WIDTH : natural := {{ fins['axilite']['addr_width'] }};
    G_AXI_DATA_WIDTH : natural := {{ fins['axilite']['data_width'] }}
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
    {%- for reg in fins['axilite']['regs'] | selectattr('is_writable') | selectattr('write_ports', 'ne', 'internal') | list %}
    {%- if (reg['write_ports'] | lower) == 'remote' %}
    reg_{{ reg['name'] }}_wr_en    : out std_logic_vector({{ reg['length'] }}-1 downto 0);
    {%- endif %}
    reg_{{ reg['name'] }}_wr_data  : out std_logic_vector({{ reg['width'] }}*{{ reg['length'] }}-1 downto 0)
    {%- if (fins['axilite']['regs'] | selectattr('is_readable') | selectattr('read_ports', 'ne', 'internal') | list | length > 0) or (not loop.last) %};{% endif %}
    {%- endfor %}
    {%- for reg in fins['axilite']['regs'] | selectattr('is_readable') | selectattr('read_ports', 'ne', 'internal') | list %}
    {%- if (reg['read_ports'] | lower) == 'remote' %}
    reg_{{ reg['name'] }}_rd_en    : out std_logic_vector({{ reg['length'] }}-1 downto 0);
    reg_{{ reg['name'] }}_rd_valid : in  std_logic_vector({{ reg['length'] }}-1 downto 0);
    {%- endif %}
    reg_{{ reg['name'] }}_rd_data  : in  std_logic_vector({{ reg['width'] }}*{{ reg['length'] }}-1 downto 0)
    {%- if not loop.last %};{% endif %}
    {%- endfor %}
  );
end {{ fins['name'] }}_axilite;

-- Architecture
architecture rtl of {{ fins['name'] }}_axilite is

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- Error code when address does not correspond to a register
  constant ERROR_CODE : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0) := x"BADADD00";

  -- The number of LSBs that are unused due to byte addressing of AXI-Lite
  constant ADDR_LSB : natural := 2;

  -- The total number of physical registers (addresses)
  -- * Logical registers can have a length>1, so this is the sum of all logical
  --   register lengths
  constant NUM_REGS : natural := {{ fins['axilite']['regs']|sum(attribute='length') }};

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
  -- Decoded Simple Signals
  ------------------------------------------------------------------------------
  signal address     : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0);
  signal wr_enable   : std_logic;
  signal wr_data     : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
  signal rd_enable   : std_logic;
  signal rd_valid    : std_logic;
  signal rd_data     : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);

  ------------------------------------------------------------------------------
  -- Register Signals
  ------------------------------------------------------------------------------
  signal reg_wr_enables : std_logic_vector(NUM_REGS-1 downto 0);               -- Registered Array of Decoded Write Enables
  signal reg_wr_values  : std_logic_vector(G_AXI_DATA_WIDTH*NUM_REGS-1 downto 0);  -- Registered Array Writable Local Registers
  signal reg_wr_data    : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);           -- Registered Write Data
  signal reg_rd_enables : std_logic_vector(NUM_REGS-1 downto 0);               -- Registered Array of Decoded Read Enables
  signal reg_rd_valids  : std_logic_vector(NUM_REGS-1 downto 0);               -- Non-registered Array of Decoded Read Valids
  signal reg_rd_values  : std_logic_vector(G_AXI_DATA_WIDTH*NUM_REGS-1 downto 0);  -- Non-registered Array of Read Data

  -- Default for Local Registers
  constant reg_default : std_logic_vector(G_AXI_DATA_WIDTH*NUM_REGS-1 downto 0) :=
    {%- for reg in fins['axilite']['regs']|reverse|list %}
    {%- set reg_loop = loop %}
    {%- for value in reg['default_values']|reverse|list %}
    {%- if reg['is_signed'] %}
    std_logic_vector(resize(to_signed({{ value }}, {{ reg['width'] }}), G_AXI_DATA_WIDTH))
    {%- else %}
    std_logic_vector(resize(to_unsigned({{ value }}, {{ reg['width'] }}), G_AXI_DATA_WIDTH))
    {%- endif %}
    {%- if loop.last and reg_loop.last %};{% else %} &{% endif %} -- {{ reg['name'] }}, {% if reg['is_writable'] %}WRITE:{{ reg['write_ports'] }}, {% endif %}{% if reg['is_readable'] %}READ:{{ reg['read_ports'] }}{% endif %}
    {%- endfor %}
    {%- endfor %}

  -- The Bit Mask for Writable Local Register Values
  -- Note: The mask prevents bits from being written in invalid areas.
  --       Remote registers have an entry here, but they are set to all zeros 
  --       since the write is happing in a remote location
  constant reg_wr_mask : std_logic_vector(G_AXI_DATA_WIDTH*NUM_REGS-1 downto 0) :=
    {%- for reg in fins['axilite']['regs']|reverse|list %}
    {%- set reg_loop = loop %}
    {%- for n in range(reg['length']) %}
    {%- if (reg['write_ports'] | lower) == 'remote' %}
    x"00000000"
    {%- elif reg['is_writable'] and ((reg['width'] == 32) or (reg['width'] == '32')) %}
    x"FFFFFFFF"
    {%- else %}
    std_logic_vector(resize(unsigned(to_signed({% if reg['is_writable'] %}-1{% else %}0{% endif %}, {{ reg['width'] }})), G_AXI_DATA_WIDTH))
    {%- endif %}
    {%- if loop.last and reg_loop.last %};{% else %} &{% endif %} -- {{ reg['name'] }}, {% if reg['is_writable'] %}WRITE:{{ reg['write_ports'] }}, {% endif %}{% if reg['is_readable'] %}READ:{{ reg['read_ports'] }}{% endif %}
    {%- endfor %}
    {%- endfor %}

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
      -- No reset needed for data buses
      wr_data   <= S_AXI_WDATA;
      axi_rdata <= rd_data;

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
          address <= std_logic_vector(shift_right(unsigned(axi_awaddr), ADDR_LSB));
        else
          address <= std_logic_vector(shift_right(unsigned(axi_araddr), ADDR_LSB));
        end if;

      end if;
    end if;
  end process s_decoded_bus;

  ------------------------------------------------------------------------------
  -- Register Decode
  ------------------------------------------------------------------------------
  -- Synchronous Process for Register Write
  s_reg_write : process (S_AXI_ACLK)
  begin
    if (rising_edge(S_AXI_ACLK)) then
      -- Pipeline the write data for all registers
      reg_wr_data <= wr_data;
      -- Control signals for the write
      if (S_AXI_ARESETN = '0') then
        reg_wr_enables <= (others => '0');
      else
        -- Set defaults for write enables
        reg_wr_enables <= (others => '0');
        -- Loop through all registers
        for reg_ix in 0 to NUM_REGS-1 loop
          -- Decode Address
          if (reg_ix = unsigned(address)) then
            -- Set the write enable
            reg_wr_enables(reg_ix) <= wr_enable;
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
        reg_wr_values <= reg_default;
      else
        -- Loop through all registers
        for reg_ix in 0 to NUM_REGS-1 loop
          -- Use the pipelined write enable
          if (reg_wr_enables(reg_ix) = '1') then
            -- Loop through bits
            for bit_ix in 0 to G_AXI_DATA_WIDTH-1 loop
              -- Masked bit-level register assignment
              reg_wr_values(reg_ix*G_AXI_DATA_WIDTH+bit_ix) <= reg_wr_data(bit_ix) AND reg_wr_mask(reg_ix*G_AXI_DATA_WIDTH+bit_ix);
            end loop;
          end if;
        end loop;
      end if;
    end if;
  end process s_reg_write_local;

  -- Synchronous Process for Register Read
  s_reg_read : process (S_AXI_ACLK)
  begin
    if (rising_edge(S_AXI_ACLK)) then
      if (S_AXI_ARESETN = '0') then
        reg_rd_enables      <= (others => '0');
        rd_valid <= '0';
        rd_data  <= ERROR_CODE;
      else
        -- Set Default
        reg_rd_enables      <= (others => '0');
        rd_valid <= rd_enable;
        rd_data  <= ERROR_CODE;

        -- Loop through Registers
        for reg_ix in 0 to NUM_REGS-1 loop
          -- Decode Address
          if (reg_ix = unsigned(address)) then
            -- Set read signals
            reg_rd_enables(reg_ix) <= rd_enable;
            rd_valid    <= reg_rd_valids(reg_ix);
            rd_data     <= reg_rd_values((reg_ix+1)*G_AXI_DATA_WIDTH-1 downto reg_ix*G_AXI_DATA_WIDTH);
          end if;
        end loop;
      end if;
    end if;
  end process s_reg_read;

  ------------------------------------------------------------------------------
  -- Input/Output Assignment for Registers
  ------------------------------------------------------------------------------
  -- Combinatorial Process to Assign Outputs
  c_reg_outputs : process (
    reg_wr_enables,
    reg_rd_enables,
    reg_wr_data,
    reg_wr_values
  )
  begin
    {%- set data_word = {'index':0} %}
    {%- for reg in fins['axilite']['regs'] %}
    {%- if reg['is_readable'] %}
    {%- if (reg['read_ports'] | lower) == 'remote' %}
    reg_{{ reg['name'] }}_rd_en <= reg_rd_enables({{ data_word['index'] }}+{{ reg['length'] }}-1 downto {{ data_word['index'] }});
    {%- endif %}
    {%- endif %}
    {%- if reg['is_writable'] %}
    {%- if (reg['write_ports'] | lower) == 'remote' %}
    reg_{{ reg['name'] }}_wr_en <= reg_wr_enables({{ data_word['index'] }}+{{ reg['length'] }}-1 downto {{ data_word['index'] }});
    {%- endif %}
    {%- if (reg['write_ports'] | lower) == 'remote' %}
    for n in 0 to {{ reg['length'] }}-1 loop
      reg_{{ reg['name'] }}_wr_data((n+1)*{{ reg['width'] }}-1 downto n*{{ reg['width'] }}) <= reg_wr_data({{ reg['width'] }}-1 downto 0);
    end loop;
    {%- elif (reg['write_ports'] | lower) == 'external' %}
    for n in 0 to {{ reg['length'] }}-1 loop
      reg_{{ reg['name'] }}_wr_data((n+1)*{{ reg['width'] }}-1 downto n*{{ reg['width'] }}) <= reg_wr_values((n+{{ data_word['index'] }})*G_AXI_DATA_WIDTH+{{ reg['width'] }}-1 downto (n+{{ data_word['index'] }})*G_AXI_DATA_WIDTH);
    end loop;
    {%- endif %}
    {%- endif %}
    {%- set _ = data_word.update({'index':data_word['index'] + reg['length']}) %}
    {%- endfor %}
  end process c_reg_outputs;

  -- Combinatorial Process to Assign Inputs
  c_reg_inputs : process (
    {%- for reg in fins['axilite']['regs'] %}
    {%- if reg['is_readable'] %}
    {%- if (reg['read_ports'] | lower) == 'remote' %}
    reg_{{ reg['name'] }}_rd_valid,
    {%- endif %}
    {%- if (reg['read_ports'] | lower) != 'internal' %}
    reg_{{ reg['name'] }}_rd_data,
    {%- endif %}
    {%- endif %}
    {%- endfor %}
    reg_rd_enables,
    reg_wr_values
  )
  begin
    -- Set defaults
    reg_rd_values <= reg_wr_values;
    reg_rd_valids <= reg_rd_enables;

    {%- set data_word = {'index':0} %}
    {%- for reg in fins['axilite']['regs'] %}
    {%- if reg['is_readable'] %}
    {%- if (reg['read_ports'] | lower) == 'remote' %}
    reg_rd_valids({{ data_word['index'] }}+{{ reg['length'] }}-1 downto {{ data_word['index'] }}) <= reg_{{ reg['name'] }}_rd_valid;
    {%- endif %}
    {%- if (reg['read_ports'] | lower) != 'internal' %}
    for n in 0 to {{ reg['length'] }}-1 loop
      reg_rd_values({{ reg['width'] }}+(n+{{ data_word['index'] }})*G_AXI_DATA_WIDTH-1 downto (n+{{ data_word['index'] }})*G_AXI_DATA_WIDTH) <= reg_{{ reg['name'] }}_rd_data((n+1)*{{ reg['width'] }}-1 downto n*{{ reg['width'] }});
    end loop;
    {%- endif %}
    {%- endif %}
    {%- set _ = data_word.update({'index':data_word['index'] + reg['length']}) %}
    {%- endfor %}
  end process c_reg_inputs;

end rtl;
