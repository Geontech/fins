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
# Run every Python regression test and enforce the coverage floor.
#
# Run from the repository root:
#     ./test/test_python.sh
###########################################################

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

export PYTHONPATH="$repo_dir/quartus/src:$repo_dir/vivado/src:$repo_dir/src${PYTHONPATH:+:$PYTHONPATH}"

python3 -m coverage erase
python3 -m coverage run -m unittest discover -s test -p 'test_*.py' -v
python3 -m coverage report
python3 -m coverage xml
