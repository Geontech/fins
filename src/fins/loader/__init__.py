'''
Main package for FINS JSON data loading.
'''
import os
import sys
import math
import logging
import json

__all__ = (
    'load_fins_data'
)

SCHEMA_FILENAME = os.path.dirname(os.path.abspath(__file__)) + '/schema.json'
SCHEMA_TYPES = ['int', 'bool', 'str', 'list', 'dict']
SCHEMA_LIST_TYPES = ['int', 'bool', 'str', 'dict']
SCHEMA_KEYS = ['is_required', 'types', 'list_types', 'fields']
PROPERTY_TYPES = [
    'read-only-constant',
    'read-only-data',
    'read-only-external',
    'read-only-memmap',
    'write-only-external',
    'write-only-memmap',
    'read-write-internal',
    'read-write-data',
    'read-write-external',
    'read-write-memmap'
]
DESIGN_FILE_TYPES = ['vhdl', 'verilog']
SCRIPT_FILE_TYPES = ['matlab', 'octave', 'python', 'tcl']
CONSTRAINT_FILE_TYPES = ['xdc', 'sdc']
VENDOR_SCRIPT_FILE_TYPES = ['tcl']

def validate_schema(parent_key,schema_object,verbose):
    # Check the keys
    found_is_required = False
    found_types = False
    for key, value in schema_object.items():
        if not key in SCHEMA_KEYS:
            print('ERROR:',parent_key,'has an invalid key:', key)
            sys.exit(1)
        if key.lower() == 'is_required':
            found_is_required = True
        if key.lower() == 'types':
            found_types = True
    if not (found_is_required and found_types):
        print('ERROR:',parent_key,'is missing the is_required or types key')
        sys.exit(1)
    # Check the types and the dependent keys
    for schema_object_type in schema_object['types']:
        if not schema_object_type in SCHEMA_TYPES:
            print('ERROR:',parent_key,'has an invalid type:', schema_object_type)
            sys.exit(1)
    if 'list' in schema_object['types']:
        if not 'list_types' in schema_object:
            print('ERROR:',parent_key,'has no definition for the list types')
            sys.exit(1)
        for schema_list_type in schema_object['list_types']:
            if not schema_list_type in SCHEMA_LIST_TYPES:
                print('ERROR:',parent_key,'has an invalid list type:', schema_list_type)
                sys.exit(1)
        if 'dict' in schema_object['list_types']:
            if not 'fields' in schema_object:
                print('ERROR:',parent_key,'has no definition for the fields in the dict list type')
                sys.exit(1)
    if 'dict' in schema_object['types']:
        if not 'fields' in schema_object:
            print('ERROR:',parent_key,'has no definition for the fields in the dict type')
            sys.exit(1)
    if ('list' in schema_object['types']) and ('dict' in schema_object['types']):
        print('ERROR:',parent_key,'cannot have both dict and list in the valid types')
        sys.exit(1)
    # Recursively check the fields
    if 'fields' in schema_object:
        if not (('list' in schema_object['types']) or ('dict' in schema_object['types'])):
            print('ERROR:',parent_key,'has a fields key but no dict or list type')
            sys.exit(1)
        for key, value in schema_object['fields'].items():
            validate_schema(key,value,verbose)
    # Notify of success
    if verbose:
        print('PASS:',parent_key)

def validate_fins(parent_key,fins_object,schema_object,verbose):
    # Check type
    if type(fins_object) is list:
        if not 'list' in schema_object['types']:
            print('ERROR:',parent_key,'incorrectly has a list type')
            sys.exit(1)
    elif type(fins_object) is dict:
        if not 'dict' in schema_object['types']:
            print('ERROR:',parent_key,'incorrectly has a dict type')
            sys.exit(1)
    elif type(fins_object) is str:
        if not 'str' in schema_object['types']:
            print('ERROR:',parent_key,'incorrectly has a str type')
            sys.exit(1)
    elif type(fins_object) is int:
        if not 'int' in schema_object['types']:
            print('ERROR:',parent_key,'incorrectly has a int type')
            sys.exit(1)
    elif type(fins_object) is bool:
        if not 'bool' in schema_object['types']:
            print('ERROR:',parent_key,'incorrectly has a bool type')
            sys.exit(1)
    else:
        print('ERROR:',parent_key,'has an unknown type')
        sys.exit(1)
    # Check list types
    if type(fins_object) is list:
        for fins_object_element in fins_object:
            if type(fins_object_element) is dict:
                if not 'dict' in schema_object['list_types']:
                    print('ERROR:',parent_key,'incorrectly has a dict list type')
                    sys.exit(1)
            elif type(fins_object_element) is str:
                if not 'str' in schema_object['list_types']:
                    print('ERROR:',parent_key,'incorrectly has a str list type')
                    sys.exit(1)
            elif type(fins_object_element) is int:
                if not 'int' in schema_object['list_types']:
                    print('ERROR:',parent_key,'incorrectly has a int list type')
                    sys.exit(1)
            elif type(fins_object_element) is bool:
                if not 'bool' in schema_object['list_types']:
                    print('ERROR:',parent_key,'incorrectly has a bool list type')
                    sys.exit(1)
            else:
                print('ERROR:',parent_key,'has an unknown list type')
                sys.exit(1)
    # Check the fields
    if 'dict' in schema_object['types']:
        # Check that the required schema keys are in the fins object
        for key, value in schema_object['fields'].items():
            if value['is_required'] and not (key in fins_object):
                print('ERROR: Required key',key,'does not exist in',parent_key)
                sys.exit(1)
        # Check for fins object keys that are not in the schema object
        for key, value in fins_object.items():
            if not key in schema_object['fields'].keys():
                print('WARNING: Undefined key',key,'in',parent_key)
                continue
            # Recursively call this function on the fields
            validate_fins(key,value,schema_object['fields'][key],verbose)
    elif ('list' in schema_object['types']) and ('dict' in schema_object['list_types']):
        for fins_object_element in fins_object:
            # Check that the required schema keys are in the fins object
            for key, value in schema_object['fields'].items():
                if value['is_required'] and not (key in fins_object_element):
                    print('ERROR: Required key',key,'does not exist in',parent_key)
                    sys.exit(1)
            # Check for fins object keys that are not in the schema object
            for key, value in fins_object_element.items():
                if not key in schema_object['fields'].keys():
                    print('WARNING: Undefined key',key,'in',parent_key)
                    continue
                # Recursively call this function on the fields
                validate_fins(key,value,schema_object['fields'][key],verbose)
    # Notify of success
    if verbose:
        print('PASS:',parent_key)

def validate_files(fins_name,filename,file_list,allowed_types,verbose):
    # Iterate through the files
    for fins_file in file_list:
        # Assemble the path name
        if os.path.dirname(filename):
            filepath = os.path.dirname(filename)+'/'+fins_file['path']
        else:
            filepath = fins_file['path']
        # Check that the file exists
        if not os.path.isfile(filepath):
            print('ERROR: File does not exist or path is incorrect',filepath)
            sys.exit(1)
        # Check the type
        if 'type' in fins_file:
            if not (fins_file['type'].lower() in [allowed_type.lower() for allowed_type in allowed_types]):
                print('ERROR: Invalid type',fins_file['type'],'for file',filepath)
        # Notify of success
        if verbose:
            print('PASS:',filepath)

def validate_ip(fins_data,verbose):
    # Collect parent parameter names
    parent_names = []
    if 'params' in fins_data:
        for param in fins_data['params']:
            parent_names.append(param['name'])
    # Iterate through the IP
    for ip in fins_data['ip']:
        # Make sure the IP file exists
        if not os.path.isfile(ip['fins_path']):
            print('ERROR: IP does not exist or path',ip['fins_path'],'is incorrect')
            sys.exit(1)
        # Make sure all parameters have a parent
        for param in ip['params']:
            if not param['parent'] in parent_names:
                print('ERROR: The parent for parameter',param['name'],'in IP',ip['fins_path'],'does not exist')
                sys.exit(1)
        # Notify of success
        if verbose:
            print('PASS:',ip['fins_path'])

def validate_properties(fins_data,verbose):
    # Iterate through all properties
    prop_names = []
    for prop in fins_data['properties']['properties']:
        # Append to list of names
        prop_names.append(prop['name'])
        # Validate the property type
        if not prop['type'] in PROPERTY_TYPES:
            print('ERROR: Property',prop['name'],'type',prop['type'],'is invalid')
            sys.exit(1)
        # Notify of success
        if verbose:
            print('PASS: Property',prop['name'])

    # Check for name duplicates
    if (len(prop_names) != len(set(prop_names))):
        print('ERROR: Duplicate property names detected')
        sys.exit(1)

def validate_streams(fins_data,verbose):
    # Iterate through all streams
    stream_names = []
    for stream in fins_data['streams']:
        stream_names.append(stream['name'])

    # Check for name duplicates
    if (len(stream_names) != len(set(stream_names))):
        print('ERROR: Duplicate stream names detected')
        sys.exit(1)

def get_param_value(params,key_or_value):
    if isinstance(key_or_value, str):
        for param in params:
            if key_or_value.lower() == param['name'].lower():
                return param['value']
        else:
            print('ERROR: {} not found in params'.format(key_or_value))
            sys.exit(1)
    else:
        return key_or_value

def convert_parameters_to_literal(fins_data,verbose):
    # Get the parameters
    params = []
    if 'params' in fins_data:
        params = fins_data['params']

    # Convert all non-string fields of streams to literals
    if 'streams' in fins_data:
        for stream in fins_data['streams']:
            for key, value in stream.items():
                # Don't convert string typed fields
                if (key.lower() == 'name'):
                    continue
                if (key.lower() == 'description'):
                    continue
                if (key.lower() == 'mode'):
                    continue
                # Convert value
                stream[key] = get_param_value(params, value)

    # Convert all non-string fields of properties
    if 'properties' in fins_data:
        # Convert top-level elements
        fins_data['properties']['addr_width'] = get_param_value(params, fins_data['properties']['addr_width'])
        fins_data['properties']['data_width'] = get_param_value(params, fins_data['properties']['data_width'])
        fins_data['properties']['is_addr_byte_indexed'] = get_param_value(params, fins_data['properties']['is_addr_byte_indexed'])
        # Process properties
        for prop in fins_data['properties']['properties']:
            # Iterate through the property dictionary
            for key, value in prop.items():
                # Don't convert string typed fields
                if (key.lower() == 'name'):
                    continue
                if (key.lower() == 'description'):
                    continue
                if (key.lower() == 'type'):
                    continue
                # Convert value
                prop[key] = get_param_value(params, value)

    # Convert all string fields of ip to literals
    if 'ip' in fins_data:
        for ip in fins_data['ip']:
            # Make sure there are params
            if 'params' in ip:
                # Loop through parameters of IP
                for param_ix, param in enumerate(ip['params']):
                    # Get the value of parent parameter
                    parent_value = get_param_value(params, param['parent'])
                    if parent_value is None:
                        print('ERROR: {} of {} not found in parent IP'.format(param['parent'], ip['fins_path']))
                        sys.exit(1)
                    # Put the value into the IP
                    ip['params'][param_ix]['value'] = parent_value
                    ip['params'][param_ix]['parent_ip'] = fins_data['name']

    return fins_data

def populate_properties(fins_data,base_offset,verbose):
    # Make sure there are properties first
    if not 'properties' in fins_data:
        return fins_data

    # Set defaults
    for prop in fins_data['properties']['properties']:
        if not 'width' in prop:
            prop['width'] = fins_data['properties']['data_width']
        if not 'length' in prop:
            prop['length'] = 1
        if not 'default_values' in prop:
            prop['default_values'] = [0] * prop['length']
        if not 'is_signed' in prop:
            prop['is_signed'] = False
        if not 'range_min' in prop:
            if prop['is_signed']:
                prop['range_min'] = -2**(prop['width'] - 1)
            else:
                prop['range_min'] = 0
        if not 'range_max' in prop:
            if prop['is_signed']:
                prop['range_max'] = 2**(prop['width']-1) - 1
            else:
                prop['range_max'] = 2**prop['width'] - 1

    # Add additional fields based on the register type
    for prop in fins_data['properties']['properties']:
        if 'read-only' in prop['type'].lower():
            prop['is_readable'] = True
            prop['is_writable'] = False
        elif 'write-only' in prop['type'].lower():
            prop['is_readable'] = False
            prop['is_writable'] = True
        else:
            prop['is_readable'] = True
            prop['is_writable'] = True

    # If default_values is not a list, make it one
    for prop in fins_data['properties']['properties']:
        if not isinstance(prop['default_values'], list):
            prop['default_values'] = [prop['default_values']]

    # Calculate offsets
    current_offset = base_offset
    for reg_ix, prop in enumerate(fins_data['properties']['properties']):
        # Add the offset field to the register
        prop['offset'] = current_offset
        # Update the offset for the next register
        current_offset = current_offset + prop['length']

    # Validate that the address space is enough for the number of properties
    if fins_data['properties']['is_addr_byte_indexed']:
        num_bits_for_byte_indexing = math.ceil(math.log2(fins_data['properties']['data_width']/8))
        largest_possible_offset = 2**(fins_data['properties']['addr_width']-num_bits_for_byte_indexing )-1
    else:
        largest_possible_offset = 2**fins_data['properties']['addr_width']-1
    if current_offset > largest_possible_offset:
        print('ERROR: The specified address width {} is not large enough to accomodate all the properties'.format(fins_data['properties']['addr_width']))
        sys.exit(1)

    # Return the modified dictionary
    return fins_data

def populate_filesets(fins_data,verbose):
    if not 'filesets' in fins_data:
        return fins_data

    design_file_keys = ['source', 'sim']
    for design_file_key in design_file_keys:
        if design_file_key in fins_data['filesets']:
            for design_file in fins_data['filesets'][design_file_key]:
                if not 'type' in design_file:
                    if '.v' in design_file['path']:
                        design_file['type'] = 'verilog'
                    elif '.vhd' in design_file['path']:
                        design_file['type'] = 'vhdl'
                    elif '.vhdl' in design_file['path']:
                        design_file['type'] = 'vhdl'
                    else:
                        print('ERROR: A type cannot be auto-detected from design file',design_file['path'])
                        sys.exit(1)

    if 'constraints' in fins_data['filesets']:
        for constraints_file in fins_data['filesets']['constraints']:
            if not 'type' in constraints_file:
                if '.sdc' in constraints_file['path']:
                    constraints_file['type'] = 'sdc'
                elif '.xdc' in constraints_file['path']:
                    constraints_file['type'] = 'xdc'
                else:
                    print('ERROR: A type cannot be auto-detected from constraints file',constraints_file['path'])
                    sys.exit(1)

    if 'scripts' in fins_data['filesets']:
        script_keys = ['presim','postsim','prebuild','postbuild']
        for script_key in script_keys:
            if script_key in fins_data['filesets']['scripts']:
                for script_file in fins_data['filesets']['scripts'][script_key]:
                    if not 'type' in script_file:
                        if '.py' in script_file['path']:
                            script_file['type'] = 'python'
                        elif '.m' in script_file['path']:
                            # NOTE: Default for .m files is Octave, not Matlab
                            script_file['type'] = 'octave'
                        elif '.tcl' in script_file['path']:
                            script_file['type'] = 'tcl'
                        else:
                            print('ERROR: A type cannot be auto-detected from script file',script_file['path'])
                            sys.exit(1)

        if 'vendor_ip' in fins_data['filesets']['scripts']:
            for script_file in fins_data['filesets']['scripts']['vendor_ip']:
                if not 'type' in script_file:
                    # There is only one option for this script type
                    script_file['type'] = 'tcl'

    return fins_data

def populate_ip(fins_data,verbose):
    # Only continue if this is applicable
    if not 'ip' in fins_data:
        return fins_data

    # Populate the sub-ip properties from the sub-ip JSON
    for ip in fins_data['ip']:
        # Load the sub-ip JSON file
        if os.path.exists(ip['fins_path']):
            with open(ip['fins_path']) as sub_ip_fins_file:
                sub_ip_fins_data = json.load(sub_ip_fins_file)
        else:
            print('ERROR: No sub-ip file',filename,'exists')
            sys.exit(1)

        # Populate the sub-ip's properties
        ip['name'] = sub_ip_fins_data['name']
        if 'company_url' in sub_ip_fins_data:
            ip['vendor'] = sub_ip_fins_data['company_url']
        else:
            ip['vendor'] = 'user.org'
        if 'library' in sub_ip_fins_data:
            ip['library'] = sub_ip_fins_data['library']
        else:
            ip['library'] = 'user'
        if 'version' in sub_ip_fins_data:
            ip['version'] = sub_ip_fins_data['version']
        else:
            ip['version'] = '1.0'

    return fins_data


def override_fins_data(fins_data,filename,verbose):
    '''
    Looks for a <filename>.json.override file in the same directory and overrides params/part of the fins data
    '''
    if (os.path.exists(filename)):
        # Open .override file
        with open(filename) as override_file:
            override_data = json.load(override_file)
        # Override parameters
        if 'params' in override_data:
            for param_ix, param in enumerate(fins_data['params']):
                for edit_param in override_data['params']:
                    if (edit_param['name'].lower() == param['name'].lower()):
                        fins_data['params'][param_ix]['value'] = edit_param['value']
        # Override the part
        if 'part' in override_data:
            fins_data['part'] = override_data['part']
    return fins_data

def validate_filesets(fins_data,filename,verbose):
    # Validate filesets
    if verbose:
        print('+++++ Validating filesets of {} ...'.format(filename))
    validate_files(fins_data['name'],filename,fins_data['filesets']['source'],DESIGN_FILE_TYPES,verbose)
    if 'sim' in fins_data['filesets']:
        validate_files(fins_data['name'],filename,fins_data['filesets']['sim'],DESIGN_FILE_TYPES,verbose)
    if 'constraints' in fins_data['filesets']:
        validate_files(fins_data['name'],filename,fins_data['filesets']['constraints'],CONSTRAINT_FILE_TYPES,verbose)
    if 'scripts' in fins_data['filesets']:
        if 'vendor_ip' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['vendor_ip'],VENDOR_SCRIPT_FILE_TYPES,verbose)
        if 'presim' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['presim'],SCRIPT_FILE_TYPES,verbose)
        if 'postsim' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['postsim'],SCRIPT_FILE_TYPES,verbose)
        if 'prebuild' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['prebuild'],SCRIPT_FILE_TYPES,verbose)
        if 'postbuild' in fins_data['filesets']['scripts']:
            validate_files(fins_data['name'],filename,fins_data['filesets']['scripts']['postbuild'],SCRIPT_FILE_TYPES,verbose)
    if verbose:
        print('+++++ Done.')

def validate_fins_data(fins_data,filename,verbose):
    if verbose:
        print('+++++ Loading schema.json ...')
    with open(SCHEMA_FILENAME) as schema_data:
        fins_schema = json.load(schema_data)
    if verbose:
        print('+++++ Done.')

    # Validate the schema itself
    if verbose:
        print('+++++ Validating schema.json ...')
    validate_schema('schema',fins_schema,verbose)
    if verbose:
        print('+++++ Done.')

    # Validate the FINS JSON file with the schema
    if verbose:
        print('+++++ Validating {} ...'.format(filename))
    validate_fins('fins',fins_data,fins_schema,verbose)
    if verbose:
        print('+++++ Done.')

    # Validate sub-IP
    if 'ip' in fins_data:
        if verbose:
            print('+++++ Validating ip of {} ...'.format(filename))
        validate_ip(fins_data,verbose)
        if verbose:
            print('+++++ Done.')

    # Validate properties
    if 'properties' in fins_data:
        if verbose:
            print('+++++ Validating properties of {} ...'.format(filename))
        validate_properties(fins_data,verbose)
        if verbose:
            print('+++++ Done.')

    # Validate streams
    if 'streams' in fins_data:
        if verbose:
            print('+++++ Validating streams of {} ...'.format(filename))
        validate_streams(fins_data,verbose)
        if verbose:
            print('+++++ Done.')

def load_fins_data(filename, verbose):
    """
    Loads data from a Firmware IP Node Specification JSON file
    """
    # Load JSON Firmware IP Node Specification
    if os.path.exists(filename):
        with open(filename) as fins_file:
            fins_data = json.load(fins_file)
    else:
        print('ERROR: No file',filename,'exists')
        sys.exit(1)

    # Validate the FINS JSON using the schema.json file
    validate_fins_data(fins_data,filename,verbose)

    # Override the FINS JSON data with a .override file if it exists
    fins_data = override_fins_data(fins_data,os.path.dirname(filename)+'.override',verbose)

    # Replace any linked parameters with their literal values
    fins_data = convert_parameters_to_literal(fins_data,verbose)

    # Apply property defaults and calculate offsets
    fins_data = populate_properties(fins_data, 0,verbose)

    # Auto-detect file types
    fins_data = populate_filesets(fins_data, verbose)

    # Auto-detect sub-ip versions
    fins_data = populate_ip(fins_data,verbose)

    # Return
    return fins_data
