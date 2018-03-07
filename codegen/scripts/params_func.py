#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Alex Newgent, Josh Schindehette
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Python functions script containing functions and a class called
#              in both gen_ip_params.py and gen_rfnoc_params.py
#===============================================================================

import os
from jinja2 import Environment
from jinja2 import FileSystemLoader

# Function to retrieve a value from parameters dictionary
def get_param_value(fins, param_name):
    for param in fins['params']:
        if param['name'] == param_name:
            return param['value']
    return None

# Function to override parameters
def edit_params(fins, fins_edit):
    param_index = 0
    for param in fins['params']:
        for edit_param in fins_edit['params']:
            if (edit_param['name'] == param['name']):
                fins['params'][param_index]['value'] = edit_param['value']
        param_index += 1
    return fins

# Function to setup Jinja2 Environment
def env_setup ( DEBUG_ON ):
    "Sets up Jinja2 environment"
    # Get the current absolute path of this script, strip off the
    # "/scripts" postfix and append "/templates"
    template_path = os.path.dirname(os.path.realpath(__file__))
    template_path = template_path[:template_path.rfind('/')]
    template_path = template_path + '/templates/'
    if DEBUG_ON: print template_path

    # Create the Jinja Environment and load templates
    # from the template_path
    env = Environment(loader=FileSystemLoader(template_path))
    return env

class template:
    temp_name = ""
    file_name = ""

    def make_file(self, env, fins, now):
        temp = env.get_template(self.temp_name)
        temp_rend = temp.render(fins=fins, now=now)
        temp_file = open(self.file_name,'w')
        temp_file.write(temp_rend)
        temp_file.close()
        return
