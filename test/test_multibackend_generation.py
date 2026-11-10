#!/usr/bin/env python3
"""Fast regression tests for multi-backend FINS generation.

These tests render the core, Vivado, and Quartus outputs but do not invoke
either FPGA toolchain.
"""

import contextlib
import io
import json
import logging
import os
from pathlib import Path
import posixpath
import shutil
import subprocess
import sys
import tempfile
import unittest
import warnings
from unittest import mock


REPO_ROOT = Path(__file__).resolve().parents[1]

# Exercise the source tree directly, including both namespace-package backend
# plugins, without requiring editable installs in a developer checkout.
for source_dir in (
        REPO_ROOT / 'quartus' / 'src',
        REPO_ROOT / 'vivado' / 'src',
        REPO_ROOT / 'src'):
    sys.path.insert(0, str(source_dir))

from fins.backend.generator import Generator  # noqa: E402
from fins.backend.quartus.generator import QuartusGenerator  # noqa: E402
from fins.backend.vivado.generator import VivadoGenerator  # noqa: E402
from fins.errors import FinsGenerationError  # noqa: E402
from fins.loader import (  # noqa: E402
    find_base_address_from_qsys,
    normalize_application_export_keys,
    populate_application_exports,
    populate_filesets,
    populate_fins_application_node,
    populate_fins_system,
    populate_fins_system_node,
    populate_ports,
    populate_properties,
    validate_application_connections,
    validate_fins_data,
)
from fins.utils import SchemaType  # noqa: E402
from fins import main as fins_main  # noqa: E402


class MultiBackendGenerationTest(unittest.TestCase):

    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.temp_root = Path(self.temp_dir.name)
        self.node_dir = self.temp_root / 'test' / 'node'
        shutil.copytree(
            REPO_ROOT / 'test' / 'node',
            self.node_dir,
            ignore=shutil.ignore_patterns(
                'Makefile', 'gen', 'log', 'project', '__pycache__',
                '*.override'))
        shutil.copy2(REPO_ROOT / 'COPYRIGHT', self.temp_root / 'COPYRIGHT')

    def tearDown(self):
        self.temp_dir.cleanup()

    @staticmethod
    def _load_generator(backend):
        generators = {
            'core': Generator,
            'vivado': VivadoGenerator,
            'quartus': QuartusGenerator,
        }
        try:
            return generators[backend]()
        except KeyError:
            raise KeyError(backend)

    def _generate_all(self, backends='all', extra_args=None):
        previous_cwd = Path.cwd()
        previous_log_level = logging.root.manager.disable
        argv = ['fins', '-b', backends]
        argv.extend(extra_args or [])
        argv.append('fins.json')
        try:
            logging.disable(logging.CRITICAL)
            os.chdir(self.node_dir)
            with warnings.catch_warnings(), \
                    contextlib.redirect_stdout(io.StringIO()), \
                    contextlib.redirect_stderr(io.StringIO()), \
                    mock.patch.object(
                        fins_main, 'load_generator', side_effect=self._load_generator), \
                    mock.patch.object(
                        sys, 'argv', argv):
                warnings.simplefilter('ignore', DeprecationWarning)
                fins_main.main()
        finally:
            os.chdir(previous_cwd)
            logging.disable(previous_log_level)

    def assertFileContains(self, relative_path, expected):
        path = self.node_dir / relative_path
        self.assertTrue(path.is_file(), f'Missing generated file: {path}')
        self.assertIn(expected, path.read_text())

    def _read_fins_json(self):
        return json.loads((self.node_dir / 'fins.json').read_text())

    def _write_fins_json(self, fins_data):
        (self.node_dir / 'fins.json').write_text(
            json.dumps(fins_data, indent=2) + '\n')

    @staticmethod
    def _run_cli_with_mocks(argv):
        generators = {}

        def load_generator(backend):
            generator = mock.Mock(name=f'{backend}_generator')
            generators.setdefault(backend, generator)
            return generators[backend]

        with mock.patch.object(sys, 'argv', ['fins', *argv]), \
                mock.patch.object(
                    fins_main, 'load_generator', side_effect=load_generator
                ) as load, \
                mock.patch.object(fins_main, 'run_generator') as run:
            fins_main.main()

        return generators, load, run

    def test_cli_rejects_invalid_and_conflicting_backends(self):
        with mock.patch.object(
                sys, 'argv', ['fins', '-b', 'missing', 'fins.json']), \
                mock.patch.object(
                    fins_main, 'load_generator', side_effect=KeyError):
            with self.assertRaisesRegex(SystemExit, 'invalid backend'):
                fins_main.main()

        with mock.patch.object(
                sys, 'argv',
                ['fins', '-b', 'all', '-b', 'vivado', 'fins.json']):
            with self.assertRaisesRegex(SystemExit, 'cannot be combined'):
                fins_main.main()

    def test_cli_discovers_backend_plugins_by_entry_point(self):
        entry_point = mock.Mock()
        entry_point.name = 'custom'
        generator_class = mock.Mock(return_value=mock.sentinel.generator)
        entry_point.load.return_value = generator_class

        with mock.patch.object(
                fins_main.pkg_resources, 'iter_entry_points',
                return_value=[entry_point]) as iter_entry_points:
            generator = fins_main.load_generator('custom')

        self.assertIs(mock.sentinel.generator, generator)
        iter_entry_points.assert_called_once_with(
            fins_main.ENTRY_POINT_ID)
        entry_point.load.assert_called_once_with()
        generator_class.assert_called_once_with()

    def test_cli_deduplicates_backends_and_processes_multiple_files(self):
        generators, load, run = self._run_cli_with_mocks([
            '-b', 'vivado', '-b', 'vivado', '--part', 'test-part',
            'first.json', 'second.json',
        ])

        self.assertEqual(
            [mock.call('vivado'), mock.call('core'), mock.call('core')],
            load.call_args_list)
        self.assertEqual([
            mock.call(
                generators['core'], 'first.json', 'core', 'test-part',
                generate_core=True, generate_backend=False),
            mock.call(
                generators['vivado'], 'first.json', 'vivado', 'test-part',
                generate_core=False, generate_backend=True),
            mock.call(
                generators['core'], 'second.json', 'core', 'test-part',
                generate_core=True, generate_backend=False),
            mock.call(
                generators['vivado'], 'second.json', 'vivado', 'test-part',
                generate_core=False, generate_backend=True),
        ], run.call_args_list)

    def test_cli_parses_boolean_and_value_backend_options(self):
        generators, _, _ = self._run_cli_with_mocks([
            '-b', 'vivado', '-o', 'flag', '-o', 'key=value', 'fins.json',
        ])

        self.assertEqual(
            [mock.call('flag', True), mock.call('key', 'value')],
            generators['vivado'].set_option.call_args_list)

    def test_cli_sets_requested_log_level(self):
        original_level = logging.getLogger().level
        try:
            self._run_cli_with_mocks(['--verbose', 'fins.json'])
            self.assertEqual(logging.DEBUG, logging.getLogger().level)

            self._run_cli_with_mocks(['--quiet', 'fins.json'])
            self.assertEqual(logging.WARNING, logging.getLogger().level)
        finally:
            logging.getLogger().setLevel(original_level)

    def test_generator_runtime_error_becomes_cli_failure(self):
        failure_json = self.temp_root / 'failure.json'
        failure_json.write_text(json.dumps({'name': 'failure'}))
        generator = Generator()
        generator.start_file = mock.Mock()
        generator.end_file = mock.Mock()
        generator.generate_node_core = mock.Mock(
            side_effect=RuntimeError('render failed'))

        with self.assertRaisesRegex(
                FinsGenerationError, 'Generator error: render failed'):
            fins_main.run_generator(
                generator, str(failure_json), 'core', None,
                generate_core=True, generate_backend=False)

        generator.start_file.assert_called_once_with('failure.json')
        generator.end_file.assert_called_once_with()

        with mock.patch.object(sys, 'argv', ['fins', 'failure.json']), \
                mock.patch.object(
                    fins_main, 'load_generator', return_value=generator), \
                mock.patch.object(
                    fins_main, 'run_generator',
                    side_effect=FinsGenerationError('render failed')), \
                mock.patch.object(fins_main.LOGGER, 'error') as error:
            with self.assertRaises(SystemExit) as raised:
                fins_main.main()

        self.assertEqual(1, raised.exception.code)
        error.assert_called_once_with('render failed')

    def test_part_override_reaches_recursive_sub_ip(self):
        self._generate_all('core', ['--part', 'override-part'])

        generated = json.loads(
            (self.node_dir / 'gen/core/test_top.json').read_text())
        child_override = json.loads(
            (self.node_dir / 'ip/test_middle/fins.json.override').read_text())
        grandchild_override = json.loads((
            self.node_dir /
            'ip/test_middle/ip/test_bottom/fins.json.override').read_text())

        self.assertEqual('override-part', generated['part'])
        self.assertEqual('override-part', child_override['part'])
        self.assertEqual('override-part', grandchild_override['part'])

    def test_application_export_keys_accept_canonical_and_legacy_names(self):
        export = [{'node_name': 'fins_test_ip_0', 'net': 'myinput'}]
        cases = (
            ('port_exports', 'port_exports'),
            ('port-exports', 'port_exports'),
            ('hdl_port_exports', 'hdl_port_exports'),
            ('hdl-port-exports', 'hdl_port_exports'),
            ('hdl_exports', 'hdl_port_exports'),
        )

        for supplied, canonical in cases:
            with self.subTest(supplied=supplied):
                application = json.loads(
                    (REPO_ROOT / 'test/application/application_test.json')
                    .read_text())
                application['schema_type'] = SchemaType.APPLICATION
                application[supplied] = export

                normalize_application_export_keys(application)
                validate_fins_data(
                    application,
                    str(REPO_ROOT / 'test/application/application_test.json'))

                self.assertEqual(export, application[canonical])
                if supplied != canonical:
                    self.assertNotIn(supplied, application)

    def test_application_export_key_alias_conflicts_are_rejected(self):
        with mock.patch('fins.loader.LOGGER.error'), \
                self.assertRaises(SystemExit):
            normalize_application_export_keys({
                'port_exports': [],
                'port-exports': [],
            })

    def test_metadata_only_port_is_rejected(self):
        fins_data = self._read_fins_json()
        fins_data['schema_type'] = SchemaType.NODE

        port = fins_data['ports']['ports'][0]
        del port['data']
        self.assertIn('metadata', port)

        with mock.patch('fins.loader.LOGGER.error') as error, \
                self.assertRaises(SystemExit):
            validate_fins_data(
                fins_data,
                str(self.node_dir / 'fins.json'))

        self.assertEqual(
            'Required key data does not exist in ports',
            error.call_args.args[0])

    def test_system_property_node_requires_offset_and_interface(self):
        node_details = {
            'name': 'property_node',
            'properties': {'properties': []},
        }
        cases = (
            ({'interface_name': 'S_AXI'}, 'properties_offset'),
            ({'properties_offset': 0}, 'interface_name'),
        )

        with mock.patch(
                'fins.loader.load_json_file',
                return_value=node_details):
            for supplied_fields, missing_key in cases:
                with self.subTest(missing_key=missing_key):
                    node = {
                        'fins_path': 'node.json',
                        'module_name': 'node_0',
                        **supplied_fields,
                    }
                    with mock.patch('fins.loader.LOGGER.error') as error, \
                            self.assertRaises(SystemExit):
                        populate_fins_system_node(node)

                    self.assertIn(missing_key, error.call_args.args[0])

    def test_system_propertyless_node_does_not_require_property_address(self):
        node = {
            'fins_path': 'node.json',
            'module_name': 'stream_node_0',
        }

        with mock.patch(
                'fins.loader.load_json_file',
                return_value={'name': 'stream_node'}):
            populate_fins_system_node(node)

        self.assertNotIn('properties_offset', node)
        self.assertNotIn('interface_name', node)

    def test_descriptive_application_node_loads_generated_json(self):
        node_details = {
            'name': 'external_node',
            'ports': {'ports': []},
        }
        node = {
            'fins_path': 'generated/external_node.json',
            'module_name': 'external_node_0',
            'descriptive_node': True,
        }

        with mock.patch(
                'fins.loader.load_json_file',
                return_value=node_details) as load_json:
            populate_fins_application_node(node)

        load_json.assert_called_once_with(node['fins_path'])
        self.assertIs(node_details, node['node_details'])
        self.assertEqual('external_node', node['node_name'])
        self.assertEqual('generated', node['fins_dir'])

    def test_hdl_only_node_does_not_require_params(self):
        fins_data = {
            'name': 'hdl_only',
            'schema_type': SchemaType.NODE,
            'ports': {
                'hdl': [{
                    'name': 'enable',
                    'direction': 'in',
                    'bit_width': 1,
                }],
            },
        }

        validate_fins_data(fins_data, 'hdl_only.json')

    def test_system_allows_only_one_dma_port_per_direction(self):
        node_details = {
            'name': 'stream_node',
            'ports': {
                'ports': [
                    {'name': 'source', 'direction': 'out'},
                    {'name': 'sink', 'direction': 'in'},
                ],
            },
        }
        cases = (
            ('ports_producer_name', 'source'),
            ('ports_consumer_name', 'sink'),
        )

        for field, port_name in cases:
            with self.subTest(field=field):
                fins_data = {
                    'nodes': [
                        {
                            'fins_path': 'node.json',
                            'module_name': 'node_0',
                            field: port_name,
                        },
                        {
                            'fins_path': 'node.json',
                            'module_name': 'node_1',
                            field: port_name,
                        },
                    ],
                }
                with mock.patch(
                        'fins.loader.load_json_file',
                        return_value=node_details), \
                        mock.patch('fins.loader.LOGGER.error') as error, \
                        self.assertRaises(SystemExit):
                    populate_fins_system(fins_data)

                message = error.call_args.args[0]
                self.assertIn(field, message)
                self.assertIn('node_0', message)
                self.assertIn('node_1', message)

    @staticmethod
    def _port_fins_data(data=None, metadata=None):
        port = {
            'name': 'stream',
            'direction': 'in',
            'data': data or {'bit_width': 8},
        }
        if metadata is not None:
            port['metadata'] = metadata
        return {'ports': {'ports': [port]}}

    def test_port_dimensions_must_be_positive(self):
        for field in ('num_samples', 'num_channels'):
            with self.subTest(field=field):
                fins_data = self._port_fins_data({
                    'bit_width': 8,
                    field: 0,
                })
                with mock.patch('fins.loader.LOGGER.error') as error, \
                        self.assertRaises(SystemExit):
                    populate_ports(fins_data)

                self.assertIn(field, error.call_args.args[0])

    def test_aggregate_port_data_width_limit_is_enforced(self):
        populate_ports(self._port_fins_data({
            'bit_width': 8,
            'num_samples': 512,
        }))

        with mock.patch('fins.loader.LOGGER.error') as error, \
                self.assertRaises(SystemExit):
            populate_ports(self._port_fins_data({
                'bit_width': 8,
                'num_samples': 513,
            }))

        self.assertIn('total data width', error.call_args.args[0])

    def test_byte_enable_widths_are_only_added_when_enabled(self):
        for configured_value in (None, False):
            with self.subTest(configured_value=configured_value):
                disabled = self._port_fins_data({'bit_width': 8})
                if configured_value is not None:
                    disabled['ports']['ports'][0][
                        'supports_byte_enable'] = configured_value
                populate_ports(disabled)
                disabled_data = disabled['ports']['ports'][0]['data']
                self.assertNotIn('byte_width', disabled_data)
                self.assertNotIn('empty_width', disabled_data)

        enabled = self._port_fins_data({'bit_width': 8})
        enabled['ports']['ports'][0]['supports_byte_enable'] = True
        populate_ports(enabled)
        enabled_data = enabled['ports']['ports'][0]['data']
        self.assertEqual(1, enabled_data['byte_width'])
        self.assertEqual(1, enabled_data['empty_width'])

        multibyte = self._port_fins_data({
            'bit_width': 8,
            'num_samples': 3,
        })
        multibyte['ports']['ports'][0]['supports_byte_enable'] = True
        populate_ports(multibyte)
        multibyte_data = multibyte['ports']['ports'][0]['data']
        self.assertEqual(3, multibyte_data['byte_width'])
        self.assertEqual(2, multibyte_data['empty_width'])

    @staticmethod
    def _application_connection(source_data, destination_data):
        def endpoint(node_name, direction, data):
            return {
                'node_name': node_name,
                'net': 'stream',
                'type': 'port',
                'instance': None,
                'port': {
                    'name': 'stream',
                    'direction': direction,
                    'supports_backpressure': False,
                    'num_instances': 1,
                    'data': {
                        'is_complex': False,
                        'is_signed': False,
                        **data,
                    },
                },
            }

        return {
            'connections': [{
                'source': endpoint('source', 'out', source_data),
                'destinations': [
                    endpoint('destination', 'in', destination_data),
                ],
            }],
        }

    def test_application_connection_allows_equal_aggregate_widths(self):
        fins_data = self._application_connection(
            {'bit_width': 8, 'num_samples': 2, 'num_channels': 1},
            {'bit_width': 16, 'num_samples': 1, 'num_channels': 1},
        )

        with mock.patch('fins.loader.LOGGER.warning') as warning:
            validate_application_connections(fins_data)

        self.assertIn('matches', warning.call_args.args[0])

    def test_application_connection_rejects_unequal_aggregate_widths(self):
        fins_data = self._application_connection(
            {'bit_width': 8, 'num_samples': 2, 'num_channels': 1},
            {'bit_width': 8, 'num_samples': 1, 'num_channels': 1},
        )

        with mock.patch('fins.loader.LOGGER.error') as error, \
                self.assertRaises(SystemExit):
            validate_application_connections(fins_data)

        self.assertIn(
            'bit_width*num_samples*num_channels does not match',
            error.call_args.args[0])

    def test_unknown_script_extension_defaults_to_cmdline(self):
        fins_data = {
            'filesets': {
                'scripts': {
                    'presim': [{'path': 'scripts/prepare'}],
                },
            },
        }

        with mock.patch('fins.loader.LOGGER.warning') as warning:
            populate_filesets(fins_data)

        self.assertEqual(
            'cmdline',
            fins_data['filesets']['scripts']['presim'][0]['type'])
        warning.assert_called_once()

    def test_metadata_width_limits_are_enforced(self):
        valid = self._port_fins_data(metadata=[
            {'name': 'low', 'bit_width': 2048},
            {'name': 'high', 'bit_width': 2048},
        ])
        populate_ports(valid)

        cases = (
            ([{'name': 'invalid', 'bit_width': 0}], 'invalid'),
            ([
                {'name': 'low', 'bit_width': 2048},
                {'name': 'high', 'bit_width': 2049},
            ], 'total metadata width'),
        )
        for metadata, expected in cases:
            with self.subTest(expected=expected):
                with mock.patch('fins.loader.LOGGER.error') as error, \
                        self.assertRaises(SystemExit):
                    populate_ports(
                        self._port_fins_data(metadata=metadata))

                self.assertIn(expected, error.call_args.args[0])

    @staticmethod
    def _property_fins_data(data_width=32, width=32):
        return {
            'properties': {
                'addr_width': 16,
                'data_width': data_width,
                'is_addr_byte_indexed': True,
                'properties': [{
                    'name': 'control',
                    'type': 'read-write-data',
                    'width': width,
                }],
            },
        }

    def test_property_width_limits_are_enforced(self):
        populate_properties(self._property_fins_data(width=32), 0)
        populate_properties(
            self._property_fins_data(data_width=128, width=128), 0)

        cases = (
            (self._property_fins_data(width=0), 'control'),
            (self._property_fins_data(width=33), 'control'),
            (self._property_fins_data(data_width=129, width=129),
             'data_width'),
        )
        for fins_data, expected in cases:
            with self.subTest(expected=expected):
                with mock.patch('fins.loader.LOGGER.error') as error, \
                        self.assertRaises(SystemExit):
                    populate_properties(fins_data, 0)

                self.assertIn(expected, error.call_args.args[0])

    def test_single_property_default_is_replicated(self):
        fins_data = self._property_fins_data()
        fins_data['properties']['properties'] = [
            {
                'name': 'scalar_default',
                'type': 'read-write-data',
                'length': 3,
                'default_values': 7,
            },
            {
                'name': 'list_default',
                'type': 'read-write-data',
                'length': 2,
                'default_values': [8],
            },
        ]

        populate_properties(fins_data, 0)

        self.assertEqual(
            [7, 7, 7],
            fins_data['properties']['properties'][0]['default_values'])
        self.assertEqual(
            [8, 8],
            fins_data['properties']['properties'][1]['default_values'])

    def test_explicit_application_exports_select_requested_ports(self):
        fins_data = {
            'nodes': [{
                'module_name': 'node_0',
                'descriptive_node': False,
                'node_details': {
                    'ports': {
                        'ports': [
                            {'name': 'selected_axis'},
                            {'name': 'other_axis'},
                        ],
                        'hdl': [
                            {'name': 'selected_hdl'},
                            {'name': 'other_hdl'},
                        ],
                    },
                },
            }],
            'port_exports': [
                {'node_name': 'node_0', 'net': 'selected_axis'},
            ],
            'hdl_port_exports': [
                {'node_name': 'node_0', 'net': 'selected_hdl'},
            ],
        }

        populate_application_exports(fins_data)

        self.assertEqual(
            ['node_0_selected_axis'],
            [port['name'] for port in fins_data['ports']['ports']])
        self.assertEqual(
            ['node_0_selected_hdl'],
            [port['name'] for port in fins_data['ports']['hdl']])

    @staticmethod
    def _expected_dependencies(fins_data, backend):
        dependencies = ['fins.json']
        dependencies.extend(
            fins_data[key] for key in ('company_logo', 'license_file')
            if key in fins_data)
        dependencies.extend(
            ip['fins_path'] for ip in fins_data.get('ip', []))

        filesets = fins_data.get('filesets', {})
        variant_files = {
            f'{fins_data["name"]}_pkg.vhd',
            f'{fins_data["name"]}_axis_verify.vhd',
        }
        for key in ('source', 'sim', 'constraints'):
            for entry in filesets.get(key, []):
                path = posixpath.normpath(entry['path'])
                if (key in ('source', 'sim') and
                        path.startswith('gen/core/') and
                        posixpath.basename(path) in variant_files):
                    path = f'gen/{backend}/core/{posixpath.basename(path)}'
                dependencies.append(path)
        for entries in filesets.get('scripts', {}).values():
            dependencies.extend(entry['path'] for entry in entries)

        return list(dict.fromkeys(
            posixpath.normpath(path) for path in dependencies))

    def test_promoted_parameters_become_top_generics_for_both_backends(self):
        self._generate_all()

        top = (self.node_dir / 'gen' / 'core' / 'test_top.vhd').read_text()
        core = (self.node_dir / 'gen' / 'core' /
                'test_top_core.vhd').read_text()
        package = (self.node_dir / 'gen' / 'core' /
                   'test_top_pkg.vhd').read_text()
        for declaration in (
                'TEST_PARAM_BOOLEAN : boolean := true',
                'TEST_PARAM_INTEGER : integer := 4',
                'TEST_PARAM_STRING : string := "my_string"'):
            self.assertIn(declaration, top)
            self.assertIn(declaration, core)
        self.assertIn(
            'constant TEST_PARAM_STRING : string := "my_string";', package)
        self.assertIn(
            'TEST_PARAM_BOOLEAN => TEST_PARAM_BOOLEAN', top)

        quartus_hw = (self.node_dir / 'gen' / 'quartus' /
                      'ip_hw.tcl').read_text()
        for name in ('TEST_PARAM_BOOLEAN', 'TEST_PARAM_INTEGER',
                     'TEST_PARAM_STRING'):
            self.assertIn(
                f'set_parameter_property {name} HDL_PARAMETER true',
                quartus_hw)

    def test_all_generates_dispatcher_vendor_outputs_and_interfaces(self):
        self._generate_all()

        self.assertFileContains(
            'Makefile',
            'Stable dispatcher for all generated vendor backends')
        self.assertFileContains(
            'Makefile',
            'gen/$(backend)/Makefile clean BACKEND=$(backend)')
        self.assertFileContains(
            'Makefile',
            '$(MAKE) -f gen/vivado/Makefile clean BACKEND=vivado')
        self.assertFileContains(
            'Makefile',
            '$(MAKE) -f gen/quartus/Makefile clean BACKEND=quartus')
        self.assertTrue((self.node_dir / 'gen/vivado/Makefile').is_file())
        self.assertTrue((self.node_dir / 'gen/quartus/Makefile').is_file())

        self.assertFileContains(
            'gen/core/test_top_pkg.vhd',
            'constant FINS_BACKEND : string := "core";')
        self.assertFileContains(
            'gen/vivado/core/test_top_pkg.vhd',
            'constant FINS_BACKEND : string := "vivado";')
        self.assertFileContains(
            'gen/quartus/core/test_top_pkg.vhd',
            'constant FINS_BACKEND : string := "quartus";')

        axis_read = (
            self.node_dir / 'gen/core/test_top_axis_file_read.m').read_text()
        axis_write = (
            self.node_dir / 'gen/core/test_top_axis_file_write.m').read_text()
        self.assertNotIn(
            'This function currently does not support metadata', axis_read)
        self.assertNotIn(
            'This function currently does not support metadata', axis_write)
        self.assertIn('unpack_unsigned_field_from_columns', axis_read)
        self.assertIn('pack_unsigned_field_into_columns', axis_write)
        self.assertIn('metadata_fieldnames', axis_read)
        self.assertIn('metadata_fieldnames', axis_write)

        register_map = (
            self.node_dir / 'gen/core/test_top_mem_map.md').read_text()
        self.assertIn(
            '| Offset | Property | Access | Default | Data Width | Description |',
            register_map)
        self.assertIn(
            '| 0x00000000 | test_prop_read_only | R | 4 | 32 |  |',
            register_map)
        self.assertIn(
            '| 0x00000004 | test_prop_read_only_data[0] | R | 0 | 32 |  |',
            register_map)
        self.assertIn(
            '| 0x00000010 | test_prop_read_only_data[3] | R | 3 | 32 |  |',
            register_map)

        self.assertFileContains(
            'gen/vivado/Makefile', 'LOGS_DIR:=log/vivado')
        self.assertFileContains(
            'gen/quartus/Makefile', 'LOGS_DIR:=log/quartus')
        self.assertFileContains(
            'gen/quartus/Makefile', 'TEMP_FILES:=$(QUARTUS_DIR) $(LOGS_DIR)')
        self.assertFileContains(
            'gen/quartus/Makefile',
            'MODELSIM_LEGACY_SETUP:=$(if '
            '$(and $(QUARTUS_LEGACY_19_4),$(FINS_MODELSIM_INI)),'
            'cp "$(FINS_MODELSIM_INI)" modelsim.ini &&)')
        self.assertFileContains(
            'gen/quartus/Makefile',
            'vsim $(MODELSIM_INI_OPTION)')

        expected_dependencies = (
            'fins.json',
            'docs/geontech_logo.png',
            '../../COPYRIGHT',
            'ip/test_middle/fins.json',
            'hdl/test_top.vhd',
            'hdl/test_top_tb.vhd',
            'constraints/test_top.xdc',
            'scripts/external_property_fifo.tcl',
        )
        for backend in ('vivado', 'quartus'):
            dependency_file = (
                self.node_dir / 'gen' / backend /
                'test_top_file_dependencies.txt')
            self.assertTrue(dependency_file.is_file())
            dependencies = dependency_file.read_text().splitlines()
            for expected_dependency in expected_dependencies:
                self.assertIn(expected_dependency, dependencies)
            self.assertEqual(len(dependencies), len(set(dependencies)))
            self.assertEqual(
                self._expected_dependencies(
                    self._read_fins_json(), backend),
                dependencies)

        quartus_hw = (self.node_dir / 'gen/quartus/ip_hw.tcl').read_text()
        for expected in (
                'add_interface S_AXI axi4lite slave',
                'add_interface_port S_AXI_ACLK S_AXI_ACLK clk Input "1"',
                'add_interface s_axis_myinput axi4stream slave',
                'add_interface_port s_axis_myinput s_axis_myinput_tdata',
                'add_interface m_axis_myoutput axi4stream master',
                'add_interface_port m_axis_myoutput m_axis_myoutput_tdata'):
            self.assertIn(expected, quartus_hw)

        quartus_sim = (
            self.node_dir / 'gen/quartus/ip_simulate.tcl').read_text()
        self.assertIn('set USER_DEFINED_ELAB_OPTIONS "-t 1ps"', quartus_sim)
        self.assertIn('if {[catch {ld} message]} {', quartus_sim)
        self.assertIn('fins_check_simulation_done', quartus_sim)
        self.assertFalse(
            any(line.startswith('vsim ') for line in quartus_sim.splitlines()),
            'Quartus simulation must not elaborate a second time with vsim')

        quartus_project = (
            self.node_dir / 'gen/quartus/ip_project.tcl').read_text()
        self.assertIn(
            'set_global_assignment -name SDC_FILE '
            '"$QUARTUS_TO_ROOT/constraints/test_top.sdc"',
            quartus_project)
        self.assertNotIn('constraints/test_top.xdc', quartus_project)

        # Recursive backend generation must produce the same layout for user
        # sub-IP rather than only for the root node.
        middle_dir = self.node_dir / 'ip' / 'test_middle'
        self.assertTrue((middle_dir / 'gen/vivado/Makefile').is_file())
        self.assertTrue((middle_dir / 'gen/quartus/Makefile').is_file())
        self.assertIn(
            'constant FINS_BACKEND : string := "quartus";',
            (middle_dir / 'gen/quartus/core/test_middle_pkg.vhd').read_text())

        bottom_dir = middle_dir / 'ip' / 'test_bottom'
        for node_dir, node_name in (
                (middle_dir, 'test_middle'),
                (bottom_dir, 'test_bottom')):
            for backend in ('vivado', 'quartus'):
                dependency_file = (
                    node_dir / 'gen' / backend /
                    f'{node_name}_file_dependencies.txt')
                self.assertTrue(dependency_file.is_file())
                self.assertIn('fins.json', dependency_file.read_text().splitlines())

        # A vendor-specific clean must preserve the other vendor's project.
        vivado_project = self.node_dir / 'project' / 'vivado'
        quartus_project = self.node_dir / 'project' / 'quartus'
        vivado_project.mkdir(parents=True)
        quartus_project.mkdir(parents=True)
        subprocess.run(
            ['make', 'clean-vivado'], cwd=self.node_dir,
            check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        self.assertFalse(vivado_project.exists())
        self.assertTrue(quartus_project.exists())

    def test_dependency_files_apply_backend_filters(self):
        fins_data = self._read_fins_json()
        vivado_only = fins_data['filesets']['source'][0]
        quartus_only = fins_data['filesets']['source'][1]
        vivado_only['backend'] = 'vivado'
        quartus_only['backend'] = ['quartus']
        self._write_fins_json(fins_data)

        self._generate_all()

        vivado_dependencies = (
            self.node_dir / 'gen/vivado/test_top_file_dependencies.txt'
        ).read_text().splitlines()
        quartus_dependencies = (
            self.node_dir / 'gen/quartus/test_top_file_dependencies.txt'
        ).read_text().splitlines()
        self.assertIn(vivado_only['path'], vivado_dependencies)
        self.assertNotIn(vivado_only['path'], quartus_dependencies)
        self.assertIn(quartus_only['path'], quartus_dependencies)
        self.assertNotIn(quartus_only['path'], vivado_dependencies)

    def test_vivado_batch_simulation_disables_default_wave_setup(self):
        self._generate_all()

        makefile = (self.node_dir / 'gen/vivado/Makefile').read_text()
        simulation_tcl = (
            self.node_dir / 'gen/vivado/ip_simulate.tcl').read_text()
        batch_tcl_path = self.node_dir / 'gen/vivado/xsim_batch.tcl'

        self.assertIn(
            '$(if $(UseBatch),-tclargs --batch-no-waves)', makefile)
        self.assertIn('--batch-no-waves', simulation_tcl)
        self.assertIn('xsim.simulate.custom_tcl', simulation_tcl)
        self.assertIn(
            'set_property xsim.simulate.custom_tcl {}', simulation_tcl)
        self.assertTrue(batch_tcl_path.is_file())

        batch_tcl = batch_tcl_path.read_text()
        self.assertIn('run 1000ns', batch_tcl)
        self.assertNotIn('add_wave', batch_tcl)

        # Quartus/Questa batch simulation does not add wave objects, so this
        # Vivado-specific workaround must not leak into the Quartus backend.
        self.assertNotIn(
            '--batch-no-waves',
            (self.node_dir / 'gen/quartus/Makefile').read_text())

    def test_dependency_file_handles_optional_fields_and_normalizes_paths(self):
        output_dir = self.temp_root / 'dependencies'
        output_dir.mkdir()
        Generator().generate_node_file_dependencies({
            'name': 'minimal',
            'filesets': {
                'source': [
                    {'path': './hdl/minimal.vhd'},
                    {'path': 'hdl/minimal.vhd'},
                ],
            },
        }, 'minimal.json', str(output_dir))

        dependencies = (
            output_dir / 'minimal_file_dependencies.txt'
        ).read_text().splitlines()
        self.assertEqual(['minimal.json', 'hdl/minimal.vhd'], dependencies)

    def test_qsys_base_address_supports_legacy_and_ipxact_formats(self):
        legacy_qsys = self.temp_root / 'legacy.qsys'
        legacy_qsys.write_text('''\
<system>
  <connection kind="avalon" start="master.out" end="app.S_AXI">
    <parameter name="baseAddress" value="0x00010000" />
  </connection>
</system>
''')
        ipxact_qsys = self.temp_root / 'ipxact.qsys'
        ipxact_qsys.write_text('''\
<ipxact:design
    xmlns:ipxact="http://www.accellera.org/XMLSchema/IPXACT/1685-2014"
    xmlns:altera="http://www.altera.com/XMLSchema/IPXact2014/extensions">
  <ipxact:vendorExtensions>
    <altera:connections>
      <altera:connection altera:kind="avalon" altera:start="master.out"
          altera:end="app.S_AXI">
        <altera:connection_parameter altera:parameter_name="baseAddress"
            altera:parameter_value="0x00020000" />
      </altera:connection>
    </altera:connections>
  </ipxact:vendorExtensions>
</ipxact:design>
''')

        self.assertEqual(
            0x00010000,
            find_base_address_from_qsys(legacy_qsys, 'app', 'S_AXI'))
        self.assertEqual(
            0x00020000,
            find_base_address_from_qsys(ipxact_qsys, 'APP', 's_axi'))

    def test_quartus_fifo_component_fallbacks_cover_supported_versions(self):
        fifo_scripts = (
            REPO_ROOT / 'src/fins/backend/templates/system/parallel_word_fifo.tcl',
            REPO_ROOT / 'test/node/scripts/external_property_fifo.tcl',
            REPO_ROOT / 'test/node/ip/test_middle/scripts/external_property_fifo.tcl',
            REPO_ROOT / (
                'test/node/ip/test_middle/ip/test_bottom/'
                'scripts/external_property_fifo.tcl'),
        )
        for script in fifo_scripts:
            contents = script.read_text()
            self.assertIn(
                'set_instance_parameter_value $FIFO_MODULE_NAME '
                '"DEVICE_FAMILY" $IP_DEVICE_FAMILY', contents)
            self.assertLess(
                contents.index('fifo 19.4.0'),
                contents.index('fifo 19.3.0'))
            self.assertLess(
                contents.index('fifo 19.3.0'),
                contents.index('fifo 19.1.0'))

    def test_quartus_ram_component_fallbacks_cover_supported_versions(self):
        ram_scripts = (
            REPO_ROOT / 'test/node/scripts/memmap_property_ram.tcl',
            REPO_ROOT / 'test/node/ip/test_middle/scripts/memmap_property_ram.tcl',
            REPO_ROOT / (
                'test/node/ip/test_middle/ip/test_bottom/'
                'scripts/memmap_property_ram.tcl'),
        )
        for script in ram_scripts:
            contents = script.read_text()
            self.assertLess(
                contents.index('ram_2port 20.5.0'),
                contents.index('ram_2port 20.0.0'))

    def test_quartus_application_bridge_fallbacks_cover_supported_versions(self):
        template = (
            REPO_ROOT / 'quartus/src/fins/backend/quartus/templates/'
            'application/application_create.tcl').read_text()
        makefile = (
            REPO_ROOT / 'quartus/src/fins/backend/quartus/templates/'
            'application/Makefile').read_text()

        self.assertIn(
            'if {[string compare $FINS_QUARTUS_VERSION "19.4"] == 0}',
            template)
        self.assertIn('set FINS_BRIDGE_VERSION "19.1"', template)
        self.assertIn('set FINS_BRIDGE_VERSION "19.2.0"', template)
        self.assertEqual(
            2, template.count('add_component {{ ') -
            template.count('add_component {{ node'))
        self.assertIn('exec quartus_sh --version', template)
        self.assertNotIn('::env(FINS_QUARTUS_VERSION)', template)
        self.assertIn(
            'cd $(QUARTUS_DIR) && qsys-script',
            makefile)
        self.assertNotIn(
            'FINS_QUARTUS_VERSION="$(QUARTUS_VERSION)" qsys-script',
            makefile)
        self.assertIn(
            "! grep -q ' Error:' $(APPLICATION_CREATE_LOG_PATH)",
            makefile)

        version_block = template.split(
            'if {[catch {exec quartus_sh --version}', 1)[1]
        version_block = (
            'if {[catch {exec quartus_sh --version}' +
            version_block.split('# Set the fixed filepaths', 1)[0])
        for version, expected_bridge in (
                ('19.4', '19.1'), ('24.2', '19.2.0'),
                ('25.1', '19.2.0')):
            result = subprocess.run(
                ['tclsh'],
                input=(
                    'rename exec FINS_ORIGINAL_EXEC\n' +
                    'proc exec {args} {\n' +
                    f'    return "Quartus Prime Pro Version {version}"\n' +
                    '}\n' +
                    version_block +
                    '\nputs $FINS_BRIDGE_VERSION\n'),
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            self.assertEqual(0, result.returncode, result.stderr)
            self.assertEqual(expected_bridge, result.stdout.splitlines()[-1])

    def test_quartus_system_component_fallbacks_cover_supported_versions(self):
        system_script = (
            REPO_ROOT / 'test/system/scripts/stratix10_system.tcl').read_text()

        system_makefile = (REPO_ROOT / 'test/system/Makefile').read_text()

        self.assertIn(
            'if {[string compare $FINS_QUARTUS_VERSION "19.4"] == 0}',
            system_script)
        self.assertIn('set FINS_BRIDGE_VERSION "19.1"', system_script)
        self.assertIn('set FINS_BRIDGE_VERSION "19.2.0"', system_script)
        self.assertIn('set FINS_HPS_VERSION "19.1"', system_script)
        self.assertIn('set FINS_HPS_VERSION "20.1.0"', system_script)
        self.assertEqual(
            2, system_script.count('add_component clock_in ') +
            system_script.count('add_component reset_in '))
        self.assertEqual(
            1, system_script.count(
                'add_component stratix10_hps_0 ip/system/'
                'system_stratix10_hps_0.ip'))
        self.assertIn('exec quartus_sh --version', system_script)
        self.assertNotIn('::env(FINS_QUARTUS_VERSION)', system_script)
        self.assertIn(
            'proc do_create_system '
            '{FINS_BRIDGE_VERSION FINS_HPS_VERSION} {', system_script)
        self.assertIn(
            'do_create_system $FINS_BRIDGE_VERSION $FINS_HPS_VERSION',
            system_script)
        self.assertIn(
            'qsys-script --script=../../scripts/stratix10_system.tcl',
            system_makefile)
        self.assertNotIn('FINS_QUARTUS_VERSION', system_makefile)
        self.assertNotIn('QUARTUS_VERSION:=', system_makefile)
        self.assertIn(
            'if {[lsearch -exact [get_component_parameters] HPS_BOOT] >= 0}',
            system_script)

        version_block = system_script.split(
            'if {[catch {exec quartus_sh --version}', 1)[1]
        version_block = (
            'if {[catch {exec quartus_sh --version}' +
            version_block.split('# create the system', 1)[0])
        for version, expected in (
                ('19.4', '19.1 19.1'),
                ('24.2', '19.2.0 20.1.0'),
                ('25.1', '19.2.0 20.1.0')):
            result = subprocess.run(
                ['tclsh'],
                input=(
                    'rename exec FINS_ORIGINAL_EXEC\n' +
                    'proc exec {args} {\n' +
                    f'    return "Quartus Prime Pro Version {version}"\n' +
                    '}\n' +
                    version_block +
                    '\nputs "$FINS_BRIDGE_VERSION $FINS_HPS_VERSION"\n'),
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            self.assertEqual(0, result.returncode, result.stderr)
            self.assertEqual(expected, result.stdout.splitlines()[-1])

    def test_quartus_application_simulation_handles_supported_versions(self):
        template = (
            REPO_ROOT / 'quartus/src/fins/backend/quartus/templates/'
            'application/Makefile').read_text()

        self.assertIn(
            'QUARTUS_IP_SETUP_ONLY_VERSIONS:=24.2 25.1', template)
        self.assertIn(
            'MODELSIM_LEGACY_SETUP:=$(if '
            '$(and $(QUARTUS_LEGACY_19_4),$(FINS_MODELSIM_INI)),'
            'cp "$(FINS_MODELSIM_INI)" modelsim.ini &&)', template)
        self.assertIn(
            '$(if $(FINS_MODELSIM_INI),-modelsimini modelsim.ini)', template)
        self.assertIn(
            'QUARTUS_LEGACY_19_4:=$(filter 19.4,$(QUARTUS_VERSION))',
            template)
        self.assertIn('vsim $(MODELSIM_INI_OPTION)', template)
        self.assertIn(
            'ifeq ($(filter $(QUARTUS_VERSION),'
            '$(QUARTUS_IP_SETUP_ONLY_VERSIONS)),)', template)
        self.assertLess(
            template.index('ip-setup-simulation'),
            template.index('sim-script-gen --search-path'))

        # Quartus 19.4 and unknown versions retain the legacy command, while
        # 24.2 and 25.1 rely on the scripts emitted by ip-setup-simulation.
        modern_versions = template.split(
            'QUARTUS_IP_SETUP_ONLY_VERSIONS:=', 1)[1].splitlines()[0].split()
        self.assertNotIn('19.4', modern_versions)
        self.assertIn('24.2', modern_versions)
        self.assertIn('25.1', modern_versions)

    def test_quartus_19_4_ci_repairs_precompiled_altera_mf_mapping(self):
        ci_config = (REPO_ROOT / '.gitlab-ci.yml').read_text()

        self.assertIn('.setup-quartus-19-4:', ci_config)
        self.assertIn(
            'ALTERA_MF_LIBRARY="$QUARTUS_PATH/modelsim_ase/'
            'altera/vhdl/altera_mf"',
                      ci_config)
        self.assertIn('vmap altera_mf "$ALTERA_MF_LIBRARY"', ci_config)
        self.assertIn('test -r "$ALTERA_MF_LIBRARY/_info"', ci_config)
        self.assertIn(
            'export FINS_MODELSIM_INI="$CI_PROJECT_DIR/ci-debug/modelsim.ini"',
            ci_config)
        setup = ci_config.split('.setup-quartus-19-4:', 1)[1].split(
            '.collect-test-debug:', 1)[0]
        self.assertNotIn('export MODELSIM=', setup)
        self.assertNotIn('altera_mf_components.vhd', ci_config)
        self.assertNotIn('altera_mf.vhd', ci_config)
        resource_group = 'resource_group: quartus-19.4-simulation'
        quartus_job = ci_config.split('test-quartus 19.4:', 1)[1].split(
            'test-multibackend end-to-end:', 1)[0]
        multibackend_job = ci_config.split(
            'test-multibackend end-to-end:', 1)[1]
        self.assertIn(resource_group, quartus_job)
        self.assertIn(resource_group, multibackend_job)

    def test_ci_shards_test_scopes_and_preserves_diagnostics(self):
        ci_config = (REPO_ROOT / '.gitlab-ci.yml').read_text()

        self.assertIn('test-python:', ci_config)
        self.assertIn('test-core-generation:', ci_config)
        self.assertIn('./test_core.sh "$TEST_SCOPE"', ci_config)
        self.assertIn('./test_backend.sh vivado "$TEST_SCOPE"', ci_config)
        self.assertIn('./test_backend.sh quartus "$TEST_SCOPE"', ci_config)
        self.assertIn('./test/test_multibackend.sh "$TEST_SCOPE"', ci_config)

        for scope in (
                'node', 'application-system', 'axis-files', 'tutorials',
                'application'):
            self.assertIn(f'- {scope}', ci_config)

        self.assertIn('.test-artifacts: &test-artifacts', ci_config)
        self.assertIn('when: always', ci_config)
        self.assertNotIn('when: on_failure', ci_config)
        self.assertEqual(5, ci_config.count('artifacts: *test-artifacts'))
        self.assertEqual(2, ci_config.count('expire_in: never'))
        self.assertNotIn('expire_in: 2 weeks', ci_config)
        self.assertIn('ci-debug/log-tails.txt', ci_config)
        self.assertIn('test/**/*.jou', ci_config)
        self.assertIn('tee "../ci-debug/test_backend_', ci_config)

        multibackend_job = ci_config.split(
            'test-multibackend end-to-end:', 1)[1]
        self.assertNotIn('unittest discover', multibackend_job)

    def test_axilite_verify_honors_disable_default_test(self):
        fins_data = self._read_fins_json()
        properties = fins_data['properties']['properties']

        disabled_property = next(
            prop for prop in properties
            if prop['name'] == 'test_prop_read_only')
        disabled_property['disable_default_test'] = True

        # Leave the control property unset to exercise the default False.
        self._write_fins_json(fins_data)
        self._generate_all('core')

        generated = (
            self.node_dir /
            'gen/core/test_top_axilite_verify.vhd').read_text()

        disabled_marker = '-- Property: test_prop_read_only\n'
        control_marker = '-- Property: test_prop_read_only_data\n'
        following_marker = '-- Property: test_prop_read_only_external\n'

        disabled_section = generated.split(
            disabled_marker, 1)[1].split(control_marker, 1)[0]
        control_section = generated.split(
            control_marker, 1)[1].split(following_marker, 1)[0]

        self.assertNotIn('-- Verify default values', disabled_section)
        self.assertNotIn(
            'TEST_TOP_PROP_TEST_PROP_READ_ONLY_OFFSET0',
            disabled_section)

        self.assertIn('-- Verify default values', control_section)
        self.assertIn(
            'TEST_TOP_PROP_TEST_PROP_READ_ONLY_DATA_OFFSET0',
            control_section)

    def test_sequence_read_write_external_has_valid_swconfig_syntax(self):
        fins_data = self._read_fins_json()
        prop = next(
            prop for prop in fins_data['properties']['properties']
            if prop['name'] == 'test_prop_read_write_external')
        prop['length'] = 2

        self._write_fins_json(fins_data)
        self._generate_all('core')

        swconfig = (
            self.node_dir /
            'gen/core/test_top_swconfig.vhd').read_text()

        expected = (
            'props_status.test_prop_read_write_external(ix).rd_valid;')
        self.assertIn(expected, swconfig)
        self.assertNotIn(expected + ';', swconfig)

    def test_node_without_properties_has_no_memory_map(self):
        fins_data = self._read_fins_json()
        del fins_data['properties']
        fins_data['filesets']['source'] = [
            entry for entry in fins_data['filesets']['source']
            if 'axilite' not in entry['path']]
        fins_data['filesets']['sim'] = [
            entry for entry in fins_data['filesets']['sim']
            if 'axilite' not in entry['path']]
        self._write_fins_json(fins_data)

        self._generate_all('core')

        self.assertFalse(
            (self.node_dir / 'gen/core/test_top_mem_map.md').exists())

    def test_primitive_node_generates_direct_vendor_simulation_flows(self):
        fins_data = self._read_fins_json()
        fins_data['node_type'] = 'primitive'
        fins_data.pop('ip', None)
        fins_data['filesets']['sim'] = [
            entry for entry in fins_data['filesets']['sim']
            if not entry['path'].startswith('./ip/')]
        self._write_fins_json(fins_data)

        self._generate_all()

        vivado_makefile = (self.node_dir / 'gen/vivado/Makefile').read_text()
        for command in ('xvhdl --2008', 'xelab test_top_tb',
                        'xsim $(SNAPSHOT)'):
            self.assertIn(command, vivado_makefile)
        self.assertIn('UseBatch:=$(if $(UseGui),,1)', vivado_makefile)

        quartus_makefile = (self.node_dir / 'gen/quartus/Makefile').read_text()
        for command in ('vcom -2008', 'vlib work'):
            self.assertIn(command, quartus_makefile)
        quartus_sim_command = next(
            line for line in quartus_makefile.splitlines()
            if '&& vsim ' in line)
        self.assertIn('vsim ', quartus_sim_command)
        self.assertIn('vsim $(MODELSIM_INI_OPTION)', quartus_sim_command)
        self.assertIn('$(MODELSIM_TIME_OPTION)', quartus_sim_command)
        self.assertIn(
            '$(if $(UseBatch),-c) work.test_top_tb', quartus_sim_command)
        self.assertIn('-do ', quartus_sim_command)
        self.assertIn('UseBatch:=$(if $(UseGui),,1)', quartus_makefile)
        self.assertNotIn('MODELSIM_LEGACY_SETUP', quartus_makefile)
        self.assertIn(
            'MODELSIM_INI_OPTION:=$(if $(QUARTUS_LEGACY_19_4),,',
            quartus_makefile)

        for backend in ('vivado', 'quartus'):
            self.assertTrue(
                (self.node_dir / 'gen' / backend /
                 'primitive_simulate.tcl').is_file())

        for path in (
                'gen/vivado/ip_create.tcl',
                'gen/vivado/ip_simulate.tcl',
                'gen/quartus/ip_project.tcl',
                'gen/quartus/ip_create.tcl',
                'gen/quartus/ip_hw.tcl',
                'gen/quartus/ip_simulate.tcl',
                'gen/core/test_top.vhd',
                'gen/core/test_top_core.vhd'):
            self.assertFalse(self.node_dir.joinpath(path).exists(), path)

        self.assertTrue(
            (self.node_dir / 'gen/core/test_top_pkg.vhd').is_file())
        self.assertFileContains(
            'Makefile', 'BACKEND ?= $(firstword $(AVAILABLE_BACKENDS))')

        dry_run = subprocess.run(
            ['make', '-n', 'all'], cwd=self.node_dir,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        self.assertEqual(0, dry_run.returncode, dry_run.stderr)

        for backend in ('vivado', 'quartus'):
            makefile = f'gen/{backend}/Makefile'
            batch_run = subprocess.run(
                ['make', '-n', '-f', makefile, 'sim', 'UseGui='],
                cwd=self.node_dir, stdout=subprocess.PIPE,
                stderr=subprocess.PIPE, text=True)
            self.assertEqual(0, batch_run.returncode, batch_run.stderr)
            gui_run = subprocess.run(
                ['make', '-n', '-f', makefile, 'sim', 'UseGui=1'],
                cwd=self.node_dir, stdout=subprocess.PIPE,
                stderr=subprocess.PIPE, text=True)
            self.assertEqual(0, gui_run.returncode, gui_run.stderr)

            if backend == 'vivado':
                self.assertIn(
                    'xsim test_top_snapshot -tclbatch', batch_run.stdout)
                self.assertIn('xsim test_top_snapshot -gui', gui_run.stdout)
                self.assertNotIn('-tclbatch', gui_run.stdout)
            else:
                self.assertIn('-c work.test_top_tb', batch_run.stdout)
                self.assertNotIn('-c work.test_top_tb', gui_run.stdout)

            self.assertIn('primitive_simulate.log 2>&1', batch_run.stdout)
            self.assertNotIn('primitive_simulate.log 2>&1', gui_run.stdout)


if __name__ == '__main__':
    unittest.main()
