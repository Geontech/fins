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
use work.power_converter_pkg.all;

-- Entity
entity power_converter is
  port (
    -- AXI4-Lite Properties Bus
    S_AXI_ACLK    : in  std_logic;
    S_AXI_ARESETN : in  std_logic;
    S_AXI_AWADDR  : in  std_logic_vector(16-1 downto 0);
    S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID : in  std_logic;
    S_AXI_AWREADY : out std_logic;
    S_AXI_WDATA   : in  std_logic_vector(32-1 downto 0);
    S_AXI_WSTRB   : in  std_logic_vector((32/8)-1 downto 0);
    S_AXI_WVALID  : in  std_logic;
    S_AXI_WREADY  : out std_logic;
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_BVALID  : out std_logic;
    S_AXI_BREADY  : in  std_logic;
    S_AXI_ARADDR  : in  std_logic_vector(16-1 downto 0);
    S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_ARVALID : in  std_logic;
    S_AXI_ARREADY : out std_logic;
    S_AXI_RDATA   : out std_logic_vector(32-1 downto 0);
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_RVALID  : out std_logic;
    S_AXI_RREADY  : in  std_logic;
    -- AXI4-Stream Input Port: iq
    s_axis_iq_aclk    : in  std_logic;
    s_axis_iq_aresetn : in  std_logic;
    s_axis_iq_tdata   : in  std_logic_vector(32-1 downto 0);
    s_axis_iq_tvalid  : in  std_logic;
    s_axis_iq_tlast   : in  std_logic;
    -- AXI4-Stream Output Port: power
    m_axis_power_aclk    : in  std_logic;
    m_axis_power_aresetn : in  std_logic;
    m_axis_power_tdata   : out std_logic_vector(16-1 downto 0);
    m_axis_power_tvalid  : out std_logic;
    m_axis_power_tlast   : out std_logic
  );
end power_converter;

-- Architecture
architecture struct of power_converter is

  --------------------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------------------
  -- Auto-generated AXI4-Lite FINS Properties interface
  component power_converter_axilite is
    generic (
      G_AXI_BYTE_INDEXED : boolean := false;
      G_AXI_ADDR_WIDTH   : natural := 16;
      G_AXI_DATA_WIDTH   : natural := 32
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
      props_control : out t_power_converter_props_control;
      props_status  : in  t_power_converter_props_status
    );
  end component;
  -- Auto-generated AXI4-Stream FINS Ports interface
  component power_converter_axis is
    port (
      -- AXI4-Stream Input Port: iq
      s_axis_iq_aclk    : in  std_logic;
      s_axis_iq_aresetn : in  std_logic;
      s_axis_iq_tdata   : in  std_logic_vector(32-1 downto 0);
      s_axis_iq_tvalid  : in  std_logic;
      s_axis_iq_tlast   : in  std_logic;
      -- AXI4-Stream Output Port: power
      m_axis_power_aclk    : in  std_logic;
      m_axis_power_aresetn : in  std_logic;
      m_axis_power_tdata   : out std_logic_vector(16-1 downto 0);
      m_axis_power_tvalid  : out std_logic;
      m_axis_power_tlast   : out std_logic;
      ports_in  : out t_power_converter_ports_in;
      ports_out : in  t_power_converter_ports_out
    );
  end component;

  --------------------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------------------
  signal props_control   : t_power_converter_props_control;
  signal props_status    : t_power_converter_props_status;
  signal ports_in        : t_power_converter_ports_in;
  signal ports_out       : t_power_converter_ports_out;

  -- Data processing
  constant MODULE_LATENCY  : natural := 4;
  signal input_i           : signed(IQ_DATA_WIDTH/2-1 downto 0);
  signal input_q           : signed(IQ_DATA_WIDTH/2-1 downto 0);
  signal input_squared_i   : signed(IQ_DATA_WIDTH-1 downto 0);
  signal input_squared_q   : signed(IQ_DATA_WIDTH-1 downto 0);
  signal power_full_scale  : signed(IQ_DATA_WIDTH-1 downto 0);
  signal power             : signed(POWER_DATA_WIDTH-1 downto 0);
  signal valid_delay_chain : std_logic_vector(MODULE_LATENCY-1 downto 0);
  signal last_delay_chain  : std_logic_vector(MODULE_LATENCY-1 downto 0);

begin
  --------------------------------------------------------------------------------
  -- Properties
  --------------------------------------------------------------------------------
  u_properties : power_converter_axilite
    port map (
      S_AXI_ACLK    => S_AXI_ACLK,
      S_AXI_ARESETN => S_AXI_ARESETN,
      S_AXI_AWADDR  => S_AXI_AWADDR,
      S_AXI_AWPROT  => S_AXI_AWPROT,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_WDATA   => S_AXI_WDATA,
      S_AXI_WSTRB   => S_AXI_WSTRB,
      S_AXI_WVALID  => S_AXI_WVALID,
      S_AXI_WREADY  => S_AXI_WREADY,
      S_AXI_BRESP   => S_AXI_BRESP,
      S_AXI_BVALID  => S_AXI_BVALID,
      S_AXI_BREADY  => S_AXI_BREADY,
      S_AXI_ARADDR  => S_AXI_ARADDR,
      S_AXI_ARPROT  => S_AXI_ARPROT,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_RDATA   => S_AXI_RDATA,
      S_AXI_RRESP   => S_AXI_RRESP,
      S_AXI_RVALID  => S_AXI_RVALID,
      S_AXI_RREADY  => S_AXI_RREADY,
      props_control => props_control,
      props_status  => props_status
    );
  --------------------------------------------------------------------------------
  -- Ports
  --------------------------------------------------------------------------------
  u_ports : power_converter_axis
    port map (
      s_axis_iq_aclk    => s_axis_iq_aclk,
      s_axis_iq_aresetn => s_axis_iq_aresetn,
      s_axis_iq_tdata   => s_axis_iq_tdata,
      s_axis_iq_tvalid  => s_axis_iq_tvalid,
      s_axis_iq_tlast   => s_axis_iq_tlast,
      m_axis_power_aclk    => m_axis_power_aclk,
      m_axis_power_aresetn => m_axis_power_aresetn,
      m_axis_power_tdata   => m_axis_power_tdata,
      m_axis_power_tvalid  => m_axis_power_tvalid,
      m_axis_power_tlast   => m_axis_power_tlast,
      ports_in  => ports_in,
      ports_out => ports_out
    );

  --------------------------------------------------------------------------------
  -- User Code
  --------------------------------------------------------------------------------
  -- To use the software-controllable FINS "Properties" interface, use the
  -- fields of the following record signals:
  --
  --   * props_control : t_power_converter_props_control;
  --   * props_status  : t_power_converter_props_status;
  --
  -- The fields of props_control and props_status record signals above are the
  -- property names. A property name field is in turn a record of access signal
  -- records. If a property has a "length" > 1, then its property name field
  -- is an array of access signal records. An access signal record has different
  -- fields depending on the property "type". The access signal record fields are
  -- listed below for each property "type":
  -- 
  --   | type                | props_control Record Fields             | props_status Record Fields |
  --   | ------------------- | ----------------------------------------| -------------------------- |
  --   | read-only-constant  | None                                    | None                       |
  --   | read-only-data      | None                                    | rd_data                    |
  --   | read-only-external  | rd_en                                   | rd_data, rd_valid          |
  --   | read-only-memmap    | rd_en, rd_addr                          | rd_data, rd_valid          |
  --   | write-only-external | wr_en, wr_data                          | None                       |
  --   | write-only-memmap   | wr_en, wr_data, wr_addr                 | None                       |
  --   | read-write-internal | None                                    | None                       |
  --   | read-write-data     | wr_data                                 | None                       |
  --   | read-write-external | rd_en, wr_en, wr_data                   | rd_data, rd_valid          |
  --   | read-write-memmap   | rd_en, rd_addr, wr_en, wr_data, wr_addr | rd_data, rd_valid          |
  --
  -- The only property types that instantiate a physical storage register
  -- inside the power_converter_axilite module are the "read-write-data"
  -- and the "read-write-internal". The most common property type used is
  -- "read-write-data", and its value can be used directly since it doesn't
  -- have any of the other access signals. An example of the usage of a property
  -- with name "gain" and type "read-write-data" is below:
  --
  --   signal_magnitude_out <= signed(props_control.gain.wr_data) * signal_magnitude_in;
  --
  -- All other types assume that the user will handle the storage and retrieval
  -- of data. Below is an example of using a property with name "coefficient"
  -- and type "read-write-external":
  --
  --   s_coefficient_property : process(S_AXI_ACLK)
  --   begin
  --     if (rising_edge(S_AXI_ACLK)) then
  --       if (S_AXI_ARESETN = '0') then
  --         coefficient_register <= (others => '0');
  --       else
  --         if (props_control.coefficient.wr_en = '1') then
  --           coefficient_register <= props_control.coefficient.wr_data;
  --         end if;
  --       end if;
  --     end if;
  --   end process s_coefficient_property;
  --   props_status.coefficient.rd_valid <= props_control.coefficient.rd_en;
  --   props_status.coefficient.rd_data  <= coefficient_register;
  --
  --------------------------------------------------------------------------------
  -- To use the standardized FINS "Ports" interfaces, use the
  -- fields of the following record signals:
  --
  --   * ports_in  : t_power_converter_ports_in;
  --   * ports_out : t_power_converter_ports_out;
  --
  -- The fields of ports_in and ports_out record signals above are the port names.
  -- A port name field is in turn a record of access signal records. The fields
  -- of the port name records are dependent on the port characteristics and are
  -- listed in the table below:
  --
  --   | `direction` | `supports_backpressure` | `data` exists | `metadata` exists | ports_in Record Fields      | ports_out Record Fields     |
  --   | ----------- | ----------------------- | ------------- | ----------------- | --------------------------- | --------------------------- |
  --   | in          | true                    | true          | false             | valid, last, data           | ready                       |
  --   | in          | true                    | false         | true              | valid, last, metadata       | ready                       |
  --   | in          | true                    | true          | true              | valid, last, data, metadata | ready                       |
  --   | in          | false                   | true          | false             | valid, last, data           |                             |
  --   | in          | false                   | false         | true              | valid, last, metadata       |                             |
  --   | in          | false                   | true          | true              | valid, last, data, metadata |                             |
  --   | out         | true                    | true          | false             | ready                       | valid, last, data           |
  --   | out         | true                    | false         | true              | ready                       | valid, last, metadata       |
  --   | out         | true                    | true          | true              | ready                       | valid, last, data, metadata |
  --   | out         | false                   | true          | false             |                             | valid, last, data           |
  --   | out         | false                   | false         | true              |                             | valid, last, metadata       |
  --   | out         | false                   | true          | true              |                             | valid, last, data, metadata |
  --
  -- At the lowest level, the data or metadata values have either signed or
  -- unsigned types (indicated by the "is_signed" field). However, the data field
  -- may itself be a more complex type when:
  --
  --   * (num_channels > 1) AND (num_samples > 1): The data field is a
  --     two-dimensional array of either complex records or signed/unsigned
  --     values. The first index is for channels, and the second is for samples.
  --     Example code for real-only output port "power":
  --         ports_out.power.data(channel)(sample) <= data_i*data_i+data_q*data_q;
  --   * (num_channels > 1) XOR (num_samples > 1): The data field is a
  --     one-dimensional array of either complex records or signed/unsigned
  --     values.
  --   * (is_complex = true): The data field is a complex record with fields
  --     "i" (real) and "q" (imaginary). "i" and "q" are either signed or
  --     unsigned types.
  --
  -- Similar to the data field, the metadata field may also be a more complex
  -- type than just signed or unsigned when:
  --
  --   * (is_complex = true): The metadata field is a complex record with fields
  --     "i" (real) and "q" (imaginary). "i" and "q" are either signed or
  --     unsigned types.
  --
  -- For ease of use, four conversion functions are provided in the pkg file
  -- for each port's data and metadata. These functions convert between the
  -- custom record types and std_logic_vector's, and their naming conventions
  -- are listed below:
  --
  --   * f_serialize_[IP_NAME]_[PORT_NAME]_data()
  --   * f_unserialize_[IP_NAME]_[PORT_NAME]_data()
  --   * f_serialize_[IP_NAME]_[PORT_NAME]_metadata()
  --   * f_unserialize_[IP_NAME]_[PORT_NAME]_metadata()
  --
  -- Example code of a "powconv" module using an input port "adc" and output
  -- port "power" that both have metadata and support backpressure is shown below:
  --
  --   ports_out.power.data     <= (ports_in.adc.i * ports_in.adc.i) + (ports_in.adc.q * ports_in.adc.q);
  --   ports_out.power.metadata <= f_unserialize_powconv_power_metadata(f_serialize_powconv_adc_metadata(ports_in.adc.metadata));
  --   ports_out.power.valid    <= ports_in.adc.valid;
  --   ports_out.power.last     <= ports_in.adc.last;
  --   ports_out.adc.ready      <= ports_in.power.ready;
  --
  -- Notice how the metadata is passed through, using the conversion functions
  -- from the package file to make the assignment with incongruous types.
  --
  --------------------------------------------------------------------------------
  -- Synchronous process for the user code of the power conversion function
  s_user_code : process (s_axis_iq_aclk)
  begin
    if (rising_edge(s_axis_iq_aclk)) then
      -- Data Registers
      input_i          <= ports_in.iq.data.i;
      input_q          <= ports_in.iq.data.q;
      input_squared_i  <= input_i * input_i;
      input_squared_q  <= input_q * input_q;
      power_full_scale <= resize(
        input_squared_i + input_squared_q,
        power_full_scale'length
      ); -- Resize drops extra signed bit from previous multiplication operation
      power <= resize(
        resize(power_full_scale, power'length) * signed(props_control.gain.wr_data),
        power'length
      );
      -- Control Registers
      if (s_axis_iq_aresetn = '0') then
        valid_delay_chain <= (others => '0');
        last_delay_chain  <= (others => '0');
      else
        valid_delay_chain(0) <= ports_in.iq.valid;
        last_delay_chain(0)  <= ports_in.iq.last;
        for ix in 1 to MODULE_LATENCY-1 loop
          valid_delay_chain(ix) <= valid_delay_chain(ix-1);
          last_delay_chain(ix)  <= last_delay_chain(ix-1);
        end loop;
      end if;
    end if;
  end process s_user_code;

  -- Assign outputs
  ports_out.power.data  <= power;
  ports_out.power.valid <= valid_delay_chain(MODULE_LATENCY-1);
  ports_out.power.last  <= last_delay_chain(MODULE_LATENCY-1);

end struct;