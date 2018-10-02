#===============================================================================
# Company:     Geon Technologies, LLC
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Auto-generated TCL user IP import script
# Generated:   {{ now }}
#===============================================================================

# Create User IP
{%- for ip in fins['ip'] %}
{%- for instance in ip['instances'] %}
create_ip -name {{ ip['name'] }} -vendor {{ ip['vendor'] }} -library {{ ip['library'] }} -version 1.0 -module_name {{ instance['module_name'] }}
{%- if 'generics' in instance %}
set_property -dict [list \
    {%- for generic in instance['generics'] %}
    CONFIG.{{ generic['name'] }} {{ generic['value'] }} \
    {%- endfor %}
] [get_ips {{ instance['module_name'] }}]
{%- endif %}
{%- endfor %}
{%- endfor %}