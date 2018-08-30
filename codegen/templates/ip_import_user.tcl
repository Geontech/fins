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
{% for ip in fins['ip'] -%}
create_ip -name {{ ip['name'] }} -vendor {{ ip['vendor'] }} -library {{ ip['library'] }} -version 1.0 -module_name {{ ip['module_name'] }}
{% endfor %}