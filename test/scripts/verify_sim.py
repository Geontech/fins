#!/usr/bin/env python3
import sys

# Import auto-generated parameters file
sys.path.append('gen/core/')
import test_top_pkg

###################################################################################################
# Path: myinput --> myoutput
###################################################################################################
# Open our simulation input
sim_source_data = {'last':[], 'data':[]}
with open('sim_data/sim_source_myinput.txt', 'r') as sim_source_file:
    for sim_source_line in sim_source_file:
        line_data = sim_source_line.split(' ')
        sim_source_data['last'].append(int(line_data[0]))
        sim_source_data['data'].append(int(line_data[1], test_top_pkg.ports['in']['myinput']['data']['bit_width']))

# Open our simulation output
sim_sink_data = {'last':[], 'data':[]}
with open('sim_data/sim_sink_myoutput.txt', 'r') as sim_sink_file:
    for sim_sink_line in sim_sink_file:
        line_data = sim_sink_line.split(' ')
        sim_sink_data['last'].append(int(line_data[0]))
        sim_sink_data['data'].append(int(line_data[1], test_top_pkg.ports['out']['myoutput']['data']['bit_width']))

# Implement the algorithm
sim_expected_data = []
for d in sim_source_data['data']:
    sim_expected_data.append(d * test_top_pkg.params['TEST_PARAM_INTEGER'] * test_top_pkg.params['TEST_PARAM_INTEGER'] * test_top_pkg.params['TEST_PARAM_INTEGER'])

if sim_expected_data == sim_sink_data['data']:
    print('PASS: myoutput simulation data is correct')
else:
    print('ERROR: myoutput simulation data is incorrect')
    print('    * Expected: {}'.format(sim_expected_data))
    print('    * Received: {}'.format(sim_sink_data))
    sys.exit(1)

###################################################################################################
# Path: test_in --> test_out
###################################################################################################
# Open our simulation input
sim_source_data = {'last':[], 'data':[], 'metadata':[]}
with open('sim_data/sim_source_test_in.txt', 'r') as sim_source_file:
    for sim_source_line in sim_source_file:
        line_data = sim_source_line.split(' ')
        sim_source_data['last'].append(line_data[0].strip())
        sim_source_data['data'].append(line_data[1].strip())
        sim_source_data['metadata'].append(line_data[2].strip())

# Open our simulation output
sim_sink_data = {'last':[], 'data':[], 'metadata':[]}
with open('sim_data/sim_sink_test_out.txt', 'r') as sim_sink_file:
    for sim_sink_line in sim_sink_file:
        line_data = sim_sink_line.split(' ')
        sim_sink_data['last'].append(line_data[0].strip())
        sim_sink_data['data'].append(line_data[1].strip())
        sim_sink_data['metadata'].append(line_data[2].strip())

if sim_source_data == sim_sink_data:
    print('PASS: test_out simulation data is correct')
else:
    print('ERROR: test_out simulation data is incorrect')
    print('    * Expected: {}'.format(sim_source_data))
    print('    * Received: {}'.format(sim_sink_data))
    sys.exit(1)
