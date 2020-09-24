#!/bin/bash
#
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
#

###########################################################
# This is a script to test the FINS Core
# Run as follows from the test/ directory:
#     ./test_backend.sh <backend>

#     <backend> examples: vivado, quartus
###########################################################

set -x
set -e

if [ -z "$1" ]; then
    echo "test_backend.sh: Must provide backend as argument. Examples:"
    echo "    ./test_backend.sh vivado"
    echo "or"
    echo "    ./test_backend.sh quartus"
    exit 1
fi
backend=$1

echo "TESTING '$backend': START"

echo "TESTING '$backend': Manually cleaning all generated files..."
rm -rf log/
rm -rf node/Makefile node/log/ node/gen/ node/project
rm -rf node/ip/test_middle/Makefile node/ip/test_middle/log/ node/ip/test_middle/gen/ node/ip/test_middle/project
rm -rf node/ip/test_middle/ip/test_bottom/Makefile node/ip/test_middle/ip/test_bottom/log/ node/ip/test_middle/ip/test_bottom/gen/ node/ip/test_middle/ip/test_bottom/project
rm -rf application/Makefile application/log/ application/gen/ application/project
rm -rf system/log/ system/gen/ system/project

echo "TESTING '$backend': Generating, building and simulating test Node..."
cd node
rm -rf Makefile gen/ project/ log/
fins -b $backend fins.json
make sim
make clean-all
echo "TESTING '$backend': Return status (should be 0): $?"

echo "TESTING '$backend': Generating, building and simulating test Application..."
cd ../application
fins -b $backend application_test.json
make sim
echo "TESTING '$backend': Return status (should be 0): $?"

echo "TESTING '$backend': Constructing a parent FPGA design for testing, and validating/generating a FINS System that uses it..."
cd ../system
make $backend
fins ${backend}_system_test.json
make clean
make clean-all -C ../application
echo "TESTING '$backend': Return status (should be 0): $?"

cd ../../tutorials/power_converter
fins -b $backend fins.json
make sim
make clean-all
echo "TESTING '$backend': Return status (should be 0): $?"

cd ../power_application
fins -b $backend fins.json
make sim
make clean-all
echo "TESTING '$backend': Return status (should be 0): $?"
