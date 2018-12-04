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
set IP_PROJECT_NAME "{{ fins['project_name'] }}"
{% if 'description' in fins %}set IP_DESCRIPTION "{{ fins['description'] }}"{% endif %}
{% if 'version' in fins %}set IP_VERSION "{{ fins['version'] }}"{% endif %}
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
{%- if 'params' in fins %}
{{ fins['name'] }}_params.vhd \
{%- endif %}
{%- if 'swconfig' in fins %}
{{ fins['name'] }}_swconfig.vhd \
{%- endif %}
{%- if 'axilite' in fins %}
{{ fins['name'] }}_axilite.vhd \
{%- endif %}
{%- for source_file in fins['filesets']['source'] %}
{{ source_file }} \
{%- endfor %}
]

# List the simulation files
set SIM_FILES [list \
{%- if 'streams' in fins %}
{{ fins['name'] }}_streams.vhd \
./fins/streams/hdl/axis_file_reader.vhd \
./fins/streams/hdl/axis_file_writer.vhd \
{%- endif %}
{%- if 'swconfig' in fins %}
{{ fins['name'] }}_swconfig_verify.vhd \
{%- endif %}
{%- if 'axilite' in fins %}
{{ fins['name'] }}_axilite_verify.vhd \
{%- endif %}
{%- for sim_file in fins['filesets']['sim'] %}
{{ sim_file }} \
{%- endfor %}
]

# List the constraints files
set CONSTRAINTS_FILES [list \
{%- for constraint_file in fins['filesets']['constraints'] %}
{{ constraint_file }} \
{%- endfor %}
]
