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

import os
import logging
import argparse
import pkg_resources

# FINS Utilities
from fins.utils import cd
from fins.utils import SchemaType

# FINS Loader and Generator
from fins import loader
from fins.backend.generator import Generator

from . import version

ENTRY_POINT_ID = 'fins.backend.generators'


class NullGenerator(Generator):
    """
    Default generator that produces no output.
    """
    def generate(self, packet):
        pass


def load_generator(name):
    if name is None:
        return NullGenerator()

    for entry_point in pkg_resources.iter_entry_points(ENTRY_POINT_ID):
        if entry_point.name == name:
            generator = entry_point.load()
            return generator()

    raise KeyError(name)


def run_generator(generator, filepath, backend, verbose):

    filename = os.path.basename(filepath)

    # Change execution directory to where json file is located
    target_dir = '.'
    if os.path.dirname(filepath):
        target_dir = os.path.dirname(filepath)

    if target_dir != '.':
        logging.info('-- Temporarily changing directories to', os.path.dirname(filepath))

    with cd(target_dir):
        # Load the fins_data and generate the backend
        generator.start_file(filename)
        fins_data = loader.load_json_file(filename, verbose)

        # Determine the schema type (NODE, APPLICATION, SYSTEM)
        fins_data['schema_type'] = int(SchemaType.get(fins_data))

        if fins_data['schema_type'] == SchemaType.NODE:
            # This is a FINS IP/Node
            fins_data = loader.validate_and_convert_node_fins_data(fins_data, filename, backend, verbose)

            # Recursively call function on all sub-ip
            if 'ip' in fins_data:
                for ip in fins_data['ip']:
                    logging.info('Recursing into IP at', ip['fins_path'])
                    ip['ip_details'] = run_generator(generator, ip['fins_path'], backend, verbose)

            loader.populate_fins_node(fins_data, verbose)
            loader.validate_node_fins_data_final(fins_data, verbose)

            try:
                # Run core generation, post core generation ops, and finally backend generation
                generator.generate_node_core(fins_data, filename)
                loader.post_generate_node_core(fins_data, verbose)
                generator.generate_node_backend(fins_data, filename)
            except RuntimeError as exc:
                logging.error('Generator error: %s', exc)

        elif fins_data['schema_type'] == SchemaType.APPLICATION:
            fins_data = loader.validate_and_convert_application_fins_data(fins_data, filename, backend, verbose)

            # Recursively call function on all nodes
            # and then populate their contents in fins_data via loader.populate_fins_node
            for node in fins_data['nodes']:
                if not node['descriptive_node']:
                    logging.info('INFO: Recursing into node at "{}"'.format(node['fins_path']))
                    node['node_details'] = run_generator(generator, node['fins_path'], backend, verbose)

            loader.populate_fins_application(fins_data, verbose)
            loader.validate_application_fins_data_final(fins_data, verbose)

            try:
                # Run core generation, post core generation ops, and finally backend generation
                generator.generate_application_core(fins_data, filename)
                generator.generate_application_backend(fins_data, filename)
            except RuntimeError as exc:
                logging.error('Generator error: %s', exc)

        else:  # schema_type == SchemaType.SYSTEM:
            fins_data = loader.validate_and_convert_system_fins_data(fins_data, filename, backend, verbose)

            loader.populate_fins_system(fins_data, verbose)
            loader.validate_system_fins_data_final(fins_data, verbose)

            try:
                # Run core generation, post core generation ops, and finally backend generation
                generator.generate_system_core(fins_data, filename)
            except RuntimeError as exc:
                logging.error('Generator error: %s', exc)

        generator.end_file()

        # Validate filesets
        # NOTE: This validate happens after the generator since some of the files referenced
        #       may be generated files
        if 'filesets' in fins_data:
            loader.validate_filesets(fins_data, filename, verbose)

        return fins_data

def main():
    logging.basicConfig()

    arg_parser = argparse.ArgumentParser(description='Generate HDL and programmable logic projects.')
    arg_parser.add_argument('filepath', nargs='+', help='Firmware IP Node Specification (FINS) JSON file')
    arg_parser.add_argument('-v', '--verbose', action='store_true', default=False,
                            help='display debug messages')
    arg_parser.add_argument('--version', action='version', version='%(prog)s '+version.__version__)
    arg_parser.add_argument('-b', '--backend', default='core', help='code generator backend to target')
    arg_parser.add_argument('-o', '--option', action='append', default=[],
                            help='options for code generator backend')

    args = arg_parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    try:
        generator = load_generator(args.backend)
    except KeyError:
        raise SystemExit("invalid backend '"+args.backend+"'")

    for option in args.option:
        if '=' in option:
            name, value = option.split('=', 1)
        else:
            name = option
            value = True
        try:
            generator.set_option(name, value)
        except Exception as exc:
            raise SystemExit(str(exc))

    for filepath in args.filepath:
        run_generator(generator, filepath, args.backend, args.verbose)
