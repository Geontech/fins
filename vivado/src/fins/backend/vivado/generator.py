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
from fins.backend.generator import Generator

VIVADO_TEMPLATE_DIR = os.path.dirname(__file__)+'/templates/'
VIVADO_OUTPUT_DIR = 'gen/vivado/'

class VivadoGenerator(Generator):
    def generate(self, fins_data, filename, is_nodeset):
        # First generate the source files using base class
        self.generate_core(fins_data, filename, is_nodeset)

        # Determine and create the root directory
        if os.path.dirname(filename):
            root_directory = os.path.dirname(filename)+'/'
            output_directory = root_directory+'/'+VIVADO_OUTPUT_DIR
        else:
            root_directory = ''
            output_directory = VIVADO_OUTPUT_DIR
        os.makedirs(output_directory, exist_ok=True)

        # Load JSON and Jinja
        jinja_env = self.create_jinja_env(VIVADO_TEMPLATE_DIR)

        # Generate Vivado targets
        self.render_jinja_template(jinja_env,'Makefile',root_directory+'Makefile',fins_data)
        self.render_jinja_template(jinja_env,'ip_create.tcl',output_directory+'ip_create.tcl',fins_data)
        self.render_jinja_template(jinja_env,'ip_simulate.tcl',output_directory+'ip_simulate.tcl',fins_data)
