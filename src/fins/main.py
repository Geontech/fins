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
# FINS Utilities and Logger
from fins.utils import cd
from fins.utils import SchemaType
from fins.utils import ColoredLogger
# FINS Loader and Generator
from fins import loader
from fins.backend.generator import Generator
# FINS version
from fins import version


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


logging.setLoggerClass(ColoredLogger)
logging.getLogger().setLevel(logging.INFO)

# Top level LOGGER
LOGGER = logging.getLogger('fins')


def run_generator(generator, filepath, backend, part):

    filename = os.path.basename(filepath)

    # Change execution directory to where json file is located
    target_dir = '.'
    if os.path.dirname(filepath):
        target_dir = os.path.dirname(filepath)

    if target_dir != '.':
        LOGGER.debug('fTemporarily changing directories to {os.path.dirname(filepath)')

    with cd(target_dir):
        # Load the fins_data and generate the backend
        generator.start_file(filename)
        fins_data = loader.load_json_file(filename)

        # Determine the schema type (NODE, APPLICATION, SYSTEM)
        fins_data['schema_type'] = int(SchemaType.get(fins_data))

        # Determine the part (if one was passed through the command line)
        if part:
            fins_data['part'] = part

        if fins_data['schema_type'] == SchemaType.NODE:
            # This is a FINS IP/Node
            fins_data = loader.validate_and_convert_node_fins_data(fins_data, filename, backend)

            # Recursively call function on all sub-ip
            if 'ip' in fins_data:
                for ip in fins_data['ip']:
                    LOGGER.info(f'Recursing into sub-IP at {os.path.abspath(ip["fins_path"])}')
                    ip['ip_details'] = run_generator(generator, ip['fins_path'], backend, part)

            loader.populate_fins_node(fins_data)
            loader.validate_node_fins_data_final(fins_data)

            try:
                # Run core generation, post core generation ops, and finally backend generation
                LOGGER.debug(f'Running generator for {os.path.abspath(filepath)}')
                generator.generate_node_core(fins_data, filename)
                loader.post_generate_node_core(fins_data)
                generator.generate_node_backend(fins_data, filename)
            except RuntimeError as exc:
                LOGGER.error(f'Generator error: {exc}')

        elif fins_data['schema_type'] == SchemaType.APPLICATION:
            fins_data = loader.validate_and_convert_application_fins_data(fins_data, filename, backend)

            # Recursively call function on all nodes
            # and then populate their contents in fins_data via loader.populate_fins_node
            for node in fins_data['nodes']:
                if not node['descriptive_node']:
                    LOGGER.info(f'Recursing into node at {os.path.abspath(node["fins_path"])}')
                    node['node_details'] = run_generator(generator, node['fins_path'], backend, part)

            loader.populate_fins_application(fins_data)
            loader.validate_application_fins_data_final(fins_data)

            try:
                # Run core generation, post core generation ops, and finally backend generation
                generator.generate_application_core(fins_data, filename)
                generator.generate_application_backend(fins_data, filename)
            except RuntimeError as exc:
                LOGGER.error(f'Generator error: {exc}')

        else:  # schema_type == SchemaType.SYSTEM:
            fins_data = loader.validate_and_convert_system_fins_data(fins_data, filename, backend)

            loader.populate_fins_system(fins_data)
            loader.validate_system_fins_data_final(fins_data)

            try:
                # Run core generation, post core generation ops, and finally backend generation
                generator.generate_system_core(fins_data, filename)
            except RuntimeError as exc:
                LOGGER.error(f'Generator error: {exc}')

        generator.end_file()

        # Validate filesets
        # NOTE: This validate happens after the generator since some of the files referenced
        #       may be generated files
        if 'filesets' in fins_data:
            loader.validate_filesets(fins_data, filename)

        return fins_data


def main():

    arg_parser = argparse.ArgumentParser(description='Generate HDL and programmable logic projects.')
    arg_parser.add_argument('filepath', nargs='+', help='Firmware IP Node Specification (FINS) JSON file')
    verbosity_group = arg_parser.add_mutually_exclusive_group()
    verbosity_group.add_argument('-v', '--verbose', action='store_true', default=False,
                                 help='display debug messages along with messages enabled by default (infos, warnings and errors)')
    verbosity_group.add_argument('-q', '--quiet', action='store_true', default=False,
                                 help='only print warnings and errors (supress infos)')
    arg_parser.add_argument('--version', action='version', version='%(prog)s ' + version.__version__)
    arg_parser.add_argument('-b', '--backend', default='core', help='code generator backend to target')
    arg_parser.add_argument('-o', '--option', action='append', default=[],
                            help='options for code generator backend')
    arg_parser.add_argument('--part', default=None, help='part number of the FPGA being built')

    args = arg_parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    elif args.quiet:
        logging.getLogger().setLevel(logging.WARNING)

    try:
        generator = load_generator(args.backend)
    except KeyError:
        raise SystemExit(f'invalid backend "{args.backend}"')

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
        run_generator(generator, filepath, args.backend, args.part)
