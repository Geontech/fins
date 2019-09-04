#===============================================================================
# Company:     Geon Technologies, LLC
# Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Auto-generated Python parameter script
# Generated:   {{ now }}
#===============================================================================
{% if 'params' in fins %}
# Parameters
params = {}
{% for param in fins['params'] -%}
params['{{ param['name'] }}'] =
{%- if param['value'] is iterable and param['value'] is not string %} [{{ param['value']|join(', ') }}]
{% elif param['value'] is string %} '{{ param['value'] }}'
{% else %} {{ param['value']|capitalize }}
{% endif -%}
{% endfor %}
{% endif %}

{% if 'ports' in fins %}
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
