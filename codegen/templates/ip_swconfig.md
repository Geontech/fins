# {{ fins['name'] }} Software Configuration Registers

| Offset | Name | Range | Default | Width | Length | Access | Write Ports | Read Ports | RAM | Signed | Description |
| - | - | - | - | - | - | - | - | - | - | - | - |
{% for reg in fins['swconfig']['regs'] -%}
| {{ '%0#10x' | format(reg['offset']) }} | {{ reg['name'] }} | [{{ reg['range_min'] }}, {{ reg['range_max'] }}] | {{ reg['default_values']|join(',') }} | {{ reg['width'] }} | {{ reg['length'] }} | {% if reg['is_readable'] %}R{% endif %}{% if reg['is_writable'] %}W{% endif %} | {{ reg['write_ports'] }} | {{ reg['read_ports'] }} | {{ reg['is_ram'] }} | {{ reg['is_signed'] }} | {{ reg['description'] }} |
{% endfor %}
