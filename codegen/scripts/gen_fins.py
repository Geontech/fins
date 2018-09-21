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
import sys
import json
import types
import shutil
import datetime
from jinja2 import Environment
from jinja2 import FileSystemLoader

#-------------------------------------------------------------------------------
# Constants
#-------------------------------------------------------------------------------
FINS_FILENAME = 'fins.json'
FINS_EDIT_FILENAME = 'fins_edit.json'
FINS_SWCONFIG_REGS_FILENAME = 'fins_swconfig_register_map.json'
FINS_AXILITE_REGS_FILENAME = 'fins_axilite_register_map.json'

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------
# NOTE: Identical function in gen_persona.py
def load_fins(directory='./'):
    # Import JSON Firmware IP Node Specification
    with open(directory + FINS_FILENAME) as fins_file:
        fins = json.load(fins_file)
    # Import JSON Edits to the Parameters of FINSpec
    if (os.path.exists(directory + FINS_EDIT_FILENAME)):
        # Open fins_edit.json
        with open(directory + FINS_EDIT_FILENAME) as fins_edit_file:
            fins_edit = json.load(fins_edit_file)
        # Override parameters
        for param_ix, param in enumerate(fins['params']):
            for edit_param in fins_edit['params']:
                if (edit_param['name'].lower() == param['name'].lower()):
                    fins['params'][param_ix]['value'] = edit_param['value']
        # Create a catalog name
        if 'name' in fins_edit:
            fins['project_name']  = fins_edit['name']
    else:
        # Set the default catalog name to the name
        fins['project_name']  = fins['name']
    return fins

# NOTE: Identical function in gen_persona.py
def get_param_value(params, key_or_value):
    if isinstance(key_or_value, str) or isinstance(key_or_value, basestring):
        for param in params:
            if key_or_value.lower() == param['name'].lower():
                return param['value']
        else:
            print('ERROR: {} not found in params'.format(key_or_value))
            sys.exit(1)
    else:
        return key_or_value

def create_jinja_env():
    # Get the current absolute path of this script, strip off the
    # "/scripts" postfix and append "/templates"
    template_path = os.path.dirname(os.path.realpath(__file__))
    template_path = template_path[:template_path.rfind('/')]
    template_path = template_path + '/templates/'

    # Create the Jinja Environment and load templates
    # from the template_path
    env = Environment(loader=FileSystemLoader(template_path))
    return env

def render_jinja_template(jinja_env, template_name, outfile_name, fins):
    template = jinja_env.get_template(template_name)
    template_render = template.render(fins=fins, now=datetime.datetime.utcnow())
    template_file = open(outfile_name, 'w')
    template_file.write(template_render)
    template_file.close()

def convert_register_fields_to_literal(reg, params):
    # Iterate through the register dictionary
    for key, value in reg.iteritems():
        # Don't convert string typed fields
        if (key.lower() == 'name'):
            continue
        if (key.lower() == 'description'):
            continue
        if (key.lower() == 'write_ports'):
            continue
        if (key.lower() == 'read_ports'):
            continue
        # Convert value
        reg[key] = get_param_value(params, value)
        # If default_values is not a list, make it one (after converting from parameter name)
        if (key.lower() == 'default_values'):
            if not isinstance(reg[key], list):
                reg[key] = [reg[key]]
    # Return modified dictionary
    return reg

def convert_fields_to_literal(fins):
    # Get the parameters
    params = []
    if 'params' in fins:
        params = fins['params']

    # Convert all non-string fields of streams to literals
    if 'streams' in fins:
        for stream in fins['streams']:
            for key, value in stream.iteritems():
                # Don't convert string typed fields
                if (key.lower() == 'name'):
                    continue
                if (key.lower() == 'description'):
                    continue
                if (key.lower() == 'mode'):
                    continue
                # Convert value
                stream[key] = get_param_value(params, value)

    # Convert all non-string fields of swconfig to literals
    if 'swconfig' in fins:
        # Convert top-level elements
        fins['swconfig']['addr_width'] = get_param_value(params, fins['swconfig']['addr_width'])
        fins['swconfig']['data_width'] = get_param_value(params, fins['swconfig']['data_width'])
        fins['swconfig']['bar_width'] = get_param_value(params, fins['swconfig']['bar_width'])
        # Look through each region for registers
        for region in fins['swconfig']['regions']:
            # Check if there are registers to process
            if not 'regs' in region:
                continue
            # Process registers
            for reg in region['regs']:
                reg = convert_register_fields_to_literal(reg, params)

    # Convert all non-string fields of axilite to literals
    if 'axilite' in fins:
        # Convert top-level elements
        fins['axilite']['addr_width'] = get_param_value(params, fins['axilite']['addr_width'])
        fins['axilite']['data_width'] = get_param_value(params, fins['axilite']['data_width'])
        # Check if there are registers to process
        if 'regs' in fins['axilite']:
            # Process registers
            for reg in fins['axilite']['regs']:
                reg = convert_register_fields_to_literal(reg, params)

    # Convert all non-string fields of ip to literals
    if 'ip' in fins:
        for ip in fins['ip']:
            # Make sure there are params
            if 'params' in ip:
                # Loop through parameters of IP
                for param_ix, param in enumerate(ip['params']):
                    # Get the value of parent parameter
                    parent_value = get_param_value(params, param['parent'])
                    if parent_value is None:
                        print 'ERROR: {} of {} not found in parent IP'.format(param['parent'], ip['name'])
                        sys.exit(1)
                    # Put the value into the IP
                    ip['params'][param_ix]['value'] = parent_value
                    ip['params'][param_ix]['parent_ip'] = fins['name']

    return fins

def apply_register_defaults(reg):
    if not 'width' in reg:
        reg['width'] = 32
    if not 'length' in reg:
        reg['length'] = 1
    if not 'default_values' in reg:
        reg['default_values'] = [0] * reg['length'] 
    if not 'is_readable' in reg:
        reg['is_readable'] = True
    if not 'is_writable' in reg:
        reg['is_writable'] = True
    if not 'write_ports' in reg:
        reg['write_ports'] = 'external'
    if not 'read_ports' in reg:
        reg['read_ports'] = 'internal'
    if not 'is_read_from_write' in reg:
        reg['is_read_from_write'] = True
    if not 'is_signed' in reg:
        reg['is_signed'] = False
    if not 'range_min' in reg:
        if reg['is_signed']:
            reg['range_min'] = -2**(reg['width'] - 1)
        else:
            reg['range_min'] = 0
    if not 'range_max' in reg:
        if reg['is_signed']:
            reg['range_max'] = 2**(reg['width']-1) - 1
        else:
            reg['range_max'] = 2**reg['width'] - 1
    return reg

def apply_all_register_defaults(fins):
    # Software configuration
    if 'swconfig' in fins:
        # Set register defaults
        for region in fins['swconfig']['regions']:
            # Check if there are registers to process
            if not 'regs' in region:
                continue
            # Process registers
            for reg in region['regs']:
                reg = apply_register_defaults(reg)

    # AXI-Lite
    if 'axilite' in fins:
        # Check if there are registers to process
        if 'regs' in fins['axilite']:
            # Process registers
            for reg in fins['axilite']['regs']:
                reg = apply_register_defaults(reg)

    # Return modified dictionary
    return fins

def create_sub_ip_fins_edit(fins):
    # Check to make sure there are ip
    if not 'ip' in fins:
        return

    # Create files for each IP
    for ip in fins['ip']:
        # Once we are done retrieving parameter values, write the
        # fins edit JSON file for sub-ip
        with open(ip['repo_name'] + '/' + FINS_EDIT_FILENAME, 'w') as fins_edit_file:
            # Strip all fields except for params
            fins_edit_params = {}
            fins_edit_params['params'] = ip['params']
            fins_edit_params['name'] = ip['name']
            json.dump(fins_edit_params, fins_edit_file, sort_keys=True, indent=2)

# NOTE: This is a recursive function
# NOTE: There is a similar function in gen_persona.py called "get_persona_regs"
# NOTE: This function must be called after apply_all_register_defaults() and convert_fields_to_literal()
def get_flattened_swconfig(fins, base_offset):
    # Verify that this IP has registers to retrieve
    if not 'swconfig' in fins:
        print('ERROR: The {} IP does not have swconfig registers'.format(fins['name']))
        sys.exit(1)

    # Init variables
    regs = []
    region_addr_width = fins['swconfig']['addr_width'] - fins['swconfig']['bar_width']

    # Loop through regions
    for region_ix, region in enumerate(fins['swconfig']['regions']):
        # Check the region type
        if 'regs' in region:
            # Initialize offset
            current_offset = base_offset + region_ix*(2**region_addr_width)
            # This region contains registers
            for reg_ix, reg in enumerate(region['regs']):
                # Add the offset field to the register
                reg['offset'] = current_offset
                # Append to output
                regs.append(reg)
                # Update the offset for the next register
                current_offset = current_offset + reg['length']
        elif 'ip_module' in region:
            # Get the IP module that this is a passthrough region for
            for ip in fins['ip']:
                if region['ip_module'].lower() == ip['module_name'].lower():
                    break
            else:
                print('ERROR: {} IP not found in FINS'.format(region['ip_module']))
                sys.exit(1)
            # Load the sub-IP module's FINS JSON file
            # * Convert parameter names to literal values
            # * Apply the register defaults
            ip_fins = load_fins(ip['repo_name'] + '/')
            ip_fins = convert_fields_to_literal(ip_fins)
            ip_fins = apply_all_register_defaults(ip_fins)
            # Recursively get the registers
            ip_regs = get_flattened_swconfig(ip_fins, base_offset + region_ix*(2**region_addr_width))
            # Add to the output list
            regs.extend(ip_regs)
        else:
            # EMPTY REGION
            print('WARNING: {} is an empty region'.format(region['name']))

    # Return all the registers found
    return regs

def flatten_swconfig(fins, base_offset):
    # Put the flattened registers in the dictionary
    fins['swconfig']['regs'] = get_flattened_swconfig(fins, base_offset)

    # Create a register map dictionary for writing to file
    register_map = {}
    register_map['name'] = fins['name']
    register_map['regs'] = fins['swconfig']['regs']

    # Write the JSON to file
    with open(FINS_SWCONFIG_REGS_FILENAME, 'w') as register_map_file:
        json.dump(register_map, register_map_file, sort_keys=True, indent=2)

    # Return the modified dictionary
    return fins

def calculate_axilite_offsets(fins, base_offset):
    # Verify that this IP has registers to retrieve
    if not 'axilite' in fins:
        print('ERROR: The {} IP does not have an axilite definition'.format(fins['name']))
        sys.exit(1)
    if not 'regs' in fins['axilite']:
        print('ERROR: The {} IP does not have axilite registers'.format(fins['name']))
        sys.exit(1)

    # Initialize offset
    current_offset = base_offset

    # Iterate through registers
    for reg_ix, reg in enumerate(fins['axilite']['regs']):
        # Add the offset field to the register
        reg['offset'] = current_offset
        # Update the offset for the next register
        current_offset = current_offset + reg['length']

    # Create a register map dictionary for writing to file
    register_map = {}
    register_map['name'] = fins['name']
    register_map['regs'] = fins['axilite']['regs']

    # Write the JSON to file
    with open(FINS_AXILITE_REGS_FILENAME, 'w') as register_map_file:
        json.dump(register_map, register_map_file, sort_keys=True, indent=2)

    # Return the modified dictionary
    return fins

#-------------------------------------------------------------------------------
# Script
#-------------------------------------------------------------------------------
# Load JSON and Jinja
fins = load_fins()
jinja_env = create_jinja_env()

# Convert parameter names to literals and apply defaults
fins = convert_fields_to_literal(fins)
fins = apply_all_register_defaults(fins)

# Generate Core FINS elements
render_jinja_template(jinja_env, 'ip.mk', 'ip.mk', fins)
render_jinja_template(jinja_env, 'ip_params.tcl', 'ip_params.tcl', fins)

# Generate Optional FINS elements
if 'params' in fins:
    # Render VHDL Package File
    render_jinja_template(jinja_env, 'ip_params.vhd', fins['name'] + '_params.vhd', fins)
if 'streams' in fins:
    # Render VHDL Streams Testbench Module
    render_jinja_template(jinja_env, 'ip_streams.vhd', fins['name'] + '_streams.vhd', fins)
# The "ip" generation MUST appear before "swconfig" generation because the 
# flatten_swconfig() function reaches into the sub-ip respositories and needs the
# fins_edit.json files to be there
if 'ip' in fins:
    # Render User IP Import TCL Script
    render_jinja_template(jinja_env, 'ip_import_user.tcl', 'ip_import_user.tcl', fins)
    # Generate fins_edit.json files for each Sub-IP
    create_sub_ip_fins_edit(fins)
if 'swconfig' in fins:
    # Flatten the registers, add to fins dictionary, and write to file
    fins = flatten_swconfig(fins, 0)
    # Render VHDL Software Configuration Register Decode Module
    render_jinja_template(jinja_env, 'ip_swconfig.vhd', fins['name'] + '_swconfig.vhd', fins)
    # Render VHDL Software Configuration Register Decode Verification Module
    render_jinja_template(jinja_env, 'ip_swconfig_verify.vhd', fins['name'] + '_swconfig_verify.vhd', fins)
    # Render Markdown Software Configuration Register Decode Documentation
    render_jinja_template(jinja_env, 'ip_swconfig.md', fins['name'] + '_swconfig.md', fins)
if 'axilite' in fins:
    # Calculate the offsets, add to fins dictionary, and write to file
    fins = calculate_axilite_offsets(fins, 0)
    # Render VHDL AXI-Lite Register Decode Module
    render_jinja_template(jinja_env, 'ip_axilite.vhd', fins['name'] + '_axilite.vhd', fins)
    # Render Markdown AXI-Lite Register Decode Documentation
    render_jinja_template(jinja_env, 'ip_axilite.md', fins['name'] + '_axilite.md', fins)
if ('streams' in fins) or ('params' in fins):
    # Render MATLAB/Octave Parameter Setup Script
    render_jinja_template(jinja_env, 'ip_params.m', 'ip_params.m', fins)
