#!/bin/bash
#
# Copyright (C) 2020, 2026 Geon Technologies, LLC
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
# Test vendor-independent FINS generation and data handling.
#
# Run all scopes from the repository root:
#     ./test/test_core.sh
#
# Run one scope from the repository root:
#     ./test/test_core.sh <scope>
#
# Scopes: node, application-system, axis-files, tutorials
###########################################################

set -euo pipefail
set -x

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "$test_dir/.." && pwd)"
scope="${1:-all}"

clean_node_outputs() {
    rm -rf "$test_dir/log"
    rm -rf "$test_dir/node/Makefile" "$test_dir/node/log" \
        "$test_dir/node/gen" "$test_dir/node/project"
    rm -rf "$test_dir/node/ip/test_middle/Makefile" \
        "$test_dir/node/ip/test_middle/log" \
        "$test_dir/node/ip/test_middle/gen" \
        "$test_dir/node/ip/test_middle/project"
    rm -rf "$test_dir/node/ip/test_middle/ip/test_bottom/Makefile" \
        "$test_dir/node/ip/test_middle/ip/test_bottom/log" \
        "$test_dir/node/ip/test_middle/ip/test_bottom/gen" \
        "$test_dir/node/ip/test_middle/ip/test_bottom/project"
}

clean_primitive_outputs() {
    rm -rf "$test_dir/primitive/Makefile" "$test_dir/primitive/log" \
        "$test_dir/primitive/gen" "$test_dir/primitive/project"
}

generate_node() {
    echo "TESTING 'core/node': Generating packaged and primitive test Nodes..."
    clean_node_outputs
    clean_primitive_outputs
    (cd "$test_dir/node" && fins fins.json -v)
    (cd "$test_dir/primitive" && fins fins.json -v)
}

test_application_system() {
    echo "TESTING 'core/application-system': START"
    clean_node_outputs
    rm -rf "$test_dir/application/Makefile" "$test_dir/application/log" \
        "$test_dir/application/gen" "$test_dir/application/project"
    rm -rf "$test_dir/system/log" "$test_dir/system/gen" \
        "$test_dir/system/project"

    # The Application and System fixtures consume generated Node metadata.
    (cd "$test_dir/node" && fins fins.json -v)
    (cd "$test_dir/application" && fins application_test.json -v)

    echo "TESTING 'core/application-system': Generating Systems; expect warnings..."
    (cd "$test_dir/system" && \
        fins quartus_system_test.json -v && \
        fins vivado_system_test.json -v)
}

test_axis_files() {
    echo "TESTING 'core/axis-files': Generating and testing AXI-Stream files..."
    rm -rf "$test_dir/axis_file_tester/gen" "$test_dir/axis_file_tester/log"
    (cd "$test_dir/axis_file_tester" && fins fins.json && octave run_tests.m)
}

test_tutorials() {
    echo "TESTING 'core/tutorials': Generating tutorial Node and Application..."
    rm -rf "$repo_dir/tutorials/power_converter/Makefile" \
        "$repo_dir/tutorials/power_converter/gen" \
        "$repo_dir/tutorials/power_converter/log" \
        "$repo_dir/tutorials/power_converter/project"
    rm -rf "$repo_dir/tutorials/power_application/Makefile" \
        "$repo_dir/tutorials/power_application/gen" \
        "$repo_dir/tutorials/power_application/log" \
        "$repo_dir/tutorials/power_application/project"
    (cd "$repo_dir/tutorials/power_converter" && fins fins.json -v)
    (cd "$repo_dir/tutorials/power_application" && fins fins.json -v)
}

case "$scope" in
    node)
        generate_node
        ;;
    application-system)
        test_application_system
        ;;
    axis-files)
        test_axis_files
        ;;
    tutorials)
        test_tutorials
        ;;
    all)
        generate_node
        test_application_system
        test_axis_files
        test_tutorials
        ;;
    *)
        echo "Usage: $0 {node|application-system|axis-files|tutorials|all}" >&2
        exit 2
        ;;
esac

echo "TESTING 'core/$scope': PASS"
