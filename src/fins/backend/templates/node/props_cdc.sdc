{#-
--
-- Copyright (C) 2020 Geon Technologies, LLC
--
-- This file is part of FINS.
--
-- FINS is free software: you can redistribute it and/or modify it under the
-- terms of the GNU Lesser General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option)
-- any later version.
--
-- FINS is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
-- more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see http://www.gnu.org/licenses/.
--
-#}
{%- if 'license_lines' in fins %}
{%-  for line in fins['license_lines'] -%}
# {{ line }}
{%-  endfor %}
{%- endif %}

#==============================================================================
# Firmware IP Node Specification (FINS) Auto-Generated File
# ---------------------------------------------------------
# Template:    props_cdc.sdc
# Backend:     {{ fins['backend'] }}
# Generated:   {{ now }}
# ---------------------------------------------------------
# Description: Clock Domain Crossings constraints for FINS Status Properties
#              (a.k.a. firmware status registers available to software) and
#              FINS Control Properties (a.k.a. software control of firmware)
# Reset Type:  Synchronous
# Limitations: This module only implements Clock Domain Crossings for
#              Properties with type "read-write-data" or "read-only-data"
#==============================================================================

{%- for prop in fins['properties']['properties'] %}
{%- if (prop['type'] == 'read-write-data') or (prop['type'] == 'read-only-data') %}
{%- if prop['width'] > 1 %}
set_false_path -to *cdc_{{ prop['name'] }}_q[*]
{%- else %}
set_false_path -to *cdc_{{ prop['name'] }}_q
{%- endif %}
{%- endif %}
{%- endfor %}{#### for prop in fins['properties']['properties'] ####}
