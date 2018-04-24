# {{ persona['name'] }}

## Register Properties

| Name | Offset | Range | Default | RAM Length | Access | Description |
| - | - | - | - | - | - | - |
{% for reg in persona['regs'] -%}
| {{ reg['name'] }} | {{ '%0#10x' | format(reg['offset']) }} | [{{ reg['range_min'] }}, {{ reg['range_max'] }}] | {{ reg['default_values']|join(',') }} | {% if reg['length'] > 1 %}{{ reg['length'] }}{% else %}N/A{% endif %} | {% if reg['writable'] %}readwrite{% else %}readonly{% endif %} | {{ reg['description'] }} |
{% endfor %}
