#===============================================================================
# Company:     Geon Technologies, LLC
# File:        ip_import_user.tcl
# Description: Auto-generated from Jinja2 IP Parameters TCL Template
# Generated:   {{ now }}
#===============================================================================

# Create User IP
{% for ip in fins['ip'] -%}
create_ip -name {{ ip['name'] }} -vendor {{ ip['vendor'] }} -library {{ ip['library'] }} -version 1.0 -module_name {{ ip['module_name'] }}
{% endfor %}