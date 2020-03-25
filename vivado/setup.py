#!/usr/bin/env python3
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

from setuptools import setup, find_namespace_packages

setup(
    name='fins-vivado',
    version='0.11',
    packages=find_namespace_packages(where='src'),
    package_dir={'':'src'},
    python_requires='>= 3.6',
    install_requires=[
        'fins == 0.11',
        'Jinja2 ~= 2.8',
    ],
    package_data={
        'fins.backend.vivado':[
            'templates/node/*',
            'templates/nodeset/*'
        ]
    },
    entry_points={
        'fins.backend.generators': [
            'vivado=fins.backend.vivado.generator:VivadoGenerator'
        ],
    }
)
