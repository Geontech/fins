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

# For a single point of maintenance, the canonical package version is in the version module
version = {}
with open('src/fins/version.py') as fp:
    exec(fp.read(), version)

setup(
    name='fins',
    description='The Firmware IP Node Specification is an automation tool for modular programmable logic design',
    version=version['__version__'],
    packages=find_namespace_packages(where='src'),
    package_dir={'':'src'},
    python_requires='>= 3.6',
    url='http://geon.tech',
    install_requires=[
        'Jinja2 ~= 2.8'
    ],
    package_data={
        'fins':[
            'loader/schema.json',
            'backend/templates/*',
            'backend/templates/.gitignore'
        ]
    },
    entry_points={
        'console_scripts':[
            'fins=fins.main:main'
        ],
        'fins.backend.generators':[
            'core=fins.backend.generator:Generator'
        ],
    }
)
