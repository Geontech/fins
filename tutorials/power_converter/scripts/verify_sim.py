#!/usr/bin/env python3
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

import sys

# Import auto-generated parameters file
sys.path.append('gen/core/')
import power_converter_pkg

# Open our simulation input
sim_source_data = {'last':[], 'data':{'i':[], 'q':[]} }
with open('sim_data/sim_source_iq.txt', 'r') as sim_source_file:
    for sim_source_line in sim_source_file:
        line_data = sim_source_line.split(' ')
        sim_source_data['last'].append(int(line_data[0], 16))
        sim_source_data['data']['q'].append(int(line_data[1][0:4], 16))
        sim_source_data['data']['i'].append(int(line_data[1][4:8], 16))

# Open our simulation output
sim_sink_data = {'last':[], 'data':[]}
with open('sim_data/sim_sink_power.txt', 'r') as sim_sink_file:
    for sim_sink_line in sim_sink_file:
        line_data = sim_sink_line.split(' ')
        sim_sink_data['last'].append(int(line_data[0], 16))
        sim_sink_data['data'].append(int(line_data[1], 16))

# Implement the algorithm
sim_expected_data = []
for ix in range(len(sim_source_data['data']['i'])):
    sim_expected_data.append(sim_source_data['data']['i'][ix]**2 + sim_source_data['data']['q'][ix]**2)

if sim_expected_data == sim_sink_data['data']:
    print('PASS: power simulation data is correct')
else:
    print('ERROR: power simulation data is incorrect')
    print('    * Expected: {}'.format(sim_expected_data))
    print('    * Received: {}'.format(sim_sink_data['data']))
    sys.exit(1)
