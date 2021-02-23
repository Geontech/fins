{#-
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
-#}
--==============================================================================
-- Firmware IP Node Specification (FINS) Auto-Generated File
-- ---------------------------------------------------------
-- Template:    axilite_verify.vhd
-- Backend:     {{ fins['backend'] }}
-- ---------------------------------------------------------
-- Description: AXI4-Lite bus verification procedure for FINS properties
--==============================================================================

-- Standard Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;
library std;
use std.textio.all;

-- Package
package {{ fins['name']|lower }}_axilite_verify is

  ------------------------------------------------------------------------------
  -- Property Offset Constants
  ------------------------------------------------------------------------------
  {%- for prop in fins['properties']['properties'] %}
  {%- for n in range(prop['length']) %}
  constant {{ fins['name']|upper }}_PROP_{{ prop['name']|upper }}_OFFSET{{ n }} : natural := {{ prop['offset'] + n }};
  {%- endfor %}
  {%- endfor %}

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type t_{{ fins['name']|lower }}_reg_array is array (natural range <>) of integer;

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- The maximum AXI-Lite data width
  constant {{ fins['name']|upper }}_MAX_DATA_WIDTH : natural := 128;

  -- Error code when address does not correspond to a property
  constant {{ fins['name']|upper }}_ERROR_CODE : std_logic_vector({{ fins['name']|upper }}_MAX_DATA_WIDTH-1 downto 0) := x"BADADD03BADADD02BADADD01BADADD00";

  -- The maximum data value
  constant {{ fins['name']|upper }}_MAX_DATA_VALUE : std_logic_vector({{ fins['name']|upper }}_MAX_DATA_WIDTH-1 downto 0) := x"FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF";

  ------------------------------------------------------------------------------
  -- Procedures
  ------------------------------------------------------------------------------
  procedure {{ fins['name']|lower }}_write_reg (
    reg_wr_address       : natural;
    reg_wr_data          : std_logic_vector;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_WSTRB   : out std_logic_vector(({{ fins['properties']['data_width'] }}/8)-1 downto 0);
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  );

  procedure {{ fins['name']|lower }}_read_reg (
    reg_rd_address       : natural;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_WSTRB   : out std_logic_vector(({{ fins['properties']['data_width'] }}/8)-1 downto 0);
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  );

  procedure {{ fins['name']|lower }}_write_regs (
    reg_wr_address       : natural;
    reg_wr_data          : t_{{ fins['name']|lower }}_reg_array;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_WSTRB   : out std_logic_vector(({{ fins['properties']['data_width'] }}/8)-1 downto 0);
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  );

  procedure {{ fins['name']|lower }}_verify_regs (
    reg_rd_address       : natural;
    reg_rd_data          : t_{{ fins['name']|lower }}_reg_array;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_WSTRB   : out std_logic_vector(({{ fins['properties']['data_width'] }}/8)-1 downto 0);
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  );

  procedure {{ fins['name']|lower }}_axilite_verify (
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_WSTRB   : out std_logic_vector(({{ fins['properties']['data_width'] }}/8)-1 downto 0);
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  );

end {{ fins['name']|lower }}_axilite_verify;

package body {{ fins['name']|lower }}_axilite_verify is

  -- Procedure to write a property through the AXI-Lite Bus
  procedure {{ fins['name']|lower }}_write_reg (
    reg_wr_address       : natural;
    reg_wr_data          : std_logic_vector;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_WSTRB   : out std_logic_vector(({{ fins['properties']['data_width'] }}/8)-1 downto 0);
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  ) is
  begin
    -- Create Write Transactions
    wait until falling_edge(S_AXI_ACLK);
    S_AXI_WVALID  <= '1';
    S_AXI_WDATA   <= reg_wr_data;
    {%- if fins['properties']['is_addr_byte_indexed'] %}
    S_AXI_AWADDR <= std_logic_vector(to_unsigned(reg_wr_address*(S_AXI_WDATA'length/8), S_AXI_AWADDR'length));
    {%- else %}
    S_AXI_AWADDR <= std_logic_vector(to_unsigned(reg_wr_address, S_AXI_AWADDR'length));
    {%- endif %}
    S_AXI_AWVALID <= '1';
    S_AXI_WSTRB   <= (others => '1');
    S_AXI_BREADY  <= '1';

    -- Wait for the ready responses (should occur at the same clock cycle)
    wait until falling_edge(S_AXI_ACLK);
    if (S_AXI_AWREADY = '0') then
      wait until (S_AXI_AWREADY = '1');
    end if;
    if (S_AXI_WREADY = '0') then
      wait until (S_AXI_WREADY = '1');
    end if;

    -- Terminate the Write Transaction
    wait until falling_edge(S_AXI_ACLK);
    S_AXI_WVALID  <= '0';
    S_AXI_WDATA   <= (others => '0');
    S_AXI_AWADDR  <= (others => '0');
    S_AXI_AWVALID <= '0';
    S_AXI_WSTRB   <= (others => '0');

    -- Wait for the response (need some more work on the responses)
    if (S_AXI_BVALID = '0') then
      wait until (S_AXI_BVALID = '1');
    end if;
    assert S_AXI_BRESP = b"00"
      report "ERROR: The AXI-Lite Write Transaction BRESP was not 00"
      severity failure;

    -- Terminate the response transaction
    wait until falling_edge(S_AXI_ACLK);
    S_AXI_BREADY  <= '0';

  end {{ fins['name']|lower }}_write_reg;

  -- Procedure to read a property through the AXI-Lite Bus
  procedure {{ fins['name']|lower }}_read_reg (
    reg_rd_address       : natural;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_WSTRB   : out std_logic_vector(({{ fins['properties']['data_width'] }}/8)-1 downto 0);
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  ) is
  begin
    -- Create a Read Transaction
    wait until falling_edge(S_AXI_ACLK);
    {%- if fins['properties']['is_addr_byte_indexed'] %}
    S_AXI_ARADDR  <= std_logic_vector(to_unsigned(reg_rd_address*(S_AXI_RDATA'length/8), S_AXI_ARADDR'length));
    {%- else %}
    S_AXI_ARADDR  <= std_logic_vector(to_unsigned(reg_rd_address, S_AXI_ARADDR'length));
    {%- endif %}
    S_AXI_ARVALID <= '1';
    S_AXI_RREADY  <= '1';

    -- Wait for the Read Address to be accepted
    wait until falling_edge(S_AXI_ACLK);
    if (S_AXI_ARREADY = '0') then
      wait until (S_AXI_ARREADY = '1');
    end if;

    -- Terminate the Read Address Transaction
    wait until falling_edge(S_AXI_ACLK);
    S_AXI_ARADDR  <= (others => '0');
    S_AXI_ARVALID <= '0';

    -- Wait for the Read Data to be valid (need some more work on the responses)
    if (S_AXI_RVALID = '0') then
      wait until (S_AXI_RVALID = '1');
    end if;
    assert S_AXI_RRESP = b"00"
      report "ERROR: The AXI-Lite Read Transaction RRESP was not 00"
      severity failure;

    -- Terminate the Read Data Transaction
    wait until falling_edge(S_AXI_ACLK);
    S_AXI_RREADY <= '0';

  end {{ fins['name']|lower }}_read_reg;

  -- Procedure to load a contiguous set of registers through the AXI-Lite Bus
  procedure {{ fins['name']|lower }}_write_regs (
    reg_wr_address       : natural;
    reg_wr_data          : t_{{ fins['name']|lower }}_reg_array;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_WSTRB   : out std_logic_vector(({{ fins['properties']['data_width'] }}/8)-1 downto 0);
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  ) is
  begin
    for n in reg_wr_data'low to reg_wr_data'high loop
      {{ fins['name']|lower }}_write_reg(
        reg_wr_address + (n - reg_wr_data'low),
        std_logic_vector(to_unsigned(reg_wr_data(n), S_AXI_WDATA'length)),
        S_AXI_ACLK,
        S_AXI_ARESETN,
        S_AXI_AWADDR,
        S_AXI_AWPROT,
        S_AXI_AWVALID,
        S_AXI_AWREADY,
        S_AXI_WDATA,
        S_AXI_WSTRB,
        S_AXI_WVALID,
        S_AXI_WREADY,
        S_AXI_BRESP,
        S_AXI_BVALID,
        S_AXI_BREADY,
        S_AXI_ARADDR,
        S_AXI_ARPROT,
        S_AXI_ARVALID,
        S_AXI_ARREADY,
        S_AXI_RDATA,
        S_AXI_RRESP,
        S_AXI_RVALID,
        S_AXI_RREADY
      );
    end loop;
  end {{ fins['name']|lower }}_write_regs;

  -- Procedure to verify a contiguous set of registers through the AXI-Lite Bus
  procedure {{ fins['name']|lower }}_verify_regs (
    reg_rd_address       : natural;
    reg_rd_data          : t_{{ fins['name']|lower }}_reg_array;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_WSTRB   : out std_logic_vector(({{ fins['properties']['data_width'] }}/8)-1 downto 0);
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  ) is
    variable my_line : line;
  begin
    for n in reg_rd_data'low to reg_rd_data'high loop
      {{ fins['name']|lower }}_read_reg(
        reg_rd_address + (n - reg_rd_data'low),
        S_AXI_ACLK,
        S_AXI_ARESETN,
        S_AXI_AWADDR,
        S_AXI_AWPROT,
        S_AXI_AWVALID,
        S_AXI_AWREADY,
        S_AXI_WDATA,
        S_AXI_WSTRB,
        S_AXI_WVALID,
        S_AXI_WREADY,
        S_AXI_BRESP,
        S_AXI_BVALID,
        S_AXI_BREADY,
        S_AXI_ARADDR,
        S_AXI_ARPROT,
        S_AXI_ARVALID,
        S_AXI_ARREADY,
        S_AXI_RDATA,
        S_AXI_RRESP,
        S_AXI_RVALID,
        S_AXI_RREADY
      );
      -- TODO: Support signed comparison
      assert (reg_rd_data(n) = to_integer(unsigned(S_AXI_RDATA)))
        report "ERROR: Incorrect value in property at address " & integer'image(reg_rd_address + n)
        severity failure;
    end loop;
    write(my_line, string'("PASS: Correct values for registers with starting offset ") & integer'image(reg_rd_address));
    writeline(output, my_line);
  end {{ fins['name']|lower }}_verify_regs;

  -- Procedure to verify all registers in the AXI-Lite Bus
  procedure {{ fins['name']|lower }}_axilite_verify (
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_WSTRB   : out std_logic_vector(({{ fins['properties']['data_width'] }}/8)-1 downto 0);
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    signal S_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    signal S_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  ) is
    variable my_line : line;
  begin

    --*********************************************
    -- Initialize Outputs
    --*********************************************
    S_AXI_AWADDR  <= (others => '0');
    S_AXI_AWPROT  <= (others => '0');
    S_AXI_AWVALID <= '0';
    S_AXI_WDATA   <= (others => '0');
    S_AXI_WSTRB   <= (others => '0');
    S_AXI_WVALID  <= '0';
    S_AXI_BREADY  <= '0';
    S_AXI_ARADDR  <= (others => '0');
    S_AXI_ARPROT  <= (others => '0');
    S_AXI_ARVALID <= '0';
    S_AXI_RREADY  <= '0';
    {%- for prop in fins['properties']['properties'] %}
    --*********************************************
    -- Property: {{ prop['name'] }}
    --*********************************************
    {%- if prop['is_readable'] and not prop['disable_default_test'] %}
    -- Verify default values
    {%- for n in range(prop['length']) %}
    {{ fins['name']|lower }}_read_reg(
      {{ fins['name']|upper }}_PROP_{{ prop['name'] | upper }}_OFFSET{{ n }},
      S_AXI_ACLK,
      S_AXI_ARESETN,
      S_AXI_AWADDR,
      S_AXI_AWPROT,
      S_AXI_AWVALID,
      S_AXI_AWREADY,
      S_AXI_WDATA,
      S_AXI_WSTRB,
      S_AXI_WVALID,
      S_AXI_WREADY,
      S_AXI_BRESP,
      S_AXI_BVALID,
      S_AXI_BREADY,
      S_AXI_ARADDR,
      S_AXI_ARPROT,
      S_AXI_ARVALID,
      S_AXI_ARREADY,
      S_AXI_RDATA,
      S_AXI_RRESP,
      S_AXI_RVALID,
      S_AXI_RREADY
    );
    {%- if prop['is_signed'] %}
    assert ({{ prop['default_values'][n] }} = to_integer(signed(S_AXI_RDATA({{ prop['width'] }}-1 downto 0))))
      report "ERROR: Incorrect default value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correct default value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"));
    writeline(output, my_line);
    {%- else %}
    assert ({{ prop['default_values'][n] }} = to_integer(unsigned(S_AXI_RDATA({{ prop['width'] }}-1 downto 0))))
      report "ERROR: Incorrect default value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correct default value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"));
    writeline(output, my_line);
    {%- endif %}
    {%- endfor %}
    {%- if prop['is_writable'] and prop['is_readable'] %}
    -- Verify maximum value is able to be written
    {%- for n in range(prop['length']) %}
    {{ fins['name']|lower }}_write_reg(
      {{ fins['name']|upper }}_PROP_{{ prop['name'] | upper }}_OFFSET{{ n }},
      x"{{ ("%%0%dx" | format(fins['properties']['data_width']/4)) | format(prop['range_max']) }}",
      S_AXI_ACLK,
      S_AXI_ARESETN,
      S_AXI_AWADDR,
      S_AXI_AWPROT,
      S_AXI_AWVALID,
      S_AXI_AWREADY,
      S_AXI_WDATA,
      S_AXI_WSTRB,
      S_AXI_WVALID,
      S_AXI_WREADY,
      S_AXI_BRESP,
      S_AXI_BVALID,
      S_AXI_BREADY,
      S_AXI_ARADDR,
      S_AXI_ARPROT,
      S_AXI_ARVALID,
      S_AXI_ARREADY,
      S_AXI_RDATA,
      S_AXI_RRESP,
      S_AXI_RVALID,
      S_AXI_RREADY
    );
    {{ fins['name']|lower }}_read_reg(
      {{ fins['name']|upper }}_PROP_{{ prop['name'] | upper }}_OFFSET{{ n }},
      S_AXI_ACLK,
      S_AXI_ARESETN,
      S_AXI_AWADDR,
      S_AXI_AWPROT,
      S_AXI_AWVALID,
      S_AXI_AWREADY,
      S_AXI_WDATA,
      S_AXI_WSTRB,
      S_AXI_WVALID,
      S_AXI_WREADY,
      S_AXI_BRESP,
      S_AXI_BVALID,
      S_AXI_BREADY,
      S_AXI_ARADDR,
      S_AXI_ARPROT,
      S_AXI_ARVALID,
      S_AXI_ARREADY,
      S_AXI_RDATA,
      S_AXI_RRESP,
      S_AXI_RVALID,
      S_AXI_RREADY
    );
    {# maximum value for prop['width'] sized slv, front-padded with 0s to fit fins['properties']['data_width'] #}
    assert ( x"{{ ("%%0%dx" | format(fins['properties']['data_width']/4)) | format(prop['range_max']) }}" = S_AXI_RDATA)
      report "ERROR: Incorrect maximum value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correct maximum value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"));
    writeline(output, my_line);
    {%- endfor %}
    -- Write back to default value
    {%- for n in range(prop['length']) %}
    {{ fins['name']|lower }}_write_reg(
      {{ fins['name']|upper }}_PROP_{{ prop['name'] | upper }}_OFFSET{{ n }},
      std_logic_vector(to_unsigned({{ prop['default_values'][n] }}, S_AXI_WDATA'length)),
      S_AXI_ACLK,
      S_AXI_ARESETN,
      S_AXI_AWADDR,
      S_AXI_AWPROT,
      S_AXI_AWVALID,
      S_AXI_AWREADY,
      S_AXI_WDATA,
      S_AXI_WSTRB,
      S_AXI_WVALID,
      S_AXI_WREADY,
      S_AXI_BRESP,
      S_AXI_BVALID,
      S_AXI_BREADY,
      S_AXI_ARADDR,
      S_AXI_ARPROT,
      S_AXI_ARVALID,
      S_AXI_ARREADY,
      S_AXI_RDATA,
      S_AXI_RRESP,
      S_AXI_RVALID,
      S_AXI_RREADY
    );
    {{ fins['name']|lower }}_read_reg(
      {{ fins['name']|upper }}_PROP_{{ prop['name'] | upper }}_OFFSET{{ n }},
      S_AXI_ACLK,
      S_AXI_ARESETN,
      S_AXI_AWADDR,
      S_AXI_AWPROT,
      S_AXI_AWVALID,
      S_AXI_AWREADY,
      S_AXI_WDATA,
      S_AXI_WSTRB,
      S_AXI_WVALID,
      S_AXI_WREADY,
      S_AXI_BRESP,
      S_AXI_BVALID,
      S_AXI_BREADY,
      S_AXI_ARADDR,
      S_AXI_ARPROT,
      S_AXI_ARVALID,
      S_AXI_ARREADY,
      S_AXI_RDATA,
      S_AXI_RRESP,
      S_AXI_RVALID,
      S_AXI_RREADY
    );
    {%- if prop['is_signed'] %}
    assert ({{ prop['default_values'][n] }} = to_integer(signed(S_AXI_RDATA({{ prop['width'] }}-1 downto 0))))
      report "ERROR: Write to default value failed for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correctly written back to default value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"));
    writeline(output, my_line);
    {%- else %}
    assert ({{ prop['default_values'][n] }} = to_integer(unsigned(S_AXI_RDATA({{ prop['width'] }}-1 downto 0))))
      report "ERROR: Write to default value failed for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset']) }}"
      severity failure;
    write(my_line, string'("PASS: Correctly written back to default value for property {{ prop['name'] }} at address {{ '%0#10x' | format(prop['offset'] + n) }}"));
    writeline(output, my_line);
    {%- endif %}
    {%- endfor %}
    {%- endif %}
    {%- else %}
    -- Property cannot be verified here since it is not readable
    {%- endif %}
    {%- endfor %}
    --*********************************************
    -- Verify Error Code
    --*********************************************
    {%- set last_prop = fins['properties']['properties']|last %}
    {{ fins['name']|lower }}_read_reg(
      {{ last_prop['offset'] + last_prop['length'] }},
      S_AXI_ACLK,
      S_AXI_ARESETN,
      S_AXI_AWADDR,
      S_AXI_AWPROT,
      S_AXI_AWVALID,
      S_AXI_AWREADY,
      S_AXI_WDATA,
      S_AXI_WSTRB,
      S_AXI_WVALID,
      S_AXI_WREADY,
      S_AXI_BRESP,
      S_AXI_BVALID,
      S_AXI_BREADY,
      S_AXI_ARADDR,
      S_AXI_ARPROT,
      S_AXI_ARVALID,
      S_AXI_ARREADY,
      S_AXI_RDATA,
      S_AXI_RRESP,
      S_AXI_RVALID,
      S_AXI_RREADY
    );
    assert ({{ fins['name']|upper }}_ERROR_CODE(S_AXI_RDATA'length-1 downto 0) = S_AXI_RDATA)
      report "ERROR: Incorrect AXI-Lite Read Error Code"
      severity failure;
    write(my_line, string'("PASS: Correct AXI-Lite Read Error Code"));
    writeline(output, my_line);

  end {{ fins['name']|lower }}_axilite_verify;

end {{ fins['name']|lower }}_axilite_verify;
