#!/bin/bash
#
# Copyright (C) 2026 Geon Technologies, LLC
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
# Generate and simulate fixtures with Vivado and Quartus in one flow.
#
# Run all scopes from the repository root:
#     ./test/test_multibackend.sh
#
# Run one scope from the repository root:
#     ./test/test_multibackend.sh <scope>
#
# Scopes: node, application
###########################################################

set -euo pipefail
set -x

test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scope="${1:-all}"

clean_node_outputs() {
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

run_vivado_simulation() {
    bash -c 'source "$VIVADO_PATH/settings64.sh"; export LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1; make sim-vivado'
}

test_node() {
    echo "TESTING 'multibackend/node': START"
    clean_node_outputs
    (cd "$test_dir/node" && \
        fins -b all fins.json -v && \
        test -f gen/vivado/Makefile && \
        test -f gen/quartus/Makefile)
    (cd "$test_dir/node" && run_vivado_simulation)
    (cd "$test_dir/node" && \
        make sim-quartus && \
        test -d project/vivado && \
        test -d project/quartus && \
        make clean-vivado && \
        test -d project/quartus && \
        make clean-quartus)
}

test_application() {
    echo "TESTING 'multibackend/application': START"
    clean_node_outputs
    rm -rf "$test_dir/application/Makefile" "$test_dir/application/log" \
        "$test_dir/application/gen" "$test_dir/application/project"
    (cd "$test_dir/application" && fins -b all application_test.json -v)
    (cd "$test_dir/application" && run_vivado_simulation)
    (cd "$test_dir/application" && \
        make sim-quartus && \
        make clean-all-vendors)
}

case "$scope" in
    node)
        test_node
        ;;
    application)
        test_application
        ;;
    all)
        test_node
        test_application
        ;;
    *)
        echo "Usage: $0 {node|application|all}" >&2
        exit 2
        ;;
esac

echo "TESTING 'multibackend/$scope': PASS"
