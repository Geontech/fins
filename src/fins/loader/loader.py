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
"""The loader module contains logic for loading FINS user input and validating it.
"""

import os
import sys
import json
import logging

LOGGER = logging.getLogger(__name__)


class Loader:
    """Base class for loading & validating FINS user input data for Nodes, Applications and Systems.
    """

    _loader_dir = os.path.dirname(os.path.abspath(__file__))

    @classmethod
    def validate(cls, fins_input):
        """Validate a FINS input Node, Application or System
        This is a baseclass function meant to be extended by subclasses

        Args:
            fins_input: The FINS input contents to validate for a Node, Application or System

        Returns:
            The validated FINS contents after applying any overrides present
        """
        LOGGER.debug(f'Validating {fins_input}...')

        overrides_present = True
        if overrides_present:
            cls._process_overrides(fins_input)

    @classmethod
    def _process_overrides(cls, fins_input):
        """Override the FINS input for a Node, Application or System
        This is a baseclass function meant to be overridden by subclasses

        Args:
            fins_input: FINS input data to apply overrides to

        Returns:
            fins_input after override modifications

        Raises:
            RuntimeError: This function should be overridden by subclasses
        """
        raise RuntimeError('Shouldn\'t be here')


class JsonLoader(Loader):
    """This class provides logic for loading JSON schemas and validating FINS JSON files.

    Basic API for using this class is just to call JsonLoader.validate(<FINS JSON>).
    """

    # Paths to schema files by type
    __schema_paths = {
        'node':        Loader._loader_dir + '/node.json',
        'application': Loader._loader_dir + '/application.json',
        'system':      Loader._loader_dir + '/system.json'
    }

    # cls.__schemas dict will be filled out as follows by cls.__load_schemas()
    #{
    #    'node'        = <Node        Schema dict>
    #    'application' = <Application Schema dict>
    #    'system'      = <System      Schema dict>
    #}
    __schemas = {}

    __schema_types = ['int', 'float', 'bool', 'str', 'list', 'dict']
    __schema_list_types = ['int', 'float', 'bool', 'str', 'dict']
    __schema_keys = ['is_required', 'types', 'list_types', 'fields']

    @classmethod
    def validate(cls, fins_json):
        """Validate a FINS JSON file for a Node, Application or System against its Schema

        Args:
            fins_json: The FINS JSON file to validate for a Node, Application or System

        Returns:
            The validated dictionary contents of that JSON file after applying any overrides present
        """
        super().validate(fins_json)

        if not cls.__schemas.values():
            cls.__load_schemas()
            for schema_type, schema in cls.__schemas.items():
                LOGGER.debug(f'Validating {schema_type} schema ...')
                try:
                    cls.__validate_schema(schema_type, schema)
                except (TypeError, KeyError) as err:
                    LOGGER.error(str(err))
                    sys.exit(1)

        LOGGER.debug(f'Loading JSON file @ {fins_json}')
        fins_dict = cls.__load_json(fins_json)
        schema_type = cls.get_json_type(fins_dict)
        schema = cls.__schemas[schema_type]
        LOGGER.debug(f'Validating {schema_type} JSON contents ...')
        try:
            cls.__validate_fins('fins-top', fins_dict, schema)
        except (TypeError, KeyError) as err:
            LOGGER.error(str(err))
            sys.exit(1)

        return fins_dict

    @classmethod
    def _process_overrides(cls, fins_dict):
        """Process any override files that exist and appy overrides to fins_dict

        Args:
            fins_dict: FINS dictionary data to apply overrides to

        Returns:
            fins_dict after override modifications
        """
        LOGGER.debug('Processing overrides...')

    @classmethod
    def __load_schemas(cls):
        """Load schemas from files into the cls.__schemas dict
        """
        for schema_type, schema_path in cls.__schema_paths.items():
            LOGGER.debug(f'Loading {schema_type} schema @ {schema_path}')
            cls.__schemas[schema_type] = cls.__load_json(schema_path)

    @classmethod
    def __load_json(cls, json_path):
        """Load a JSON file.

        Args:
            json_path: Path to a JSON file to load

        Returns:
            JSON contents as a dict
        """
        with open(json_path) as json_file:
            return json.load(json_file)

    @classmethod
    def get_json_type(cls, fins_dict):
        """Get the 'type' of a FINS JSON/dict

        Args:
            fins_dict: FINS dictionary data

        Returns:
            String (node, application, system) that decribes the FINS type of the JSON
        """
        if 'nodes' not in fins_dict:
            return 'node'
        elif 'is_application' in fins_dict and fins_dict['is_application']:
            return 'application'
        else:
            return 'system'

    @classmethod
    def __validate_schema(cls, parent_key, schema_object):
        """Validate a schema (recursively) - make sure it is a valid schema

        Args:
            parent_key: The key of the parent element that this function was recursively called on
            schema_object: The schema to validate (or schema sub-dict on recursions)

        Raises:
            TypeError: A field type in the schema is unsupported, invalid, or creates a conflict
            KeyError: A necessary key is missing for a given schema entry
        """
        # Check the keys
        found_is_required = False
        found_types = False

        for key, value in schema_object.items():
            if key not in cls.__schema_keys:
                raise KeyError(f'{parent_key} has an invalid key: {key}')
            if key.lower() == 'is_required':
                found_is_required = True
            if key.lower() == 'types':
                found_types = True

        if not (found_is_required and found_types):
            raise TypeError(f'{parent_key} is missing the is_required or types key')

        # Check the types and the dependent keys
        for schema_object_type in schema_object['types']:
            if schema_object_type not in cls.__schema_types:
                raise TypeError(f'{parent_key} has an invalid type: {schema_object_type}')

        if 'list' in schema_object['types']:
            if 'list_types' not in schema_object:
                raise KeyError(f'{(parent_key)} has no definition for the list types')

            for schema_list_type in schema_object['list_types']:
                if schema_list_type not in cls.__schema_list_types:
                    raise TypeError(f'{parent_key} has an invalid list type: {schema_list_type}')

            if 'dict' in schema_object['list_types']:
                if 'fields' not in schema_object:
                    raise KeyError(f'{parent_key} has no definition for the fields in the dict list type')

        if 'dict' in schema_object['types']:
            if 'fields' not in schema_object:
                raise KeyError(f'{parent_key} has no definition for the fields in the dict type')

        if 'list' in schema_object['types'] and 'dict' in schema_object['types']:
            raise TypeError(f'{parent_key} cannot have both dict and list in the valid types')

        # Recursively check the fields
        if 'fields' in schema_object:
            if 'list' not in schema_object['types'] and 'dict' not in schema_object['types']:
                raise TypeError(f'{parent_key} has a fields key but no dict or list type')
            for key, value in schema_object['fields'].items():
                JsonLoader.__validate_schema(key, value)

        # Notify of success
        LOGGER.debug(f'PASS: {parent_key}')

    @classmethod
    def __validate_fins(cls, parent_key, fins_object, schema_object):
        """Validate a FINS JSON dictionary (recursively) against schema

        Args:
            parent_key: The key of the parent element that this function was recursively called on
            fins_object: The FINS dict being validated (or sub-dict on recursions)
            schema_object: The schema to validate against (or schema sub-dict on recursions)

        Raises:
            TypeError: Element in JSON has unsupported type
            KeyError: Key in JSON is not present in schema
        """

        # Check type
        if type(fins_object) is list:
            if 'list' not in schema_object['types']:
                raise TypeError(f'{parent_key} incorrectly has a list type')
        elif type(fins_object) is dict:
            if 'dict' not in schema_object['types']:
                raise TypeError(f'{parent_key} incorrectly has a dict type')
        elif type(fins_object) is str:
            if 'str' not in schema_object['types']:
                raise TypeError(f'{parent_key} incorrectly has a str type')
        elif type(fins_object) is int:
            if 'int' not in schema_object['types'] and 'float' not in schema_object['types']:
                raise TypeError(f'{parent_key} incorrectly has a int type')
        elif type(fins_object) is float:
            if 'float' not in schema_object['types']:
                raise TypeError(f'{parent_key} incorrectly has a float type')
        elif type(fins_object) is bool:
            if 'bool' not in schema_object['types']:
                raise TypeError(f'{parent_key} incorrectly has a bool type')
        else:
            raise TypeError(f'{parent_key} has an unknown type')

        # Check list types
        if type(fins_object) is list:
            for fins_object_element in fins_object:
                if type(fins_object_element) is dict:
                    if 'dict' not in schema_object['list_types']:
                        raise TypeError(f'{parent_key} incorrectly has a dict list type')
                elif type(fins_object_element) is str:
                    if 'str' not in schema_object['list_types']:
                        raise TypeError(f'{parent_key} incorrectly has a str list type')
                elif type(fins_object_element) is int:
                    if 'int' not in schema_object['list_types'] and 'float' not in schema_object['list_types']:
                        raise TypeError(f'{parent_key} incorrectly has a int list type')
                elif type(fins_object_element) is float:
                    if 'float' not in schema_object['list_types']:
                        raise TypeError(f'{parent_key} incorrectly has a float list type')
                elif type(fins_object_element) is bool:
                    if 'bool' not in schema_object['list_types']:
                        raise TypeError(f'{parent_key} incorrectly has a bool list type')
                else:
                    raise TypeError(f'{parent_key} has an unknown list type')

        # Check the fields
        if 'dict' in schema_object['types']:
            # Check that the required schema keys are in the fins object
            for key, value in schema_object['fields'].items():
                if value['is_required'] and (key not in fins_object):
                    raise KeyError(f'Required key {key} does not exist in {parent_key}')
            # Check for fins object keys that are not in the schema object
            for key, value in fins_object.items():
                if key not in schema_object['fields'].keys():
                    LOGGER.warning(f'Undefined key {key} in {parent_key}')
                    continue
                # Recursively call this function on the fields
                cls.__validate_fins(key, value, schema_object['fields'][key])

        elif ('list' in schema_object['types']) and ('dict' in schema_object['list_types']):
            for fins_object_element in fins_object:
                # Check that the required schema keys are in the fins object
                for key, value in schema_object['fields'].items():
                    if value['is_required'] and key not in fins_object_element:
                        raise KeyError(f'Required key {key} does not exist in {parent_key}')
                # Check for fins object keys that are not in the schema object
                for key, value in fins_object_element.items():
                    if key not in schema_object['fields'].keys():
                        LOGGER.warning(f'Undefined key {key} in {parent_key}')
                        continue
                    # Recursively call this function on the fields
                    cls.__validate_fins(key, value, schema_object['fields'][key])

        # Notify of success
        LOGGER.debug(f'PASS: {parent_key}')
