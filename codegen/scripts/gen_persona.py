#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Josh Schindehette
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Python script for generating Persona files using Jinja2
#              templates
#===============================================================================
import os
import json
import types
import shutil
import datetime
import uuid
import jinja2

# Define Constants
FINS_FILENAME      = 'fins.json'
FINS_EDIT_FILENAME = 'fins_edit.json'
PERSONA_OUTPUT     = 'rh_persona'

def load_fins(directory='./'):
    # Import JSON Firmware IP Node Specification
    with open(directory + FINS_FILENAME) as fins_file:
        fins = json.load(fins_file)
    # Import JSON Edits to the Parameters of FINSpec
    if (os.path.exists(directory + FINS_EDIT_FILENAME)):
        with open(directory + FINS_EDIT_FILENAME) as fins_edit_file:
            fins_edit = json.load(fins_edit_file)
        for param_ix, param in enumerate(fins['params']):
            for edit_param in fins_edit['params']:
                if (edit_param['name'] == param['name']):
                    fins['params'][param_ix]['value'] = edit_param['value']
    return fins

def get_param_value(params, key_or_value):
    if isinstance(key_or_value, str) or isinstance(key_or_value, basestring):
        for param in params:
            if key_or_value.lower() == param['name'].lower():
                return param['value']
        else:
            print('ERROR: {} not found in params'.format(key_or_value))
            return None
    else:
        return key_or_value

def get_persona_regs(fins, offset):
    # Verify that this IP has registers to retrieve
    if not 'regs' in fins:
        print('ERROR: The {} IP does not have registers'.format(fins['name']))
        return None
    
    # Init variables
    regs = []
    data_width = get_param_value(fins['params'], fins['regs']['data_width'])
    addr_width = get_param_value(fins['params'], fins['regs']['addr_width'])
    bar_width = get_param_value(fins['params'], fins['regs']['bar_width'])
    region_addr_width = addr_width - bar_width

    # Loop through regions
    for region_ix, region in enumerate(fins['regs']['regions']):
        # Check the region type
        if 'regs' in region:
            # This region contains registers
            for reg_ix, reg in enumerate(region['regs']):
                # Convert required fields from parameter names into values
                reg['width'] = get_param_value(fins['params'], reg['width'])
                reg['writable'] = get_param_value(fins['params'], reg['writable'])
                # Add some dictionary fields needed for persona
                reg['length'] = 1
                reg['offset'] = offset + 4*region_ix*(2**region_addr_width) + 4*reg_ix
                # Check for optional fields and set them if not set
                if not 'default_values' in reg:
                    # Use 0 as default to match HDL
                    reg['default_values'] = [0]
                else:
                    for value_ix, value in enumerate(reg['default_values']):
                        reg['default_values'][value_ix] = get_param_value(fins['params'], value)
                if not 'range_min' in reg:
                    # Use valid range of unsigned value with bit width
                    reg['range_min'] = 0
                else:
                    reg['range_min'] = get_param_value(fins['params'], reg['range_min'])
                if not 'range_max' in reg:
                    # Use valid range of unsigned value with bit width
                    reg['range_max'] = 2**reg['width']-1
                else:
                    reg['range_max'] = get_param_value(fins['params'], reg['range_max'])
                # Append to output
                regs.append(reg)
        elif 'ip_module' in region:
            # Get the IP module that this is a passthrough region for
            for ip in fins['ip']:
                if region['ip_module'].lower() == ip['module_name'].lower():
                    break
            else:
                print('ERROR: {} IP not found in FINS'.format(region['ip_module']))
                return None
            # Load the IP module's firmware IP node specification
            ip_fins = load_fins(ip['repo_name'] + '/')
            # Recursively get the registers
            ip_regs = get_persona_regs(ip_fins, offset + 4*region_ix*(2**region_addr_width))
            # Add to the output list
            regs.extend(ip_regs)
        else:
            # Create a single "reg" that serves as the base address for a RAM
            reg = region
            reg['width'] = data_width
            reg['range_min'] = 0
            reg['range_max'] = 2**reg['width']-1
            reg['length'] = 2**region_addr_width
            reg['offset'] = offset + 4*region_ix*(2**region_addr_width)
            reg['writable'] = True
            if 'default_values' in region:
                reg['default_values'] = region['default_values']
            else:
                reg['default_values'] = [0] * 2**region_addr_width
            # Append to output
            regs.append(reg)

    # Return all the registers found
    return regs

# Load the FINSpec from the execution directory
fins = load_fins()

# Create a persona dictionary
persona = {}
if 'persona_name' in fins:
    persona['name'] = fins['persona_name']
else:
    persona['name'] = fins['name']
persona['id'] = 'DCE:{}'.format(uuid.uuid4())
persona['device_kind_id'] = 'DCE:{}'.format(uuid.uuid4())
persona['device_model_id'] = 'DCE:{}'.format(uuid.uuid4())
persona['regs'] = get_persona_regs(fins, 0)

# Setup Jinja2 environment
template_path = os.path.dirname(os.path.realpath(__file__))
template_path = template_path[:template_path.rfind('/')]
template_path = template_path + '/templates/persona'
env = jinja2.Environment(loader=jinja2.FileSystemLoader(template_path))

# Generate files from templates
if not os.path.exists(PERSONA_OUTPUT):
    os.makedirs(PERSONA_OUTPUT)
if not os.path.exists(PERSONA_OUTPUT + '/cpp'):
    os.makedirs(PERSONA_OUTPUT + '/cpp')
for template_name in env.list_templates():
    template = env.get_template(template_name)
    dest_filename = PERSONA_OUTPUT + '/' + template_name.replace('Persona', persona['name'])
    with open(dest_filename, 'w') as template_file:
        template_file.write(template.render(persona=persona))
