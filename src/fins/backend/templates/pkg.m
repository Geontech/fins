%===============================================================================
% Company:     Geon Technologies, LLC
% Copyright:   (c) 2019 Geon Technologies, LLC. All rights reserved.
%              Dissemination of this information or reproduction of this 
%              material is strictly prohibited unless prior written
%              permission is obtained from Geon Technologies, LLC
% Description: Auto-generated MATLAB/Octave parameter script
% Generated:   {{ now }}
%===============================================================================
{% if 'params' in fins %}
% Parameters
{% for param in fins['params'] -%}
params.{{ param['name'] }} =
{%- if param['value'] is iterable and param['value'] is not string %} [{{ param['value']|join(', ') }}];
{% elif param['value'] is string %} '{{ param['value'] }}';
{% else %} {{ param['value']|lower }};
{% endif -%}
{% endfor %}
{% endif %}

{% if 'ports' in fins %}
% Ports
{%- for port in fins['ports']['ports'] %}
ports.{{ port['direction']|lower }}.{{ port['name']|lower }}.data.bit_width    = {{ port['data']['bit_width'] }};
ports.{{ port['direction']|lower }}.{{ port['name']|lower }}.data.is_complex   = {{ port['data']['is_complex']|lower }};
ports.{{ port['direction']|lower }}.{{ port['name']|lower }}.data.is_signed    = {{ port['data']['is_signed']|lower }};
ports.{{ port['direction']|lower }}.{{ port['name']|lower }}.data.num_samples  = {{ port['data']['num_samples'] }};
ports.{{ port['direction']|lower }}.{{ port['name']|lower }}.data.num_channels = {{ port['data']['num_channels'] }};
{%- if 'metadata' in port %}
{%- for metafield in port['metadata'] %}
ports.{{ port['direction']|lower }}.{{ port['name']|lower }}.metadata.{{ metafield['name']|lower }}.bit_width  = {{ metafield['bit_width'] }};
ports.{{ port['direction']|lower }}.{{ port['name']|lower }}.metadata.{{ metafield['name']|lower }}.is_complex = {{ metafield['is_complex']|lower }};
ports.{{ port['direction']|lower }}.{{ port['name']|lower }}.metadata.{{ metafield['name']|lower }}.is_signed  = {{ metafield['is_signed']|lower }};
{%- endfor %}
{%- endif %}
{%- endfor %}
{% endif %}
