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
# Generate, build, and simulate FINS fixtures with one FPGA backend.
#
# Run all scopes from the repository root:
#     ./test/test_backend.sh <backend>
#
# Run one scope from the repository root:
#     ./test/test_backend.sh <backend> <scope>
#
# Backends: vivado, quartus
# Scopes: node, application-system, tutorials
###########################################################

set -euo pipefail
set -x

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd "$test_dir/.." && pwd)"
backend="${1:-}"
scope="${2:-all}"

case "$backend" in
    vivado|quartus) ;;
    *)
        echo "Usage: $0 {vivado|quartus} [node|application-system|tutorials|all]" >&2
        exit 2
        ;;
esac

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

test_node() {
    echo "TESTING '$backend/node': Generating, building, and simulating packaged and primitive test Nodes..."
    clean_node_outputs
    clean_primitive_outputs
    (cd "$test_dir/node" && \
        fins -b "$backend" fins.json -v && \
        make sim && \
        make clean-all)
    (cd "$test_dir/primitive" && \
        fins -b "$backend" fins.json -v && \
        make sim && \
        grep -q 'SIMULATION PASSED' "log/$backend/primitive_simulate.log" && \
        make clean-all)
}

test_application_system() {
    echo "TESTING '$backend/application-system': START"
    clean_node_outputs
    rm -rf "$test_dir/application/Makefile" "$test_dir/application/log" \
        "$test_dir/application/gen" "$test_dir/application/project"
    rm -rf "$test_dir/system/log" "$test_dir/system/gen" \
        "$test_dir/system/project"

    (cd "$test_dir/application" && \
        fins -b "$backend" application_test.json -v && \
        make sim)

    echo "TESTING '$backend/application-system': Constructing parent design and generating System..."
    (cd "$test_dir/system" && \
        make "$backend" && \
        fins "${backend}_system_test.json" -v && \
        make clean)
    make clean-all -C "$test_dir/application"
}

test_tutorials() {
    echo "TESTING '$backend/tutorials': Simulating tutorial Node and Application..."
    rm -rf "$repo_dir/tutorials/power_converter/Makefile" \
        "$repo_dir/tutorials/power_converter/gen" \
        "$repo_dir/tutorials/power_converter/log" \
        "$repo_dir/tutorials/power_converter/project"
    rm -rf "$repo_dir/tutorials/power_application/Makefile" \
        "$repo_dir/tutorials/power_application/gen" \
        "$repo_dir/tutorials/power_application/log" \
        "$repo_dir/tutorials/power_application/project"

    (cd "$repo_dir/tutorials/power_converter" && \
        fins -b "$backend" fins.json -v && \
        make sim && \
        make clean-all)
    (cd "$repo_dir/tutorials/power_application" && \
        fins -b "$backend" fins.json -v && \
        make sim && \
        make clean-all)
}

case "$scope" in
    node)
        test_node
        ;;
    application-system)
        test_application_system
        ;;
    tutorials)
        test_tutorials
        ;;
    all)
        test_node
        test_application_system
        test_tutorials
        ;;
    *)
        echo "Usage: $0 {vivado|quartus} [node|application-system|tutorials|all]" >&2
        exit 2
        ;;
esac

echo "TESTING '$backend/$scope': PASS"
