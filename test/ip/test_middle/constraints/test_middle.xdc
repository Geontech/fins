# Use a 400MHz clock for this test IP to check timing closure results
create_clock -period 2.500 -name S_AXI_ACLK -waveform {0.000 1.250} [get_ports S_AXI_ACLK]
