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
from fins.backend.generator import Generator


# This logger will inherit log-level and settings from main.py
LOGGER = logging.getLogger(__name__)


QUARTUS_TEMPLATE_DIR = os.path.dirname(__file__) + '/templates/'
QUARTUS_OUTPUT_DIR = 'gen/quartus/'


class QuartusGenerator(Generator):

    def generate_node_backend(self, fins_data, filename):
        # Determine and create the root directory
        if os.path.dirname(filename):
            root_dir = os.path.dirname(filename) + '/'
            output_dir = root_dir + '/' + QUARTUS_OUTPUT_DIR
        else:
            root_dir = ''
            output_dir = QUARTUS_OUTPUT_DIR
        os.makedirs(output_dir, exist_ok=True)
        self.generate_node_backend_core(fins_data, output_dir)

        # Load JSON and Jinja
        jinja_env = self.create_jinja_env(os.path.join(QUARTUS_TEMPLATE_DIR, 'node'))

        # Generate Quartus targets. Primitive nodes compile and simulate their
        # HDL directly and are not packaged as Platform Designer components.
        if fins_data.get('node_type', 'ip') == 'primitive':
            self.render_jinja_template(
                jinja_env, 'primitive_Makefile',
                output_dir + 'Makefile', fins_data)
            self.render_jinja_template(
                jinja_env, 'primitive_simulate.tcl',
                output_dir + 'primitive_simulate.tcl', fins_data)
        else:
            self.render_jinja_template(jinja_env, 'Makefile', output_dir + 'Makefile', fins_data)
            self.render_jinja_template(jinja_env, 'ip_project.tcl', output_dir + 'ip_project.tcl', fins_data)
            self.render_jinja_template(jinja_env, 'ip_create.tcl', output_dir + 'ip_create.tcl', fins_data)
            self.render_jinja_template(jinja_env, 'ip_hw.tcl', output_dir + 'ip_hw.tcl', fins_data)
            self.render_jinja_template(jinja_env, 'ip_simulate.tcl', output_dir + 'ip_simulate.tcl', fins_data)
        self.generate_node_file_dependencies(fins_data, filename, output_dir)
        self.generate_backend_dispatcher(fins_data, filename)

    def generate_application_backend(self, fins_data, filename):
        # Determine and create the root directory
        if os.path.dirname(filename):
            root_dir = os.path.dirname(filename) + '/'
            output_dir = root_dir + '/' + QUARTUS_OUTPUT_DIR
        else:
            root_dir = ''
            output_dir = QUARTUS_OUTPUT_DIR
        os.makedirs(output_dir, exist_ok=True)
        self.generate_application_backend_core(fins_data, output_dir)

    # Load JSON and Jinja
        jinja_env = self.create_jinja_env(os.path.join(QUARTUS_TEMPLATE_DIR, 'application'))

        # Generate Quartus targets
        self.render_jinja_template(jinja_env, 'Makefile', output_dir + 'Makefile', fins_data)
        self.render_jinja_template(jinja_env, 'application_project.tcl', output_dir + 'application_project.tcl', fins_data)
        self.render_jinja_template(jinja_env, 'application_create.tcl', output_dir + 'application_create.tcl', fins_data)
        self.render_jinja_template(jinja_env, 'application_simulate.tcl', output_dir + 'application_simulate.tcl', fins_data)
        self.generate_backend_dispatcher(fins_data, filename)
