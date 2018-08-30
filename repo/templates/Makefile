#===============================================================================
# Company:     Geon Technologies, LLC
# Author:      Josh Schindehette
# Copyright:   (c) 2018 Geon Technologies, LLC. All rights reserved.
#              Dissemination of this information or reproduction of this 
#              material is strictly prohibited unless prior written
#              permission is obtained from Geon Technologies, LLC
# Description: Makefile to generate Firmware IP Node Specifications (FINS)
#===============================================================================
IP_NAME      := {{ fins['name'] }}
IP_PROJ      := $(IP_NAME).xpr
IP_MAKE      := ip.mk
PERSONA_DIR  := ./rh_persona
PERSONA_NAME := {% if 'persona_name' in fins %}{{ fins['persona_name'] }}{% else %}$(IP_NAME){% endif %}
PERSONA_PROJ := $(PERSONA_DIR)/$(PERSONA_NAME).spd.xml

.PHONY: all sim netlist clean clean-all fins persona

all: $(IP_PROJ)

sim netlist: $(IP_MAKE)
	make -f $(IP_MAKE) $@

clean clean-all: $(IP_MAKE)
	make -f $(IP_MAKE) $@
	rm -f $(IP_MAKE)

fins: $(IP_MAKE)

persona: $(PERSONA_PROJ)

$(IP_MAKE): fins.json
	python ./fins/repo/scripts/validate_fins.py
	python ./fins/codegen/scripts/gen_fins.py

$(IP_PROJ): $(IP_MAKE)
	make -f $(IP_MAKE) all

$(PERSONA_DIR): fins.json
	python ./fins/codegen/scripts/gen_persona.py

$(PERSONA_PROJ): $(PERSONA_DIR)
	redhawk-codegen -C $(PERSONA_DIR) --persona $@
