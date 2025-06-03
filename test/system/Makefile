# Copyright (C) 2020 Geon Technologies, LLC
#
# This file is part of FINS.
#
# FINS is free software: you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# FINS is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
# more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.

.PHONY: all quartus vivado clean

all:
ifeq ($(origin XILINX_VIVADO), environment)
	$(MAKE) vivado
else ifeq ($(origin QUARTUS_ROOTDIR), environment)
	$(MAKE) quartus
else
	$(error Neither XILINX_VIVADO nor QUARTUS_ROOTDIR is set. Please source your FPGA tool environment first.)
endif

quartus: project/quartus/system.qsys

project/quartus/system.qsys: scripts/stratix10_system.tcl
	rm -rf project/quartus/ log/ && mkdir -p project/quartus/ && mkdir -p log/
	cd project/quartus && \
	qsys-script --script=../../scripts/stratix10_system.tcl --new-quartus-project=stratix10_system.qpf --search-path=../../../application/project/quartus/**/*,../../../node/**/*,$$ > ../../log/quartus_system_create.log 2>&1

vivado: project/vivado/zedboard_system.srcs/sources_1/bd/system/system.bd

project/vivado/zedboard_system.srcs/sources_1/bd/system/system.bd: scripts/zedboard_system.tcl
	rm -rf log/ && mkdir -p log/
	mkdir -p project/vivado
	vivado -mode batch -source $< > log/vivado_system_create.log 2>&1

clean:
	rm -rf project/ log/ gen/ *.log *.jou
