#===============================================================================
# Company:     Geon Technologies, LLC
# File:        gen_ip_params.py
# Description: Python script for generating parameter files using Jinja2
#              templates
#
# Revision History:
# Date        Author             Revision
# ----------  -----------------  -----------------------------------------------
# 2017-08-04  Josh Schindehette  Initial Version
#
#===============================================================================

#-------------------------------------------------------------------------------
# Python Module Imports
#-------------------------------------------------------------------------------
import os
import json
import types
import shutil
import pprint
import datetime
import params_func
from jinja2 import Environment
from jinja2 import FileSystemLoader

#-------------------------------------------------------------------------------
# Script Constants
#-------------------------------------------------------------------------------
# Turn on verbose output for this script
DEBUG_ON              = False

# JSON Filename
params_filename       = 'ip_params.json'
override_filename     = 'ip_override.json'

# Create a class for each file
hdl                   = params_func.template()
mat                   = params_func.template()
tcl                   = params_func.template()
make                  = params_func.template()
hdl_streams           = params_func.template()

# Template filenames
hdl.temp_name         = 'ip_pkg.vhd'
mat.temp_name         = 'ip_params.m'
tcl.temp_name         = 'ip_params.tcl'
make.temp_name        = 'ip.mk'
hdl_streams.temp_name = 'ip_streams.vhd'

# Parameter filenames
mat.file_name         = 'ip_params.m'
tcl.file_name         = 'ip_params.tcl'
make.file_name        = 'ip.mk'

# Use a custom filename for streams
streams_name = params_func.getValue(json_params,'IP_STREAMS')
if streams_name:
    # Set Filename
    hdl_streams.file_name = streams_name + '.vhd'
else:
    # Set the default package name to be <IP_NAME>_pkg
    default_streams_name = params_func.getValue(json_params,'IP_NAME') + '_streams'
    # Insert this default parameter into the json_params dictionary
    json_params['params'].append({u'name':u'IP_STREAMS',u'value':default_streams_name,u'type':u'string',u'used_in':[u'tcl']})
    # Set Filename
    hdl_streams.file_name = default_streams_name + '.vhd'

# Use a custom filename for streams
package_name = params_func.getValue(json_params,'IP_PACKAGE')
if package_name:
    # Set Filename
    hdl.file_name = package_name + '.vhd'
else:
    # Set the default package name to be <IP_NAME>_pkg
    default_package_name = params_func.getValue(json_params,'IP_NAME') + '_pkg'
    # Insert this default parameter into the json_params dictionary
    json_params['params'].append({u'name':u'IP_PACKAGE',u'value':default_package_name,u'type':u'string',u'used_in':[u'tcl']})
    # Set Filename
    hdl.file_name = default_package_name + '.vhd'

#-------------------------------------------------------------------------------
# Read JSON Parameters/Configuration Files
#-------------------------------------------------------------------------------
# Import JSON Parameters
with open(params_filename) as json_params_data:
    json_params = json.load(json_params_data)
    if DEBUG_ON: pprint.pprint(json_params)

# Import JSON Override Parameters if they exist
if (os.path.exists(override_filename)):
    with open(override_filename) as json_override_data:
        json_override = json.load(json_override_data)
        if DEBUG_ON: pprint.pprint(json_override)
        json_params = params_func.overrideParams(json_params, json_override)
        if DEBUG_ON: pprint.pprint(json_params)

#-------------------------------------------------------------------------------
# Setup Jinja2 Environment
#-------------------------------------------------------------------------------
# Get current date and time
now = datetime.datetime.utcnow()
# Setup Jinja2 environment
env = params_func.env_setup(DEBUG_ON)

#-------------------------------------------------------------------------------
# Generate the Files from Templates
#-------------------------------------------------------------------------------
# Generate VHDL Streams File
hdl_streams.make_file(env, json_params, now)

# Generate VHDL Package File
hdl.make_file(env, json_params, now)

# Generate the Matlab/Octave Simulation Parameters File
mat.make_file(env, json_params, now)

# Generate the TCL Script
tcl.make_file(env, json_params, now)

# Generate the Makefile
make.make_file(env, json_params, now)

#-------------------------------------------------------------------------------
# Create the Override Parameters for Sub-IP
#-------------------------------------------------------------------------------
# Check if the current IP has sub-ip
if 'ip' in json_params:
    # Loop through IP
    for ip in json_params['ip']:
        # Loop thorugh parameters of IP
        param_index = 0;
        for param in ip['params']:
            # Get the value of parent parameter
            parent_value = params_func.getValue(json_params, param['parent'])
            if parent_value:
                # Put the value into the IP
                ip['params'][param_index]['value'] = parent_value
                # Remove the 'parent' field
                ip['params'][param_index].pop('parent', None)
            else:
                print 'Error: ' + param['parent'] + ' of ' + ip['name'] + ' not found in parent IP.'
                exit()
            # Increment the index
            param_index += 1
        # Once we are done retrieving parameter values, write the
        # JSON Override Parameters file for sub-ip
        with open(ip['repo_name'] + '/ip_override.json', 'w') as override_file:
            # Strip all fields except for params
            override_params = {}
            override_params['params'] = ip['params']
            json.dump(override_params, override_file, sort_keys=True, indent=2)
