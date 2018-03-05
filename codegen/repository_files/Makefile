#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Josh Schindehette
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Makefile to retrieve repositories and generate parameters
#===============================================================================
# This should match IP_NAME in ip_params.json
IP_NAME := {{ json_params['params']|selectattr('name', 'equalto', 'IP_NAME')|map(attribute='value')|join('') }}
IP_PROJ := $(IP_NAME).xpr

.PHONY: all sim netlist clean clean-all params

all: $(IP_PROJ)

sim netlist: ip.mk
	make -f ip.mk $@

clean clean-all: ip.mk
	make -f ip.mk $@
	rm -f ip.mk

params: ip.mk

ip.mk: ip_params.json
	python ./fins/codegen/scripts/gen_ip_params.py

$(IP_PROJ): ip.mk
	make -f ip.mk all
