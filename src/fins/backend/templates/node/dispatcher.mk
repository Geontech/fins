{# FINS multi-backend dispatcher -#}
#===============================================================================
# Firmware IP Node Specification (FINS) Auto-Generated File
# Description: Stable dispatcher for all generated vendor backends
#===============================================================================

AVAILABLE_BACKENDS := $(foreach vendor,vivado quartus,$(if $(wildcard gen/$(vendor)/Makefile),$(vendor)))
BACKEND ?= $(firstword $(AVAILABLE_BACKENDS))
BACKEND_MAKEFILE := gen/$(BACKEND)/Makefile

.PHONY: all sim clean clean-all vivado quartus sim-vivado sim-quartus \
        clean-vivado clean-quartus clean-all-vendors

all sim:
	@test -f $(BACKEND_MAKEFILE) || { echo "Backend '$(BACKEND)' has not been generated" >&2; exit 2; }
	$(MAKE) -f $(BACKEND_MAKEFILE) $@ BACKEND=$(BACKEND)

clean:
	@set -e; $(foreach backend,$(AVAILABLE_BACKENDS),$(MAKE) -f gen/$(backend)/Makefile clean BACKEND=$(backend);)

clean-all:
	@set -e; $(foreach backend,$(AVAILABLE_BACKENDS),$(MAKE) -f gen/$(backend)/Makefile clean-all BACKEND=$(backend);)

vivado:
	$(MAKE) BACKEND=vivado all

quartus:
	$(MAKE) BACKEND=quartus all

sim-vivado:
	$(MAKE) BACKEND=vivado sim

sim-quartus:
	$(MAKE) BACKEND=quartus sim

clean-vivado:
	$(MAKE) -f gen/vivado/Makefile clean BACKEND=vivado

clean-quartus:
	$(MAKE) -f gen/quartus/Makefile clean BACKEND=quartus

clean-all-vendors:
	$(MAKE) clean-all
