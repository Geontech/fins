#!/usr/bin/env python3

'''
Company: Geon Technologies, LLC
Copyright:
    (c) 2019 Geon Technologies, LLC. All rights reserved.
    Dissemination of this information or reproduction of this material is strictly
    prohibited unless prior written permission is obtained from Geon Technologies, LLC.
'''

from setuptools import setup, find_namespace_packages

setup(
    name='fins-vivado',
    version='0.9',
    packages=find_namespace_packages(where='src'),
    package_dir={'':'src'},
    python_requires='>= 3.6',
    install_requires=[
        'fins == 0.9',
        'Jinja2 ~= 2.8',
    ],
    package_data={
        'fins.backend.vivado':[
            'templates/*'
        ]
    },
    entry_points={
        'fins.backend.generators': [
            'vivado=fins.backend.vivado.generator:VivadoGenerator'
        ],
    }
)
