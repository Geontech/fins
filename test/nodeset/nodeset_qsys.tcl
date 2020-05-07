#!/bin/bash
#
# Copyright (C) 2019 Geon Technologies, LLC
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
#

#package require qsys
package require -exact qsys 18.0

proc do_create_nodeset_test {} {
    # create the system
    create_system nodeset_test
    set_project_property DEVICE {10CX220YF780I5G}
    set_project_property DEVICE_FAMILY {Cyclone 10 GX}
    set_project_property HIDE_FROM_IP_CATALOG {false}
    set_use_testbench_naming_pattern 0 {}

    # add the components
    add_component clock_in ip/nodeset_test/nodeset_test_clock_in.ip altera_clock_bridge clock_in 19.1
    load_component clock_in
    set_component_parameter_value EXPLICIT_CLOCK_RATE {50000000.0}
    set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
    set_component_project_property HIDE_FROM_IP_CATALOG {false}
    save_component
    load_instantiation clock_in
    #remove_instantiation_interfaces_and_ports
    add_instantiation_interface in_clk clock INPUT
    set_instantiation_interface_parameter_value in_clk clockRate {0}
    set_instantiation_interface_parameter_value in_clk externallyDriven {false}
    set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
    add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
    add_instantiation_interface out_clk clock OUTPUT
    set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
    set_instantiation_interface_parameter_value out_clk clockRate {50000000}
    set_instantiation_interface_parameter_value out_clk clockRateKnown {true}
    set_instantiation_interface_parameter_value out_clk externallyDriven {false}
    set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
    set_instantiation_interface_sysinfo_parameter_value out_clk clock_rate {50000000}
    add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
    save_instantiation
    add_component reset_in ip/nodeset_test/nodeset_test_reset_in.ip altera_reset_bridge reset_in 19.1
    load_component reset_in
    set_component_parameter_value ACTIVE_LOW_RESET {1}
    set_component_parameter_value NUM_RESET_OUTPUTS {1}
    set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
    set_component_parameter_value SYNC_RESET {0}
    set_component_parameter_value USE_RESET_REQUEST {0}
    set_component_project_property HIDE_FROM_IP_CATALOG {false}
    save_component
    load_instantiation reset_in
    #remove_instantiation_interfaces_and_ports
    add_instantiation_interface clk clock INPUT
    set_instantiation_interface_parameter_value clk clockRate {0}
    set_instantiation_interface_parameter_value clk externallyDriven {false}
    set_instantiation_interface_parameter_value clk ptfSchematicName {}
    add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
    add_instantiation_interface in_reset reset INPUT
    set_instantiation_interface_parameter_value in_reset associatedClock {clk}
    set_instantiation_interface_parameter_value in_reset synchronousEdges {DEASSERT}
    add_instantiation_interface_port in_reset in_reset_n reset_n 1 STD_LOGIC Input
    add_instantiation_interface out_reset reset OUTPUT
    set_instantiation_interface_parameter_value out_reset associatedClock {clk}
    set_instantiation_interface_parameter_value out_reset associatedDirectReset {in_reset}
    set_instantiation_interface_parameter_value out_reset associatedResetSinks {in_reset}
    set_instantiation_interface_parameter_value out_reset synchronousEdges {DEASSERT}
    add_instantiation_interface_port out_reset out_reset_n reset_n 1 STD_LOGIC Output
    save_instantiation

    add_connection clock_in.out_clk/reset_in.clk

    # Source FINS nodeset Tcl to instantiate FINS nodes and make connections to/between them
    source ../../gen/quartus/node_inst.tcl

    # add the exports
    set_interface_property clk EXPORT_OF clock_in.in_clk
    #set_exported_interface_sysinfo_parameter_value clk clock_domain {-1}
    #set_exported_interface_sysinfo_parameter_value clk clock_rate {-1}
    #set_exported_interface_sysinfo_parameter_value clk reset_domain {-1}
    set_interface_property reset EXPORT_OF reset_in.in_reset
    set_interface_property fins_test_ip_0_s_axis_myinput EXPORT_OF fins_test_ip_0.s_axis_myinput
    set_interface_property fins_test_ip_0_s00_axis_test_in EXPORT_OF fins_test_ip_0.s00_axis_test_in
    set_interface_property fins_test_ip_0_s01_axis_test_in EXPORT_OF fins_test_ip_0.s01_axis_test_in
    set_interface_property fins_test_ip_0_s_axis_sfix_cpx_in EXPORT_OF fins_test_ip_0.s_axis_sfix_cpx_in
    set_interface_property fins_test_ip_1_m_axis_myoutput EXPORT_OF fins_test_ip_1.m_axis_myoutput
    set_interface_property fins_test_ip_1_m00_axis_test_out EXPORT_OF fins_test_ip_1.m00_axis_test_out
    set_interface_property fins_test_ip_1_m01_axis_test_out EXPORT_OF fins_test_ip_1.m01_axis_test_out
    set_interface_property fins_test_ip_1_m_axis_sfix_cpx_out EXPORT_OF fins_test_ip_1.m_axis_sfix_cpx_out
    set_interface_property fins_test_ip_0_S_AXI EXPORT_OF fins_test_ip_0.S_AXI
    set_interface_property fins_test_ip_0_S_AXI_TEST_MIDDLE EXPORT_OF fins_test_ip_0.S_AXI_TEST_MIDDLE
    set_interface_property fins_test_ip_0_S_AXI_TEST_BOTTOM EXPORT_OF fins_test_ip_0.S_AXI_TEST_BOTTOM
    set_interface_property fins_test_ip_1_S_AXI EXPORT_OF fins_test_ip_1.S_AXI
    set_interface_property fins_test_ip_1_S_AXI_TEST_MIDDLE EXPORT_OF fins_test_ip_1.S_AXI_TEST_MIDDLE
    set_interface_property fins_test_ip_1_S_AXI_TEST_BOTTOM EXPORT_OF fins_test_ip_1.S_AXI_TEST_BOTTOM

    # save the system
    sync_sysinfo_parameters
    save_system nodeset_test
}

# create the system
do_create_nodeset_test
