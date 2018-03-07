#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Josh Schindehette
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Python script for generating fins scripts into a repository
#===============================================================================
import os
import json
import datetime
import glob
import jinja2

# Constants
FINS_FILENAME = 'fins.json'

# Import JSON Parameters
with open(FINS_FILENAME) as fins_data:
    fins = json.load(fins_data)

# Get IP_NAME
for param in fins['params']:
    if param['name'] == 'IP_NAME':
        IP_NAME = param['value']
        break
else:
    print('Error: IP_NAME not found in fins.json')
    exit()

# Setup Jinja2 environment
template_path = os.path.dirname(os.path.realpath(__file__))
template_path = template_path[:template_path.rfind('/')]
template_path = template_path + '/templates/'
env = jinja2.Environment(loader=jinja2.FileSystemLoader(template_path))

# Generate files from templates
template_filenames = glob.glob(template_path + '*')
for template_filename in template_filenames:
    # Render the Jinja2 template
    template_name = template_filename[template_filename.rfind('/')+1:]
    template = env.get_template(template_name)
    template_render = template.render(fins=fins, now=datetime.datetime.utcnow())
    # Write the output file
    if 'gitignore' in template_name:
        template_file = open('.'+template_name,'w')
    else:
        template_file = open(template_name,'w')
    template_file.write(template_render)
    template_file.close()
