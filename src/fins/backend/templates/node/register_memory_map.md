{#-
--
-- Copyright (C) 2026 Geon Technologies, LLC
--
-- This file is part of FINS.
--
-- FINS is free software: you can redistribute it and/or modify it under the
-- terms of the GNU Lesser General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option)
-- any later version.
--
-- FINS is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
-- more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see http://www.gnu.org/licenses/.
--
-#}
{%- if 'license_lines' in fins %}
# License

{%   for line in fins['license_lines'] -%}
{{ line }}
{%-  endfor %}
{%  endif %}
# {{ fins['name'] }} Register Memory Map

| Offset | Property | Access | Default | Data Width | Description |
| ---: | --- | :---: | ---: | ---: | --- |
{% set byte_stride = fins['properties']['data_width'] // 8 if fins['properties']['is_addr_byte_indexed'] else 1 -%}
{% for reg in fins['properties']['properties'] -%}
{% for index in range(reg['length']) -%}
| {{ '%0#10x' | format((reg['offset'] + index) * byte_stride) }} | {{ reg['name'] }}{% if reg['length'] > 1 %}[{{ index }}]{% endif %} | {% if reg['is_readable'] %}R{% endif %}{% if reg['is_writable'] %}W{% endif %} | {{ reg['default_values'][index] }} | {{ reg['width'] }} | {{ reg['description']|replace('|', '\\|') }} |
{% endfor -%}
{% endfor %}
