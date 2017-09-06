#===============================================================================
# Company:     Geon Technologies, LLC
# File:        ip_params.tcl
# Description: Auto-generated from Jinja2 IP Parameters TCL Template
# Generated:   {{ now }}
#===============================================================================

# Parameters
{% for param in json_params['params'] -%}
{% if "tcl" in param['used_in'] -%}
{% if param['type'] == "string" -%} set {{ param['name'] }} "{{ param['value'] }}"
{% elif param['type'] == "code" -%} {{ param['value'] }}
{% else -%} set {{ param['name'] }} {{ param['value'] }}
{% endif -%}
{% endif -%}
{% endfor %}

# List the source files
set SOURCE_FILES [list \
{% for source_file in json_params['filesets']['source'] -%}
{{ source_file }} \
{% endfor %}]

# List the simulation files
set SIM_FILES [list \
{% for sim_file in json_params['filesets']['sim'] -%}
{{ sim_file }} \
{% endfor %}]

# List the constraints files
set CONSTRAINTS_FILES [list \
{% for constraint_file in json_params['filesets']['constraints'] -%}
{{ constraint_file }} \
{% endfor %}]
