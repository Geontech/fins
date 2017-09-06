#===============================================================================
# Company:     Geon Technologies, LLC
# File:        rfnoc_tb_make
# Description: Auto-generated from Jinja2 IP Parameters Makefile Template
# Generated:   {{ now }}
#===============================================================================

#-------------------------------------------------
# Top-of-Makefile
#-------------------------------------------------
# Define BASE_DIR to point to the "top" dir
BASE_DIR =
{%- for param in json_params['params'] -%}
{%- if param['name'] == "SIM_FILES_DEST" -%} {{ param['value'] }}usrp3/top
{%- endif -%}
{%- endfor %}

# Include viv_sim_preample after defining BASE_DIR
include $(BASE_DIR)/../tools/make/viv_sim_preamle.mak

#-------------------------------------------------
# Testbench Specific
#-------------------------------------------------
# Define only one toplevel module
SIM_TOP =
{%- for param in json_params['params'] -%}
{%- if param['name'] == "TB_NAME" -%} {{ param['value'] }}
{%- endif -%}
{%- endfor %}

# Add test bench, user design under test, and
# additional user created files
SIM_SRCS = \
{% for source_file in json_params['filesets']['source'] -%}
$(abspath {{ source_file }}) \ \
{% endfor %}

MODELSIM_USER_DO =

#-------------------------------------------------
# Bottom-of-Makefile
#-------------------------------------------------
# Include all simulator specific makefiles here
# Each should define a unique target to simulate
# e.g. xsim, vsim, etcx and a common "clean" target
include $(BASE_DIR)/../tools/make/viv_simulator.mak
