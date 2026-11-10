#
# Copyright (C) 2019, 2026 Geon Technologies, LLC
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
from contextlib import contextmanager
# FINS Utilities and Logger
from fins.utils import cd
from fins.utils import SchemaType
from fins.utils import ColoredLogger
# FINS Loader and Generator
from fins import loader
from fins.backend.generator import Generator
from fins.errors import FinsError, FinsGenerationError
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


@contextmanager
def generator_file(generator, filename):
    """Balance generator file lifecycle callbacks, including on failure."""
    generator.start_file(filename)
    try:
        yield
    finally:
        generator.end_file()


def run_generator(generator, filepath, backend, part, generate_core=True, generate_backend=True):

    filename = os.path.basename(filepath)

    # Change execution directory to where json file is located
    target_dir = '.'
    if os.path.dirname(filepath):
        target_dir = os.path.dirname(filepath)

    if target_dir != '.':
        LOGGER.debug('fTemporarily changing directories to {os.path.dirname(filepath)')

    with cd(target_dir), generator_file(generator, filename):
        # Load the fins_data and generate the backend
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
                    child_part = part or fins_data.get('part')
                    ip['ip_details'] = run_generator(generator, ip['fins_path'], backend, child_part,
                                                     generate_core, generate_backend)

            loader.populate_fins_node(fins_data)
            loader.validate_node_fins_data_final(fins_data)

            try:
                # Run core generation, post core generation ops, and finally backend generation
                LOGGER.debug(f'Running generator for {os.path.abspath(filepath)}')
                if generate_core:
                    generator.generate_node_core(fins_data, filename)
                # HDL inference depends on core-generated top-level sources, but
                # backend-only passes load a fresh fins_data object. Populate it
                # for both the core pass and every vendor backend pass.
                if generate_core or generate_backend:
                    loader.post_generate_node_core(fins_data)
                if generate_backend:
                    generator.generate_node_backend(fins_data, filename)
            except RuntimeError as exc:
                raise FinsGenerationError(f'Generator error: {exc}') from exc

        elif fins_data['schema_type'] == SchemaType.APPLICATION:
            fins_data = loader.validate_and_convert_application_fins_data(fins_data, filename, backend)

            # Recursively call function on all nodes
            # and then populate their contents in fins_data via loader.populate_fins_node
            for node in fins_data['nodes']:
                if not node['descriptive_node']:
                    LOGGER.info(f'Recursing into node at {os.path.abspath(node["fins_path"])}')
                    child_part = part or fins_data.get('part')
                    node['node_details'] = run_generator(generator, node['fins_path'], backend, child_part,
                                                         generate_core, generate_backend)

            loader.populate_fins_application(fins_data)
            loader.validate_application_fins_data_final(fins_data)

            try:
                # Run core generation, post core generation ops, and finally backend generation
                if generate_core:
                    generator.generate_application_core(fins_data, filename)
                if generate_backend:
                    generator.generate_application_backend(fins_data, filename)
            except RuntimeError as exc:
                raise FinsGenerationError(f'Generator error: {exc}') from exc

        else:  # schema_type == SchemaType.SYSTEM:
            fins_data = loader.validate_and_convert_system_fins_data(fins_data, filename, backend)

            loader.populate_fins_system(fins_data)
            loader.validate_system_fins_data_final(fins_data)

            try:
                # Run core generation, post core generation ops, and finally backend generation
                if generate_core:
                    generator.generate_system_core(fins_data, filename)
            except RuntimeError as exc:
                raise FinsGenerationError(f'Generator error: {exc}') from exc

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
    arg_parser.add_argument('-b', '--backend', action='append', dest='backends',
                            help='code generator backend to target; repeat for multiple backends or use "all"')
    arg_parser.add_argument('-o', '--option', action='append', default=[],
                            help='options for code generator backend')
    arg_parser.add_argument('--part', default=None, help='part number of the FPGA being built')

    args = arg_parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    elif args.quiet:
        logging.getLogger().setLevel(logging.WARNING)

    backends = args.backends or ['core']
    if 'all' in backends:
        if len(backends) != 1:
            raise SystemExit('backend "all" cannot be combined with other backends')
        backends = ['vivado', 'quartus']

    # Preserve order while avoiding duplicate generation.
    backends = list(dict.fromkeys(backends))
    generators = []
    for backend in backends:
        try:
            generator = load_generator(backend)
        except KeyError:
            raise SystemExit(f'invalid backend "{backend}"')
        for option in args.option:
            if '=' in option:
                name, value = option.split('=', 1)
            else:
                name, value = option, True
            try:
                generator.set_option(name, value)
            except Exception as exc:
                raise SystemExit(str(exc))
        generators.append((backend, generator))

    try:
        for filepath in args.filepath:
            if backends == ['core']:
                run_generator(generators[0][1], filepath, 'core', args.part,
                              generate_core=True, generate_backend=False)
                continue

            # Generate common HDL once from the vendor-neutral specification.
            core_generator = load_generator('core')
            run_generator(core_generator, filepath, 'core', args.part,
                          generate_core=True, generate_backend=False)
            # Then render each vendor from its own filtered configuration.
            for backend, generator in generators:
                run_generator(generator, filepath, backend, args.part,
                              generate_core=False, generate_backend=True)
    except FinsError as exc:
        LOGGER.error(str(exc))
        raise SystemExit(1)
