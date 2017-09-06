/*
********************************************************************************
* Company:     Geon Technologies, LLC
* File:        rfnoc_block_tb.sv
* Description: Auto-generated from Jinja2 RFNOC Testbench Params Template
* Generated:   {{ now }}
********************************************************************************
*/

`timescale 1ns/1ps
`define NS_PER_TICK 1
`define NUM_TEST_CASES 5

`include "sim_exec_report.vh"
`include "sim_clks_rsts.vh"
`include "sim_rfnoc_lib.svh"

module noc_block_psd_tb();
    `TEST_BENCH_INIT("noc_block_psd",`NUM_TEST_CASES,`NS_PER_TICK);
    localparam BUS_CLK_PERIOD   = $ceil(1e9/166.67e6);
    localparam CE_CLK_PERIOD    = $ceil(1e9/200e6);
    localparam NUM_CE           = 1;    // Number of Computation Engines / User RFNoC blocks to simulate
    localparam NUM_STREAMS      = 1;    // Number of test bench streams
    `RFNOC_SIM_INIT(NUM_CE, NUM_STREAMS, BUS_CLK_PERIOD, CE_CLK_PERIOD);
    `RFNOC_ADD_BLOCK(noc_block_psd, 0);

    localparam PACKETS_TO_SIM =
    {%- for param in json_params['params'] -%}
    {%- if param['name'] == "PACKETS_TO_SIM" -%}
    {{ param['value'] }}; // Number of packets to process
    {%- endif -%}
    {%- endfor %}

    localparam SPP =
    {%- for param in json_params['config'] -%}
    {%- if param['name'] == "PACKET_SIZE" -%}
    {{ param['value'] }}; // Samples per packet
    {%- endif -%}
    {%- endfor %}

    /*****************************************************************************
    ** Verification
    *****************************************************************************/
    initial begin : tb_main
        string s;
        logic [31:0] random_word;
        logic [63:0] readback;
        //////////////////////////////////////////////////////////////////////////
        // Extra elements needed by user
        //////////////////////////////////////////////////////////////////////////



        /*************************************************************************
        ** Test 1 -- Reset
        *************************************************************************/
        `TEST_CASE_START("Wait for Reset");
        while (bus_rst) @(posedge bus_clk);
        while (ce_rst) @(posedge ce_clk);
        `TEST_CASE_DONE(~bus_rst & ~ce_rst);

        /*************************************************************************
        ** Test 2 -- Check for correct NoC IDs
        *************************************************************************/
        `TEST_CASE_START("Check NoC ID");
        // Read NOC IDs
        tb_streamer.read_reg(sid_noc_block_psd, RB_NOC_ID, readback);
        $display("Read psd NOC ID: %16x", readback);
        `ASSERT_ERROR(readback == noc_block_psd.NOC_ID, "Incorrect NOC ID");
        `TEST_CASE_DONE(1);

        /*************************************************************************
        ** Test 3 -- Connect RFNoC blocks
        *************************************************************************/
        `TEST_CASE_START("Connect RFNoC blocks");
        `RFNOC_CONNECT(noc_block_tb,noc_block_psd,SC16,SPP);
        `RFNOC_CONNECT(noc_block_psd,noc_block_tb,SC16,SPP);
        `TEST_CASE_DONE(1);

        /*************************************************************************
        ** Test 4 -- Write / readback user register
        *************************************************************************/
        `TEST_CASE_START("Write / readback user registers");
        random_word = $random();
        //////////////////////////////////////////////////////////////////////////
        // Insert readback registers
        // Use tb_streamer.write_user_reg and tb_streamer.read_user_reg
        //////////////////////////////////////////////////////////////////////////
        `TEST_CASE_DONE(1);

        /*************************************************************************
        ** Test 5 -- Test Sequence
        *************************************************************************/
        // Send data into the user code and compare it to the expected result
        'TEST_CASE_START("Test sequence");
        fork
            begin
                cvita_payload_t send_payload;
                // Default is to send a ramp to the module
                for (int i = 0; i < SPP/2; i++) begin
                    send_payload.push_back(64'(i));
                end
                tb_streamer.send(send_payload);
            end
            begin
                cvita_payload_t recv_payload;
                cvita_metadata_t md;
                logic [
                {%- for param in json_params['config'] -%}
                {%- if param['name'] == "DATA_WIDTH" -%}
                {{ param['value'] }}:0] expected_value;
                {%- endif -%}
                {% endfor %}
                tb_streamer.recv(recv_payload,md);
                for (in i=0; i<SPP/2; i++) begin
                    expected_value = i; // Manipulate i to fit the expected value of user's code
                    $sformat(s, "Incorrect value recieved! Expected: %0d, Received: %0d", expected_value, recv_payload[i]);
                    `ASSERT_ERROR(recv_payload[i] == expected_value, s);
                end
            end
        join
        `TEST_CASE_DONE(1);
        `TEST_BENCH_DONE;
    end
endmodule
