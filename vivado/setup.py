#!/usr/bin/env python3

from setuptools import setup, find_packages

setup(
    name='fins-vivado',
    version='0.1',
    packages=['fins.backend.vivado'],
    package_dir={'':'src'},
    python_requires='>= 3.6',
    install_requires=[
        'fins == 0.1',
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
