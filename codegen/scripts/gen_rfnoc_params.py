#===============================================================================
# Company:     Geon Technologies, LLC
# File:        gen_rfnoc_params.py
# Description: Python script for generating parameter files using Jinja2
#              templates
#
# Revision History:
# Date        Author             Revision
# ----------  -----------------  -----------------------------------------------
# 2017-07-10  Alex Newgent       Initial Version
#
#===============================================================================

#-------------------------------------------------------------------------------
# Python Module Imports
#-------------------------------------------------------------------------------
import os
import json
import types
import shutil
import datetime
import params_func
from file_read import ip
from jinja2 import Environment
from jinja2 import FileSystemLoader

# Turn on verbose output for this script
DEBUG_ON    = False
#-------------------------------------------------------------------------------
# Open and Read JSON Files
#-------------------------------------------------------------------------------
# JSON Filenames
params_filename                 = 'ip_params.json'
override_filename               = 'ip_override.json'

# Import JSON Parameters
with open(params_filename) as json_params_data:
    json_params = json.load(json_params_data)

# Import JSON Override Parameters - If they exist
if (os.path.exists(override_filename)):
    with open(override_filename) as json_override_data:
        json_override = json.load(json_override_data)
        json_params = params_func.overrideParams(json_params, json_override)

#-------------------------------------------------------------------------------
# Assign File and Path names
#-------------------------------------------------------------------------------
# Get name of IP
ip_name = params_func.getValue(json_params, 'IP_TOP')
ports = ip(ip_name)
# Create classes for sim file templates
makefile            = params_func.template()
srcs                = params_func.template()
xml                 = params_func.template()
testbench           = params_func.template()
# Directory Names
tb_path             = './testbenches/noc_block_' + ip_name + '_tb/'
srcs_path           = './fpga-src/'
block_path          = './blocks/'

# Parameter filenames
makefile.file_name  = tb_path + 'Makefile'
srcs.file_name      = srcs_path + 'Makefile.srcs'
xml.file_name       = block_path + ip_name + '.xml'
ver_file_name       = srcs_path + 'noc_block_' + ip_name + '.v'
testbench.file_name = tb_path + 'noc_block_' + ip_name + '_tb.sv'

# Template filenames
makefile.temp_name  = 'rfnoc_block_tb.mk'
srcs.temp_name      = 'rfnoc_block.srcs'
xml.temp_name       = 'rfnoc_block.xml'
ver_temp_name       = 'rfnoc_block.v'
testbench.temp_name = 'rfnoc_block_tb.sv'

#-------------------------------------------------------------------------------
# Create Directory Structure
#-------------------------------------------------------------------------------
# Check if tb_path exists
if not os.path.exists(tb_path):
    # If it doesn't exist, create it
    os.makedirs(tb_path)

# Check if srcs_path exists
if not os.path.exists(srcs_path):
    os.makedirs(srcs_path)

# Check if block_path exists
if not os.path.exists(block_path):
    os.makedirs(block_path)

#-------------------------------------------------------------------------------
# Setup Jinja2 Environment
#-------------------------------------------------------------------------------
# Get current date and time
now = datetime.datetime.utcnow()
env = params_func.env_setup(DEBUG_ON)

#-------------------------------------------------------------------------------
# Generate Simulation Files
#-------------------------------------------------------------------------------
# Generate the Noc Block
ver_template = env.get_template(ver_temp_name)
ver_render = ver_template.render(json_params=json_params,ports=ports.ports,now=now)
ver_file = open(ver_file_name,'w')
ver_file.write(ver_render)
ver_file.close()
# Generate the Testbench's Makefile
makefile.make_file(env, json_params, now)
# Generate the Noc_Block Makefile
srcs.make_file(env, json_params, now)
# Generate the XML file
xml.make_file(env, json_params, now)
# Generate the Testbench
testbench.make_file(env, json_params, now)
