#!/usr/bin/env python3

'''
Company: Geon Technologies, LLC
Copyright:
    (c) 2019 Geon Technologies, LLC. All rights reserved.
    Dissemination of this information or reproduction of this material is strictly
    prohibited unless prior written permission is obtained from Geon Technologies, LLC.
'''

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
