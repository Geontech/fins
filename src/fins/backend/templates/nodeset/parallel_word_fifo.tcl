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

#------------------------------------------------------------------------------
# FWFT FIFO
#------------------------------------------------------------------------------
# Set the width to the fully-parallel data+metadata bit width of a single instance of the FINS port
# NOTE: +1 is for TLAST
{%- if 'metadata' in fins %}
set FIFO_WIDTH {{ fins['data']['bit_width']*fins['data']['num_samples']*fins['data']['num_channels'] + fins['metadata']|sum(attribute='bit_width') + 1 }}
{%- else %}
set FIFO_WIDTH {{ fins['data']['bit_width']*fins['data']['num_samples']*fins['data']['num_channels'] + 1 }}
{%- endif %}

{%- if fins['supports_backpressure'] %}
# Set the depth to be fairly shallow since the purpose is to buffer data while waiting for metadata to be multiplexed
set FIFO_DEPTH 32
{%- else %}
# Set the depth to be fairly large since the purpose is to buffer data until the output is ready
set FIFO_DEPTH 1024
{%- endif %}

# Create the FIFO with vendor TCL commands
if { $FINS_BACKEND == "vivado" } {
    set FIFO_MODULE_NAME "xilinx_parallel_word_fifo"
    create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name $FIFO_MODULE_NAME
    set_property -dict [list \
        CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM} \
        CONFIG.Performance_Options {First_Word_Fall_Through} \
        CONFIG.Input_Data_Width $FIFO_WIDTH \
        CONFIG.Input_Depth $FIFO_DEPTH \
    ] [get_ips $FIFO_MODULE_NAME]
} else {
    set FIFO_MODULE_NAME "intel_parallel_word_fifo"
    set FIFO_MODE_NORMAL 1
    set FIFO_MODE_SHOW_AHEAD 0
    set FIFO_USED_WORDS_COUNT_DISABLED 0
    set FIFO_USED_WORDS_COUNT_ENABLED 1
    add_hdl_instance $FIFO_MODULE_NAME fifo 19.1
    set_instance_parameter_value $FIFO_MODULE_NAME "GUI_LegacyRREQ" $FIFO_MODE_SHOW_AHEAD
    set_instance_parameter_value $FIFO_MODULE_NAME "GUI_Width" $FIFO_WIDTH
    set_instance_parameter_value $FIFO_MODULE_NAME "GUI_Depth" $FIFO_DEPTH
    set_instance_parameter_value $FIFO_MODULE_NAME "GUI_UsedW" $FIFO_USED_WORDS_COUNT_DISABLED
}
