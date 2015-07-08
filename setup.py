#!/usr/bin/env python

from distutils.core import setup

setup(name='calmeqmypi',
      version='0.1',
      description='Python package to manage a calmeq device',
      author='CalmEQ',
      author_email='jay@calmeq.com',
      package_dir = {'': 'python'},
      py_modules=['record_and_push'],
      url="http://calmeq.com/",
      install_requires=[ 'requests' ]
     )
