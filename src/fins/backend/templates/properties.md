# {{ fins['name'] }} Properties

| Offset | Name | Type | Range | Default | Width | Length | Access | Signed | Description |
| - | - | - | - | - | - | - | - | - | - | - | - |
{% for reg in fins['properties']['properties'] -%}
| {{ '%0#10x' | format(reg['offset']) }} | {{ reg['name'] }} | {{ reg['type'] }} | [{{ reg['range_min'] }}, {{ reg['range_max'] }}] | {{ reg['default_values']|join(',') }} | {{ reg['width'] }} | {{ reg['length'] }} | {% if reg['is_readable'] %}R{% endif %}{% if reg['is_writable'] %}W{% endif %} | {{ reg['is_signed'] }} | {{ reg['description'] }} |
{% endfor %}
