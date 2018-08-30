#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Adam Martin, Josh Schindehette
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Python script for checking a Firmware IP Node Specification 
#              JSON file against the defined schema
# Assumptions: It is assumed that this script will be executed in the root
#              of a FINS module
#===============================================================================
import os
import sys
import io
import json
import datetime

#===============================================================================
# Constants
#===============================================================================
VERBOSE = False
FINS_FILENAME = 'fins.json'
SCHEMA_FILENAME = './fins/schema.json'
FINS_OUTFILE_POSTFIXES = ['_params.vhd', '_streams.vhd', '_swconfig.vhd', '_swconfig_verify.vhd', '_axilite.vhd']
SCHEMA_TYPES = ['int', 'bool', 'unicode', 'list', 'dict']
SCHEMA_LIST_TYPES = ['int', 'bool', 'unicode', 'dict']
SCHEMA_KEYS = ['is_required', 'types', 'list_types', 'fields']
WRITE_PORTS_VALUES = ['external', 'internal', 'remote']
READ_PORTS_VALUES = ['external', 'internal', 'remote']
SIM_TOOLS_VALUES = ['matlab', 'octave']

#===============================================================================
# Functions
#===============================================================================
def validate_schema(parent_key, schema_object):
    # Check the keys
    found_is_required = False
    found_types = False
    for key, value in schema_object.iteritems():
        if not key in SCHEMA_KEYS:
            print 'ERROR:',parent_key,'has an invalid key:', key
            sys.exit(1)
        if key.lower() == 'is_required':
            found_is_required = True
        if key.lower() == 'types':
            found_types = True
    if not (found_is_required and found_types):
        print 'ERROR:',parent_key,'is missing the is_required or types key'
        sys.exit(1)
    # Check the types and the dependent keys
    for schema_object_type in schema_object['types']:
        if not schema_object_type in SCHEMA_TYPES:
            print 'ERROR:',parent_key,'has an invalid type:', schema_object_type
            sys.exit(1)
    if 'list' in schema_object['types']:
        if not 'list_types' in schema_object:
            print 'ERROR:',parent_key,'has no definition for the list types'
            sys.exit(1)
        for schema_list_type in schema_object['list_types']:
            if not schema_list_type in SCHEMA_LIST_TYPES:
                print 'ERROR:',parent_key,'has an invalid list type:', schema_list_type
                sys.exit(1)
        if 'dict' in schema_object['list_types']:
            if not 'fields' in schema_object:
                print 'ERROR:',parent_key,'has no definition for the fields in the dict list type'
                sys.exit(1)
    if 'dict' in schema_object['types']:
        if not 'fields' in schema_object:
            print 'ERROR:',parent_key,'has no definition for the fields in the dict type'
            sys.exit(1)
    if ('list' in schema_object['types']) and ('dict' in schema_object['types']):
        print 'ERROR:',parent_key,'cannot have both dict and list in the valid types'
        sys.exit(1)
    # Recursively check the fields
    if 'fields' in schema_object:
        if not (('list' in schema_object['types']) or ('dict' in schema_object['types'])):
            print 'ERROR:',parent_key,'has a fields key but no dict or list type'
            sys.exit(1)
        for key, value in schema_object['fields'].iteritems():
            validate_schema(key, value)
    # Notify of success
    if VERBOSE:
        print 'PASS:',parent_key

def validate_fins(parent_key, fins_object, schema_object):
    # Check type
    if type(fins_object) is list:
        if not 'list' in schema_object['types']:
            print 'ERROR:',parent_key,'incorrectly has a list type'
            sys.exit(1)
    elif type(fins_object) is dict:
        if not 'dict' in schema_object['types']:
            print 'ERROR:',parent_key,'incorrectly has a dict type'
            sys.exit(1)
    elif type(fins_object) is unicode:
        if not 'unicode' in schema_object['types']:
            print 'ERROR:',parent_key,'incorrectly has a unicode type'
            sys.exit(1)
    elif type(fins_object) is int:
        if not 'int' in schema_object['types']:
            print 'ERROR:',parent_key,'incorrectly has a int type'
            sys.exit(1)
    elif type(fins_object) is bool:
        if not 'bool' in schema_object['types']:
            print 'ERROR:',parent_key,'incorrectly has a bool type'
            sys.exit(1)
    else:
        print 'ERROR:',parent_key,'has an unknown type'
        sys.exit(1)
    # Check list types
    if type(fins_object) is list:
        for fins_object_element in fins_object:
            if type(fins_object_element) is dict:
                if not 'dict' in schema_object['list_types']:
                    print 'ERROR:',parent_key,'incorrectly has a dict list type'
                    sys.exit(1)
            elif type(fins_object_element) is unicode:
                if not 'unicode' in schema_object['list_types']:
                    print 'ERROR:',parent_key,'incorrectly has a unicode list type'
                    sys.exit(1)
            elif type(fins_object_element) is int:
                if not 'int' in schema_object['list_types']:
                    print 'ERROR:',parent_key,'incorrectly has a int list type'
                    sys.exit(1)
            elif type(fins_object_element) is bool:
                if not 'bool' in schema_object['list_types']:
                    print 'ERROR:',parent_key,'incorrectly has a bool list type'
                    sys.exit(1)
            else:
                print 'ERROR:',parent_key,'has an unknown list type'
                sys.exit(1)
    # Check the fields
    if 'dict' in schema_object['types']:
        # Check that the required schema keys are in the fins object
        for key, value in schema_object['fields'].iteritems():
            if value['is_required'] and not (key in fins_object):
                print 'ERROR: Required key',key,'does not exist in',parent_key
                sys.exit(1)
        # Check for fins object keys that are not in the schema object
        for key, value in fins_object.iteritems():
            if not key in schema_object['fields'].keys():
                print 'WARNING: Undefined key',key,'in',parent_key
                continue
            # Recursively call this function on the fields
            validate_fins(key, value, schema_object['fields'][key])
    elif ('list' in schema_object['types']) and ('dict' in schema_object['list_types']):
        for fins_object_element in fins_object:
            # Check that the required schema keys are in the fins object
            for key, value in schema_object['fields'].iteritems():
                if value['is_required'] and not (key in fins_object_element):
                    print 'ERROR: Required key',key,'does not exist in',parent_key
                    sys.exit(1)
            # Check for fins object keys that are not in the schema object
            for key, value in fins_object_element.iteritems():
                if not key in schema_object['fields'].keys():
                    print 'WARNING: Undefined key',key,'in',parent_key
                    continue
                # Recursively call this function on the fields
                validate_fins(key, value, schema_object['fields'][key])
    # Notify of success
    if VERBOSE:
        print 'PASS:',parent_key

def validate_files(fins_name, file_list):
    # Assemble the list of generated fins output files
    fins_outfiles = []
    for fins_outfile_postfix in FINS_OUTFILE_POSTFIXES:
        fins_outfiles.append(fins_name + fins_outfile_postfix)
    # If the file is not a generated fins output file, then check that it exists
    for fins_file in file_list:
        # Skip generated fins output files
        if fins_file in fins_outfiles:
            continue
        # Check the other source files
        if not os.path.isfile(fins_file):
            print 'ERROR: file does not exist or path is incorrect',fins_file
            sys.exit(1)
        # Notify of success
        if VERBOSE:
            print 'PASS:',fins_file

def validate_ip(fins):
    # Collect parent parameter names
    parent_names = []
    if 'params' in fins:
        for param in fins['params']:
            parent_names.append(param['name'])
    # Iterate through the IP
    for ip in fins['ip']:
        # Make sure the IP repository is there
        if not os.path.isdir(ip['repo_name']):
            print 'ERROR: ip submodule',ip['module_name'],'does not exist or path is incorrect'
            sys.exit(1)
        # Make sure the IP repository has a FINS file
        if not os.path.isfile(ip['repo_name']+'/fins.json'):
            print 'WARNING: ip submodule',ip['module_name'],'is not integrated with fins'
        # Make sure all parameters have a parent
        for param in ip['params']:
            if not param['parent'] in parent_names:
                print 'ERROR: The parent for parameter',param['name'],'in ip submodule',ip['module_name'],'does not exist'
                sys.exit(1)
        # Notify of success
        if VERBOSE:
            print 'PASS:',ip['module_name']

def validate_registers(regs):
    reg_names = []
    for reg in regs:
        reg_names.append(reg['name'])
        if ('is_writable' in reg) and ('is_readable' in reg):
            # Make sure at least either readable or writable
            if (not reg['is_writable']) and (not reg['is_readable']):
                print 'ERROR: Register',reg['name'],'is not readable or writable'
                sys.exit(1)
        if 'write_ports' in reg:
            # Make sure valid value for write_ports
            if not reg['write_ports'].lower() in WRITE_PORTS_VALUES:
                print 'ERROR: Register',reg['name'],'has an invalid value for write_ports:',reg['write_ports']
                sys.exit(1)
            # Make sure not remote write and internal read
            if (reg['write_ports'].lower() == 'remote'):
                # Calculate if the register is readable/writable
                is_writable = True
                is_readable = True
                if ('is_writable' in reg):
                    is_writable = reg['is_writable']
                if ('is_readable' in reg):
                    is_readable = reg['is_readable']
                if is_writable and is_readable:
                    if not 'read_ports' in reg:
                        # Error because read_ports default is "internal"
                        print 'ERROR: Register',reg['name'],'cannot have an external write and internal read'
                        sys.exit(1)
                    if reg['read_ports'].lower() == 'internal':
                        print 'ERROR: Register',reg['name'],'cannot have an external write and internal read'
                        sys.exit(1)
        if 'read_ports' in reg:
            # Make sure valid value for read_ports
            if not reg['read_ports'].lower() in READ_PORTS_VALUES:
                print 'ERROR: Register',reg['name'],'has an invalid value for read_ports:',reg['write_ports']
                sys.exit(1)
        # Notify of success
        if VERBOSE:
            print 'PASS: register',reg['name']
    if (len(reg_names) != len(set(reg_names))):
        print 'ERROR: Duplicate register names detected'
        sys.exit(1)

def validate_swconfig(fins):
    for region in fins['swconfig']['regions']:
        if 'ip_module' in region:
            # Make sure regs and ip_module don't coexist
            if 'regs' in region:
                print 'ERROR: ip_module and regs fields should not coexist within swconfig key'
                sys.exit(1)
            # Make sure IP exists in fins
            if not 'ip' in fins:
                print 'ERROR: No ip in fins to link to',region['name']
                sys.exit(1)
            # Gather the list of IP names
            ip_module_names = []
            for ip in fins['ip']:
                ip_module_names.append(ip['module_name'])
            # Make sure the ip module exists
            if not region['ip_module'] in ip_module_names:
                print 'ERROR: ip_module',region['ip_module'],'not in fins["ip"]'
                sys.exit(1)
            # Notify of success
            if VERBOSE:
                print 'PASS: ip_module',fins_file
        elif 'regs' in region:
            validate_registers(region['regs'])
        # Notify of success
        if VERBOSE:
            print 'PASS: region',region['name']

def validate_axilite(fins):
    validate_registers(fins['axilite']['regs'])

def validate_tools(fins):
    if 'sim' in fins['tools']:
        if not fins['tools']['sim'] in SIM_TOOLS_VALUES:
            print 'ERROR: sim tool',fins['tools']['sim'],'is invalid'
            sys.exit(1)
    # Notify of success
    if VERBOSE:
        print 'PASS: sim'

#===============================================================================
# Script
#===============================================================================
# Load JSON
if VERBOSE:
    print '+++++ Loading fins.json and schema.json ...'
with open(FINS_FILENAME) as fins_data:
    fins = json.load(fins_data)
with open(SCHEMA_FILENAME) as schema_data:
    schema = json.load(schema_data)
if VERBOSE:
    print '+++++ Done.'

# Validate the schema itself
if VERBOSE:
    print '+++++ Validating schema.json ...'
validate_schema('schema', schema)
if VERBOSE:
    print '+++++ Done.'

# Validate the FINS JSON file with the schema
if VERBOSE:
    print '+++++ Validating fins.json ...'
validate_fins('fins', fins, schema)
if VERBOSE:
    print '+++++ Done.'

# Validate filesets
if VERBOSE:
    print '+++++ Validating filesets ...'
validate_files(fins['name'], fins['filesets']['source'])
if 'sim' in fins['filesets']:
    validate_files(fins['name'], fins['filesets']['sim'])
if 'constraints' in fins['filesets']:
    validate_files(fins['name'], fins['filesets']['constraints'])
if VERBOSE:
    print '+++++ Done.'

# Validate sub-IP
if 'ip' in fins:
    if VERBOSE:
        print '+++++ Validating ip ...'
    validate_ip(fins)
    if VERBOSE:
        print '+++++ Done.'

# Validate software configuration
if 'swconfig' in fins:
    if VERBOSE:
        print '+++++ Validating swconfig ...'
    validate_swconfig(fins)
    if VERBOSE:
        print '+++++ Done.'

# Validate AXI-Lite
if 'axilite' in fins:
    if VERBOSE:
        print '+++++ Validating axilite ...'
    validate_axilite(fins)
    if VERBOSE:
        print '+++++ Done.'

# Validate Tools
if 'tools' in fins:
    if VERBOSE:
        print '+++++ Validating tools ...'
    validate_tools(fins)
    if VERBOSE:
        print '+++++ Done.'
