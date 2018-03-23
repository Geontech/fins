#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Josh Schindehette
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Python script for generating parameter files using Jinja2
#              templates
#===============================================================================
import os
import re
import json
import types
import shutil
import datetime
import params_func
from pprint import pprint
from jinja2 import Environment
from jinja2 import FileSystemLoader

# Turn on verbose output for this script
DEBUG_ON = False

# JSON Filename
fins_filename      = 'fins.json'
fins_edit_filename = 'fins_edit.json'

# Create a class for each file
hdl         = params_func.template()
mat         = params_func.template()
tcl         = params_func.template()
tcl_ip      = params_func.template()
make        = params_func.template()
hdl_streams = params_func.template()
hdl_regs    = params_func.template()

# Template filenames
hdl.temp_name         = 'ip_params.vhd'
mat.temp_name         = 'ip_params.m'
tcl.temp_name         = 'ip_params.tcl'
tcl_ip.temp_name      = 'ip_import_user.tcl'
make.temp_name        = 'ip.mk'
hdl_streams.temp_name = 'ip_streams.vhd'
hdl_regs.temp_name    = 'ip_regs.vhd'

# Import JSON Parameters
with open(fins_filename) as fins_data:
    fins = json.load(fins_data)
    if DEBUG_ON: pprint(fins)

# Import JSON Override Parameters if they exist
if os.path.exists(fins_edit_filename):
    with open(fins_edit_filename) as fins_edit_data:
        fins_edit = json.load(fins_edit_data)
        if DEBUG_ON: pprint(fins_edit)
        fins = params_func.edit_params(fins, fins_edit)
        if DEBUG_ON: pprint(fins)

# Dynamic Parameter filenames
mat.file_name         = 'ip_params.m'
tcl.file_name         = 'ip_params.tcl'
tcl_ip.file_name      = 'ip_import_user.tcl'
make.file_name        = 'ip.mk'
hdl.file_name         = fins['name'] + '_params.vhd'
hdl_streams.file_name = fins['name'] + '_streams.vhd'
hdl_regs.file_name    = fins['name'] + '_regs.vhd'

# Check if any of the source files are package files and add them to fins
hdl_packages = []
for source_file in fins['filesets']['source']:
    if not os.path.exists(source_file):
        continue
    if hdl.file_name in source_file or hdl_regs.file_name in source_file:
        continue
    with open(source_file) as source_file_data:
        source_file_text = source_file_data.read()
        regex_pattern = re.compile(r'\npackage *\w* *is', re.IGNORECASE)
        match = regex_pattern.search(source_file_text)
        if match:
            hdl_package = source_file[source_file.rfind('/')+1:source_file.rfind('.')]
            hdl_packages.append(hdl_package)
if hdl_packages:
    fins['packages'] = hdl_packages

# Get current date and time
now = datetime.datetime.utcnow()

# Setup Jinja2 environment
env = params_func.env_setup(DEBUG_ON)

# Generate Files from templates
if 'streams' in fins:
    hdl_streams.make_file(env, fins, now)
if 'regs' in fins:
    hdl_regs.make_file(env, fins, now)
if 'ip' in fins:
    tcl_ip.make_file(env, fins, now)
if 'params' in fins:
    hdl.make_file(env, fins, now)
if ('streams' in fins) or ('params' in fins):
    mat.make_file(env, fins, now)
tcl.make_file(env, fins, now)
make.make_file(env, fins, now)

#-------------------------------------------------------------------------------
# Create the Override Parameters for Sub-IP
#-------------------------------------------------------------------------------
# Check if the current IP has sub-ip
if 'ip' in fins:
    # Loop through IP
    for ip in fins['ip']:
        # Make sure there are params
        if 'params' in ip:
            # Loop through parameters of IP
            for param_ix, param in enumerate(ip['params']):
                # Get the value of parent parameter
                parent_value = params_func.get_param_value(fins, param['parent'])
                if parent_value is not None:
                    # Put the value into the IP
                    ip['params'][param_ix]['value'] = parent_value
                    # Remove the 'parent' field
                    ip['params'][param_ix].pop('parent', None)
                else:
                    print 'Error: {} of {} not found in parent IP'.format(param['parent'], ip['name'])
                    exit()
            # Once we are done retrieving parameter values, write the
            # fins edit JSON file for sub-ip
            with open(ip['repo_name'] + '/' + fins_edit_filename, 'w') as fins_edit_file:
                # Strip all fields except for params
                fins_edit_params = {}
                fins_edit_params['params'] = ip['params']
                json.dump(fins_edit_params, fins_edit_file, sort_keys=True, indent=2)
