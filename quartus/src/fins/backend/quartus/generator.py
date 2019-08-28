import os
from fins.backend.generator import Generator

QUARTUS_TEMPLATE_DIR = os.path.dirname(__file__)+'/templates/'
QUARTUS_OUTPUT_DIR = 'gen/quartus/'

class QuartusGenerator(Generator):
    def generate(self, fins_data, filename):
        # First generate the source files using base class
        self.generate_core(fins_data, filename)

        # Determine and create the root directory
        if os.path.dirname(filename):
            root_directory = os.path.dirname(filename)+'/'
            output_directory = root_directory+'/'+QUARTUS_OUTPUT_DIR
        else:
            root_directory = ''
            output_directory = QUARTUS_OUTPUT_DIR
        os.makedirs(output_directory, exist_ok=True)

        # Load JSON and Jinja
        jinja_env = self.create_jinja_env(QUARTUS_TEMPLATE_DIR)

        # Generate Vivado targets
        self.render_jinja_template(jinja_env,'Makefile',root_directory+'Makefile',fins_data)
        self.render_jinja_template(jinja_env,'ip_create.tcl',output_directory+'ip_create.tcl',fins_data)
        self.render_jinja_template(jinja_env,'ip_hw.tcl',output_directory+'ip_hw.tcl',fins_data)
        self.render_jinja_template(jinja_env,'ip_simulate.tcl',output_directory+'ip_simulate.tcl',fins_data)
