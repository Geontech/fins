import os
import json
import datetime
from jinja2 import Environment
from jinja2 import FileSystemLoader

CORE_TEMPLATE_DIR = os.path.dirname(__file__)+'/templates/'
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
        # Create custom Jinja2 filters for basename and dirname
        def basename(path):
            return os.path.basename(path)
        def dirname(path):
            return os.path.dirname(path)

        # Create the Jinja Environment and load templates
        env = Environment(loader=FileSystemLoader(directory))
        env.filters['basename'] = basename
        env.filters['dirname'] = dirname

        return env

    def render_jinja_template(self, jinja_env, template_name, outfile_name, fins_data):
        template = jinja_env.get_template(template_name)
        template_render = template.render(fins=fins_data, now=datetime.datetime.utcnow())
        template_file = open(outfile_name, 'w')
        template_file.write(template_render)
        template_file.close()

    def generate_core(self, fins_data, filename):
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

        # Write the FINS data model to file
        with open(output_directory+fins_data['name']+'.json', 'w') as fins_data_file:
            json.dump(fins_data, fins_data_file, sort_keys=True, indent=2)

        # Create the Jinja2 envjironment
        jinja_env = self.create_jinja_env(CORE_TEMPLATE_DIR)

        # Generate FINS core files
        if not os.path.exists(root_directory+'.gitignore'):
            # Only auto-generate .gitignore if the repository doesn't have one
            self.render_jinja_template(jinja_env, '.gitignore', root_directory+'.gitignore', fins_data)
        if 'params' in fins_data:
            self.render_jinja_template(jinja_env, 'pkg.vhd', output_directory+fins_data['name']+'_pkg.vhd', fins_data)
        if 'streams' in fins_data:
            self.render_jinja_template(jinja_env, 'streams.vhd', output_directory+fins_data['name']+'_streams.vhd', fins_data)
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
        if 'properties' in fins_data:
            # Documentation
            self.render_jinja_template(jinja_env, 'properties.md', output_directory+fins_data['name']+'_properties.md', fins_data)
            # AXI4-Lite bus code
            self.render_jinja_template(jinja_env, 'axilite.vhd', output_directory+fins_data['name']+'_axilite.vhd', fins_data)
            self.render_jinja_template(jinja_env, 'axilite_verify.vhd', output_directory+fins_data['name']+'_axilite_verify.vhd', fins_data)
            # Software Configuration bus code
            self.render_jinja_template(jinja_env, 'swconfig.vhd', output_directory+fins_data['name']+'_swconfig.vhd', fins_data)
            self.render_jinja_template(jinja_env, 'swconfig_verify.vhd', output_directory+fins_data['name']+'_swconfig_verify.vhd', fins_data)
        if ('streams' in fins_data) or ('params' in fins_data):
            self.render_jinja_template(jinja_env, 'params.m', output_directory+fins_data['name']+'_params.m', fins_data)
            self.render_jinja_template(jinja_env, 'params.py', output_directory+fins_data['name']+'_params.py', fins_data)

    def generate(self, fins_data, filename):
        self.generate_core(fins_data, filename)
