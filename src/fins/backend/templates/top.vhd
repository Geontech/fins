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
-- Template:    top.vhd
-- Backend:     {{ fins['backend'] }}
-- Generated:   {{ now }}
-- ---------------------------------------------------------
-- Description: Top-level interface wrapper for a FINS IP
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
entity {{ fins['name']|lower }} is
  port (
    {%- if 'properties' in fins %}
    -- AXI4-Lite Properties Bus
    S_AXI_ACLK    : in  std_logic;
    S_AXI_ARESETN : in  std_logic;
    S_AXI_AWADDR  : in  std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID : in  std_logic;
    S_AXI_AWREADY : out std_logic;
    S_AXI_WDATA   : in  std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    S_AXI_WSTRB   : in  std_logic_vector(({{ fins['properties']['data_width'] }}/8)-1 downto 0);
    S_AXI_WVALID  : in  std_logic;
    S_AXI_WREADY  : out std_logic;
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_BVALID  : out std_logic;
    S_AXI_BREADY  : in  std_logic;
    S_AXI_ARADDR  : in  std_logic_vector({{ fins['properties']['addr_width'] }}-1 downto 0);
    S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_ARVALID : in  std_logic;
    S_AXI_ARREADY : out std_logic;
    S_AXI_RDATA   : out std_logic_vector({{ fins['properties']['data_width'] }}-1 downto 0);
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_RVALID  : out std_logic;
    S_AXI_RREADY  : in  std_logic{% if 'ports' in fins %};{% endif %}
    {%- endif %}
    {%- if 'ports' in fins %}
    {%- for port in fins['ports']['ports'] %}
    {%- set outer_loop = loop %}
    -- AXI4-Stream Port {{ port['direction']|upper }}: {{ port['name']|lower }}
    {%- for i in range(port['num_instances']) %}
    {{ port|axisprefix(i) }}_aclk    : in  std_logic;
    {{ port|axisprefix(i) }}_aresetn : in  std_logic;
    {%- if port['supports_backpressure'] %}
    {{ port|axisprefix(i) }}_tready  : {% if port['direction']|lower == 'in' %}out{% else %}in {% endif %} std_logic;
    {%- endif %}
    {%- if 'data' in port %}
    {{ port|axisprefix(i) }}_tdata   : {% if port['direction']|lower == 'in' %}in {% else %}out{% endif %} std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
    {%- endif %}
    {%- if 'metadata' in port %}
    {{ port|axisprefix(i) }}_tuser   : {% if port['direction']|lower == 'in' %}in {% else %}out{% endif %} std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
    {%- endif %}
    {{ port|axisprefix(i) }}_tvalid  : {% if port['direction']|lower == 'in' %}in {% else %}out{% endif %} std_logic;
    {{ port|axisprefix(i) }}_tlast   : {% if port['direction']|lower == 'in' %}in {% else %}out{% endif %} std_logic{% if not (outer_loop.last and loop.last) %};{% endif %}
    {%- endfor %}
    {%- endfor %}
    {%- endif %}
  );
end {{ fins['name']|lower }};

-- Architecture
architecture struct of {{ fins['name']|lower }} is

  --------------------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------------------
  {%- if 'properties' in fins %}
  -- Auto-generated AXI4-Lite FINS Properties interface
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

  {%- if 'ports' in fins %}
  -- Auto-generated AXI4-Stream FINS Ports interface
  component {{ fins['name']|lower }}_axis is
    port (
      {%- for port in fins['ports']['ports'] %}
      -- AXI4-Stream Port {{ port['direction']|upper }}: {{ port['name']|lower }}
      {%- for i in range(port['num_instances']) %}
      {{ port|axisprefix(i) }}_aclk    : in  std_logic;
      {{ port|axisprefix(i) }}_aresetn : in  std_logic;
      {%- if port['supports_backpressure'] %}
      {{ port|axisprefix(i) }}_tready  : {% if port['direction']|lower == 'in' %}out{% else %}in {% endif %} std_logic;
      {%- endif %}
      {%- if 'data' in port %}
      {{ port|axisprefix(i) }}_tdata   : {% if port['direction']|lower == 'in' %}in {% else %}out{% endif %} std_logic_vector({{ port['data']['bit_width']*port['data']['num_samples']*port['data']['num_channels'] }}-1 downto 0);
      {%- endif %}
      {%- if 'metadata' in port %}
      {{ port|axisprefix(i) }}_tuser   : {% if port['direction']|lower == 'in' %}in {% else %}out{% endif %}  std_logic_vector({{ port['metadata']|sum(attribute='bit_width') }}-1 downto 0);
      {%- endif %}
      {{ port|axisprefix(i) }}_tvalid  : {% if port['direction']|lower == 'in' %}in {% else %}out{% endif %}  std_logic;
      {{ port|axisprefix(i) }}_tlast   : {% if port['direction']|lower == 'in' %}in {% else %}out{% endif %}  std_logic;
      {%- endfor %}
      {%- endfor %}
      ports_in  : out t_{{ fins['name']|lower }}_ports_in;
      ports_out : in  t_{{ fins['name']|lower }}_ports_out
    );
  end component;
  {%- endif %}

  -- Auto-generated User Core Code
  component {{ fins['name']|lower }}_core is
    port (
      {%- if 'properties' in fins %}
      props_control : in  t_{{ fins['name']|lower }}_props_control;
      props_status  : out t_{{ fins['name']|lower }}_props_status{% if 'ports' in fins %};{% endif %}
      {%- endif %}
      {%- if 'ports' in fins %}
      ports_in      : in  t_{{ fins['name']|lower }}_ports_in;
      ports_out     : out t_{{ fins['name']|lower }}_ports_out
      {%- endif %}
    );
  end component;

  --------------------------------------------------------------------------------
  -- Signals
  --------------------------------------------------------------------------------
  {%- if 'properties' in fins %}
  signal props_control : t_{{ fins['name']|lower }}_props_control;
  signal props_status  : t_{{ fins['name']|lower }}_props_status;
  {%- endif %}
  {%- if 'ports' in fins %}
  signal ports_in      : t_{{ fins['name']|lower }}_ports_in;
  signal ports_out     : t_{{ fins['name']|lower }}_ports_out;
  {%- endif %}

begin

  {%- if 'properties' in fins %}
  --------------------------------------------------------------------------------
  -- Properties
  --------------------------------------------------------------------------------
  u_properties : {{ fins['name']|lower }}_axilite
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
  {%- endif %}

  {%- if 'ports' in fins %}
  --------------------------------------------------------------------------------
  -- Ports
  --------------------------------------------------------------------------------
  u_ports : {{ fins['name']|lower }}_axis
    port map (
      {%- for port in fins['ports']['ports'] %}
      {%- for i in range(port['num_instances']) %}
      {{ port|axisprefix(i) }}_aclk    => {{ port|axisprefix(i) }}_aclk,
      {{ port|axisprefix(i) }}_aresetn => {{ port|axisprefix(i) }}_aresetn,
      {%- if port['supports_backpressure'] %}
      {{ port|axisprefix(i) }}_tready  => {{ port|axisprefix(i) }}_tready,
      {%- endif %}
      {%- if 'data' in port %}
      {{ port|axisprefix(i) }}_tdata   => {{ port|axisprefix(i) }}_tdata,
      {%- endif %}
      {%- if 'metadata' in port %}
      {{ port|axisprefix(i) }}_tuser   => {{ port|axisprefix(i) }}_tuser,
      {%- endif %}
      {{ port|axisprefix(i) }}_tvalid  => {{ port|axisprefix(i) }}_tvalid,
      {{ port|axisprefix(i) }}_tlast   => {{ port|axisprefix(i) }}_tlast,
      {%- endfor %}
      {%- endfor %}
      ports_in  => ports_in,
      ports_out => ports_out
    );
  {%- endif %}

  --------------------------------------------------------------------------------
  -- User Core
  --------------------------------------------------------------------------------
  u_core : {{ fins['name']|lower }}_core
    port map (
      {%- if 'properties' in fins %}
      props_control => props_control,
      props_status  => props_status{% if 'ports' in fins %},{% endif %}
      {%- endif %}
      {%- if 'ports' in fins %}
      ports_in      => ports_in,
      ports_out     => ports_out
      {%- endif %}
    );

end struct;
