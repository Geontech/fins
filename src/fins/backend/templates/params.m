%===============================================================================
% Company:     Geon Technologies, LLC
% Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
%              Dissemination of this information or reproduction of this 
%              material is strictly prohibited unless prior written
%              permission is obtained from Geon Technologies, LLC
% Description: Auto-generated MATLAB/Octave parameter script
% Generated:   {{ now }}
%===============================================================================

% Parameters
{% for param in fins['params'] -%}
params.{{ param['name'] }} =
{%- if param['value'] is iterable and param['value'] is not string %} [{{ param['value']|join(', ') }}];
{% elif param['value'] is string %} '{{ param['value'] }}';
{% else %} {{ param['value']|lower }};
{% endif -%}
{% endfor %}

% Streams
{% for stream in fins['streams'] -%}
streams.{%- if stream['mode'] == "slave" -%}in{%- else -%}out{%- endif -%}.{{ stream['name'] }}.bit_width   = {{ stream['bit_width'] }};
streams.{%- if stream['mode'] == "slave" -%}in{%- else -%}out{%- endif -%}.{{ stream['name'] }}.is_complex  = {{ stream['is_complex'] | lower }};
streams.{%- if stream['mode'] == "slave" -%}in{%- else -%}out{%- endif -%}.{{ stream['name'] }}.is_signed   = {{ stream['is_signed'] | lower }};
streams.{%- if stream['mode'] == "slave" -%}in{%- else -%}out{%- endif -%}.{{ stream['name'] }}.frame_size  = {{ stream['packet_size'] }};
{% endfor %}
