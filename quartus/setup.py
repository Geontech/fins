#!/usr/bin/env python3

from setuptools import setup, find_packages

setup(
    name='fins-quartus',
    version='0.1',
    packages=['fins.backend.quartus'],
    package_dir={'':'src'},
    python_requires='>= 3.6',
    install_requires=[
        'fins == 0.1',
        'Jinja2 ~= 2.8',
    ],
    package_data={
        'fins.backend.quartus':[
            'templates/*'
        ]
    },
    entry_points={
        'fins.backend.generators': [
            'quartus=fins.backend.quartus.generator:QuartusGenerator'
        ],
    }
)
