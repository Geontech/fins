# Copyright (C) 2020 Geon Technologies, LLC
#
# This file is part of FINS.
#
# FINS is free software: you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# FINS is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
# more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.

# Creates a top-level Block Design that connects the test application to the Zynq PS
# and assigns each AXI4Lite interface in the test application an address

set TEST_DIR "../"
set PROJECT_VIVADO_DIR "./project/vivado"
set PROJECT_NAME "zedboard_system"
set BD_NAME "system"

create_project $PROJECT_NAME $PROJECT_VIVADO_DIR -part xc7z020clg484-1 -force
set_property board_part em.avnet.com:zed:part0:1.4 [current_project]
set_property target_language VHDL [current_project]
create_bd_design $BD_NAME
update_compile_order -fileset sources_1

lappend IP_SEARCH_PATHS $TEST_DIR/application/project/vivado
lappend IP_SEARCH_PATHS $TEST_DIR/node/project/vivado
lappend IP_SEARCH_PATHS $TEST_DIR/node/ip/test_middle/project/vivado
lappend IP_SEARCH_PATHS $TEST_DIR/node/ip/test_middle/ip/test_bottom/project/vivado

set_property  ip_repo_paths $IP_SEARCH_PATHS [current_project]
update_ip_catalog
create_bd_cell -type ip -vlnv geon.tech:user:application_test:0.0 application_test_0
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins application_test_0/hdl_aclk]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/processing_system7_0/FCLK_CLK0 (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins application_test_0/processing_aclk]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/application_test_0/S_AXI_FINS_TEST_IP_0_TEST_BOTTOM} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins application_test_0/S_AXI_FINS_TEST_IP_0_TEST_BOTTOM]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/application_test_0/S_AXI_FINS_TEST_IP_0_TEST_MIDDLE} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins application_test_0/S_AXI_FINS_TEST_IP_0_TEST_MIDDLE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/application_test_0/S_AXI_FINS_TEST_IP_0_TEST_TOP} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins application_test_0/S_AXI_FINS_TEST_IP_0_TEST_TOP]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/application_test_0/S_AXI_FINS_TEST_IP_1_TEST_BOTTOM} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins application_test_0/S_AXI_FINS_TEST_IP_1_TEST_BOTTOM]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/application_test_0/S_AXI_FINS_TEST_IP_1_TEST_MIDDLE} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins application_test_0/S_AXI_FINS_TEST_IP_1_TEST_MIDDLE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/application_test_0/S_AXI_FINS_TEST_IP_1_TEST_TOP} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins application_test_0/S_AXI_FINS_TEST_IP_1_TEST_TOP]
connect_bd_net [get_bd_pins application_test_0/input_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins application_test_0/hdl_aresetn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins application_test_0/input_aresetn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_net [get_bd_pins application_test_0/output_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins application_test_0/output_aresetn] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]
connect_bd_intf_net [get_bd_intf_pins application_test_0/m_axis_fins_test_ip_1_myoutput] [get_bd_intf_pins application_test_0/s_axis_fins_test_ip_0_myinput]
connect_bd_intf_net [get_bd_intf_pins application_test_0/m00_axis_fins_test_ip_1_test_out] [get_bd_intf_pins application_test_0/s00_axis_fins_test_ip_0_test_in]
connect_bd_intf_net [get_bd_intf_pins application_test_0/m01_axis_fins_test_ip_1_test_out] [get_bd_intf_pins application_test_0/s01_axis_fins_test_ip_0_test_in]
connect_bd_net [get_bd_pins application_test_0/fins_test_ip_1_test_hdl_std_logic_out] [get_bd_pins application_test_0/fins_test_ip_0_test_hdl_std_logic_in]
connect_bd_net [get_bd_pins application_test_0/fins_test_ip_1_test_hdl_std_logic_vector_out] [get_bd_pins application_test_0/fins_test_ip_0_test_hdl_std_logic_vector_in]
connect_bd_intf_net [get_bd_intf_pins application_test_0/m_axis_fins_test_ip_1_sfix_cpx_out] [get_bd_intf_pins application_test_0/s_axis_fins_test_ip_0_sfix_cpx_in]
regenerate_bd_layout
validate_bd_design
save_bd_design

make_wrapper -files [get_files $PROJECT_VIVADO_DIR/$PROJECT_NAME.srcs/sources_1/bd/$BD_NAME/$BD_NAME.bd] -top
add_files -norecurse $PROJECT_VIVADO_DIR/$PROJECT_NAME.srcs/sources_1/bd/$BD_NAME/hdl/${BD_NAME}_wrapper.vhd
