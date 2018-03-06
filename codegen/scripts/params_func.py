#===============================================================================
# Company:      Geon Techonologies, LLC
# File:         params_func.py
# Description:  Python functions script containing functions and a class called
#               in both gen_ip_params.py and gen_rfnoc_params.py
#
# Revision History:
# Date          Author                  Revision
# ------------- ----------------------- ----------------------------------------
# 2017-07-12    Alex Newgent            Initial Version
#
#===============================================================================

import os
from jinja2 import Environment
from jinja2 import FileSystemLoader

# Function to retrieve a value from parameters dictionary
def getValue(params_dict, param_name):
    for param in params_dict['params']:
        if param['name'] == param_name:
            return param['value']
    return ''

# Function to override parameters
def overrideParams(params_dict, override_dict):
    param_index = 0
    for param in params_dict['params']:
        for override_param in override_dict['params']:
            if (override_param['name'] == param['name']):
                params_dict['params'][param_index]['value'] = override_param['value']
        param_index += 1
    return params_dict

# Function to setup Jinja2 Environment
def env_setup ( DEBUG_ON ):
    "Sets up Jinja2 environment"
    # Get the current absolute path of this script, strip off the
    # "/scripts" postfix and append "/templates"
    template_path = os.path.dirname(os.path.realpath(__file__))
    template_path = template_path[0:template_path.rfind('/')]
    template_path = template_path + '/templates/'
    if DEBUG_ON: print template_path

    # Create the Jinja Environment and load templates
    # from the template_path
    env = Environment(loader=FileSystemLoader(template_path))
    return env;

class template:
    temp_name = ""
    file_name = ""

    def make_file (self,env,json_params,now):
        temp = env.get_template(self.temp_name)
        temp_rend = temp.render(json_params=json_params,now=now)
        temp_file = open(self.file_name,'w')
        temp_file.write(temp_rend)
        temp_file.close()
        return;
