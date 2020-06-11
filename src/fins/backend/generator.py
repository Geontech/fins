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
import datetime
from jinja2 import Environment
from jinja2 import FileSystemLoader

CORE_NODE_TEMPLATE_DIR = os.path.dirname(__file__)+'/templates/node/'
CORE_NODESET_TEMPLATE_DIR = os.path.dirname(__file__)+'/templates/nodeset/'
CORE_OUTPUT_DIR = 'gen/core/'
class Generator:
    def set_option(self, name, value):
        raise ValueError("invalid option '"+name+"'")

    def start_file(self, filename):
        """
        Notification for the start of processing of an input JSON file.

        Override if your generator needs to perform any actions at the start
        of an input file, such as opening an output file.
        """

    def end_file(self):
        """
        Notification for the end of processing of an input JSON file.

        Override if your generator needs to perform any actions at the end of
        an input file, such as closing an output file.
        """

    def create_jinja_env(self, directory):
        # Create custom Jinja2 filters
        def basename(path):
            return os.path.basename(path)
        def dirname(path):
            return os.path.dirname(path)
        def axisprefix(port, instance_index, reverse=False):
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

        # Create the Jinja Environment and load templates
        env = Environment(loader=FileSystemLoader(directory))
        env.filters['basename'] = basename
        env.filters['dirname'] = dirname
        env.filters['axisprefix'] = axisprefix

        return env

    def render_jinja_template(self, jinja_env, template_name, outfile_name, fins_data):
        template = jinja_env.get_template(template_name)
        template_render = template.render(fins=fins_data, now=datetime.datetime.utcnow())
        template_file = open(outfile_name, 'w')
        template_file.write(template_render)
        template_file.close()

    def generate_core(self, fins_data, filename, is_nodeset):
        """
        Should be called by the generate() methods of child classes to
        generate the source files used by backend targets
        """
        # Determine and create the root directory
        if os.path.dirname(filename):
            root_directory = os.path.dirname(filename)+'/'
            output_directory = root_directory+CORE_OUTPUT_DIR
        else:
            root_directory = ''
            output_directory = CORE_OUTPUT_DIR
        os.makedirs(output_directory, exist_ok=True)

        # Do different generation actions based on the type of schema
        if is_nodeset:
            # Write the build data to a new json file
            with open(output_directory+filename, 'w') as fins_data_file:
                json.dump(fins_data, fins_data_file, sort_keys=True, indent=2)

            # Create the Jinja2 envjironment
            jinja_env = self.create_jinja_env(CORE_NODESET_TEMPLATE_DIR)

            # Create the parameters TCL script
            self.render_jinja_template(jinja_env, 'params.tcl', output_directory+'params.tcl', fins_data)

            for node in fins_data['nodes']:
                # Generate JSON override files for each node
                if 'params' in node:
                    # Once we are done retrieving parameter values, write the
                    # fins edit JSON file for sub-ip
                    with open(node['fins_path']+'.override', 'w') as override_file:
                        # Strip all fields except for params
                        override_data = {}
                        override_data['params'] = node['params']
                        if 'part' in fins_data:
                            override_data['part'] = fins_data['part']
                        json.dump(override_data, override_file, sort_keys=True, indent=2)

            self.render_jinja_template(jinja_env, 'nodeset_tb.vhd', output_directory+fins_data['name']+'_tb.vhd', fins_data)

            # Generate FINS core files
            for node in fins_data['nodes']:
                if node['ports_producer']:
                    ports_producer_directory = output_directory + node['ports_producer']['name'] + '_axis_parallel_to_tdm/'
                    os.makedirs(ports_producer_directory, exist_ok=True)
                    self.render_jinja_template(jinja_env, 'axis_parallel_to_tdm.vhd', ports_producer_directory+node['ports_producer']['name']+'_axis_parallel_to_tdm.vhd', node['ports_producer'])
                    self.render_jinja_template(jinja_env, 'axis_parallel_to_tdm.json', ports_producer_directory+node['ports_producer']['name']+'_axis_parallel_to_tdm.json', node['ports_producer'])
                    self.render_jinja_template(jinja_env, 'parallel_word_fifo.tcl', ports_producer_directory+node['ports_producer']['name']+'_parallel_word_fifo.tcl', node['ports_producer'])
                    ports_producer_directory = output_directory + node['ports_producer']['name'] + '_avalonst_parallel_to_tdm/'
                    os.makedirs(ports_producer_directory, exist_ok=True)
                    self.render_jinja_template(jinja_env, 'avalonst_parallel_to_tdm.vhd', ports_producer_directory+node['ports_producer']['name']+'_avalonst_parallel_to_tdm.vhd', node['ports_producer'])
                    self.render_jinja_template(jinja_env, 'avalonst_parallel_to_tdm.json', ports_producer_directory+node['ports_producer']['name']+'_avalonst_parallel_to_tdm.json', node['ports_producer'])
                    self.render_jinja_template(jinja_env, 'parallel_word_fifo.tcl', ports_producer_directory+node['ports_producer']['name']+'_parallel_word_fifo.tcl', node['ports_producer'])
                if node['ports_consumer']:
                    ports_consumer_directory = output_directory + node['ports_consumer']['name'] + '_axis_tdm_to_parallel/'
                    os.makedirs(ports_consumer_directory, exist_ok=True)
                    self.render_jinja_template(jinja_env, 'axis_tdm_to_parallel.vhd', ports_consumer_directory+node['ports_consumer']['name']+'_axis_tdm_to_parallel.vhd', node['ports_consumer'])
                    self.render_jinja_template(jinja_env, 'axis_tdm_to_parallel.json', ports_consumer_directory+node['ports_consumer']['name']+'_axis_tdm_to_parallel.json', node['ports_consumer'])
                    ports_consumer_directory = output_directory + node['ports_consumer']['name'] + '_avalonst_tdm_to_parallel/'
                    os.makedirs(ports_consumer_directory, exist_ok=True)
                    self.render_jinja_template(jinja_env, 'avalonst_tdm_to_parallel.vhd', ports_consumer_directory+node['ports_consumer']['name']+'_avalonst_tdm_to_parallel.vhd', node['ports_consumer'])
                    self.render_jinja_template(jinja_env, 'avalonst_tdm_to_parallel.json', ports_consumer_directory+node['ports_consumer']['name']+'_avalonst_tdm_to_parallel.json', node['ports_consumer'])
        else:
            # Write the FINS data model to file
            with open(output_directory+fins_data['name']+'.json', 'w') as fins_data_file:
                json.dump(fins_data, fins_data_file, sort_keys=True, indent=2)

            # Create the Jinja2 envjironment
            jinja_env = self.create_jinja_env(CORE_NODE_TEMPLATE_DIR)

            # Generate FINS core files
            if not os.path.exists(root_directory+'.gitignore'):
                # Only auto-generate .gitignore if the repository doesn't have one
                self.render_jinja_template(jinja_env, '.gitignore', root_directory+'.gitignore', fins_data)
            # HDL Source Package, Octave/Python Simulation Packages
            self.render_jinja_template(jinja_env, 'pkg.vhd', output_directory+fins_data['name']+'_pkg.vhd', fins_data)
            self.render_jinja_template(jinja_env, 'pkg.m', output_directory+fins_data['name']+'_pkg.m', fins_data)
            self.render_jinja_template(jinja_env, 'pkg.py', output_directory+fins_data['name']+'_pkg.py', fins_data)
            if 'ip' in fins_data:
                # Generate fins_edit.json files for each Sub-IP
                for ip in fins_data['ip']:
                    # Once we are done retrieving parameter values, write the
                    # fins edit JSON file for sub-ip
                    with open(ip['fins_path']+'.override', 'w') as override_file:
                        # Strip all fields except for params
                        override_data = {}
                        override_data['params'] = ip['params']
                        if 'part' in fins_data:
                            override_data['part'] = fins_data['part']
                        json.dump(override_data, override_file, sort_keys=True, indent=2)
            if 'ports' in fins_data:
                # Only generate when we have FINS Ports not just HDL Ports
                if 'ports' in fins_data['ports']:
                    self.render_jinja_template(jinja_env, 'axis.vhd', output_directory+fins_data['name']+'_axis.vhd', fins_data)
                    self.render_jinja_template(jinja_env, 'axis_verify.vhd', output_directory+fins_data['name']+'_axis_verify.vhd', fins_data)
            if 'properties' in fins_data:
                # Documentation
                self.render_jinja_template(jinja_env, 'properties.md', output_directory+fins_data['name']+'_properties.md', fins_data)
                # AXI4-Lite bus code
                self.render_jinja_template(jinja_env, 'axilite.vhd', output_directory+fins_data['name']+'_axilite.vhd', fins_data)
                self.render_jinja_template(jinja_env, 'axilite_verify.vhd', output_directory+fins_data['name']+'_axilite_verify.vhd', fins_data)
                # Software Configuration bus code
                self.render_jinja_template(jinja_env, 'swconfig.vhd', output_directory+fins_data['name']+'_swconfig.vhd', fins_data)
                self.render_jinja_template(jinja_env, 'swconfig_verify.vhd', output_directory+fins_data['name']+'_swconfig_verify.vhd', fins_data)
            if ('ports' in fins_data) or ('properties' in fins_data):
                # Top-level stubbed out code
                self.render_jinja_template(jinja_env, 'core.vhd', output_directory+fins_data['name']+'_core.vhd', fins_data)
                self.render_jinja_template(jinja_env, 'top.vhd', output_directory+fins_data['name']+'.vhd', fins_data)
                self.render_jinja_template(jinja_env, 'top_tb.vhd', output_directory+fins_data['name']+'_tb.vhd', fins_data)

    def generate(self, fins_data, filename, is_nodeset):
        self.generate_core(fins_data, filename, is_nodeset)
