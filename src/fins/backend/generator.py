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
import json
import logging
import datetime
from jinja2 import Environment
from jinja2 import FileSystemLoader


# This logger will inherit log-level and settings from main.py
LOGGER = logging.getLogger(__name__)


CORE_NODE_TEMPLATE_DIR = os.path.dirname(__file__) + '/templates/node/'
CORE_APPLICATION_TEMPLATE_DIR = os.path.dirname(__file__) + '/templates/application/'
CORE_SYSTEM_TEMPLATE_DIR = os.path.dirname(__file__) + '/templates/system/'
CORE_OUTPUT_DIR = 'gen/core/'


class Generator:

    def set_option(self, name, value):
        raise ValueError("invalid option '" + name + "'")

    def start_file(self, filename):
        """Notification for the start of processing of an input JSON file.

        Override if your generator needs to perform any actions at the start
        of an input file, such as opening an output file.
        """

    def end_file(self):
        """Notification for the end of processing of an input JSON file.

        Override if your generator needs to perform any actions at the end of
        an input file, such as closing an output file.
        """

    def create_jinja_env(self, directory):
        """Create custom Jinja2 filters
        and return the Environment

        Args:
            directory (str): directory in which to create the Jinja2 Environment

        Returns:
            obj: Environment - the Jinja2 environment to be used by code-gen
        """

        def basename(path):
            return os.path.basename(path)

        def dirname(path):
            return os.path.dirname(path)

        def axisprefix(port, instance_index=0, reverse=False):
            """Given a port, construct its name with the AXI4-Lite prefix prepended.

            Args:
                port (dict): the port dictionary containing the name, direction, and num_instances of the port
                             name: the name of this port
                             direction: is this an "in" or "out" port
                num_instances (int): how many instances are there of this port
                instance_index (int): which port instance?
                reverse (bool): use the master prefix for input and slave for output

            Returns:
                str: the full port name with the prefix prepended
            """
            prefix = ''
            if port['direction'].lower() == 'in':
                if not reverse:
                    prefix += 's'
                else:
                    prefix += 'm'
            else:
                if not reverse:
                    prefix += 'm'
                else:
                    prefix += 's'
            if port['num_instances'] > 1:
                prefix += '{0:02d}'.format(instance_index)
            return prefix + '_axis_' + port['name'].lower()

        def axi4liteprefix(interface, application_external=False, master=False):
            """Given an interface, construct its name with an AXI4-Lite prefix prepended.
            Args:
                interface (dict): the interface dictionary containing the name, extended name, and top
                                  name: the simple and short name of this interface
                                  extended_name: includes the parent-node name when inside an Application
                                  top: is this the interface of the top-IP in a hierarchy (not a sub-IP)?
                application_external (bool): should this function return the extended interface name
                                             as it should be used when exported from a Application?
                master (bool): use the master prefix instead of slave

            Returns:
                str: the full interface name with the prefix prepended
            """

            prefix = ''
            if not master:
                prefix += 'S'
            else:
                prefix += 'M'

            if application_external:
                return prefix + '_AXI_' + interface['extended_name'].upper()

            # The top-level interface of a node does not have a unique name (just 'M/S_AXI')
            if interface['top']:
                return prefix + '_AXI'
            else:
                return prefix + '_AXI_' + interface['name'].upper()

        # Create the Jinja Environment and load templates
        env = Environment(loader=FileSystemLoader(directory))
        env.filters['basename'] = basename
        env.filters['dirname'] = dirname
        env.filters['axisprefix'] = axisprefix
        env.filters['axi4liteprefix'] = axi4liteprefix

        return env

    def render_jinja_template(self, jinja_env, template_name, outfile_name, fins_data):
        template = jinja_env.get_template(template_name)
        template_render = template.render(fins=fins_data, now=datetime.datetime.utcnow())
        template_file = open(outfile_name, 'w')
        template_file.write(template_render)
        template_file.close()

    def generate_node_core(self, fins_data, filename):
        """Generate the core backend files for a FINS Application
        """

        root_dir, output_dir, jinja_env = self.__setup_gen(fins_data, filename, CORE_NODE_TEMPLATE_DIR)

        # Write the build data to a new json file
        with open(output_dir + fins_data['name'] + '.json', 'w') as fins_data_file:
            json.dump(fins_data, fins_data_file, sort_keys=True, indent=2)

        # Generate FINS core files
        if not os.path.exists(root_dir + '.gitignore'):
            # Only auto-generate .gitignore if the repository doesn't have one
            self.render_jinja_template(jinja_env, '.gitignore', root_dir + '.gitignore', fins_data)
        # HDL Source Package, Octave/Python Simulation Packages
        self.render_jinja_template(jinja_env, 'pkg.vhd', output_dir + fins_data['name'] + '_pkg.vhd', fins_data)
        self.render_jinja_template(jinja_env, 'pkg.m', output_dir + fins_data['name'] + '_pkg.m', fins_data)
        self.render_jinja_template(jinja_env, 'pkg.py', output_dir + fins_data['name'] + '_pkg.py', fins_data)
        if 'ip' in fins_data:
            # Generate fins_edit.json files for each Sub-IP
            for ip in fins_data['ip']:
                # Once we are done retrieving parameter values, write the
                # fins edit JSON file for sub-ip
                with open(ip['fins_path'] + '.override', 'w') as override_file:
                    # Strip all fields except for params
                    override_data = {}
                    override_data['params'] = ip['params']
                    if 'part' in fins_data:
                        override_data['part'] = fins_data['part']
                    json.dump(override_data, override_file, sort_keys=True, indent=2)
        if 'ports' in fins_data:
            # Only generate when we have FINS Ports not just HDL Ports
            if 'ports' in fins_data['ports']:
                self.render_jinja_template(jinja_env, 'axis.vhd', output_dir + fins_data['name'] + '_axis.vhd', fins_data)
                self.render_jinja_template(jinja_env, 'axis_verify.vhd', output_dir + fins_data['name'] + '_axis_verify.vhd', fins_data)
        if 'properties' in fins_data:
            # Documentation
            self.render_jinja_template(jinja_env, 'properties.md', output_dir + fins_data['name'] + '_properties.md', fins_data)
            # AXI4-Lite bus code
            self.render_jinja_template(jinja_env, 'axilite.vhd', output_dir + fins_data['name'] + '_axilite.vhd', fins_data)
            self.render_jinja_template(jinja_env, 'axilite_verify.vhd', output_dir + fins_data['name'] + '_axilite_verify.vhd', fins_data)
            # Software Configuration bus code
            self.render_jinja_template(jinja_env, 'swconfig.vhd', output_dir + fins_data['name'] + '_swconfig.vhd', fins_data)
            self.render_jinja_template(jinja_env, 'swconfig_verify.vhd', output_dir + fins_data['name'] + '_swconfig_verify.vhd', fins_data)
            # Clock Domain Crossings code and constraints
            self.render_jinja_template(jinja_env, 'props_cdc.xdc', output_dir + fins_data['name'] + '_props_cdc.xdc', fins_data)
            self.render_jinja_template(jinja_env, 'props_cdc.sdc', output_dir + fins_data['name'] + '_props_cdc.sdc', fins_data)
            self.render_jinja_template(jinja_env, 'props_control_cdc.vhd', output_dir + fins_data['name'] + '_props_control_cdc.vhd', fins_data)
            self.render_jinja_template(jinja_env, 'props_status_cdc.vhd', output_dir + fins_data['name'] + '_props_status_cdc.vhd', fins_data)
        if ('ports' in fins_data) or ('properties' in fins_data):
            # Top-level stubbed out code
            self.render_jinja_template(jinja_env, 'core.vhd', output_dir + fins_data['name'] + '_core.vhd', fins_data)
            self.render_jinja_template(jinja_env, 'top.vhd', output_dir + fins_data['name'] + '.vhd', fins_data)
            self.render_jinja_template(jinja_env, 'top_tb.vhd', output_dir + fins_data['name'] + '_tb.vhd', fins_data)

    def generate_application_core(self, fins_data, filename):
        """Generate the core backend files for a FINS Application
        """
        root_dir, output_dir, jinja_env = self.__setup_gen(fins_data, filename, CORE_APPLICATION_TEMPLATE_DIR)

        # Write the build data to a new json file
        with open(output_dir + fins_data['name'] + '.json', 'w') as fins_data_file:
            json.dump(fins_data, fins_data_file, sort_keys=True, indent=2)

        if not os.path.exists(root_dir + '.gitignore'):
            # Only auto-generate .gitignore if the repository doesn't have one
            self.render_jinja_template(jinja_env, '.gitignore', root_dir + '.gitignore', fins_data)

        # HDL Source Package, Octave/Python Simulation Packages
        self.render_jinja_template(jinja_env, 'pkg.vhd', output_dir + fins_data['name'] + '_pkg.vhd', fins_data)
        self.render_jinja_template(jinja_env, 'pkg.m', output_dir + fins_data['name'] + '_pkg.m', fins_data)
        self.render_jinja_template(jinja_env, 'pkg.py', output_dir + fins_data['name'] + '_pkg.py', fins_data)

        # Some operations only happen for Applications
        # Run some HDL code generation and iterate into sub-nodes
        for node in fins_data['nodes']:
            # Generate JSON override files for each node
            if 'params' in node:
                # Once we are done retrieving parameter values, write the
                # fins edit JSON file for sub-ip
                with open(node['fins_path'] + '.override', 'w') as override_file:
                    # Strip all fields except for params
                    override_data = {}
                    override_data['params'] = node['params']
                    if 'part' in fins_data:
                        override_data['part'] = fins_data['part']
                    json.dump(override_data, override_file, sort_keys=True, indent=2)

        self.render_jinja_template(jinja_env, 'axis_verify.vhd', output_dir + fins_data['name'] + '_axis_verify.vhd', fins_data)
        self.render_jinja_template(jinja_env, 'application_tb.vhd', output_dir + fins_data['name'] + '_tb.vhd', fins_data)

    def generate_system_core(self, fins_data, filename):
        """Generate the core backend files for a FINS System
        """
        root_dir, output_dir, jinja_env = self.__setup_gen(fins_data, filename, CORE_SYSTEM_TEMPLATE_DIR)

        # Write the build data to a new json file
        with open(output_dir + filename, 'w') as fins_data_file:
            json.dump(fins_data, fins_data_file, sort_keys=True, indent=2)

        # Create the parameters TCL script
        self.render_jinja_template(jinja_env, 'params.tcl', output_dir + 'params.tcl', fins_data)

        # Some operations only happen for FINS Systems
        for node in fins_data['nodes']:
            if node['ports_producer']:
                ports_producer_dir = output_dir + node['ports_producer']['name'] + '_axis_parallel_to_tdm/'
                os.makedirs(ports_producer_dir, exist_ok=True)
                self.render_jinja_template(jinja_env, 'axis_parallel_to_tdm.vhd', ports_producer_dir + node['ports_producer']['name'] + '_axis_parallel_to_tdm.vhd', node['ports_producer'])
                self.render_jinja_template(jinja_env, 'axis_parallel_to_tdm.json', ports_producer_dir + node['ports_producer']['name'] + '_axis_parallel_to_tdm.json', node['ports_producer'])
                self.render_jinja_template(jinja_env, 'parallel_word_fifo.tcl', ports_producer_dir + node['ports_producer']['name'] + '_parallel_word_fifo.tcl', node['ports_producer'])
                ports_producer_dir = output_dir + node['ports_producer']['name'] + '_avalonst_parallel_to_tdm/'
                os.makedirs(ports_producer_dir, exist_ok=True)
                self.render_jinja_template(jinja_env, 'avalonst_parallel_to_tdm.vhd', ports_producer_dir + node['ports_producer']['name'] + '_avalonst_parallel_to_tdm.vhd', node['ports_producer'])
                self.render_jinja_template(jinja_env, 'avalonst_parallel_to_tdm.json', ports_producer_dir + node['ports_producer']['name'] + '_avalonst_parallel_to_tdm.json', node['ports_producer'])
                self.render_jinja_template(jinja_env, 'parallel_word_fifo.tcl', ports_producer_dir + node['ports_producer']['name'] + '_parallel_word_fifo.tcl', node['ports_producer'])
            if node['ports_consumer']:
                ports_consumer_dir = output_dir + node['ports_consumer']['name'] + '_axis_tdm_to_parallel/'
                os.makedirs(ports_consumer_dir, exist_ok=True)
                self.render_jinja_template(jinja_env, 'axis_tdm_to_parallel.vhd', ports_consumer_dir + node['ports_consumer']['name'] + '_axis_tdm_to_parallel.vhd', node['ports_consumer'])
                self.render_jinja_template(jinja_env, 'axis_tdm_to_parallel.json', ports_consumer_dir + node['ports_consumer']['name'] + '_axis_tdm_to_parallel.json', node['ports_consumer'])
                ports_consumer_dir = output_dir + node['ports_consumer']['name'] + '_avalonst_tdm_to_parallel/'
                os.makedirs(ports_consumer_dir, exist_ok=True)
                self.render_jinja_template(jinja_env, 'avalonst_tdm_to_parallel.vhd', ports_consumer_dir + node['ports_consumer']['name'] + '_avalonst_tdm_to_parallel.vhd', node['ports_consumer'])
                self.render_jinja_template(jinja_env, 'avalonst_tdm_to_parallel.json', ports_consumer_dir + node['ports_consumer']['name'] + '_avalonst_tdm_to_parallel.json', node['ports_consumer'])

    def generate_node_backend(self, fins_data, filename):
        """Only implemented by Generator subclasses
        """
        pass

    def generate_application_backend(self, fins_data, filename):
        """Only implemented by Generator subclasses
        """
        pass

    def generate_system_backend(self, fins_data, filename):
        """Only implemented by Generator subclasses
        """
        pass

    def __setup_gen(self, fins_data, filename, template_dir):
        """Do some preliminary work for generation:
        Create the core code-gen output dir,
        create a jinja environment with the given the template directory

        Args:
            fins_data (str):    FINS data dictionary
            filename (str):     name of the 'source' JSON
            template_dir (str): directory containing Jinja2 templates

        Returns:
            str: root_dir - directory containing the 'source' JSON
            str: output_dir - the code-generation output directory (e.g. 'gen/core')
            obj: Environment - the Jinja2 environment to be used by code-gen
        """
        # Determine and create the root directory
        if os.path.dirname(filename):
            root_dir = os.path.dirname(filename) + '/'
            output_dir = root_dir + CORE_OUTPUT_DIR
        else:
            root_dir = ''
            output_dir = CORE_OUTPUT_DIR
        os.makedirs(output_dir, exist_ok=True)

        # Create the Jinja2 envjironment
        jinja_env = self.create_jinja_env(template_dir)

        return root_dir, output_dir, jinja_env
