--==============================================================================
-- Firmware IP Node Specification (FINS) Auto-Generated File
-- ---------------------------------------------------------
-- Template:    core.vhd
-- Backend:     vivado
-- Generated:   2019-10-23 21:13:34.806938
-- ---------------------------------------------------------
-- Description: Core functionality code stub for a FINS IP
-- Reset Type:  Synchronous
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- User Libraries
library work;
use work.power_converter_pkg.all;

-- Entity
entity power_converter_core is
  port (
    props_control : in  t_power_converter_props_control;
    props_status  : out t_power_converter_props_status;
    ports_in      : in  t_power_converter_ports_in;
    ports_out     : out t_power_converter_ports_out
  );
end power_converter_core;

-- Architecture
architecture rtl of power_converter_core is

  constant MODULE_LATENCY  : natural := 4;
  signal input_i           : signed(IQ_DATA_WIDTH/2-1 downto 0);
  signal input_q           : signed(IQ_DATA_WIDTH/2-1 downto 0);
  signal input_squared_i   : signed(IQ_DATA_WIDTH-1 downto 0);
  signal input_squared_q   : signed(IQ_DATA_WIDTH-1 downto 0);
  signal power_full_scale  : signed(IQ_DATA_WIDTH-1 downto 0);
  signal power             : signed(POWER_DATA_WIDTH-1 downto 0);
  signal valid_delay_chain : std_logic_vector(MODULE_LATENCY-1 downto 0);
  signal last_delay_chain  : std_logic_vector(MODULE_LATENCY-1 downto 0);
  signal cdc_gain_q        : std_logic_vector(16-1 downto 0);
  signal cdc_gain_qq       : std_logic_vector(16-1 downto 0);

begin

  -- Synchronous process for the user code of the power conversion function
  s_user_code : process (ports_in.iq.clk)
  begin
    if (rising_edge(ports_in.iq.clk)) then
      -- Clock Domain Crossing: Properties -> IQ Port
      cdc_gain_q  <= props_control.gain.wr_data;
      cdc_gain_qq <= cdc_gain_q;
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
        resize(power_full_scale, power'length) * signed(cdc_gain_qq),
        power'length
      );
      -- Control Registers
      if (ports_in.iq.resetn = '0') then
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
  ports_out.power.data(POWER_DATA_WIDTH-1 downto 0) <= power;
  ports_out.power.valid                             <= valid_delay_chain(MODULE_LATENCY-1);
  ports_out.power.last                              <= last_delay_chain(MODULE_LATENCY-1);

end rtl;
