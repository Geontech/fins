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
"""
This module contains utilities for FINS-types
"""

class SchemaType:
    """
    Enumerated type to represent the different FINS Schema types

    Does not inherit from the Enum class because that
    would prevent it from being JSON serializable
    """
    NODE        = 1
    APPLICATION = 2
    SYSTEM      = 3

    @classmethod
    def get_str(cls, fins_data):
        """
        Given a FINS data dictionary, return its Schema Type as a string
        """
        if 'nodes' not in fins_data:
            return "node"
        elif 'is_application' in fins_data and fins_data['is_application']:
            return "application"
        else:
            return "system"

    @classmethod
    def get(cls, fins_data):
        """
        Given a FINS data dictionary, return its Schema Type
        """
        if 'nodes' not in fins_data:
            return cls.NODE
        elif 'is_application' in fins_data and fins_data['is_application']:
            return cls.APPLICATION
        else:
            return cls.SYSTEM
