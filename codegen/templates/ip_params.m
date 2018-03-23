%===============================================================================
% Company:     Geon Technologies, LLC
% File:        ip_params.m
% Description: Auto-generated from Jinja2 Matlab/Octave Params Template
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
streams.{%- if stream['mode'] == "slave" -%}in{%- else -%}out{%- endif -%}.{{ stream['name'] }}.bit_width   = params.{{ stream['bit_width'] }};
streams.{%- if stream['mode'] == "slave" -%}in{%- else -%}out{%- endif -%}.{{ stream['name'] }}.is_complex  = params.{{ stream['is_complex'] }};
streams.{%- if stream['mode'] == "slave" -%}in{%- else -%}out{%- endif -%}.{{ stream['name'] }}.is_signed   = params.{{ stream['is_signed'] }};
streams.{%- if stream['mode'] == "slave" -%}in{%- else -%}out{%- endif -%}.{{ stream['name'] }}.frame_size  = params.{{ stream['packet_size'] }};
{% endfor %}
