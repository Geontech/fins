#===============================================================================
# Company:     Geon Technologies, LLC
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Auto-generated TCL parameter script
# Generated:   {{ now }}
#===============================================================================

# IP Definition
set IP_NAME "{{ fins['name'] }}"
{% if 'description' in fins %}set IP_DESCRIPTION "{{ fins['description'] }}"{% endif %}
{% if 'company_name' in fins %}set IP_COMPANY_NAME "{{ fins['company_name'] }}"{% endif %}
{% if 'company_url' in fins %}set IP_COMPANY_URL "{{ fins['company_url'] }}"{% endif %}
{% if 'company_logo' in fins %}set IP_COMPANY_LOGO "{{ fins['company_logo'] }}"{% endif %}
{% if 'user_ip_catalog' in fins %}set IP_USER_IP_CATALOG "{{ fins['user_ip_catalog'] }}"{% endif %}
{% if 'part' in fins %}set IP_PART "{{ fins['part'] }}"{% endif %}
{% if 'top_source' in fins %}set IP_TOP "{{ fins['top_source'] }}"{% endif %}
{% if 'top_sim' in fins %}set IP_TESTBENCH "{{ fins['top_sim'] }}"{% endif %}

# Parameters
{% for param in fins['params'] -%}
set {{ param['name'] }}
{%- if param['value'] is iterable and param['value'] is not string %} [list {{ param['value']|join(' ') }}]
{% elif param['value'] is string %} "{{ param['value'] }}"
{% else %} {{ param['value'] }}
{% endif -%}
{% endfor %}

# List the source files
set SOURCE_FILES [list \
{% for source_file in fins['filesets']['source'] -%}
{{ source_file }} \
{% endfor %}]

# List the simulation files
set SIM_FILES [list \
{% for sim_file in fins['filesets']['sim'] -%}
{{ sim_file }} \
{% endfor %}]

# List the constraints files
set CONSTRAINTS_FILES [list \
{% for constraint_file in fins['filesets']['constraints'] -%}
{{ constraint_file }} \
{% endfor %}]
