{#-
--
-- Copyright (C) 2019 Geon Technologies, LLC
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
# {{ fins['name'] }} Properties

| Offset | Name | Type | Range | Default | Width | Length | Access | Signed | Description |
| - | - | - | - | - | - | - | - | - | - |
{% for reg in fins['properties']['properties'] -%}
| {{ '%0#10x' | format(reg['offset']) }} | {{ reg['name'] }} | {{ reg['type'] }} | [{{ reg['range_min'] }}, {{ reg['range_max'] }}] | {{ reg['default_values']|join(',') }} | {{ reg['width'] }} | {{ reg['length'] }} | {% if reg['is_readable'] %}R{% endif %}{% if reg['is_writable'] %}W{% endif %} | {{ reg['is_signed'] }} | {{ reg['description'] }} |
{% endfor %}
