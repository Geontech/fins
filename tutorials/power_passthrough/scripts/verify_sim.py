#!/usr/bin/env python3
import sys

# Import auto-generated parameters file
sys.path.append('gen/core/')
import power_passthrough_pkg

# Open our simulation input
sim_source_data = {'last':[], 'data':[]}
with open('sim_data/sim_source_power_in.txt', 'r') as sim_source_file:
    for sim_source_line in sim_source_file:
        line_data = sim_source_line.split(' ')
sim_source_data['last'].append(int(line_data[0], 16))
sim_source_data['data'].append(int(line_data[1], 16))

# Open our simulation output
sim_sink_data = {'last':[], 'data':[]}
with open('sim_data/sim_sink_power_out.txt', 'r') as sim_sink_file:
    for sim_sink_line in sim_sink_file:
        line_data = sim_sink_line.split(' ')
sim_sink_data['last'].append(int(line_data[0], 16))
sim_sink_data['data'].append(int(line_data[1], 16))


if sim_source_data['data'] == sim_sink_data['data']:
    print('PASS: power simulation data is correct')
else:
    print('ERROR: power simulation data is incorrect')
print('    * Expected: {}'.format(sim_source_data['data']))
print('    * Received: {}'.format(sim_sink_data['data']))

