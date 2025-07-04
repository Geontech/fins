#!/usr/bin/env python3
#
# Copyright (C) 2024 Geon Technologies, LLC
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

from setuptools import setup, find_namespace_packages

setup(
    name='fins-quartus',
    version='0.16.3',
    packages=find_namespace_packages(where='src'),
    package_dir={'': 'src'},
    python_requires='>= 3.6',
    install_requires=[
        'fins == 0.16.3',
        'Jinja2 >= 2.8',
    ],
    package_data={
        'fins.backend.quartus': [
            'templates/node/*',
            'templates/application/*',
            'templates/system/*'
        ]
    },
    entry_points={
        'fins.backend.generators': [
            'quartus=fins.backend.quartus.generator:QuartusGenerator'
        ],
    }
)
