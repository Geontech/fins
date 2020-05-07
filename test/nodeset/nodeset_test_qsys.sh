#!/bin/bash
#
# Copyright (C) 2019 Geon Technologies, LLC
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
#
mkdir -p project/quartus
(cd project/quartus
PROJECT_FILENAME=nodeset_test.qpf

qsys-script --search-path=../../../node/gen/quartus,../../../node/ip/test_middle/**/*,$ --new-quartus-project=${PROJECT_FILENAME} --script=../../nodeset_qsys.tcl
qsys-generate --search-path=../../../node/gen/quartus,../../../node/ip/test_middle/**/*,$ --quartus-project=${PROJECT_FILENAME} --synthesis=VHDL --simulation=VHDL --ipxact nodeset_test.qsys


ip-setup-simulation --quartus-project=${PROJECT_FILENAME} --output-directory=./ --use-relative-paths
sim-script-gen --system-file=nodeset_test.qsys --output-directory=./ --use-relative-paths)

(cd project/quartus/mentor && vsim -batch -do ../../../notgen/quartus/ip_simulate.tcl)
python3 ./scripts/verify_sim.py
