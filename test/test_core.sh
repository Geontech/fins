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

###########################################################
# This is a script to test the FINS Core
# Run as follows from the test/ directory:
#     ./test_core.sh
###########################################################

set -x
set -e

echo "TESTING 'core': START"

echo "TESTING 'core': Manually cleaning all generated files..."
rm -rf log/
rm -rf node/Makefile node/log/ node/gen/ node/project
rm -rf node/ip/test_middle/Makefile node/ip/test_middle/log/ node/ip/test_middle/gen/ node/ip/test_middle/project
rm -rf node/ip/test_middle/ip/test_bottom/Makefile node/ip/test_middle/ip/test_bottom/log/ node/ip/test_middle/ip/test_bottom/gen/ node/ip/test_middle/ip/test_bottom/project
rm -rf application/Makefile application/log/ application/gen/ application/project

echo "TESTING 'core': Generating test Node..."
cd node
fins fins.json -v
echo "Return status (should be 0): $?"

echo "TESTING 'core': Generating test Application..."
cd ../application
fins application_test.json -v
echo "Return status (should be 0): $?"

echo "TESTING 'core': Generating test Systems. Expect WARNINGs..."
cd ../system
fins quartus_system_test.json -v
echo "Return status (should be 0): $?"
fins vivado_system_test.json -v
echo "Return status (should be 0): $?"

echo "TESTING 'core': Generating tutorial Node..."
cd ../../tutorials/power_converter
fins fins.json -v
echo "TESTING 'core': Return status (should be 0): $?"

echo "TESTING 'core': Generating tutorial Application..."
cd ../power_application
fins fins.json -v
echo "TESTING 'core': Return status (should be 0): $?"
