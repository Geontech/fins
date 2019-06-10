--==============================================================================
-- Company:     Geon Technologies, LLC
-- Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
--              Dissemination of this information or reproduction of this 
--              material is strictly prohibited unless prior written
--              permission is obtained from Geon Technologies, LLC
-- Description: Auto-generated AXI-Lite verification procedure
-- Generated:   {{ now }}
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
package {{ fins['name'] }}_axilite_verify is

  ------------------------------------------------------------------------------
  -- Register Address Constants
  ------------------------------------------------------------------------------
  {%- for reg in fins['axilite']['regs'] %}
  {%- for n in range(reg['length']) %}
  constant REG_{{ reg['name'] | upper }}_OFFSET{{ n }} : natural := {{ reg['offset'] + n }};
  {%- endfor %}
  {%- endfor %}

  ------------------------------------------------------------------------------
  -- Types
  ------------------------------------------------------------------------------
  type t_reg_array is array (natural range <>) of integer;

  ------------------------------------------------------------------------------
  -- Constants
  ------------------------------------------------------------------------------
  -- The maximum AXI-Lite data width
  constant MAX_DATA_WIDTH : natural := 64;

  -- Error code when address does not correspond to a register
  constant ERROR_CODE : std_logic_vector(MAX_DATA_WIDTH-1 downto 0) := x"BADADD00BADADD01";

  -- The maximum data value
  constant MAX_DATA_VALUE : std_logic_vector(MAX_DATA_WIDTH-1 downto 0) := x"FFFF_FFFF_FFFF_FFFF";

  -- AXI-Lite is byte-addressed, so calculate the number of bytes per offset
  constant BYTES_PER_OFFSET : natural := 4;

  ------------------------------------------------------------------------------
  -- Procedures
  ------------------------------------------------------------------------------
  procedure write_reg (
    reg_wr_address       : natural;
    reg_wr_data          : std_logic_vector;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector;
    signal S_AXI_AWPROT  : out std_logic_vector;
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector;
    signal S_AXI_WSTRB   : out std_logic_vector;
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector;
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector;
    signal S_AXI_ARPROT  : out std_logic_vector;
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector;
    signal S_AXI_RRESP   : in  std_logic_vector;
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  );

  procedure read_reg (
    reg_rd_address       : natural;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector;
    signal S_AXI_AWPROT  : out std_logic_vector;
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector;
    signal S_AXI_WSTRB   : out std_logic_vector;
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector;
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector;
    signal S_AXI_ARPROT  : out std_logic_vector;
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector;
    signal S_AXI_RRESP   : in  std_logic_vector;
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  );

  procedure write_regs (
    reg_wr_address       : natural;
    reg_wr_data          : t_reg_array;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector;
    signal S_AXI_AWPROT  : out std_logic_vector;
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector;
    signal S_AXI_WSTRB   : out std_logic_vector;
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector;
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector;
    signal S_AXI_ARPROT  : out std_logic_vector;
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector;
    signal S_AXI_RRESP   : in  std_logic_vector;
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  );

  procedure verify_regs (
    reg_rd_address       : natural;
    reg_rd_data          : t_reg_array;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector;
    signal S_AXI_AWPROT  : out std_logic_vector;
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector;
    signal S_AXI_WSTRB   : out std_logic_vector;
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector;
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector;
    signal S_AXI_ARPROT  : out std_logic_vector;
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector;
    signal S_AXI_RRESP   : in  std_logic_vector;
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  );

  procedure verify_axilite (
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector;
    signal S_AXI_AWPROT  : out std_logic_vector;
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector;
    signal S_AXI_WSTRB   : out std_logic_vector;
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector;
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector;
    signal S_AXI_ARPROT  : out std_logic_vector;
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector;
    signal S_AXI_RRESP   : in  std_logic_vector;
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  );

end {{ fins['name'] }}_axilite_verify;

package body {{ fins['name'] }}_axilite_verify is

  -- Procedure to write a register through the AXI-Lite Bus
  procedure write_reg (
    reg_wr_address       : natural;
    reg_wr_data          : std_logic_vector;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector;
    signal S_AXI_AWPROT  : out std_logic_vector;
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector;
    signal S_AXI_WSTRB   : out std_logic_vector;
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector;
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector;
    signal S_AXI_ARPROT  : out std_logic_vector;
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector;
    signal S_AXI_RRESP   : in  std_logic_vector;
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  ) is
  begin
    -- Create Write Transactions
    wait until falling_edge(S_AXI_ACLK);
    S_AXI_WVALID  <= '1';
    S_AXI_WDATA   <= reg_wr_data;
    S_AXI_AWADDR  <= std_logic_vector(to_unsigned(reg_wr_address*BYTES_PER_OFFSET, S_AXI_AWADDR'length));
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

  end write_reg;

  -- Procedure to read a register through the AXI-Lite Bus
  procedure read_reg (
    reg_rd_address       : natural;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector;
    signal S_AXI_AWPROT  : out std_logic_vector;
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector;
    signal S_AXI_WSTRB   : out std_logic_vector;
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector;
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector;
    signal S_AXI_ARPROT  : out std_logic_vector;
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector;
    signal S_AXI_RRESP   : in  std_logic_vector;
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  ) is
  begin
    -- Create a Read Transaction
    wait until falling_edge(S_AXI_ACLK);
    S_AXI_ARADDR  <= std_logic_vector(to_unsigned(reg_rd_address*BYTES_PER_OFFSET, S_AXI_ARADDR'length));
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

  end read_reg;

  -- Procedure to load a contiguous set of registers through the AXI-Lite Bus
  procedure write_regs (
    reg_wr_address       : natural;
    reg_wr_data          : t_reg_array;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector;
    signal S_AXI_AWPROT  : out std_logic_vector;
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector;
    signal S_AXI_WSTRB   : out std_logic_vector;
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector;
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector;
    signal S_AXI_ARPROT  : out std_logic_vector;
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector;
    signal S_AXI_RRESP   : in  std_logic_vector;
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  ) is
  begin
    for n in reg_wr_data'low to reg_wr_data'high loop
      write_reg(
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
  end write_regs;

  -- Procedure to verify a contiguous set of registers through the AXI-Lite Bus
  procedure verify_regs (
    reg_rd_address       : natural;
    reg_rd_data          : t_reg_array;
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector;
    signal S_AXI_AWPROT  : out std_logic_vector;
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector;
    signal S_AXI_WSTRB   : out std_logic_vector;
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector;
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector;
    signal S_AXI_ARPROT  : out std_logic_vector;
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector;
    signal S_AXI_RRESP   : in  std_logic_vector;
    signal S_AXI_RVALID  : in  std_logic;
    signal S_AXI_RREADY  : out std_logic
  ) is
    variable my_line : line;
  begin
    for n in reg_rd_data'low to reg_rd_data'high loop
      read_reg(
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
        report "ERROR: Incorrect value in register at address " & integer'image(reg_rd_address + n)
        severity failure;
    end loop;
    write(my_line, string'("PASS: Correct values for registers with starting offset ") & integer'image(reg_rd_address));
    writeline(output, my_line);
  end verify_regs;

  -- Procedure to verify all registers in the AXI-Lite Bus
  procedure verify_axilite (
    signal S_AXI_ACLK    : in  std_logic;
    signal S_AXI_ARESETN : in  std_logic;
    signal S_AXI_AWADDR  : out std_logic_vector;
    signal S_AXI_AWPROT  : out std_logic_vector;
    signal S_AXI_AWVALID : out std_logic;
    signal S_AXI_AWREADY : in  std_logic;
    signal S_AXI_WDATA   : out std_logic_vector;
    signal S_AXI_WSTRB   : out std_logic_vector;
    signal S_AXI_WVALID  : out std_logic;
    signal S_AXI_WREADY  : in  std_logic;
    signal S_AXI_BRESP   : in  std_logic_vector;
    signal S_AXI_BVALID  : in  std_logic;
    signal S_AXI_BREADY  : out std_logic;
    signal S_AXI_ARADDR  : out std_logic_vector;
    signal S_AXI_ARPROT  : out std_logic_vector;
    signal S_AXI_ARVALID : out std_logic;
    signal S_AXI_ARREADY : in  std_logic;
    signal S_AXI_RDATA   : in  std_logic_vector;
    signal S_AXI_RRESP   : in  std_logic_vector;
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
    {%- for reg in fins['axilite']['regs'] %}
    --*********************************************
    -- Register: {{ reg['name'] }}
    --*********************************************
    {%- if reg['is_readable'] and not reg['is_ram'] %}
    -- Verify default values
    {%- for n in range(reg['length']) %}
    read_reg(
      REG_{{ reg['name'] | upper }}_OFFSET{{ n }},
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
    {%- if reg['is_signed'] %}
    assert ({{ reg['default_values'][n] }} = to_integer(signed(S_AXI_RDATA({{ reg['width'] }}-1 downto 0))))
      report "ERROR: Incorrect default value for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correct default value for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"));
    writeline(output, my_line);
    {%- else %}
    assert ({{ reg['default_values'][n] }} = to_integer(unsigned(S_AXI_RDATA({{ reg['width'] }}-1 downto 0))))
      report "ERROR: Incorrect default value for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correct default value for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"));
    writeline(output, my_line);
    {%- endif %}
    {%- endfor %}
    {%- if reg['is_writable'] and reg['is_read_from_write'] %}
    -- Verify write width by writing all 1s and reading back correct width
    {%- for n in range(reg['length']) %}
    write_reg(
      REG_{{ reg['name'] | upper }}_OFFSET{{ n }},
      MAX_DATA_VALUE(S_AXI_WDATA'length-1 downto 0),
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
    read_reg(
      REG_{{ reg['name'] | upper }}_OFFSET{{ n }},
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
    {# maximum value for reg['width'] sized slv, front-padded with 0s to fit fins['axilite']['data_width'] #}
    assert ({{ ("x\"{:0" ~ fins['axilite']['data_width']//4 ~ "x}\"").format(2**reg['width']-1) }} = S_AXI_RDATA)
      report "ERROR: Incorrect write width for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correct write width for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"));
    writeline(output, my_line);
    {%- endfor %}
    -- Write back to default value
    {%- for n in range(reg['length']) %}
    write_reg(
      REG_{{ reg['name'] | upper }}_OFFSET{{ n }},
      std_logic_vector(to_unsigned({{ reg['default_values'][n] }}, S_AXI_WDATA'length)),
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
    read_reg(
      REG_{{ reg['name'] | upper }}_OFFSET{{ n }},
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
    {%- if reg['is_signed'] %}
    assert ({{ reg['default_values'][n] }} = to_integer(signed(S_AXI_RDATA({{ reg['width'] }}-1 downto 0))))
      report "ERROR: Write to default value failed for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"
      severity failure;
    write(my_line, string'("PASS: Correctly written back to default value for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"));
    writeline(output, my_line);
    {%- else %}
    assert ({{ reg['default_values'][n] }} = to_integer(unsigned(S_AXI_RDATA({{ reg['width'] }}-1 downto 0))))
      report "ERROR: Write to default value failed for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset']) }}"
      severity failure;
    write(my_line, string'("PASS: Correctly written back to default value for register {{ reg['name'] }} at address {{ '%0#10x' | format(reg['offset'] + n) }}"));
    writeline(output, my_line);
    {%- endif %}
    {%- endfor %}
    {%- endif %}
    {%- else %}
    -- Register cannot be verified here since it is either not readable or it is a RAM
    {%- endif %}
    {%- endfor %}
    --*********************************************
    -- Verify Error Code
    --*********************************************
    {%- set last_reg = fins['axilite']['regs'] | last %}
    read_reg(
      {{ last_reg['offset'] + last_reg['length'] }},
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
    assert (ERROR_CODE(MAX_DATA_WIDTH-1 downto MAX_DATA_WIDTH-S_AXI_RDATA'length) = S_AXI_RDATA)
      report "ERROR: Incorrect AXI-Lite Read Error Code"
      severity failure;
    write(my_line, string'("PASS: Correct AXI-Lite Read Error Code"));
    writeline(output, my_line);

  end verify_axilite;

end {{ fins['name'] }}_axilite_verify;
