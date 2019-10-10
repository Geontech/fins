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

if { $FINS_BACKEND == "vivado" } {
    # Make sure the simulation_done signal is True
    if { [get_value [get_objects "simulation_done"]] == "FALSE" } {
        error "***** SIMULATION FAILED (simulation_done=false) *****"
    }
} else {
    # Make sure the simulation_done signal is True
    if { [examine "simulation_done"] == "FALSE" } {
        error "***** SIMULATION FAILED (simulation_done=false) *****"
    }
}
