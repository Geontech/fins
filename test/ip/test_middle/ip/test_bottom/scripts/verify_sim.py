#!/usr/bin/env python3
import sys

# Import auto-generated parameters file
sys.path.append('gen/core/')
import test_bottom_pkg

# Open our simulation input
sim_source_data = []
with open('sim_data/sim_source_myinput.txt', 'r') as sim_source_file:
    for sim_source_line in sim_source_file:
        sim_source_data.append(int(sim_source_line, test_bottom_pkg.streams['in']['myinput']['bit_width']))

# Open our simulation output
sim_sink_data = []
with open('sim_data/sim_sink_myoutput.txt', 'r') as sim_sink_file:
    for sim_sink_line in sim_sink_file:
        sim_sink_data.append(int(sim_sink_line, test_bottom_pkg.streams['out']['myoutput']['bit_width']))

# Implement the algorithm
sim_expected_data = []
for d in sim_source_data:
    sim_expected_data.append(d * test_bottom_pkg.params['TEST_PARAM_INTEGER'])

if sim_expected_data == sim_sink_data:
    print('PASS: Simulation data is correct')
else:
    print('ERROR: Simulation data is incorrect')
    print('    * Expected: {}'.format(sim_expected_data))
    print('    * Received: {}'.format(sim_sink_data))
    sys.exit(1)
