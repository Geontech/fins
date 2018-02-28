#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Josh Schindehette
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Makefile to retrieve repositories and generate parameters
#===============================================================================
.PHONY: all sim netlist clean params

all sim netlist: params
	make -f ip.mk $@

clean: params
	make -f ip.mk $@
	rm -rf ip.mk

params: ip_params.json
	python ./fins/codegen/scripts/gen_ip_params.py
