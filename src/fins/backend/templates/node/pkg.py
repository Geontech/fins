{#-
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
-#}
{%- if 'license_lines' in fins %}
{%-  for line in fins['license_lines'] -%}
# {{ line }}
{%-  endfor %}
{%- endif %}

#===============================================================================
# Firmware IP Node Specification (FINS) Auto-Generated File
# ---------------------------------------------------------
# Template:    pkg.py
# Backend:     {{ fins['backend'] }}
# ---------------------------------------------------------
# Description: Python package script for definition of FINS parameters, ports,
#              and properties
#===============================================================================

# Parameters
params = {}
params['FINS_BACKEND'] = '{{ fins['backend'] }}'
{% if 'params' in fins %}
{% for param in fins['params'] -%}
params['{{ param['name'] }}'] =
{%- if param['value'] is iterable and param['value'] is not string %} [{{ param['value']|join(', ') }}]
{% elif param['value'] is string %} '{{ param['value'] }}'
{% else %} {{ param['value']|capitalize }}
{% endif -%}
{% endfor %}
{% endif %}

{% if 'ports' in fins %}
{% if 'ports' in fins['ports'] %}
# Ports
ports = {}
ports['in'] = {}
ports['out'] = {}
{%- for port in fins['ports']['ports'] %}
ports['{{ port['direction']|lower }}']['{{ port['name']|lower }}'] = {}
ports['{{ port['direction']|lower }}']['{{ port['name']|lower }}']['data'] = {}
ports['{{ port['direction']|lower }}']['{{ port['name']|lower }}']['data']['bit_width']    = {{ port['data']['bit_width'] }}
ports['{{ port['direction']|lower }}']['{{ port['name']|lower }}']['data']['is_complex']   = {{ port['data']['is_complex']|capitalize }}
ports['{{ port['direction']|lower }}']['{{ port['name']|lower }}']['data']['is_signed']    = {{ port['data']['is_signed']|capitalize }}
ports['{{ port['direction']|lower }}']['{{ port['name']|lower }}']['data']['num_samples']  = {{ port['data']['num_samples'] }}
ports['{{ port['direction']|lower }}']['{{ port['name']|lower }}']['data']['num_channels'] = {{ port['data']['num_channels'] }}
{%- if 'metadata' in port %}
ports['{{ port['direction']|lower }}']['{{ port['name']|lower }}']['metadata'] = {}
{%- for metafield in port['metadata'] %}
ports['{{ port['direction']|lower }}']['{{ port['name']|lower }}']['metadata']['{{ metafield['name']|lower }}'] = {}
ports['{{ port['direction']|lower }}']['{{ port['name']|lower }}']['metadata']['{{ metafield['name']|lower }}']['bit_width']  = {{ metafield['bit_width'] }}
ports['{{ port['direction']|lower }}']['{{ port['name']|lower }}']['metadata']['{{ metafield['name']|lower }}']['is_complex'] = {{ metafield['is_complex']|capitalize }}
ports['{{ port['direction']|lower }}']['{{ port['name']|lower }}']['metadata']['{{ metafield['name']|lower }}']['is_signed']  = {{ metafield['is_signed']|capitalize }}
{%- endfor %}
{%- endif %}
{%- endfor %}
{% endif %}
{% endif %}
